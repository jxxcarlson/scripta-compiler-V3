port module DiffMain exposing (main)

import Parser.Expression
import Parser.Forest
import TestData


port out : List String -> Cmd msg


main : Program (List String) () ()
main =
    Platform.worker
        { init = \sources -> ( (), out (List.map run sources) )
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
