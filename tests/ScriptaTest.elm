module ScriptaTest exposing (suite)

import Expect
import Scripta
import Scripta.Internal as Internal
import Test exposing (Test, describe, test)
import V3.Types


suite : Test
suite =
    describe "Scripta"
        [ describe "Options builders"
            [ test "defaultOptions has NoFilter" <|
                \_ ->
                    Internal.optionsToParams Scripta.defaultOptions
                        |> .filter
                        |> Expect.equal V3.Types.NoFilter
            , test "withTheme Dark sets the theme" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withTheme Scripta.Dark
                        |> Internal.optionsToParams
                        |> .theme
                        |> Expect.equal V3.Types.Dark
            , test "withWindowWidth sets windowWidth" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withWindowWidth 750
                        |> Internal.optionsToParams
                        |> .windowWidth
                        |> Expect.equal 750
            , test "withContentWidth sets width" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withContentWidth 640
                        |> Internal.optionsToParams
                        |> .width
                        |> Expect.equal 640
            , test "withTOC sets showTOC" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withTOC True
                        |> Internal.optionsToParams
                        |> .showTOC
                        |> Expect.equal True
            , test "withMaxLevel sets maxLevel" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withMaxLevel 3
                        |> Internal.optionsToParams
                        |> .maxLevel
                        |> Expect.equal 3
            , test "withSizing sets the sizing configuration" <|
                \_ ->
                    let
                        customSizing =
                            { baseFontSize = 16.0
                            , paragraphSpacing = 20.0
                            , marginLeft = 4.0
                            , marginRight = 8.0
                            , indentation = 24.0
                            , indentUnit = 3
                            , scale = 1.5
                            }
                    in
                    Scripta.defaultOptions
                        |> Scripta.withSizing customSizing
                        |> Internal.optionsToParams
                        |> .sizing
                        |> Expect.equal customSizing
            , test "withFilter sets the forest filter" <|
                \_ ->
                    Scripta.defaultOptions
                        |> Scripta.withFilter Scripta.SuppressDocumentBlocks
                        |> Internal.optionsToParams
                        |> .filter
                        |> Expect.equal V3.Types.SuppressDocumentBlocks
            , test "builders compose without clobbering" <|
                \_ ->
                    let
                        params =
                            Scripta.defaultOptions
                                |> Scripta.withTheme Scripta.Dark
                                |> Scripta.withWindowWidth 800
                                |> Internal.optionsToParams
                    in
                    Expect.equal ( params.theme, params.windowWidth )
                        ( V3.Types.Dark, 800 )
            ]
        , describe "pipeline"
            [ test "compile produces a non-empty body" <|
                \_ ->
                    Scripta.compile Scripta.defaultOptions "Hello [strong world]."
                        |> .body
                        |> List.isEmpty
                        |> Expect.equal False
            , test "parse then render produces a non-empty body" <|
                \_ ->
                    let
                        doc =
                            Scripta.parse Scripta.defaultOptions "Hello world."
                    in
                    Scripta.render Scripta.defaultOptions doc
                        |> .body
                        |> List.isEmpty
                        |> Expect.equal False
            , test "reparse of an edited document produces a non-empty body" <|
                \_ ->
                    let
                        doc0 =
                            Scripta.parse Scripta.defaultOptions "First paragraph.\n\nSecond paragraph."

                        doc1 =
                            Scripta.reparse Scripta.defaultOptions doc0 "First paragraph edited.\n\nSecond paragraph."
                    in
                    Scripta.render Scripta.defaultOptions doc1
                        |> .body
                        |> List.isEmpty
                        |> Expect.equal False
            ]
        ]
