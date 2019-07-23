module KataKata05BuildUpDecoder exposing (Model, Msg(..), init, main, update, view)

{-|


# katakata 05 Build up Decoder

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


### 今回学ぶこと

  - Int型のDecoder
      - Decoder.intで`Decoder String err Int`が作れる
  - 最大値を最小値のバリデーションを適用する
      - minBoundとmaxBoundでできる
  - Decoderの組み合わせ方
      - top, fieldを使った組み合わせ方
      - liftを使って入力の型を合わせる方法


#### `lift`する

まずこういう虎型と虎フォーム型がある

    type alias Tiger =
        { name : String, species : Species }

    type alais TigerForm =
        { name : String, species : String }

そしてname用のdecoderもある。（実装略）

    nameDecoder : Decoder String Error String

これを使ってDecoder.runしてみる

    Decoder.run nameDecoder tigerForm

これはコンパイルエラーになる。nameDecoderのinputはStringであってTigerFormではないからだ。
Decoderが`input -> Result (List err) a`であることを意識したらわかると思う。

`input -> Result (List err) a`をnameDecoderの型変数で埋めてみる。

    String -> Result (List Error) String

最初のStringをTigerFormに変えたい。

    TigerForm -> Result (List Error) String

TigerFormからnameは`.name`で簡単に取れるのでこの変換は簡単にできるように思う。

    nameDecoder : String -> Result (List Error) String

    nameDecoder_ : TigerForm -> Result (List Error) String
    nameDecoder_ form =
        nameDecoder form.name

できた。これをDecoder上でやるのに`lift`がある。

    nameDecoder : Decoder String Error String

    nameDecoder_ : Decoder TigerForm Error String
    nameDecoder_ =
        Decoder.lift .name nameDecoder

    Decoder.run nameDecoder_ tigerForm

このようにレコードのDecoderを作るときはほぼ必ず`lift`することになるので使ってみましょう。


#### Decoderを組み合わせる

題材はそのまま虎を使う。

    nameDecoder : Decoder String Error String

    speciesDecoder : Decoder String Error Species

    decoder : Decoder TigerForm Error Tiger
    decoder =
        Decoder.top Tiger
            |> Decoder.field (Decoder.lift .name nameDecoder)
            |> Decoder.field (Decoder.lift .species speciesDecoder)

`top`と`field`を使う。このAPIは[NoRedInk/elm-json-decode-pipeline](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/)と一緒で最初にコンストラクターを置いてパイプで引数を与えていく形になっている。

合成するときは各Decoderの入力の型を合わせなければならない。そのために前項で学んだ`lift`を使う。`top Constructor |> field (lift .accessor subDecoder)`をとりあえず覚えてしまってもいい。


## 追加課題

文字列の長さはnumber以下にすることにしました。つまり、numberは1以上10以下の整数でtextはnumber文字以下の空文字ではない文字列です。


### やり方

  - 一番下の"form.textがnumber文字より長いとき、変換は失敗します"のテストについている`skip <|`を外して有効化しましょう
  - 🎉🎉テストが全部通ったらクリアです！🎉🎉


### 学ぶ

実装方法はいくつかあると思うが、ここでは組み合わせた後にバリデーションすることにする。（もちろん自分で考えたやり方でやってもらっていい）


#### 考え方

回答作ったときの考え方を書いておきますがあんまり役に立たなさそうです。

numberに依存してDecoderを作らないといけないので、値に依存したDecoderを作る関数は`with`と`andThen`で作れる。これで作ってみようとするとdecoderの実装がこんがらがってちょっと勉強用には適さないかもしれない。バリデーションをつけ足せば既存のは壊さないで書けそう。

ということでdecoderにtextがnumber文字以下のバリデーションを足してみましょう。


#### カスタムバリデーターを作る

packageに用意されているValidator（minBound, minLength,...）はあくまでよく使うだろうから用意されているだけであって、自分で作ってはいけないだなんて固定観念を今すぐ捨て去るべきです。作りましょう。

    type alias Validator input err =
        Decoder input err ()

Validatorを作る専用APIはありませんが、Validatorの定義をみれば作り方はわかると思います。`i -> Result (List err) ()`を作ればいいわけです。`custom`を使えば作ることができます。

    custom : (input -> Result (List err) a) -> Decoder input err a

    tigerValidator : Validator Tiger Err
    tigerValidator =
        custom <|
            \tiger ->
                if hoge tiger then
                    Ok ()

                else
                    Err [ TigerTooBig ]

このようにデコードしたあとの虎を使っていくらでもバリデーションできます。

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


viewInput :
    { onChange : String -> msg
    , value : String
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
            , text = value
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
    Test.describe "05 - Build up Decoder"
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
