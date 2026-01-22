module Render.Utility exposing (highlightStyle, idAttr, makeId, selectedStyle)

{-| Utility functions for rendering.
-}

import Html exposing (Attribute)
import Html.Attributes as HA
import Types exposing (Theme(..))


{-| Create an id attribute from block id.
-}
idAttr : String -> Attribute msg
idAttr id =
    HA.id id


{-| Make an ID string from components.
-}
makeId : String -> String -> String
makeId prefix suffix =
    prefix ++ "-" ++ suffix


{-| Style for selected element.
-}
selectedStyle : String -> String -> Theme -> List (Attribute msg)
selectedStyle selectedId blockId theme =
    if selectedId == blockId then
        case theme of
            Light ->
                [ HA.style "background-color" "#d0e8ff" ]

            Dark ->
                [ HA.style "background-color" "#2a4a6a" ]

    else
        []


{-| Style for highlighted element.
-}
highlightStyle : Theme -> List (Attribute msg)
highlightStyle theme =
    case theme of
        Light ->
            [ HA.style "background-color" "#ffffcc" ]

        Dark ->
            [ HA.style "background-color" "#4a4a00" ]
