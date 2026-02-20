module Render.Utility exposing (blockIdAndStyle, getArg, highlightStyle, idAttr, rlBlockSync, rlSync, selectedStyle)

{-| Utility functions for rendering.
-}

import Dict
import Html exposing (Attribute)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as Decode
import List.Extra
import Render.Constants
import V3.Types exposing (CompilerParameters, ExpressionBlock, Msg, Theme(..))


rlSync : V3.Types.ExprMeta -> List (Html.Attribute V3.Types.Msg)
rlSync meta =
    [ HA.id meta.id
    , HA.attribute "data-begin" (String.fromInt meta.begin)
    , HA.attribute "data-end" (String.fromInt meta.end)
    , HE.stopPropagationOn "click"
        (Decode.field "altKey" Decode.bool
            |> Decode.andThen
                (\altKey ->
                    if altKey then
                        -- Option held: fire SendMeta (Path A data needed by Path B),
                        -- but DON'T stop propagation so click reaches container
                        -- for RequestAnchorOffset (Path B)
                        Decode.succeed ( V3.Types.SendMeta meta, False )

                    else
                        -- Plain click: fire SendMeta, stop propagation
                        Decode.succeed ( V3.Types.SendMeta meta, True )
                )
        )
    ]


rlBlockSync : V3.Types.BlockMeta -> List (Html.Attribute V3.Types.Msg)
rlBlockSync blockMeta =
    [ HA.attribute "data-begin" "0"
    , HA.attribute "data-end" "0"
    , HE.stopPropagationOn "click"
        (Decode.field "altKey" Decode.bool
            |> Decode.andThen
                (\altKey ->
                    if altKey then
                        -- Option held: fire SendBlockMeta so editorData has correct
                        -- block info for Path B; don't stop propagation so click
                        -- reaches container for RequestAnchorOffset
                        Decode.succeed ( V3.Types.SendBlockMeta blockMeta, False )

                    else
                        -- Plain click: fire SendBlockMeta, stop propagation
                        Decode.succeed ( V3.Types.SendBlockMeta blockMeta, True )
                )
        )
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
            [ HA.style "background-color" Render.Constants.highlightColor ]

        Dark ->
            [ HA.style "background-color" Render.Constants.highlightColorDark ]


{-| Compute the DOM id and highlight style for a block.

If the block has a `mark` property, use its value as the DOM id
and apply highlight style when selectedId matches or is "__ALL_MARKS__".
Otherwise, fall back to the block's meta id with normal selection style.

-}
blockIdAndStyle : CompilerParameters -> ExpressionBlock -> List (Attribute Msg)
blockIdAndStyle params block =
    case Dict.get "mark" block.properties of
        Just markId ->
            [ HA.id markId ]
                ++ (if params.selectedId == "__ALL_MARKS__" then
                        highlightStyle params.theme

                    else if params.selectedId == markId then
                        highlightStyle params.theme

                    else
                        selectedStyle params.selectedId block.meta.id params.theme
                   )

        Nothing ->
            [ HA.id block.meta.id ]
                ++ selectedStyle params.selectedId block.meta.id params.theme


getArg : String -> Int -> List String -> String
getArg default index args =
    case List.Extra.getAt index args of
        Nothing ->
            default

        Just a ->
            a
