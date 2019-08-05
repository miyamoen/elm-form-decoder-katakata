module KataKata.Element exposing (line, withTitle, wrappedText)

import Element exposing (..)
import Element.Border as Border


wrappedText : List (Attribute msg) -> String -> Element msg
wrappedText attrs string =
    paragraph attrs [ text string ]


withTitle : String -> Element msg -> Element msg
withTitle title content =
    column [ width fill, spacing 32 ]
        [ row [ width fill, spacing 32 ] [ line <| px 64, text title, line fill ]
        , content
        ]


line : Length -> Element msg
line length =
    el [ width length, Border.width 2, Border.color <| rgba255 0 0 0 0.2 ] none
