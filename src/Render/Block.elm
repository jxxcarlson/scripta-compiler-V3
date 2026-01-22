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
import Types exposing (Accumulator, CompilerParameters, ExpressionBlock, Heading(..), Msg(..), RenderSettings)


{-| Render a block's body content, dispatching based on heading type.
Children are the rendered subtree elements.
-}
renderBody : CompilerParameters -> RenderSettings -> Accumulator -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderBody params settings acc block children =
    case block.heading of
        Paragraph ->
            renderParagraph params settings acc block children

        Ordinary name ->
            Render.OrdinaryBlock.render params settings acc name block children

        Verbatim name ->
            Render.VerbatimBlock.render params settings acc name block children


{-| Render a paragraph block.
-}
renderParagraph : CompilerParameters -> RenderSettings -> Accumulator -> ExpressionBlock -> List (Html Msg) -> List (Html Msg)
renderParagraph params settings acc block children =
    case block.body of
        Left errorMsg ->
            -- Error case - display error message
            [ Html.div
                ([ idAttr block.meta.id
                 , HA.style "color" "red"
                 , HA.style "margin-bottom" (String.fromInt settings.paragraphSpacing ++ "px")
                 ]
                    ++ selectedStyle settings.selectedId block.meta.id settings.theme
                )
                [ Html.text ("Error: " ++ errorMsg) ]
            ]
                ++ children

        Right expressions ->
            if List.isEmpty expressions then
                -- Empty paragraph, just return children
                children

            else
                [ Html.p
                    ([ idAttr block.meta.id
                     , HA.style "margin-bottom" (String.fromInt settings.paragraphSpacing ++ "px")
                     , HA.style "line-height" "1.5"
                     ]
                        ++ selectedStyle settings.selectedId block.meta.id settings.theme
                    )
                    (Render.Expression.renderList params settings acc expressions)
                ]
                    ++ children
