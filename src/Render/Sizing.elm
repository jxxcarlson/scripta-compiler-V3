module Render.Sizing exposing
    ( codeSize
    , itemSpacingPx
    , paragraphSpacingPx
    , scaled
    , toEm
    , toPx
    )

{-| Helper functions for sizing and spacing calculations.
All sizes in px (Float), with a scale multiplier for global adjustments.
-}

import V3.Types exposing (SizingConfig)


{-| Apply scale multiplier to a pixel value.
-}
scaled : SizingConfig -> Float -> Float
scaled config px =
    px * config.scale


{-| Convert a pixel value to a CSS px string, applying scale.
Example: toPx config 18.0 -> "18px" (or "21.6px" if scale is 1.2)
-}
toPx : SizingConfig -> Float -> String
toPx config px =
    String.fromFloat (scaled config px) ++ "px"


{-| Convert to CSS em string. Em values are NOT scaled since they're already relative.
Example: toEm config 1.5 -> "1.5em"
-}
toEm : SizingConfig -> Float -> String
toEm _ em =
    String.fromFloat em ++ "em"


{-| Get paragraph spacing as a CSS px string, applying scale.
-}
paragraphSpacingPx : SizingConfig -> String
paragraphSpacingPx config =
    toPx config config.paragraphSpacing


{-| Get item spacing (for list items) as a CSS px string.
Item spacing is 2/3 of paragraph spacing, with a minimum of 4px.
-}
itemSpacingPx : SizingConfig -> String
itemSpacingPx config =
    let
        itemSpacing =
            max 4.0 (config.paragraphSpacing * 2.0 / 3.0)
    in
    toPx config itemSpacing


{-| Get code font size as a CSS px string.
Code size is 93% of base font size, scaled.
-}
codeSize : SizingConfig -> String
codeSize config =
    toPx config (config.baseFontSize * 0.93)
