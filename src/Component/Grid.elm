module Component.Grid exposing (view)

import Element exposing (..)
import List.Extra


view : List (Attribute msg) -> List Length -> List (List (Element msg)) -> Element msg
view attrs lengths matrix =
    case matrix of
        topRow :: rest ->
            table attrs
                { data = rest
                , columns =
                    List.indexedMap
                        (\index header ->
                            { header = header
                            , width = List.Extra.getAt index lengths |> Maybe.withDefault shrink
                            , view = List.Extra.getAt index >> Maybe.withDefault none
                            }
                        )
                        topRow
                }

        [] ->
            table attrs { data = [], columns = [] }



-- book : Book
-- book =
--     bookWithFrontCover "Grid"
--         (column [ spacing 36, width fill ]
--             [ column [ spacing 16, width fill ]
--                 [ text "普通"
--                 , view [ spacingXY 16 8, width fill ]
--                     []
--                     [ [ text "label", row [ width fill ] [ text "hamhamhamhamhamham" ] ]
--                     , [ text "long long ago", row [ width fill ] [ text "egg" ] ]
--                     , [ text "a", text "a" ]
--                     ]
--                 ]
--             , column [ spacing 16 ]
--                 [ text "noneまじり"
--                 , view [ spacingXY 16 8, width fill ]
--                     []
--                     [ [ text "label", row [ width fill ] [ text "hamhamhamhamhamham" ] ]
--                     , [ none, row [ width fill ] [ text "egg" ] ]
--                     , [ text "a" ]
--                     ]
--                 ]
--             , column [ spacing 16 ]
--                 [ text "headerがnone（domの順番が逆になる）"
--                 , view [ spacingXY 16 8, width fill ]
--                     []
--                     [ [ none, none ]
--                     , [ text "long long ago", row [ width fill ] [ text "egg" ] ]
--                     , [ text "a", text "a" ]
--                     ]
--                 ]
--             , column [ spacing 16, width fill ]
--                 [ text "fill"
--                 , view [ spacingXY 16 8, width fill ]
--                     [ fill, fill ]
--                     [ [ text "label", row [ width fill ] [ text "hamhamhamhamhamham" ] ]
--                     , [ text "long long ago", row [ width fill ] [ text "egg" ] ]
--                     , [ text "a", text "a" ]
--                     ]
--                 ]
--             ]
--         )
