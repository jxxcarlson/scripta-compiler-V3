module Parser.ForestTest exposing (..)

import Dict
import Either exposing (Either(..))
import Expect
import Parser.Forest as PF
import RoseTree.Tree as Tree
import Test exposing (..)
import TestData
import V3.Types exposing (Expr(..), ExpressionBlock, Heading(..))


suite : Test
suite =
    describe "Parser.Forest"
        [ describe "parse"
            [ test "parses str1 into forest of 4 expression blocks" <|
                \_ ->
                    let
                        result =
                            PF.parse (String.lines TestData.str1)
                    in
                    Expect.equal 4 (List.length result)
            , test "first block is a Paragraph with 'This is a test:' firstLine" <|
                \_ ->
                    let
                        result =
                            PF.parse (String.lines TestData.str1)

                        firstBlock =
                            List.head result
                                |> Maybe.map Tree.value
                    in
                    case firstBlock of
                        Just block ->
                            Expect.all
                                [ \b -> Expect.equal Paragraph b.heading
                                , \b -> Expect.equal "This is a test:" b.firstLine
                                , \b -> Expect.equal 0 b.indent
                                ]
                                block

                        Nothing ->
                            Expect.fail "Expected at least one block"
            , test "first block body contains full paragraph text" <|
                \_ ->
                    let
                        result =
                            PF.parse (String.lines TestData.str1)

                        firstBlock =
                            List.head result
                                |> Maybe.map Tree.value
                    in
                    case firstBlock of
                        Just block ->
                            case block.body of
                                Right [ Text text _ ] ->
                                    -- Both lines of the paragraph are now in body
                                    Expect.equal "This is a test:\nOne two three" text

                                Right _ ->
                                    Expect.fail "Expected single Text expression"

                                Left _ ->
                                    Expect.fail "Expected Right with expressions"

                        Nothing ->
                            Expect.fail "Expected at least one block"
            , test "second block is Verbatim 'equation' with body 'a^2 + b^2 = c^2'" <|
                \_ ->
                    let
                        result =
                            PF.parse (String.lines TestData.str1)

                        secondBlock =
                            List.drop 1 result
                                |> List.head
                                |> Maybe.map Tree.value
                    in
                    case secondBlock of
                        Just block ->
                            Expect.all
                                [ \b -> Expect.equal (Verbatim "equation") b.heading
                                , \b ->
                                    case b.body of
                                        Left text ->
                                            Expect.equal "a^2 + b^2 = c^2" text

                                        Right _ ->
                                            Expect.fail "Expected Left with raw text"
                                ]
                                block

                        Nothing ->
                            Expect.fail "Expected at least two blocks"
            , test "third block is Ordinary 'Theorem'" <|
                \_ ->
                    let
                        result =
                            PF.parse (String.lines TestData.str1)

                        thirdBlock =
                            List.drop 2 result
                                |> List.head
                                |> Maybe.map Tree.value
                    in
                    case thirdBlock of
                        Just block ->
                            Expect.all
                                [ \b -> Expect.equal (Ordinary "Theorem") b.heading
                                , \b ->
                                    case b.body of
                                        Right [ Text text _ ] ->
                                            Expect.equal "There are infintelty many primes." text

                                        Right _ ->
                                            Expect.fail "Expected single Text expression"

                                        Left _ ->
                                            Expect.fail "Expected Right with expressions"
                                ]
                                block

                        Nothing ->
                            Expect.fail "Expected at least three blocks"
            , test "fourth block is Verbatim 'math' with body 'int_0^1 x^n dx = frac(1,n+1)'" <|
                \_ ->
                    let
                        result =
                            PF.parse (String.lines TestData.str1)

                        fourthBlock =
                            List.drop 3 result
                                |> List.head
                                |> Maybe.map Tree.value
                    in
                    case fourthBlock of
                        Just block ->
                            Expect.all
                                [ \b -> Expect.equal (Verbatim "math") b.heading
                                , \b ->
                                    case b.body of
                                        Left text ->
                                            Expect.equal "int_0^1 x^n dx = frac(1,n+1)" text

                                        Right _ ->
                                            Expect.fail "Expected Left with raw text"
                                ]
                                block

                        Nothing ->
                            Expect.fail "Expected at least four blocks"
            , test "all blocks have empty children (flat structure)" <|
                \_ ->
                    let
                        result =
                            PF.parse (String.lines TestData.str1)

                        allChildrenEmpty =
                            List.all (\tree -> List.isEmpty (Tree.children tree)) result
                    in
                    Expect.equal True allChildrenEmpty
            , test "blocks have correct id properties" <|
                \_ ->
                    let
                        result =
                            PF.parse (String.lines TestData.str1)

                        ids =
                            List.map (\tree -> Dict.get "id" (Tree.value tree).properties) result
                    in
                    Expect.equal
                        [ Just "1-0", Just "4-1", Just "7-2", Just "10-3" ]
                        ids
            ]
        ]
