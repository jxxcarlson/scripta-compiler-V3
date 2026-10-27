module ScriptaSizingTest exposing (suite)

import Expect
import Render.Sizing as Sz
import Test exposing (..)
import V3.Types exposing (defaultSizingConfig)


suite : Test
suite =
    describe "Render.Sizing (phase 3 additions)"
        [ test "lineHeight returns the unitless ratio from config" <|
            \_ ->
                Expect.equal "1.5" (Sz.lineHeight defaultSizingConfig)
        , test "bodyFontSizePx is baseFontSize in px" <|
            \_ ->
                Expect.equal "14px" (Sz.bodyFontSizePx defaultSizingConfig)
        , test "headingSizePx level 1 is baseFontSize * headingScale[0]" <|
            \_ ->
                Expect.equal "21px" (Sz.headingSizePx 1 defaultSizingConfig)
        , test "headingSizePx beyond the list falls back to ratio 1.0" <|
            \_ ->
                Expect.equal "14px" (Sz.headingSizePx 99 defaultSizingConfig)
        ]
