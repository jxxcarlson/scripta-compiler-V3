module Scripta exposing
    ( Options, defaultOptions
    , withTheme, withWindowWidth, withContentWidth, withTOC, withMaxLevel, withSizing, withFilter
    , Theme(..), Filter(..), SizingConfig, defaultSizing
    )

{-| Public API for the Scripta compiler.


# Options

@docs Options, defaultOptions
@docs withTheme, withWindowWidth, withContentWidth, withTOC, withMaxLevel, withSizing, withFilter
@docs Theme, Filter, SizingConfig, defaultSizing

-}

import Scripta.Internal as Internal exposing (Options(..))
import V3.Types


{-| Opaque compiler options. Build with `defaultOptions` and the `with*`
functions.
-}
type alias Options =
    Internal.Options


{-| Light or dark theme.
-}
type Theme
    = Light
    | Dark


{-| Forest filter. `NoFilter` renders everything; `SuppressDocumentBlocks`
hides `document` and `title` blocks.
-}
type Filter
    = NoFilter
    | SuppressDocumentBlocks


{-| Sizing/spacing configuration (a record).
-}
type alias SizingConfig =
    Internal.SizingConfig


{-| Default sizing configuration.
-}
defaultSizing : SizingConfig
defaultSizing =
    V3.Types.defaultSizingConfig


themeToInternal : Theme -> Internal.Theme
themeToInternal theme =
    case theme of
        Light ->
            Internal.Light

        Dark ->
            Internal.Dark


filterToInternal : Filter -> Internal.Filter
filterToInternal filter =
    case filter of
        NoFilter ->
            Internal.NoFilter

        SuppressDocumentBlocks ->
            Internal.SuppressDocumentBlocks


{-| Default options: no filter, 800px window and content width, light theme,
no table of contents, default sizing, unlimited heading level.
-}
defaultOptions : Options
defaultOptions =
    Internal.Options
        { filter = Internal.NoFilter
        , windowWidth = 800
        , theme = Internal.Light
        , contentWidth = 800
        , showTOC = False
        , sizing = V3.Types.defaultSizingConfig
        , maxLevel = 0
        }


{-| Set the theme.
-}
withTheme : Theme -> Options -> Options
withTheme theme (Internal.Options data) =
    Internal.Options { data | theme = themeToInternal theme }


{-| Set the window width in pixels.
-}
withWindowWidth : Int -> Options -> Options
withWindowWidth w (Internal.Options data) =
    Internal.Options { data | windowWidth = w }


{-| Set the content (text column) width in pixels.
-}
withContentWidth : Int -> Options -> Options
withContentWidth w (Internal.Options data) =
    Internal.Options { data | contentWidth = w }


{-| Show or hide the table of contents.
-}
withTOC : Bool -> Options -> Options
withTOC show (Internal.Options data) =
    Internal.Options { data | showTOC = show }


{-| Set the maximum heading level to render.
-}
withMaxLevel : Int -> Options -> Options
withMaxLevel level (Internal.Options data) =
    Internal.Options { data | maxLevel = level }


{-| Set the sizing configuration.
-}
withSizing : SizingConfig -> Options -> Options
withSizing sizing (Internal.Options data) =
    Internal.Options { data | sizing = sizing }


{-| Set the forest filter.
-}
withFilter : Filter -> Options -> Options
withFilter filter (Internal.Options data) =
    Internal.Options { data | filter = filterToInternal filter }
