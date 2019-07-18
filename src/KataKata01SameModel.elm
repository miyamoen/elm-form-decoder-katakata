module KataKata01SameModel exposing (Model, Msg(..), init, main, update, view)

{-|


# katakata 01 Same Model

最初のkataです。まず一番簡単なフォームから始めてみましょう


## ストーリー

あなたは10文字以下の文字列が必要になりました。そこで`Model`に`text`という名前で保持することにしました。このtextは取り急ぎ画面上に表示しておこうと思います。
textは変更できるようにしたいと思います。そこでテキスト入力フォームも実装することにしました

表示の部分とtextが更新される部分を作りましたが、何か忘れています。テストで確認しましょう！


## やり方

  - elm reactorでこのファイルを開きましょう
  - 画面下部に表示されるテスト結果を読んで`replace____me*`を書き換えましょう
  - 🎉🎉テストが全部通ったらクリアです！🎉🎉

-}

import Browser
import Element exposing (..)
import Element.Input
import Expect
import Html exposing (Html)
import Html.Attributes
import KataKata.Element exposing (..)
import KataKata.Test as Test exposing (Test)
import KataKata.Util exposing (replace____me)


{-| textが今回欲しい10文字以下の文字列です
-}
type alias Model =
    { text : String }


{-| textを変更するためのMsgです
-}
type Msg
    = ChangeText String


init : Model
init =
    { text = "initial" }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeText string ->
            -- 何か実装し忘れているような
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
