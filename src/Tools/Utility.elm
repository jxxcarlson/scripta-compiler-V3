module Tools.Utility exposing (compressWhitespace, keyValueDict, removeNonAlphaNum, userReplace)

import Dict exposing (Dict)
import Regex


compressWhitespace : String -> String
compressWhitespace str =
    str
        |> String.words
        |> String.join " "


keyValueDict : List String -> Dict String String
keyValueDict strings_ =
    List.map (String.split ":") strings_
        |> List.map (List.map String.trim)
        |> List.filterMap pairFromList
        |> Dict.fromList


pairFromList : List String -> Maybe ( String, String )
pairFromList strings =
    case strings of
        [ x, y ] ->
            Just ( x, y )

        _ ->
            Nothing


removeNonAlphaNum : String -> String
removeNonAlphaNum string =
    userReplace "[^A-Za-z0-9\\-]" (\_ -> "") string


userReplace : String -> (Regex.Match -> String) -> String -> String
userReplace regexString replacer string =
    case Regex.fromString regexString of
        Nothing ->
            string

        Just regex ->
            Regex.replace regex replacer string
