port module DiffMain exposing (main)

import Dict
import Parser.Expression
import Parser.Forest
import TestData


port out : List String -> Cmd msg


type alias Flags =
    { sources : List String
    , edits : List ( String, String )
    }


main : Program Flags () ()
main =
    Platform.worker
        { init = \flags -> ( (), out (List.map run flags.sources ++ List.map runEdit flags.edits) )
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


run : String -> String
run source =
    let
        lines =
            String.lines source
    in
    String.join "\n"
        [ Debug.toString (Parser.Forest.parse lines)
        , Debug.toString (Parser.Forest.parseToForestWithAccumulator TestData.defaultCompilerParameters lines)
        , Debug.toString (List.indexedMap Parser.Expression.parse lines)
        ]


{-| Parse `before` as Scripta.parse does, then reparse `after` as Scripta.reparse does.
-}
runEdit : ( String, String ) -> String
runEdit ( before, after ) =
    let
        params =
            TestData.defaultCompilerParameters

        ( cache, acc, forest ) =
            Parser.Forest.parseIncrementally params Dict.empty (String.lines before)

        result =
            Parser.Forest.parseIncrementallySkipAcc params cache ( acc, forest ) (String.lines after)
    in
    String.join "\n"
        [ "accWasSkipped = " ++ Debug.toString result.accWasSkipped
        , Debug.toString result.forest
        , Debug.toString result.acc
        , Debug.toString (Dict.toList result.cache)
        ]
