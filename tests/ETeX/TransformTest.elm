module ETeX.TransformTest exposing (..)

import Dict
import ETeX.Transform exposing (evalStr)
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "ETeX.Transform.evalStr"
        [ test "simple expression" <|
            \_ ->
                evalStr Dict.empty "x^2 + 1"
                    |> String.contains "ETeX error"
                    |> Expect.equal False
        , test "single-line environment passes through" <|
            \_ ->
                evalStr Dict.empty "\\begin{small}text\\end{small}"
                    |> String.contains "ETeX error"
                    |> Expect.equal False
        , test "multi-line environment passes through" <|
            \_ ->
                evalStr Dict.empty "\\begin{pmatrix}\n1 & 2 \\\\\n3 & 4\n\\end{pmatrix}"
                    |> Expect.equal "\\begin{pmatrix}\n1 & 2 \\\\\n3 & 4\n\\end{pmatrix}"
        , test "two adjacent environments (\\end then \\begin on same line)" <|
            \_ ->
                evalStr Dict.empty "\\begin{pmatrix}\n1 & 2\n\\end{pmatrix}\\begin{pmatrix}\n3 & 4\n\\end{pmatrix}"
                    |> String.contains "ETeX error"
                    |> Expect.equal False
        , test "expression before \\begin on same line" <|
            \_ ->
                evalStr Dict.empty "= \\begin{pmatrix}\n1 & 2\n\\end{pmatrix}"
                    |> String.contains "ETeX error"
                    |> Expect.equal False
        , test "three environments with expressions between" <|
            \_ ->
                let
                    input =
                        "\\begin{pmatrix}\n1\n\\end{pmatrix}\\begin{pmatrix}\n2\n\\end{pmatrix} = \\begin{pmatrix}\n3\n\\end{pmatrix}"
                in
                evalStr Dict.empty input
                    |> String.contains "ETeX error"
                    |> Expect.equal False
        , test "LET with multi-line pmatrix definitions no error" <|
            \_ ->
                let
                    input =
                        "LET\n  A = \\begin{pmatrix}\n  2 & 1 \\\\\n  1 & 2\n  \\end{pmatrix}\n  B = \\begin{pmatrix}\n  2 & 1 \\\\\n  1 & 2\n  \\end{pmatrix}\nIN\n  AB"
                in
                evalStr Dict.empty input
                    |> String.contains "ETeX error"
                    |> Expect.equal False
        , test "LET with three pmatrix defs and body AB = C no error" <|
            \_ ->
                let
                    input =
                        "LET\n  A = \\begin{pmatrix}\n  2 & 1 \\\\\n  1 & 2\n  \\end{pmatrix}\n  B = \\begin{pmatrix}\n  2 & 1 \\\\\n  1 & 2\n  \\end{pmatrix}\n  C = \\begin{pmatrix}\n  5 & 4 \\\\\n  4 & 5\n  \\end{pmatrix}\nIN\n  AB = C"
                in
                evalStr Dict.empty input
                    |> String.contains "ETeX error"
                    |> Expect.equal False
        ]
