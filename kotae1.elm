                | value =
                    case String.toInt form.number of
                        Just number ->
                            if (not <| String.isEmpty form.text) && String.length form.text <= number && 1 <= number && number <= 10 then
                                Ok { text = form.text, number = number }

                            else
                                Err "textかnumberがちょっと問題"

                        Nothing ->
                            Err "整数に変換できない"



    Decoder.identity
        |> Decoder.assert (Decoder.minLength TextEmpty 1)
        |> Decoder.assert (Decoder.maxLength TextOver10Length 10)

decoder : Decoder Form Error Value
decoder =
    Decoder.top Value
        |> Decoder.field (Decoder.lift .text textDecoder)
        |> Decoder.field (Decoder.lift .number numberDecoder)
        |> Decoder.assert
            (Decoder.custom <|
                \{ text, number } ->
                    if String.length text <= number then
                        Ok ()

                    else
                        Err [ TextTooLong ]
            )


textDecoder : Decoder String Error String
textDecoder =
    Decoder.identity
        |> Decoder.assert (Decoder.minLength TextEmpty 1)
        |> Decoder.assert (Decoder.maxLength TextTooLong 10)


numberDecoder : Decoder String Error Int
numberDecoder =
    Decoder.int NumberInvalidInt
        |> Decoder.assert (Decoder.minBound NumberBelow 1)
        |> Decoder.assert (Decoder.maxBound NumberOver 10)

