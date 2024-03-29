module KataKata.Test exposing (Test(..), describe, skip, test, view, withTest)

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Expect exposing (Expectation)
import Html exposing (Html)
import KataKata.Element exposing (..)
import Test
import Test.Runner
import Test.Runner.Failure exposing (Reason)


type Test
    = Single String (() -> Expectation)
    | Batch String (List Test)
    | Skip Test


test : String -> (() -> Expectation) -> Test
test =
    Single


describe : String -> List Test -> Test
describe =
    Batch


skip : Test -> Test
skip =
    Skip


withTest : Test -> Element msg -> Html msg
withTest suite element =
    layout [] <|
        column [ width fill, padding 32, spacing 128 ]
            [ element
            , view suite
            ]


type alias Failure =
    { description : String
    , reason : Reason
    }


convertFailure : { r | description : String, reason : Reason } -> Failure
convertFailure { description, reason } =
    { description = description, reason = reason }


type TestResult
    = SingleResult String (Maybe Failure)
    | BatchResult String (List TestResult)
    | Skiped


run : Test -> TestResult
run suite =
    case suite of
        Single label expect ->
            SingleResult label <|
                Maybe.map convertFailure <|
                    Test.Runner.getFailureReason (expect ())

        Batch label suites ->
            BatchResult label <| List.map run suites

        Skip _ ->
            Skiped


view : Test -> Element msg
view suite =
    withTitle "Test" (viewTestResult <| run suite)


viewTestResult : TestResult -> Element msg
viewTestResult result =
    case result of
        SingleResult label failure ->
            viewSingle label failure

        BatchResult label results ->
            viewBatch label results

        Skiped ->
            none


viewSingle : String -> Maybe Failure -> Element msg
viewSingle label maybe =
    case maybe of
        Nothing ->
            row [ width fill, spacing 8, Font.bold ] [ text "✅", text label ]

        Just { description, reason } ->
            row [ spacing 8, width fill, Font.bold ]
                [ el [ alignTop ] <| text "🆖"
                , column [ width fill, spacing 16 ]
                    [ text label
                    , textColumn
                        [ width fill
                        , Font.size 16
                        , Font.regular
                        , spacing 4
                        , paddingEach
                            { top = 0, right = 0, bottom = 0, left = 16 }
                        ]
                      <|
                        List.map (wrappedText [ width fill ]) <|
                            String.lines <|
                                Test.Runner.Failure.format description reason
                    ]
                ]


viewBatch : String -> List TestResult -> Element msg
viewBatch label results =
    column [ width fill, spacing 32 ]
        [ text label
        , column
            [ width fill
            , paddingEach { top = 0, right = 0, bottom = 0, left = 32 }
            , spacing 32
            ]
          <|
            List.map viewTestResult results
        ]
