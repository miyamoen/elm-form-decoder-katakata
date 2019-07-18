module KataKata.Element exposing (wrappedText)

import Element exposing (..)


wrappedText : List (Attribute msg) -> String -> Element msg
wrappedText attrs string =
    paragraph attrs [ text string ]
