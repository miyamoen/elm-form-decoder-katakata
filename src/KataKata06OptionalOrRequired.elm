module KataKata06OptionalOrRequired exposing (Model, Msg(..), init, main, update, view)

{-|


# katakata 06 Optional or Required

Decoderを組み合わせて使ってみましょう


## ストーリー

Decoderを作ってみて自信を付けたあなたは、次にkatakata 03のtextとnumberのレコードのフォームをelm-form-decoderで作ってみることにしました。

制約は以下です

  - 文字列は空文字でなく長さ10文字以下
  - 数字は1以上10以下の整数


## やり方

  - elm reactorでこのファイルを開きましょう
  - 画面下部に表示されるテスト結果を読んで`replace____me*`を書き換えましょう
  - 🎉🎉テストが全部通ったらクリアです！🎉🎉
  - katakata 03と比べてみましょう


## 学ぶ


### 記事で学ぶ

  - [package document](https://package.elm-lang.org/packages/arowM/elm-form-decoder/latest/)
  - 作者の書いた紹介記事[「フォームバリデーションからフォームデコーディングの時代へ」](https://qiita.com/arowM/items/6c32db1f9e4b92445f3b)
  - API詳解[「arowM/elm-form-decoderのAPIを【かんぜんりかい】しよう！」](https://qiita.com/miyamo_madoka/items/d02f003ec1c212360111)

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
    { value : Value, form : Form }


type alias Tiger =
    { name : String
    , age : Int
    , species : Maybe String
    }


type alias TigerForm =
    { text : String, number : String }


type Msg
    = ChangeText String
    | ChangeNumber String
    | ConvertForm


init : Model
init =
    { value = { text = "initial", number = 1 }
    , form = { text = "", number = "" }
    }


update : Msg -> Model -> Model
update msg model =
    let
        form =
            model.form
    in
    case msg of
        ChangeText string ->
            { model | form = { form | text = string } }

        ChangeNumber string ->
            { model | form = { form | number = string } }

        ConvertForm ->
            case Decoder.run decoder form of
                Ok value ->
                    { model | value = value }

                Err _ ->
                    model


type Error
    = TextEmpty
    | TextTooLong
    | NumberInvalidInt
    | NumberBelow
    | NumberOver


decoder : Decoder Form Error Value
decoder =
    replace____me3 <| Decoder.always { text = "initial", number = 1 }


textDecoder : Decoder String Error String
textDecoder =
    -- katakata 04のdecoderの実装をそのまま使いましょう
    replace____me1 <| Decoder.always "虎にならない"


numberDecoder : Decoder String Error Int
numberDecoder =
    replace____me2 <| Decoder.always -5


view : Model -> Html Msg
view { form, value } =
    let
        errors =
            Decoder.errors decoder form
    in
    Test.withTest testSuite <|
        column [ width fill, spacing 32 ]
            [ viewInput
                { onChange = ChangeText
                , value = form.text
                , label = "text"
                , validations =
                    [ { message = "必須です", invalid = List.member TextEmpty errors }
                    , { message = "10文字以下にしてください", invalid = List.member TextTooLong errors }
                    ]
                }
            , viewInput
                { onChange = ChangeNumber
                , value = form.number
                , label = "number"
                , validations =
                    [ { message = "整数を入力してください", invalid = List.member NumberInvalidInt errors }
                    , { message = "1以上の整数を入力してください", invalid = List.member NumberBelow errors }
                    , { message = "10以下の整数を入力してください", invalid = List.member NumberOver errors }
                    ]
                }
            , row [ width fill, spacing 16 ]
                [ Element.Input.button
                    [ alignTop
                    , Border.width 1
                    , Border.rounded 4
                    , Border.color <| rgba255 0 0 0 0.3
                    , if List.isEmpty errors then
                        Background.color <| rgb255 255 236 165

                      else
                        Background.color <| rgb255 243 236 214
                    ]
                    { onPress =
                        if List.isEmpty errors then
                            Just ConvertForm

                        else
                            Nothing
                    , label = el [ padding 8 ] <| text "変換する"
                    }
                , viewValue value
                ]
            ]


viewValue : Value -> Element msg
viewValue { text, number } =
    column [ width fill, spacing 4 ]
        [ wrappedText [ width fill ] <| "{ text : " ++ text
        , wrappedText [ width fill ] <| ", number : " ++ String.fromInt number
        , Element.text "}"
        ]



-- Text


type Input
    = NoInput
    | Input String


noInput : Input
noInput =
    NoInput


fromString : String -> Input
fromString =
    Input


toString : Input -> String
toString input =
    case input of
        NoInput ->
            ""

        Input string ->
            string


required : err -> Decoder String err a -> Decoder Input err a
required err d =
    Decoder.with <|
        \input ->
            case toString input of
                "" ->
                    Decoder.fail err

                _ ->
                    Decoder.lift toString d


optional : Decoder String err a -> Decoder Input err (Maybe a)
optional d =
    Decoder.with <|
        \text ->
            case toString text of
                "" ->
                    Decoder.always Nothing

                _ ->
                    Decoder.lift toString <| Decoder.map Just <| d


viewInput :
    { onChange : String -> msg
    , value : Input
    , label : String
    , validations : List { message : String, invalid : Bool }
    }
    -> Element msg
viewInput { onChange, value, label, validations } =
    column [ width fill, spacing 8 ]
        [ Element.Input.text
            [ width fill
            , htmlAttribute <| Html.Attributes.autofocus True
            ]
            { onChange = onChange
            , text = toString value
            , placeholder = Nothing
            , label = Element.Input.labelAbove [] <| text label
            }
        , row
            [ width fill
            , height <| px 20
            , spacing 32
            , Font.color <| rgb255 234 122 184
            ]
          <|
            List.map
                (\{ message, invalid } ->
                    if invalid then
                        text message

                    else
                        none
                )
                validations
        ]


main =
    Browser.sandbox
        { init = init, view = view, update = update }


testSuite : Test
testSuite =
    Test.describe "06 - Optional or Required"
        [ Test.test "textDecoderを実装しましょう" <|
            \_ ->
                let
                    text =
                        "虎になる"
                in
                Decoder.run textDecoder text
                    |> Expect.equal (Ok text)
                    |> Expect.onFail "replace____me1をkatakata04のdecoderで書き換えましょう。そのまま使えます。"
        , Test.test "numberDecoderを実装しましょう01" <|
            \_ ->
                Decoder.run numberDecoder "5"
                    |> Expect.equal (Ok 5)
                    |> Expect.onFail "replace____me2をIntを変換できるように書き換えましょう"
        , Test.test "numberDecoderを実装しましょう02" <|
            \_ ->
                Decoder.run numberDecoder "0"
                    |> Expect.err
                    |> Expect.onFail "numberDecoderに1より小さいときNumberBelowエラーになるようにバリデーションを追加しましょう"
        , Test.test "numberDecoderを実装しましょう03" <|
            \_ ->
                Decoder.run numberDecoder "11"
                    |> Expect.err
                    |> Expect.onFail "numberDecoderに10より大きいときNumberOverエラーになるようにバリデーションを追加しましょう"
        , Test.test "定義したデコーダーを組み合わせて`decoder`を実装しましょう" <|
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
                    |> Expect.equal value
                    |> Expect.onFail "replace____me03を書き換えてtextDecoderとnumberDecoderを組み合わせましょう"
        , Test.test "form.textが10文字より長いとき、変換は失敗します" <|
            \_ ->
                init
                    |> update (ChangeText "我が臆病な自尊心と、尊大な羞恥心との所為である")
                    |> update (ChangeNumber "10")
                    |> .form
                    |> Decoder.run decoder
                    |> Expect.err
                    |> Expect.onFail "form.textが10文字より長いときは変換が失敗するようにしましょう"
        , Test.test "form.textが空文字のとき、変換は失敗します" <|
            \_ ->
                init
                    |> update (ChangeText "")
                    |> update (ChangeNumber "5")
                    |> .form
                    |> Decoder.run decoder
                    |> Expect.err
                    |> Expect.onFail "form.textが空文字のときは変換が失敗するようにしましょう"
        , Test.test "form.numberが整数に変換できなければ、変換は失敗します" <|
            \_ ->
                init
                    |> update (ChangeText "虎になる")
                    |> update (ChangeNumber "数字のつもり")
                    |> .form
                    |> Decoder.run decoder
                    |> Expect.err
                    |> Expect.onFail "form.numberが整数にできないときは変換が失敗するようにしましょう"
        , Test.test "form.numberが1以上10以下の整数に変換できなければ、変換は失敗します" <|
            \_ ->
                let
                    zero =
                        init
                            |> update (ChangeText "虎になる")
                            |> update (ChangeNumber "0")
                            |> .form
                            |> Decoder.run decoder

                    eleven =
                        init
                            |> update (ChangeText "虎になる")
                            |> update (ChangeNumber "11")
                            |> .form
                            |> Decoder.run decoder
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
        , Test.skip <|
            Test.test "form.textがnumber文字より長いとき、変換は失敗します" <|
                \_ ->
                    init
                        |> update (ChangeText "虎になる")
                        |> update (ChangeNumber "3")
                        |> .form
                        |> Decoder.run decoder
                        |> Expect.err
                        |> Expect.onFail "form.textがnumber文字より長いときは変換が失敗するようにしましょう"
        ]
