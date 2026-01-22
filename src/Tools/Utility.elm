module Tools.Utility exposing (compressWhitespace)

{-| General utilities for the Scripta compiler.
-}


{-| Compress multiple whitespace characters into single spaces.
-}
compressWhitespace : String -> String
compressWhitespace str =
    str
        |> String.words
        |> String.join " "

