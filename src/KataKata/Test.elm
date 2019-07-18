module KataKata.Test exposing (Test(..), describe, test, view, withTest)

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


test : String -> (() -> Expectation) -> Test
test =
    Single


describe : String -> List Test -> Test
describe =
    Batch


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


run : Test -> TestResult
run suite =
    case suite of
        Single label expect ->
            SingleResult label <|
                Maybe.map convertFailure <|
                    Test.Runner.getFailureReason (expect ())

        Batch label suites ->
            BatchResult label <| List.map run suites


view : Test -> Element msg
view suite =
    column [ width fill, spacing 32 ]
        [ row [ width fill, spacing 32 ] [ viewLine <| px 64, text "Test", viewLine fill ]
        , viewTestResult <| run suite
        ]


viewLine : Length -> Element msg
viewLine length =
    el [ width length, Border.width 2, Border.color <| rgba255 0 0 0 0.2 ] none


viewTestResult : TestResult -> Element msg
viewTestResult result =
    case result of
        SingleResult label failure ->
            viewSingle label failure

        BatchResult label results ->
            viewBatch label results


viewSingle : String -> Maybe Failure -> Element msg
viewSingle label maybe =
    case maybe of
        Nothing ->
            row [ spacing 8 ] [ text "✅", text label ]

        Just { description, reason } ->
            row [ spacing 8, width fill ]
                [ el [ alignTop ] <| text "🆖"
                , column [ width fill, spacing 16 ]
                    [ text label
                    , text <| Test.Runner.Failure.format description reason
                    ]
                ]


viewBatch : String -> List TestResult -> Element msg
viewBatch label results =
    column [ spacing 32 ]
        [ text label
        , column [ paddingXY 32 0, spacing 32 ] <| List.map viewTestResult results
        ]
