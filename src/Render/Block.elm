module Render.Block exposing (renderBody)

{-| Render blocks by dispatching on Heading type.
-}

import Either exposing (Either(..))
import Html exposing (Html)
import Html.Attributes as HA
import Render.Expression
import Render.OrdinaryBlock
import Render.Utility exposing (idAttr, selectedStyle)
import Render.VerbatimBlock
import Types exposing (Accumulator, CompilerParameters, ExpressionBlock, Heading(..), Msg(..))


{-| Render a block's body content, dispatching based on heading type.
Children are the rendered subtree elements.
-}
renderBody : CompilerParameters -> Accumulator -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderBody params acc block children =
    case block.heading of
        Paragraph ->
            renderParagraph params acc block children

        Ordinary name ->
            Render.OrdinaryBlock.render params acc name block children

        Verbatim name ->
            Render.VerbatimBlock.render params acc name block children


{-| Render a paragraph block.
-}
renderParagraph : CompilerParameters -> Accumulator -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderParagraph params acc block children =
    case block.body of
        Left errorMsg ->
            -- Error case - display error message
            Html.div
                ([ idAttr block.meta.id
                 , HA.style "color" "red"
                 , HA.style "margin-bottom" (String.fromInt params.paragraphSpacing ++ "px")
                 ]
                    ++ selectedStyle params.selectedId block.meta.id params.theme
                )
                [ Html.text ("Error: " ++ errorMsg) ]
                :: children

        Right expressions ->
            if List.isEmpty expressions then
                -- Empty paragraph, just return children
                children

            else
                Html.p
                    ([ idAttr block.meta.id
                     , HA.style "margin-bottom" (String.fromInt params.paragraphSpacing ++ "px")
                     , HA.style "line-height" "1.5"
                     ]
                        ++ selectedStyle params.selectedId block.meta.id params.theme
                    )
                    (Render.Expression.renderList params acc expressions)
                    :: children
