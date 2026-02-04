module Render.Utility exposing (idAttr, rlBlockSync, rlSync, selectedStyle)

{-| Utility functions for rendering.
-}

import Html exposing (Attribute)
import Html.Attributes as HA
import Html.Events as HE
import V3.Types exposing (Theme(..))


rlSync : V3.Types.ExprMeta -> List (Html.Attribute V3.Types.Msg)
rlSync meta =
    [ HA.id meta.id
    , HA.attribute "data-begin" (String.fromInt meta.begin)
    , HA.attribute "data-end" (String.fromInt meta.end)
    , HE.onClick (V3.Types.SendMeta meta)
    ]


rlBlockSync : V3.Types.BlockMeta -> List (Html.Attribute V3.Types.Msg)
rlBlockSync blockMeta =
    let
        -- Use expression id format "e-{lineNumber}.0" so mapV3Msg can extract the line number.
        -- Block ids use a different format ("{lineNumber}-{index}") that mapV3Msg can't parse.
        exprId =
            "e-" ++ String.fromInt blockMeta.lineNumber ++ ".0"

        meta =
            { begin = 0, end = String.length blockMeta.sourceText, index = 0, id = exprId }
    in
    [ HA.attribute "data-begin" (String.fromInt meta.begin)
    , HA.attribute "data-end" (String.fromInt meta.end)
    , HE.onClick (V3.Types.SendMeta meta)
    ]


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
