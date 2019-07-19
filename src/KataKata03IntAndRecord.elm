module KataKata03IntAndRecord exposing (Model, Msg(..), init, main, update, view)

{-|


# katakata 03 Int & Record

Int型と合わせてRecord型にしよう。


## ストーリー

あなたは10文字以下の文字列のほかに新たに1以上10以下の整数も必要になりました。個人的にスライダーUIは使いにくいしコピペで入力できないのでテキスト入力で入力することにしました。
textとnumberをまとめてレコード型で扱うことにしました。フォーム用のレコードと変換した後のレコードの2つをModelに入れました。フォームからの変換はいろいろな理由で失敗しそうなので`Result String Value`にしました。
また、忘れていましたが空文字のtextは意味がないのでこれもちゃんとチェックしておこうと思います。

また肝心の変換を実装し忘れています。テストで確認しましょう！


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
    { value : Result String Value, form : Form }


type alias Value =
    { text : String, number : Int }


type alias Form =
    { text : String, number : String }


type Msg
    = ChangeText String
    | ChangeNumber String
    | ConvertForm


init : Model
init =
    { value = Ok { text = "initial", number = 0 }
    , form = { text = "", number = "" }
    }


update : Msg -> Model -> Model
update msg ({ form } as model) =
    case msg of
        ChangeText string ->
            { model | form = { form | text = string } }

        ChangeNumber string ->
            { model | form = { form | number = string } }

        ConvertForm ->
            { model
              -- `replace____me model.value`全体を書き換えてください
                | value = replace____me model.value
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
                , text = model.form.text
                , placeholder = Nothing
                , label = Element.Input.labelAbove [] <| text "text"
                }
            , Element.Input.text [ width fill ]
                { onChange = ChangeNumber
                , text = model.form.number
                , placeholder = Nothing
                , label = Element.Input.labelAbove [] <| text "number"
                }
            , row [ width fill, spacing 16 ]
                [ Element.Input.button
                    [ Border.width 1
                    , Border.rounded 4
                    , Border.color <| rgba255 0 0 0 0.3
                    , Background.color <| rgb255 255 236 165
                    , alignTop
                    ]
                    { onPress = Just ConvertForm
                    , label = el [ padding 8 ] <| text "変換する"
                    }
                , case model.value of
                    Ok value ->
                        column [ width fill, spacing 16 ]
                            [ wrappedText [ width fill ] value.text
                            , text <| String.fromInt value.number
                            ]

                    Err error ->
                        text error
                ]
            ]


main =
    Browser.sandbox
        { init = init, view = view, update = update }


testSuite : Test
testSuite =
    Test.describe "03 - Int & Record"
        [ Test.test "valueはformから変換されます" <|
            \_ ->
                let
                    value =
                        { text = "虎になる"
                        , number = 5
                        }
                in
                init
                    |> update (ChangeText value.text)
                    |> update (ChangeNumber <| String.fromInt value.number)
                    |> update ConvertForm
                    |> .value
                    |> Expect.equal (Ok value)
                    |> Expect.onFail "valueがformから変換されるように`replace____me`を書き換えましょう"
        , Test.test "form.textが10文字より長いとき、変換は失敗します" <|
            \_ ->
                init
                    |> update (ChangeText "我が臆病な自尊心と、尊大な羞恥心との所為である")
                    |> update (ChangeNumber "5")
                    |> update ConvertForm
                    |> .value
                    |> Expect.err
                    |> Expect.onFail "form.textが10文字以上のときは変換が失敗するようにしましょう"
        , Test.test "form.textが空文字のとき、変換は失敗します" <|
            \_ ->
                init
                    |> update (ChangeText "")
                    |> update (ChangeNumber "5")
                    |> update ConvertForm
                    |> .value
                    |> Expect.err
                    |> Expect.onFail "form.textが空文字のときは変換が失敗するようにしましょう"
        , Test.test "form.numberが整数に変換できなければ、変換は失敗します" <|
            \_ ->
                init
                    |> update (ChangeText "虎になる")
                    |> update (ChangeNumber "数字のつもり")
                    |> update ConvertForm
                    |> .value
                    |> Expect.err
                    |> Expect.onFail "form.numberが整数にできないときは変換が失敗するようにしましょう"
        , Test.test "form.numberが1以上10以下の整数に変換できなければ、変換は失敗します" <|
            \_ ->
                let
                    zero =
                        init
                            |> update (ChangeText "虎になる")
                            |> update (ChangeNumber "0")
                            |> update ConvertForm
                            |> .value

                    eleven =
                        init
                            |> update (ChangeText "虎になる")
                            |> update (ChangeNumber "11")
                            |> update ConvertForm
                            |> .value
                in
                case ( zero, eleven ) of
                    ( Err _, Err _ ) ->
                        Expect.pass

                    ( Err _, Ok _ ) ->
                        Expect.fail "10以下の条件を忘れていませんか？"

                    ( Ok _, Err _ ) ->
                        Expect.fail "1以上の条件を忘れていませんか？"

                    _ ->
                        Expect.fail "form.numberが1以上10以下の整数に変換できなければ失敗するようにしましょう"
        ]
