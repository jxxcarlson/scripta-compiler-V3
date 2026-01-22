module Parser.PrimitiveBlockTest exposing (..)

import Expect
import Parser.PrimitiveBlock exposing (parse)
import Test exposing (..)
import TestData
import Types exposing (Heading(..))


p : String -> List Types.PrimitiveBlock
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
        ]
