module KataKata01SameModel exposing (Model, Msg(..), init, main, update, view)

import Browser
import Element exposing (..)
import Element.Input
import Expect
import Html exposing (Html)
import Html.Attributes
import KataKata.Element exposing (..)
import KataKata.Test as Test exposing (Test)
import KataKata.Util exposing (replace____me)


type alias Model =
    { text : String }


type Msg
    = ChangeText String


init : Model
init =
    { text = "initial" }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeText string ->
            { model | text = replace____me string }


view : Model -> Html Msg
view model =
    Test.withTest testSuite <|
        column [ width fill, spacing 16 ]
            [ Element.Input.text
                [ width fill
                , htmlAttribute <| Html.Attributes.autofocus True
                ]
                { onChange = ChangeText
                , text = model.text
                , placeholder = Nothing
                , label = Element.Input.labelHidden "text"
                }
            , wrappedText [ width fill ] model.text
            ]


main =
    Browser.sandbox
        { init = init, view = view, update = update }


testSuite : Test
testSuite =
    Test.describe "01 - SameModel"
        [ Test.test "textは10文字以下の文字列です" <|
            \_ ->
                init
                    |> update (ChangeText "Lorem ipsum dolor sit amet")
                    |> .text
                    |> String.length
                    |> Expect.atMost 10
                    |> Expect.onFail "textが常に10文字以下になるように`KataKata01SameModel.elm`の`replace____me`を書き換えましょう"
        ]
