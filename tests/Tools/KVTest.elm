module Tools.KVTest exposing (..)

import Dict
import Expect
import Test exposing (Test, describe, test)
import Tools.KV exposing (argsAndPropertiesFromList, mergeArgsAndProperties)


suite : Test
suite =
    describe "Tools.KV"
        [ describe "argsAndPropertiesFromList"
            [ test "simple KV pair: [\"width:400\"]" <|
                \_ ->
                    argsAndPropertiesFromList [ "width:400" ]
                        |> Expect.equal ( [], Dict.fromList [ ( "width", "400" ) ] )
            , test "args + properties: [\"arg1\", \"key:val\"]" <|
                \_ ->
                    argsAndPropertiesFromList [ "arg1", "key:val" ]
                        |> Expect.equal ( [ "arg1" ], Dict.fromList [ ( "key", "val" ) ] )
            , test "args only: [\"arg1\", \"arg2\"]" <|
                \_ ->
                    argsAndPropertiesFromList [ "arg1", "arg2" ]
                        |> Expect.equal ( [ "arg1", "arg2" ], Dict.empty )
            , test "empty input" <|
                \_ ->
                    argsAndPropertiesFromList []
                        |> Expect.equal ( [], Dict.empty )
            , test "multi-value property: [\"key:val1\", \"extra\", \"key2:val2\"]" <|
                \_ ->
                    argsAndPropertiesFromList [ "key:val1", "extra", "key2:val2" ]
                        |> Expect.equal ( [], Dict.fromList [ ( "key", "val1 extra" ), ( "key2", "val2" ) ] )
            , test "item without colon is a positional arg" <|
                -- M13: item without colon handled correctly as positional arg
                \_ ->
                    argsAndPropertiesFromList [ "nocolon" ]
                        |> Expect.equal ( [ "nocolon" ], Dict.empty )
            ]
        , describe "mergeArgsAndProperties"
            [ test "overlapping keys: second wins" <|
                \_ ->
                    mergeArgsAndProperties
                        ( [ "a" ], Dict.fromList [ ( "k", "v1" ) ] )
                        ( [ "b" ], Dict.fromList [ ( "k", "v2" ) ] )
                        |> Expect.equal ( [ "a", "b" ], Dict.fromList [ ( "k", "v2" ) ] )
            ]
        ]
