module Render.Utility exposing (blockIdAndStyle, getArg, idAttr, rlBlockSync, rlSync)

{-| Utility functions for rendering.
-}

import Dict
import Html exposing (Attribute)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as Decode
import List.Extra
import V3.Types exposing (ExpressionBlock, Msg)


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


{-| Compute the DOM id and CSS class for a block.

If the block has a `mark` property, use its value as the DOM id
and add a "scripta-mark" class for CSS-based highlighting.
Otherwise, fall back to the block's meta id.

Selection highlighting is handled via a dynamic <style> element
in the host app, not inline styles.

-}
blockIdAndStyle : ExpressionBlock -> List (Attribute Msg)
blockIdAndStyle block =
    case Dict.get "mark" block.properties of
        Just markId ->
            [ HA.id markId, HA.class "scripta-mark" ]

        Nothing ->
            [ HA.id block.meta.id ]


getArg : String -> Int -> List String -> String
getArg default index args =
    case List.Extra.getAt index args of
        Nothing ->
            default

        Just a ->
            a
