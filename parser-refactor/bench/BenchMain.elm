port module BenchMain exposing (main)

{-| Times nothing itself: run.js measures Elm.init, which parses every input
synchronously. Output is the number of top-level expressions per input, so the
work cannot be skipped.
-}

import Parser.Expression


port out : List Int -> Cmd msg


main : Program (List String) () ()
main =
    Platform.worker
        { init = \inputs -> ( (), out (List.map (Parser.Expression.parse 0 >> List.length) inputs) )
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
