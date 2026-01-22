module Render.Math exposing (DisplayMode(..), mathText)

{-| Math rendering using math-text custom web component.
-}

import Html exposing (Html)
import Html.Attributes as HA
import Html.Keyed
import Json.Encode as Encode


{-| Display mode for math: inline or display.
-}
type DisplayMode
    = InlineMathMode
    | DisplayMathMode


{-| Render math using the math-text custom element.
The generation parameter ensures KaTeX re-renders on content changes.
-}
mathText : Int -> String -> DisplayMode -> String -> Html msg
mathText generation id displayMode content =
    Html.Keyed.node "span"
        []
        [ ( String.fromInt generation ++ "-" ++ id
          , Html.node "math-text"
                [ HA.property "display" (Encode.bool (displayMode == DisplayMathMode))
                , HA.property "content" (Encode.string content)
                , HA.id id
                ]
                []
          )
        ]


{-| Render inline math.
-}
inlineMath : Int -> String -> String -> Html msg
inlineMath generation id content =
    mathText generation id InlineMathMode content


{-| Render display math.
-}
displayMath : Int -> String -> String -> Html msg
displayMath generation id content =
    mathText generation id DisplayMathMode content
