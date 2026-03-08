module ETeX.LetTest exposing (..)

import ETeX.Let exposing (reduce)
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "ETeX.Let.reduce"
        [ test "no LET block passes through" <|
            \_ -> Expect.equal "x^2 + 1" (reduce "x^2 + 1")
        , test "simple single variable" <|
            \_ ->
                reduce "LET\n  A = x^2\nIN\n  A + 1"
                    |> Expect.equal "x^2 + 1"
        , test "two independent variables" <|
            \_ ->
                reduce "LET\n  A = x^2\n  B = y^2\nIN\n  A + B"
                    |> Expect.equal "x^2 + y^2"
        , test "sequential definitions" <|
            \_ ->
                reduce "LET\n  A = e1\n  B = e2\n  P = A + B\nIN\n  P"
                    |> Expect.equal "(e1 + e2)"
        , test "full example from design doc" <|
            \_ ->
                reduce "LET\n  A = e1\n  B = e2\n  P = A + B\n  Q = A - B\nIN\n  PQ"
                    |> Expect.equal "(e1 + e2)(e1 - e2)"
        , test "content before LET is preserved" <|
            \_ ->
                reduce "preamble\nLET\n  A = x\nIN\n  A + 1"
                    |> Expect.equal "preamble\nx + 1"
        , test "adjacent uppercase variables both replaced" <|
            \_ ->
                reduce "LET\n  A = x^2\n  B = y^2\nIN\n  AB"
                    |> Expect.equal "x^2y^2"
        , test "variables not replaced next to lowercase" <|
            \_ ->
                reduce "LET\n  A = x\nIN\n  Ab + A"
                    |> Expect.equal "Ab + x"
        , test "parens added for expressions with plus" <|
            \_ ->
                reduce "LET\n  A = a + b\nIN\n  A + 1"
                    |> Expect.equal "(a + b) + 1"
        , test "no parens for simple expressions" <|
            \_ ->
                reduce "LET\n  A = x^2\nIN\n  A + 1"
                    |> Expect.equal "x^2 + 1"
        , test "no parens for frac" <|
            \_ ->
                reduce "LET\n  A = \\frac{1}{2}\nIN\n  A + 1"
                    |> Expect.equal "\\frac{1}{2} + 1"
        , test "no parens for already parenthesized" <|
            \_ ->
                reduce "LET\n  A = (a + b)\nIN\n  A + 1"
                    |> Expect.equal "(a + b) + 1"
        ]
