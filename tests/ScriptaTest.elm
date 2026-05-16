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
        ]
