module Component.Form exposing (button, button_, errors, text, view)

import Component.Grid as Grid
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import KataKata.Element exposing (wrappedText)


view : List (Attribute msg) -> List (List (Element msg)) -> Element msg
view attrs inputs =
    Grid.view ([ spacingXY 24 12 ] ++ attrs)
        [ shrink, fill, shrink, fill ]
        ([ none, heading "Form", none, heading "Value" ] :: inputs)


heading : String -> Element msg
heading string =
    el
        [ padding 12
        , Border.widthEach
            { bottom = 1
            , left = 0
            , right = 0
            , top = 0
            }
        , Border.color <| rgba255 200 200 200 1
        ]
    <|
        Element.text string


text :
    { label : String
    , onChange : String -> msg
    , attrs : List (Attribute msg)
    , form : String
    , value : String
    }
    -> List (Element msg)
text { label, onChange, attrs, form, value } =
    [ el [ centerY ] <| Element.text label
    , Element.Input.text attrs
        { onChange = onChange
        , text = form
        , placeholder = Nothing
        , label = Element.Input.labelHidden label
        }
    , el [ centerY ] <| Element.text "➡"
    , wrappedText [ centerY, paddingXY 12 0 ] value
    ]


errors : List ( String, Bool ) -> List (Element msg)
errors messages =
    [ none
    , column [ spacing 12, paddingXY 12 0, Font.size 16, Font.color <| rgb255 234 122 184 ] <|
        List.map
            (\( message, invalid ) ->
                if invalid then
                    Element.text message

                else
                    none
            )
            messages
    , none
    , none
    ]


button : { label : String, msg : msg, enable : Bool } -> List (Element msg)
button option =
    [ none
    , el [] <| button_ [ alignRight ] option
    , none
    , none
    ]


button_ : List (Attribute msg) -> { label : String, msg : msg, enable : Bool } -> Element msg
button_ attrs { msg, enable, label } =
    Element.Input.button
        ([ Border.width 1
         , Border.rounded 4
         , Border.color <| rgba255 0 0 0 0.3
         , if enable then
            Background.color <| rgb255 255 236 165

           else
            Background.color <| rgb255 243 236 214
         , alignTop
         ]
            ++ attrs
        )
        { onPress =
            if enable then
                Just msg

            else
                Nothing
        , label = el [ padding 8 ] <| Element.text label
        }
