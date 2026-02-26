module MiniLaTeX.UtilTest exposing (..)

import Expect
import MiniLaTeX.Util exposing (normalizedWord, transformLabel)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "MiniLaTeX.Util"
        [ describe "transformLabel"
            [ test "basic label" <|
                \_ ->
                    transformLabel "[label foo]"
                        |> Expect.equal "\\label{foo}"
            , test "hyphenated label" <|
                \_ ->
                    transformLabel "[label foo-bar]"
                        |> Expect.equal "\\label{foo-bar}"
            , test "no match passthrough" <|
                \_ ->
                    transformLabel "no labels here"
                        |> Expect.equal "no labels here"
            , test "two labels on same line are both transformed" <|
                -- FIXED M6: non-greedy (.*?) now correctly matches each label independently
                \_ ->
                    transformLabel "[label a] and [label b]"
                        |> Expect.equal "\\label{a} and \\label{b}"
            ]
        , describe "normalizedWord"
            [ test "basic normalization" <|
                \_ ->
                    normalizedWord [ "Hello", "World" ]
                        |> Expect.equal "hello-world"
            , test "strips non-alphanumeric" <|
                \_ ->
                    normalizedWord [ "It's", "a", "Test!" ]
                        |> Expect.equal "its-a-test"
            , test "empty input" <|
                \_ ->
                    normalizedWord []
                        |> Expect.equal ""
            ]
        ]
