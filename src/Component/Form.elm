module Component.Form exposing (view)


import Element exposing(..)


view : List {label : String, msg} -> Element msg
view item =


    Grid.view [ spacingXY 16 8 ]
        [ shrink, fill, shrink, fill ]
        [ [ el [ centerY ] <| text "text"
          , Element.Input.text
                [ htmlAttribute <| Html.Attributes.autofocus True ]
                { onChange = ChangeText
                , text = model.form.text
                , placeholder = Nothing
                , label = Element.Input.labelHidden "text"
                }
          , el [ centerY ] <| text "➡"
          , case model.value of
                Ok value ->
                    wrappedText [ centerY ] value.text

                Err error ->
                    el [ centerY ] <| text "textの変換に失敗しました"
          ]
        , [ el [ centerY ] <| text "number"
          , Element.Input.text []
                { onChange = ChangeNumber
                , text = model.form.number
                , placeholder = Nothing
                , label = Element.Input.labelHidden "number"
                }
          , el [ centerY ] <| text "➡"
          , case model.value of
                Ok value ->
                    wrappedText [ centerY ] <| String.fromInt value.number

                Err error ->
                    el [ centerY ] <| text "numberの変換に失敗しました"
          ]
        ]
