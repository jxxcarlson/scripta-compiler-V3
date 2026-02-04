module Parser.ExpressionParserTest exposing (..)

import Expect
import Parser.Expression as PE
import Test exposing (..)
import V3.Types exposing (Expr(..), Expression)


pe : String -> List Expression
pe =
    PE.parse 0


suite : Test
suite =
    describe "Parser.Expression"
        [ describe "parse"
            [ test "parses plain text" <|
                \_ ->
                    let
                        result =
                            pe "hello"

                        expected =
                            [ Text "hello" { begin = 0, end = 4, id = "e-0.0", index = 0 } ]
                    in
                    Expect.equal expected result
            , test "parses function syntax" <|
                \_ ->
                    let
                        result =
                            pe "This is [b bold text]!"

                        expected =
                            [ Text "This is " { begin = 0, end = 7, id = "e-0.0", index = 0 }
                            , Fun "b" [ Text "bold text" { begin = 10, end = 19, id = "e-0.3", index = 3 } ] { begin = 9, end = 9, id = "e-0.2", index = 2 }
                            , Text "!" { begin = 21, end = 21, id = "e-0.5", index = 5 }
                            ]
                    in
                    Expect.equal expected result
            , test "parses math syntax" <|
                \_ ->
                    let
                        result =
                            pe "Pythagoras sez: $a^2 + b^2 = c^2$!"

                        expected =
                            [ Text "Pythagoras sez: " { begin = 0, end = 15, id = "e-0.0", index = 0 }
                            , VFun "math" "a^2 + b^2 = c^2" { begin = 16, end = 16, id = "e-0.1", index = 1 }
                            , Text "!" { begin = 33, end = 33, id = "e-0.4", index = 4 }
                            ]
                    in
                    Expect.equal expected result
            ]
        ]
