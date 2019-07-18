module KataKata02SeparateModel exposing (Model, Msg(..), init, main, update, view)

{-|


# katakata 02 Separate Model

欲しいModelとフォームの値を分けてみましょう。


## ストーリー

あなたは前回のフォームで10文字以上入力できなくなっているのがおかしいと感じ始めました。初めて触ったひとには動かなくなって壊れたのかと思われてしまいそうです。それに勝手に文字列を切り取ってしまうのはよくないでしょう。
そこで、入力欄のModelはtextとは別のものにして、都度変換することにしました。変換は失敗するかもしれないのでtextをMaybeにしました。

Modelの定義と変換するMsgも作りましたが、何か忘れています。テストで確認しましょう！


## やり方

  - elm reactorでこのファイルを開きましょう
  - 画面下部に表示されるテスト結果を読んで`replace____me*`を書き換えましょう
  - 🎉🎉テストが全部通ったらクリアです！🎉🎉

-}

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input
import Expect
import Html exposing (Html)
import Html.Attributes
import KataKata.Element exposing (..)
import KataKata.Test as Test exposing (Test)
import KataKata.Util exposing (replace____me)


type alias Model =
    { text : Maybe String, formText : String }


type Msg
    = ChangeText String
    | ConvertText


init : Model
init =
    { text = Just "initial", formText = "" }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeText string ->
            { model | formText = string }

        ConvertText ->
            { model
              -- `replace____me model.text`全体を書き換えてください
                | text = replace____me model.text
            }


view : Model -> Html Msg
view model =
    Test.withTest testSuite <|
        column [ width fill, spacing 16 ]
            [ Element.Input.text
                [ width fill
                , htmlAttribute <| Html.Attributes.autofocus True
                ]
                { onChange = ChangeText
                , text = model.formText
                , placeholder = Nothing
                , label = Element.Input.labelHidden "text"
                }
            , row [ width fill, spacing 16 ]
                [ Element.Input.button
                    [ Border.width 1
                    , Border.rounded 4
                    , Border.color <| rgba255 0 0 0 0.3
                    , Background.color <| rgb255 255 236 165
                    ]
                    { onPress = Just ConvertText
                    , label = el [ padding 8 ] <| text "変換する"
                    }
                , case model.text of
                    Just string ->
                        wrappedText [ width fill ] string

                    Nothing ->
                        text "入力欄が10文字より長いです"
                ]
            ]


main =
    Browser.sandbox
        { init = init, view = view, update = update }


testSuite : Test
testSuite =
    Test.describe "02 - SeparateModel"
        [ Test.test "textはformTextから変換されます" <|
            \_ ->
                let
                    text =
                        "虎になる"
                in
                init
                    |> update (ChangeText text)
                    |> update ConvertText
                    |> .text
                    |> Expect.equal (Just text)
                    |> Expect.onFail "textがformTextから変換されるように`replace____me`を書き換えましょう"
        , Test.test "formTextが10文字より長いとき、変換は失敗します" <|
            \_ ->
                let
                    text =
                        "我が臆病な自尊心と、尊大な羞恥心との所為である"
                in
                init
                    |> update (ChangeText text)
                    |> update ConvertText
                    |> .text
                    |> Expect.equal Nothing
                    |> Expect.onFail "formTextからtextへの変換をformTextが10文字より長いときは失敗するようにしましょう"
        ]
