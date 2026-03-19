module ETeX.TransformTest exposing (..)

import Dict
import ETeX.Transform exposing (evalStr, makeMacroDict)
import Expect
import Test exposing (Test, describe, test)


setMacros =
    makeMacroDict "set: \\{\\ #1 \\}"


suite : Test
suite =
    describe "ETeX.Transform.evalStr"
        [ describe "basic expressions"
            [ test "simple expression" <|
                \_ ->
                    evalStr Dict.empty "x^2 + 1"
                        |> String.contains "ETeX error"
                        |> Expect.equal False
            , test "parenthesized expression" <|
                \_ ->
                    evalStr Dict.empty "(a + b)"
                        |> Expect.equal "(a + b)"
            , test "frac with two args" <|
                \_ ->
                    evalStr Dict.empty "frac(1, n+1)"
                        |> Expect.equal "\\frac{1}{ n+1}"
            ]
        , describe "LaTeX environments"
            [ test "single-line environment passes through" <|
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
                    evalStr Dict.empty "\\begin{pmatrix}\n1\n\\end{pmatrix}\\begin{pmatrix}\n2\n\\end{pmatrix} = \\begin{pmatrix}\n3\n\\end{pmatrix}"
                        |> String.contains "ETeX error"
                        |> Expect.equal False
            ]
        , describe "user-defined macros with nested parens"
            [ test "set(a > 0) — no nested parens" <|
                \_ ->
                    evalStr setMacros "set(a > 0)"
                        |> Expect.equal "\\{\\ {a > 0} \\}"
            , test "set((1,2)) — nested parens with comma" <|
                \_ ->
                    evalStr setMacros "set((1,2))"
                        |> Expect.equal "\\{\\ {(1,2)} \\}"
            , test "set( (1,2) ) — nested parens with spaces" <|
                \_ ->
                    evalStr setMacros "set( (1,2) )"
                        |> Expect.equal "\\{\\ { (1,2) } \\}"
            ]
        , describe "user-defined macros inside function args"
            [ test "bvec(p) inside frac() expands correctly" <|
                \_ ->
                    let
                        bvecMacros =
                            makeMacroDict "bvec:   mathbf{#1}"
                    in
                    evalStr bvecMacros "frac(d bvec(p)_i,dt)"
                        |> String.contains "\\mathbf"
                        |> Expect.equal True
            , test "bvec(p) inside frac() does not produce error" <|
                \_ ->
                    let
                        bvecMacros =
                            makeMacroDict "bvec:   mathbf{#1}"
                    in
                    evalStr bvecMacros "m frac(d bvec(p)_i,dt) = F_i"
                        |> String.contains "ETeX error"
                        |> Expect.equal False
            , test "bvec(p) inside frac() does not leave unexpanded #1" <|
                \_ ->
                    let
                        bvecMacros =
                            makeMacroDict "bvec:   mathbf{#1}"
                    in
                    evalStr bvecMacros "frac(d bvec(p)_i,dt)"
                        |> String.contains "#1"
                        |> Expect.equal False
            ]
        , describe "line breaks (\\\\)"
            [ test "trailing \\\\ is preserved" <|
                \_ ->
                    evalStr Dict.empty "x = \\\\"
                        |> Expect.equal "x = \\\\"
            , test "equation with trailing \\\\ does not produce error" <|
                \_ ->
                    evalStr Dict.empty "Omega_{AB} = \\\\\nOmega_A"
                        |> String.contains "ETeX error"
                        |> Expect.equal False
            , test "\\\\ between expressions is preserved" <|
                \_ ->
                    evalStr Dict.empty "a + b \\\\\nc + d"
                        |> String.contains "\\\\"
                        |> Expect.equal True
            ]
        , describe "LET with environments"
            [ test "LET with multi-line pmatrix definitions no error" <|
                \_ ->
                    evalStr Dict.empty "LET\n  A = \\begin{pmatrix}\n  2 & 1 \\\\\n  1 & 2\n  \\end{pmatrix}\n  B = \\begin{pmatrix}\n  2 & 1 \\\\\n  1 & 2\n  \\end{pmatrix}\nIN\n  AB"
                        |> String.contains "ETeX error"
                        |> Expect.equal False
            , test "LET with three pmatrix defs and body AB = C no error" <|
                \_ ->
                    evalStr Dict.empty "LET\n  A = \\begin{pmatrix}\n  2 & 1 \\\\\n  1 & 2\n  \\end{pmatrix}\n  B = \\begin{pmatrix}\n  2 & 1 \\\\\n  1 & 2\n  \\end{pmatrix}\n  C = \\begin{pmatrix}\n  5 & 4 \\\\\n  4 & 5\n  \\end{pmatrix}\nIN\n  AB = C"
                        |> String.contains "ETeX error"
                        |> Expect.equal False
            ]
        ]
