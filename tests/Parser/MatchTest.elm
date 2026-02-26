module Parser.MatchTest exposing (..)

import Expect
import Parser.Match as Match
import Parser.Symbol exposing (Symbol(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Parser.Match"
        [ describe "isReducible"
            [ test "[L, ST, R] is True (simple [name])" <|
                \_ ->
                    Match.isReducible [ L, ST, R ]
                        |> Expect.equal True
            , test "[M, ST, M] is True (math $...$)" <|
                \_ ->
                    Match.isReducible [ M, ST, M ]
                        |> Expect.equal True
            , test "[C, ST, C] is True (code `...`)" <|
                \_ ->
                    Match.isReducible [ C, ST, C ]
                        |> Expect.equal True
            , test "[L, ST, L, ST, R, R] is True (nested brackets)" <|
                \_ ->
                    Match.isReducible [ L, ST, L, ST, R, R ]
                        |> Expect.equal True
            , test "[L, ST] is False (unclosed bracket)" <|
                \_ ->
                    Match.isReducible [ L, ST ]
                        |> Expect.equal False
            , test "[ST] is False (plain text)" <|
                \_ ->
                    Match.isReducible [ ST ]
                        |> Expect.equal False
            , test "[] is False (empty list)" <|
                \_ ->
                    Match.isReducible []
                        |> Expect.equal False
            ]
        , describe "match"
            [ test "[L, ST, R] is Just 2" <|
                \_ ->
                    Match.match [ L, ST, R ]
                        |> Expect.equal (Just 2)
            , test "[M, ST, M] is Just 2" <|
                \_ ->
                    Match.match [ M, ST, M ]
                        |> Expect.equal (Just 2)
            , test "[R] is Nothing (unmatched close)" <|
                \_ ->
                    Match.match [ R ]
                        |> Expect.equal Nothing
            , test "[] is Nothing (empty)" <|
                \_ ->
                    Match.match []
                        |> Expect.equal Nothing
            ]
        , describe "getSegment"
            [ test "M [M, ST, ST, M] returns [M, ST, ST, M]" <|
                \_ ->
                    Match.getSegment M [ M, ST, ST, M ]
                        |> Expect.equal [ M, ST, ST, M ]
            ]
        , describe "splitAt"
            [ test "splitAt 2 [L, ST, R, ST] gives ([L, ST], [R, ST])" <|
                \_ ->
                    Match.splitAt 2 [ L, ST, R, ST ]
                        |> Expect.equal ( [ L, ST ], [ R, ST ] )
            ]
        ]
