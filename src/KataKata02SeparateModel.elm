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
import Component.Form as Form
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


title : String
title =
    "02 Separate Model"


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
              -- `replace____me model.text`を書き換えましょう
                | text = replace____me model.text
            }


view : Model -> Html Msg
view model =
    Test.withTest testSuite <|
        withTitle title <|
            column [ width fill, spacing 32 ]
                [ row [ width fill, spacing 16 ]
                    [ el [ centerY ] <| text "text"
                    , Element.Input.text
                        [ width fill
                        , htmlAttribute <| Html.Attributes.autofocus True
                        ]
                        { onChange = ChangeText
                        , text = model.formText
                        , placeholder = Nothing
                        , label = Element.Input.labelHidden "text"
                        }
                    , el [ centerY ] <| Element.text "➡"
                    , wrappedText [ width fill, centerY, paddingXY 12 0 ] <|
                        case model.text of
                            Just string ->
                                string

                            Nothing ->
                                "入力欄が10文字より長いです"
                    ]
                , Form.button_ [] { label = "変換する", msg = ConvertText, enable = True }
                ]


main =
    Browser.sandbox
        { init = init, view = view, update = update }


testSuite : Test
testSuite =
    Test.describe title
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
