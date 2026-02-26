module Parser.SymbolTest exposing (..)

import Expect
import Parser.Symbol exposing (Symbol(..), toSymbols, value)
import Parser.Tokenizer exposing (Token_(..), Meta)
import Test exposing (Test, describe, test)


dummyMeta : Meta
dummyMeta =
    { begin = 0, end = 0, index = 0 }


suite : Test
suite =
    describe "Parser.Symbol"
        [ describe "value"
            [ test "value L is 1" <|
                \_ ->
                    value L |> Expect.equal 1
            , test "value R is -1" <|
                \_ ->
                    value R |> Expect.equal -1
            , test "value ST is 0" <|
                \_ ->
                    value ST |> Expect.equal 0
            , test "value M is 0" <|
                \_ ->
                    value M |> Expect.equal 0
            ]
        , describe "toSymbols"
            [ test "[LB, S, RB] gives [L, ST, R]" <|
                \_ ->
                    toSymbols [ LB dummyMeta, S "hello" dummyMeta, RB dummyMeta ]
                        |> Expect.equal [ L, ST, R ]
            , test "[] gives []" <|
                \_ ->
                    toSymbols []
                        |> Expect.equal []
            ]
        ]
