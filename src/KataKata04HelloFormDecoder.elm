module KataKata04HelloFormDecoder exposing (Model, Msg(..), init, main, update, view)

{-|


# katakata 04 Hello, Form Decoder

arowM/elm-form-decoderを使ってみましょう


## ストーリー

あなたはcase式とif式のネストに嫌気がさしてきました。数値への変換と各種条件をごちゃごちゃ書くのは絡まってしまってよくない兆候です。
そんなとき[arowM/elm-form-decoder](https://package.elm-lang.org/packages/arowM/elm-form-decoder/latest/)というライブラリがいいと聞き使ってみることにしました。

初めてなので簡単なところから始めてみることにしました。空文字ではない10文字以下の文字列をform decoderで変換してみましょう。


## やり方

  - elm reactorでこのファイルを開きましょう
  - 画面下部に表示されるテスト結果を読んで`replace____me*`を書き換えましょう
  - 🎉🎉テストが全部通ったらクリアです！🎉🎉


## 学ぶ


### 記事で学ぶ

紹介記事は軽く目を通してください

  - [package document](https://package.elm-lang.org/packages/arowM/elm-form-decoder/latest/)
  - 作者の書いた紹介記事[「フォームバリデーションからフォームデコーディングの時代へ」](https://qiita.com/arowM/items/6c32db1f9e4b92445f3b)
  - API詳解[「arowM/elm-form-decoderのAPIを【かんぜんりかい】しよう！」](https://qiita.com/miyamo_madoka/items/d02f003ec1c212360111)


### 今回学ぶこと

  - Decoderの実行方法
      - `Decoder.run decoder input`で定義したdecoderで変換できる
      - `run`の結果は`Result (List err) a`なのでパターンマッチで欲しい値を手に入れる
  - 簡単なDecoderとValidator
      - Stringを受け取ってStringを返すDecoderは`identity`で作れる
      - Validatorは`assert`で適用する
      - 長さに関するValidatorは`minLength`と`maxLength`


#### `Decoder i err a`

`i`から`a`への変換。変換に失敗すると`List err`になる。

実体は`i -> Result (List err) a`です。


#### `Validator i err`

変換をせずにバリデーションのみをする型です。

    decoder
        |> assert validator

assertを使ってDecoderに適用します。Decoderで変換したあと、その値をバリデーションします。成功したらそのまま通し失敗したらDecoder全体が失敗になります。

`minLength`, `maxLength`, `minBound`, `maxBound`がヘルパーとして用意されています。

-}

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Expect
import Form.Decoder as Decoder exposing (Decoder)
import Html exposing (Html)
import Html.Attributes
import KataKata.Element exposing (..)
import KataKata.Test as Test exposing (Test)
import KataKata.Util exposing (..)


type alias Model =
    { text : String, formText : String }


type Msg
    = ChangeText String
    | ConvertText


init : Model
init =
    { text = "initial", formText = "" }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeText string ->
            { model | formText = string }

        ConvertText ->
            replace____me1 model


type Error
    = TextEmpty
    | TextOver10Length


decoder : Decoder String Error String
decoder =
    replace____me2 <| Decoder.always "虎にならない"


view : Model -> Html Msg
view model =
    let
        errors =
            Decoder.errors decoder model.formText
    in
    Test.withTest testSuite <|
        column [ width fill, spacing 32 ]
            [ column [ width fill, spacing 8 ]
                [ Element.Input.text
                    [ width fill
                    , htmlAttribute <| Html.Attributes.autofocus True
                    ]
                    { onChange = ChangeText
                    , text = model.formText
                    , placeholder = Nothing
                    , label = Element.Input.labelAbove [] <| text "text"
                    }
                , row [ width fill, height <| px 20, spacing 32, Font.color <| rgb255 234 122 184 ]
                    [ if List.member TextEmpty errors then
                        text "必須です"

                      else
                        none
                    , if List.member TextOver10Length errors then
                        text "10文字以下にしてください"

                      else
                        none
                    ]
                ]
            , row [ width fill, spacing 16 ]
                [ Element.Input.button
                    [ Border.width 1
                    , Border.rounded 4
                    , Border.color <| rgba255 0 0 0 0.3
                    , if List.isEmpty errors then
                        Background.color <| rgb255 255 236 165

                      else
                        Background.color <| rgb255 243 236 214
                    ]
                    { onPress =
                        if List.isEmpty errors then
                            Just ConvertText

                        else
                            Nothing
                    , label = el [ padding 8 ] <| text "変換する"
                    }
                , wrappedText [ width fill ] <| "text : " ++ model.text
                ]
            ]


main =
    Browser.sandbox
        { init = init, view = view, update = update }


testSuite : Test
testSuite =
    Test.describe "04 - Hello, Form Decoder"
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
                    |> Expect.equal text
                    |> Expect.onFail """textがformTextから変換されるように`replace____me*`を書き換えましょう

replace____me1はDecoder.runとdecoderを使ってformTextを変換しましょう
replace____me2はDecoder.identityで`Decoder String err Strig`を作りましょう"""
        , Test.test "formTextが空文字のとき、変換は失敗します" <|
            \_ ->
                let
                    { text, formText } =
                        init
                            |> update (ChangeText "")
                            |> update ConvertText

                    errors =
                        Decoder.errors decoder formText
                in
                if String.isEmpty text then
                    Expect.fail "formTextが空文字のときは失敗するようにしましょう"

                else if List.member TextEmpty errors then
                    Expect.pass

                else
                    Expect.fail "formTextが空文字のときはTextEmptyのエラーで失敗するようにしましょう"
        , Test.test "formTextが10文字より長いとき、変換は失敗します" <|
            \_ ->
                let
                    text =
                        "我が臆病な自尊心と、尊大な羞恥心との所為である"

                    updated =
                        init
                            |> update (ChangeText text)
                            |> update ConvertText

                    errors =
                        Decoder.errors decoder updated.formText
                in
                if text == updated.text then
                    Expect.fail "formTextが10文字以上のときは失敗するようにdecoderでバリデーションしましょう"

                else if List.member TextOver10Length errors then
                    Expect.pass

                else
                    Expect.fail "formTextが10文字以上のときはTextOver10Lengthのエラーで失敗するようにdecoderにバリデーションを足しましょう"
        ]
