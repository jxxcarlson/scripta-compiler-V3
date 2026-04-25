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
                            , VFun "math" "a^2 + b^2 = c^2" { begin = 16, end = 32, id = "e-0.1", index = 1 }
                            , Text "!" { begin = 33, end = 33, id = "e-0.4", index = 4 }
                            ]
                    in
                    Expect.equal expected result
            , test "unclosed bracket produces non-empty result" <|
                -- M7: unclosed bracket — parser should produce output (possibly with error indication)
                \_ ->
                    pe "This is [b"
                        |> List.isEmpty
                        |> Expect.equal False
            , test "unclosed math produces non-empty result" <|
                -- M7: unclosed math — parser should produce output (possibly with error indication)
                \_ ->
                    pe "$x + y"
                        |> List.isEmpty
                        |> Expect.equal False
            , test "empty input produces empty list" <|
                \_ ->
                    pe ""
                        |> Expect.equal []
            , test "nested functions parse correctly" <|
                \_ ->
                    let
                        result =
                            pe "[b [i nested]]"
                    in
                    case result of
                        [ Fun "b" innerExprs _ ] ->
                            case innerExprs of
                                [ Text _ _, Fun "i" [ Text _ _ ] _ ] ->
                                    Expect.pass

                                _ ->
                                    Expect.fail ("Expected [Text, Fun \"i\" [...]] inside [b ...], got: " ++ Debug.toString innerExprs)

                        _ ->
                            Expect.fail ("Expected single Fun \"b\" expression, got: " ++ Debug.toString result)
            , test "parses \\(...\\) as inline math" <|
                \_ ->
                    let
                        result =
                            pe "\\(A\\)"
                    in
                    case result of
                        [ VFun "math" "A" _ ] ->
                            Expect.pass

                        _ ->
                            Expect.fail ("Expected [VFun \"math\" \"A\" _], got: " ++ Debug.toString result)
            , test "parses \\(...\\) with surrounding text" <|
                \_ ->
                    let
                        result =
                            pe "hello \\(x + y\\) world"
                    in
                    case result of
                        [ Text "hello " _, VFun "math" "x + y" _, Text " world" _ ] ->
                            Expect.pass

                        _ ->
                            Expect.fail ("Expected [Text, VFun \"math\", Text], got: " ++ Debug.toString result)
            , test "parses mixed \\(...\\) and $...$ delimiters" <|
                \_ ->
                    let
                        result =
                            pe "\\(A\\) and $B$"
                    in
                    case result of
                        [ VFun "math" "A" _, Text " and " _, VFun "math" "B" _ ] ->
                            Expect.pass

                        _ ->
                            Expect.fail ("Expected [VFun \"math\" \"A\", Text, VFun \"math\" \"B\"], got: " ++ Debug.toString result)
            , test "parses \\(...\\) with backslash macros and nested parens" <|
                \_ ->
                    let
                        result =
                            pe "\\(\\suc\\; (\\suc\\, \\zero) : \\nat\\)"
                    in
                    case result of
                        [ VFun "math" content _ ] ->
                            if String.contains "\\suc" content && String.contains "\\zero" content && String.contains "\\nat" content then
                                Expect.pass

                            else
                                Expect.fail ("Math content missing expected macros, got: " ++ content)

                        _ ->
                            Expect.fail ("Expected [VFun \"math\" _ _], got: " ++ Debug.toString result)
            , test "parses $...$ with backslash macros and nested parens" <|
                \_ ->
                    let
                        result =
                            pe "$\\suc\\; (\\suc\\, \\zero) : \\nat$"
                    in
                    case result of
                        [ VFun "math" content _ ] ->
                            if String.contains "\\suc" content && String.contains "\\zero" content && String.contains "\\nat" content then
                                Expect.pass

                            else
                                Expect.fail ("Math content missing expected macros, got: " ++ content)

                        _ ->
                            Expect.fail ("Expected [VFun \"math\" _ _], got: " ++ Debug.toString result)
            , test "parses [[foo]] as Fun wikilink with single Text arg" <|
                \_ ->
                    let
                        result =
                            pe "[[foo]]"
                    in
                    case result of
                        [ Fun "wikilink" [ Text "foo" _ ] _ ] ->
                            Expect.pass

                        _ ->
                            Expect.fail ("Expected Fun \"wikilink\" [Text \"foo\"], got: " ++ Debug.toString result)
            , test "parses [[foo bar baz]] with first Text arg = ID" <|
                \_ ->
                    let
                        result =
                            pe "[[foo bar baz]]"
                    in
                    case result of
                        [ Fun "wikilink" args _ ] ->
                            case args of
                                (Text "foo" _) :: _ ->
                                    Expect.pass

                                _ ->
                                    Expect.fail ("Expected first arg Text \"foo\" (the ID), got: " ++ Debug.toString args)

                        _ ->
                            Expect.fail ("Expected [Fun \"wikilink\" args _], got: " ++ Debug.toString result)
            , test "parses [[jxxcarlson-202611141744 Plato]] (zku id)" <|
                \_ ->
                    let
                        result =
                            pe "[[jxxcarlson-202611141744 Plato]]"
                    in
                    case result of
                        [ Fun "wikilink" args _ ] ->
                            case args of
                                (Text "jxxcarlson-202611141744" _) :: _ ->
                                    Expect.pass

                                _ ->
                                    Expect.fail ("Expected first arg = zku ID, got: " ++ Debug.toString args)

                        _ ->
                            Expect.fail ("Expected [Fun \"wikilink\" …], got: " ++ Debug.toString result)
            , test "parses [[]] as Fun red with literal [[]]" <|
                \_ ->
                    let
                        result =
                            pe "[[]]"
                    in
                    case result of
                        [ Fun "red" [ Text "[[]]" _ ] _ ] ->
                            Expect.pass

                        _ ->
                            Expect.fail ("Expected [Fun \"red\" [Text \"[[]]\"]], got: " ++ Debug.toString result)
            , test "parses [[   ]] as Fun red with literal [[   ]]" <|
                \_ ->
                    let
                        result =
                            pe "[[   ]]"
                    in
                    case result of
                        [ Fun "red" [ Text "[[   ]]" _ ] _ ] ->
                            Expect.pass

                        _ ->
                            Expect.fail ("Expected [Fun \"red\" [Text \"[[   ]]\"]], got: " ++ Debug.toString result)
            , test "parses [[a [b] c]] as Fun red" <|
                \_ ->
                    let
                        result =
                            pe "[[a [b] c]]"
                    in
                    case result of
                        [ Fun "red" [ Text src _ ] _ ] ->
                            src
                                |> Expect.equal "[[a [b] c]]"

                        _ ->
                            Expect.fail ("Expected [Fun \"red\" [Text ...]], got: " ++ Debug.toString result)
            , test "parses [[a [[b]] c]] as Fun red (nested wikilink malformed)" <|
                \_ ->
                    let
                        result =
                            pe "[[a [[b]] c]]"
                    in
                    case result of
                        [ Fun "red" [ Text src _ ] _ ] ->
                            src
                                |> Expect.equal "[[a [[b]] c]]"

                        _ ->
                            Expect.fail ("Expected [Fun \"red\" [Text \"[[a [[b]] c]]\"]], got: " ++ Debug.toString result)
            , test "parses [[unclosed as Fun red" <|
                \_ ->
                    let
                        result =
                            pe "[[unclosed"
                    in
                    case result of
                        [ Fun "red" [ Text src _ ] _ ] ->
                            src
                                |> Expect.equal "[[unclosed"

                        _ ->
                            Expect.fail ("Expected [Fun \"red\" [Text \"[[unclosed\"]], got: " ++ Debug.toString result)
            , test "parses [foo [[bar]] baz] with wikilink child" <|
                \_ ->
                    let
                        result =
                            pe "[foo [[bar]] baz]"
                    in
                    case result of
                        [ Fun "foo" children _ ] ->
                            let
                                hasWikilinkChild =
                                    List.any
                                        (\child ->
                                            case child of
                                                Fun "wikilink" [ Text "bar" _ ] _ ->
                                                    True

                                                _ ->
                                                    False
                                        )
                                        children
                            in
                            if hasWikilinkChild then
                                Expect.pass

                            else
                                Expect.fail ("Expected a wikilink child, got: " ++ Debug.toString children)

                        _ ->
                            Expect.fail ("Expected [Fun \"foo\" children _], got: " ++ Debug.toString result)
            , test "regression: [italic how is this [bold possible?]] unchanged" <|
                \_ ->
                    let
                        result =
                            pe "[italic how is this [bold possible?]]"
                    in
                    case result of
                        [ Fun "italic" _ _ ] ->
                            Expect.pass

                        _ ->
                            Expect.fail ("Expected [Fun \"italic\" ...], got: " ++ Debug.toString result)
            , test "parses two wikilinks on one line" <|
                \_ ->
                    let
                        result =
                            pe "prefix [[a]] middle [[b]] suffix"

                        wikilinkCount =
                            List.length
                                (List.filter
                                    (\expr ->
                                        case expr of
                                            Fun "wikilink" _ _ ->
                                                True

                                            _ ->
                                                False
                                    )
                                    result
                                )
                    in
                    wikilinkCount
                        |> Expect.equal 2
            ]
        ]
