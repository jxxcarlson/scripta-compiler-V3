module Parser.PrimitiveBlockTest exposing (..)

import Dict
import Expect
import Parser.PrimitiveBlock exposing (parse)
import Test exposing (..)
import TestData
import V3.Types exposing (Heading(..))


p : String -> List V3.Types.PrimitiveBlock
p str =
    String.lines str |> parse


{-| Get the character position of the first character of a given line (1-indexed).
-}
linePosition : Int -> String -> Int
linePosition lineNum str =
    String.lines str
        |> List.take (lineNum - 1)
        |> List.map (\line -> String.length line + 1)
        |> List.sum
        |> (+) 1


suite : Test
suite =
    describe "Parser.PrimitiveBlock"
        [ describe "line positions"
            [ test "str1 lines 1, 4, 7, 10 have positions 1, 32, 60, 105" <|
                \_ ->
                    let
                        positions =
                            [ 1, 4, 7, 10 ]
                                |> List.map (\n -> linePosition n TestData.str1)

                        expected =
                            [ 1, 32, 60, 105 ]
                    in
                    Expect.equal expected positions
            ]
        , describe "parse"
            [ test "str1 produces correct headings" <|
                \_ ->
                    let
                        headings =
                            p TestData.str1 |> List.map .heading

                        expected =
                            [ Paragraph
                            , Verbatim "equation"
                            , Ordinary "Theorem"
                            , Verbatim "math"
                            ]
                    in
                    Expect.equal expected headings
            , test "str1 produces correct position, lineNumber, numberOfLines" <|
                \_ ->
                    let
                        metaData =
                            p TestData.str1
                                |> List.map (\block -> ( block.meta.position, block.meta.lineNumber, block.meta.numberOfLines ))

                        expected =
                            [ ( 1, 1, 2 )
                            , ( 32, 4, 2 )
                            , ( 60, 7, 2 )
                            , ( 105, 10, 2 )
                            ]
                    in
                    Expect.equal expected metaData
            ]
        , describe "block source-text offsets (begin/end)"
            [ test "equation block: begin and end bracket the block in source" <|
                \_ ->
                    let
                        source =
                            String.join "\n"
                                [ "1: blah blah"
                                , "2: blah blah"
                                , ""
                                , "| equation"
                                , "a^2 + b^2 = c^2"
                                , ""
                                , "3: blah blah"
                                , "4: blah blah"
                                ]

                        maybeEq =
                            p source
                                |> List.filter (\b -> b.heading == Verbatim "equation")
                                |> List.head
                    in
                    case maybeEq of
                        Nothing ->
                            Expect.fail "Expected an equation block"

                        Just block ->
                            -- "| equation\n" spans offsets 27..37 (10 chars heading + 1 newline);
                            -- "a^2 + b^2 = c^2" spans offsets 38..52 (15 chars).
                            -- So the whole block covers offsets 27..52 (inclusive) / 27..53 (exclusive).
                            Expect.equal ( 27, 53 ) ( block.meta.begin, block.meta.end )
            , test "equation block: slicing source by (begin, end) recovers block text" <|
                \_ ->
                    let
                        source =
                            String.join "\n"
                                [ "1: blah blah"
                                , "2: blah blah"
                                , ""
                                , "| equation"
                                , "a^2 + b^2 = c^2"
                                , ""
                                , "3: blah blah"
                                , "4: blah blah"
                                ]

                        maybeEq =
                            p source
                                |> List.filter (\b -> b.heading == Verbatim "equation")
                                |> List.head
                    in
                    case maybeEq of
                        Nothing ->
                            Expect.fail "Expected an equation block"

                        Just block ->
                            Expect.equal
                                "| equation\na^2 + b^2 = c^2"
                                (String.slice block.meta.begin block.meta.end source)
            , test "equation block body: contentBegin/contentEnd recover \"a^2 + b^2 = c^2\"" <|
                \_ ->
                    let
                        source =
                            String.join "\n"
                                [ "1: blah blah"
                                , "2: blah blah"
                                , ""
                                , "| equation"
                                , "a^2 + b^2 = c^2"
                                , ""
                                , "3: blah blah"
                                , "4: blah blah"
                                ]

                        maybeEq =
                            p source
                                |> List.filter (\b -> b.heading == Verbatim "equation")
                                |> List.head
                    in
                    case maybeEq of
                        Nothing ->
                            Expect.fail "Expected an equation block"

                        Just block ->
                            Expect.equal
                                "a^2 + b^2 = c^2"
                                (String.slice block.meta.contentBegin block.meta.contentEnd source)
            , test "equation block: contentBegin is one line past begin" <|
                \_ ->
                    -- "| equation" is 10 chars; contentBegin = begin + 10 + 1 (newline).
                    let
                        source =
                            String.join "\n"
                                [ "1: blah blah"
                                , "2: blah blah"
                                , ""
                                , "| equation"
                                , "a^2 + b^2 = c^2"
                                , ""
                                , "3: blah blah"
                                , "4: blah blah"
                                ]

                        maybeEq =
                            p source
                                |> List.filter (\b -> b.heading == Verbatim "equation")
                                |> List.head
                    in
                    case maybeEq of
                        Nothing ->
                            Expect.fail "Expected an equation block"

                        Just block ->
                            Expect.equal ( 38, 53 ) ( block.meta.contentBegin, block.meta.contentEnd )
            , test "equation block with multi-line body: contentBegin/contentEnd span all body lines" <|
                \_ ->
                    let
                        source =
                            String.join "\n"
                                [ "| equation"
                                , "a + b"
                                , "  = c"
                                , "  = d"
                                ]

                        maybeEq =
                            p source
                                |> List.filter (\b -> b.heading == Verbatim "equation")
                                |> List.head
                    in
                    case maybeEq of
                        Nothing ->
                            Expect.fail "Expected an equation block"

                        Just block ->
                            Expect.equal
                                "a + b\n  = c\n  = d"
                                (String.slice block.meta.contentBegin block.meta.contentEnd source)
            , test "paragraph block: contentBegin/contentEnd equal begin/end (no header line)" <|
                \_ ->
                    let
                        source =
                            "hello world"

                        maybeBlock =
                            p source |> List.head
                    in
                    case maybeBlock of
                        Nothing ->
                            Expect.fail "Expected a block"

                        Just block ->
                            Expect.equal
                                ( block.meta.begin, block.meta.end )
                                ( block.meta.contentBegin, block.meta.contentEnd )
            , test "$$ math block: contentBegin skips the \"$$\" header line" <|
                \_ ->
                    let
                        source =
                            "$$\nx^2 + y^2"

                        maybeBlock =
                            p source
                                |> List.filter (\b -> b.heading == Verbatim "math")
                                |> List.head
                    in
                    case maybeBlock of
                        Nothing ->
                            Expect.fail "Expected a math block"

                        Just block ->
                            Expect.equal
                                "x^2 + y^2"
                                (String.slice block.meta.contentBegin block.meta.contentEnd source)
            , test "equation block: end - begin equals sourceText length" <|
                \_ ->
                    let
                        source =
                            String.join "\n"
                                [ "1: blah blah"
                                , "2: blah blah"
                                , ""
                                , "| equation"
                                , "a^2 + b^2 = c^2"
                                , ""
                                , "3: blah blah"
                                , "4: blah blah"
                                ]

                        maybeEq =
                            p source
                                |> List.filter (\b -> b.heading == Verbatim "equation")
                                |> List.head
                    in
                    case maybeEq of
                        Nothing ->
                            Expect.fail "Expected an equation block"

                        Just block ->
                            Expect.equal
                                (String.length block.meta.sourceText)
                                (block.meta.end - block.meta.begin)
            , test "paragraph block: single-line sourceText slice matches source" <|
                \_ ->
                    let
                        source =
                            "hello world"

                        maybeBlock =
                            p source |> List.head
                    in
                    case maybeBlock of
                        Nothing ->
                            Expect.fail "Expected a block"

                        Just block ->
                            Expect.equal
                                "hello world"
                                (String.slice block.meta.begin block.meta.end source)
            ]
        , describe "extended header syntax (multi-line)"
            [ test "single line args and properties (backward compatibility)" <|
                \_ ->
                    let
                        input =
                            "| image width:400 caption:Test\nhttps://example.com/img.jpg\n"

                        blocks =
                            p input

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Verbatim "image")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just []) (Maybe.map .args b)
                        , \b -> Expect.equal (Just (Dict.fromList [ ( "width", "400" ), ( "caption", "Test" ) ])) (Maybe.map .properties b)
                        ]
                        block
            , test "multi-line properties only" <|
                \_ ->
                    let
                        blocks =
                            p TestData.multiLineHeader1

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Verbatim "image")) (Maybe.map .heading b)
                        , \b ->
                            Expect.equal
                                (Just (Dict.fromList [ ( "width", "400" ), ( "caption", "A beautiful sunset" ), ( "alt", "Sunset over mountains" ) ]))
                                (Maybe.map .properties b)
                        , \b -> Expect.equal (Just [ "https://example.com/sunset.jpg" ]) (Maybe.map .body b)
                        ]
                        block
            , test "multi-line args and properties" <|
                \_ ->
                    let
                        blocks =
                            p TestData.multiLineHeader2

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Ordinary "theorem")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just [ "numbered" ]) (Maybe.map .args b)
                        , \b ->
                            Expect.equal
                                (Just (Dict.fromList [ ( "label", "main-theorem" ), ( "title", "Main Result" ) ]))
                                (Maybe.map .properties b)
                        , \b -> Expect.equal (Just [ "There are infinitely many primes." ]) (Maybe.map .body b)
                        ]
                        block
            , test "verbatim block multi-line header" <|
                \_ ->
                    let
                        blocks =
                            p TestData.multiLineHeader3

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Verbatim "code")) (Maybe.map .heading b)
                        , \b ->
                            Expect.equal
                                (Just (Dict.fromList [ ( "lang", "elm" ), ( "highlight", "1-5" ) ]))
                                (Maybe.map .properties b)
                        ]
                        block
            , test "multi-line args only" <|
                \_ ->
                    let
                        blocks =
                            p TestData.multiLineArgs

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Ordinary "block")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just [ "arg1", "arg2", "arg3", "arg4" ]) (Maybe.map .args b)
                        , \b -> Expect.equal (Just [ "Body content" ]) (Maybe.map .body b)
                        ]
                        block
            , test "multi-line mixed args and properties" <|
                \_ ->
                    let
                        blocks =
                            p TestData.multiLineMixed

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Ordinary "theorem")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just [ "numbered" ]) (Maybe.map .args b)
                        , \b ->
                            Expect.equal
                                (Just (Dict.fromList [ ( "label", "pythagoras" ), ( "title", "Pythagorean Theorem" ) ]))
                                (Maybe.map .properties b)
                        ]
                        block
            , test "backward compatibility - section block" <|
                \_ ->
                    let
                        input =
                            "| section 1\nIntroduction\n"

                        blocks =
                            p input

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Ordinary "section")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just [ "1" ]) (Maybe.map .args b)
                        ]
                        block
            , test "backward compatibility - equation with label" <|
                \_ ->
                    let
                        input =
                            "| equation label:eq1\na^2 + b^2 = c^2\n"

                        blocks =
                            p input

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Verbatim "equation")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just (Dict.fromList [ ( "label", "eq1" ) ])) (Maybe.map .properties b)
                        ]
                        block
            , test "numberOfLines includes continuation lines" <|
                \_ ->
                    let
                        blocks =
                            p TestData.multiLineHeader1

                        block =
                            List.head blocks
                    in
                    -- 4 lines: header + 2 continuations + body
                    Expect.equal (Just 4) (Maybe.map (\b -> b.meta.numberOfLines) block)
            , test "table is parsed as verbatim block" <|
                -- M14: table is in verbatimNames
                \_ ->
                    let
                        blocks =
                            p "| table\ncol1\n"

                        block =
                            List.head blocks
                    in
                    Expect.equal (Just (Verbatim "table")) (Maybe.map .heading block)
            , test "code is parsed as verbatim block" <|
                \_ ->
                    let
                        blocks =
                            p "| code\nfoo\n"

                        block =
                            List.head blocks
                    in
                    Expect.equal (Just (Verbatim "code")) (Maybe.map .heading block)
            , test "block name alone on first line, then continuation lines" <|
                \_ ->
                    let
                        blocks =
                            p TestData.userTestCase

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Ordinary "theorem")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just [ "foo", "bar" ]) (Maybe.map .args b)
                        , \b ->
                            Expect.equal
                                (Just (Dict.fromList [ ( "title", "Pythagorean theorem" ), ( "label", "pyth" ) ]))
                                (Maybe.map .properties b)
                        , \b -> Expect.equal (Just [ "a^2 + b^2 = c^2" ]) (Maybe.map .body b)
                        ]
                        block
            , test "verbatim block: | unknown_name in body is NOT a continuation" <|
                \_ ->
                    let
                        blocks =
                            p TestData.codeWithPipeInBody

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Verbatim "code")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just []) (Maybe.map .args b)
                        , \b ->
                            Expect.equal
                                (Just [ "  | bibitem einstein1905a", "  Albert Einstein, blah blah" ])
                                (Maybe.map .body b)
                        ]
                        block
            , test "verbatim block: | unknown_name (no indent) is NOT a continuation" <|
                \_ ->
                    let
                        blocks =
                            p TestData.codeWithPipeInBodyNoIndent

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Verbatim "code")) (Maybe.map .heading b)
                        , \b -> Expect.equal (Just []) (Maybe.map .args b)
                        , \b ->
                            Expect.equal
                                (Just [ "| foo bar", "yada yada" ])
                                (Maybe.map .body b)
                        ]
                        block
            , test "verbatim block: property continuation works, then | line is body" <|
                \_ ->
                    let
                        blocks =
                            p TestData.codeWithPropertyThenPipeBody

                        block =
                            List.head blocks
                    in
                    Expect.all
                        [ \b -> Expect.equal (Just (Verbatim "code")) (Maybe.map .heading b)
                        , \b ->
                            Expect.equal
                                (Just (Dict.fromList [ ( "lang", "elm" ), ( "highlight", "1-5" ) ]))
                                (Maybe.map .properties b)
                        , \b ->
                            Expect.equal
                                (Just [ "| bibitem foo", "module Main exposing (..)" ])
                                (Maybe.map .body b)
                        ]
                        block
            ]
        ]
