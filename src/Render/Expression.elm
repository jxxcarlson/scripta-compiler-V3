module Render.Expression exposing (render, renderList)

{-| Render expressions to HTML.
-}

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Render.Math exposing (DisplayMode(..), mathText)
import Types exposing (Accumulator, CompilerParameters, Expr(..), ExprMeta, Expression, Msg(..), RenderSettings)


{-| Render a list of expressions.
-}
renderList : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> List (Html Msg)
renderList params settings acc expressions =
    List.map (render params settings acc) expressions


{-| Render a single expression.
-}
render : CompilerParameters -> RenderSettings -> Accumulator -> Expression -> Html Msg
render params settings acc expr =
    case expr of
        Text str meta ->
            renderText str meta

        Fun name args meta ->
            renderFun params settings acc name args meta

        VFun name content meta ->
            renderVFun params settings acc name content meta

        ExprList _ exprs meta ->
            Html.span [ HA.id meta.id ]
                (renderList params settings acc exprs)


{-| Render plain text.
-}
renderText : String -> ExprMeta -> Html Msg
renderText str meta =
    Html.span
        [ HA.id meta.id
        , HE.onClick (SelectId meta.id)
        ]
        [ Html.text str ]


{-| Render a function application.
-}
renderFun : CompilerParameters -> RenderSettings -> Accumulator -> String -> List Expression -> ExprMeta -> Html Msg
renderFun params settings acc name args meta =
    case Dict.get name markupDict of
        Just renderer ->
            renderer params settings acc args meta

        Nothing ->
            -- Default rendering for unknown functions
            renderDefaultFun params settings acc name args meta


{-| Render a verbatim function.
-}
renderVFun : CompilerParameters -> RenderSettings -> Accumulator -> String -> String -> ExprMeta -> Html Msg
renderVFun params settings acc name content meta =
    case name of
        "$" ->
            -- Inline math (legacy)
            mathText settings.editCount meta.id InlineMathMode content

        "math" ->
            -- Inline math
            mathText settings.editCount meta.id InlineMathMode content

        "code" ->
            Html.code [ HA.id meta.id ] [ Html.text content ]

        _ ->
            -- Default: just show the content
            Html.span [ HA.id meta.id ] [ Html.text content ]


{-| Default rendering for unknown function names.
-}
renderDefaultFun : CompilerParameters -> RenderSettings -> Accumulator -> String -> List Expression -> ExprMeta -> Html Msg
renderDefaultFun params settings acc name args meta =
    Html.span [ HA.id meta.id ]
        (Html.span [ HA.style "color" "blue" ] [ Html.text ("[" ++ name ++ " ") ]
            :: renderList params settings acc args
            ++ [ Html.text "]" ]
        )



-- MARKUP DICTIONARY


{-| Dictionary of markup function renderers.
-}
markupDict : Dict String (CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg)
markupDict =
    Dict.fromList
        [ ( "strong", renderStrong )
        , ( "bold", renderStrong )
        , ( "b", renderStrong )
        , ( "italic", renderItalic )
        , ( "i", renderItalic )
        , ( "emph", renderItalic )
        , ( "strike", renderStrike )
        , ( "underline", renderUnderline )
        , ( "red", renderColor "red" )
        , ( "blue", renderColor "blue" )
        , ( "green", renderColor "green" )
        , ( "highlight", renderHighlight )
        , ( "link", renderLink )
        , ( "href", renderHref )
        , ( "image", renderImage )
        , ( "ilink", renderIlink )
        , ( "index", renderIndex )
        , ( "ref", renderRef )
        , ( "eqref", renderEqRef )
        , ( "cite", renderCite )
        , ( "sup", renderSup )
        , ( "sub", renderSub )
        ]



-- MARKUP RENDERERS


renderStrong : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderStrong params settings acc args meta =
    Html.strong [ HA.id meta.id ] (renderList params settings acc args)


renderItalic : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderItalic params settings acc args meta =
    Html.em [ HA.id meta.id ] (renderList params settings acc args)


renderStrike : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderStrike params settings acc args meta =
    Html.span [ HA.id meta.id, HA.style "text-decoration" "line-through" ] (renderList params settings acc args)


renderUnderline : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderUnderline params settings acc args meta =
    Html.span [ HA.id meta.id, HA.style "text-decoration" "underline" ] (renderList params settings acc args)


renderColor : String -> CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderColor color params settings acc args meta =
    Html.span [ HA.id meta.id, HA.style "color" color ] (renderList params settings acc args)


renderHighlight : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderHighlight params settings acc args meta =
    Html.span [ HA.id meta.id, HA.style "background-color" "yellow" ] (renderList params settings acc args)


renderLink : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderLink params settings acc args meta =
    case args of
        [ Text label _, Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text label ]

        [ Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text url ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params settings acc args)


renderHref : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderHref params settings acc args meta =
    case args of
        [ Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text url ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params settings acc args)


renderImage : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderImage _ settings _ args meta =
    case args of
        [ Text src _ ] ->
            Html.img
                [ HA.id meta.id
                , HA.src src
                , HA.style "max-width" (String.fromInt settings.width ++ "px")
                ]
                []

        _ ->
            Html.text "[image: invalid args]"


renderIlink : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderIlink params settings acc args meta =
    -- Internal link - render as link with SelectId message
    case args of
        [ Text label _, Text targetId _ ] ->
            Html.a
                [ HA.id meta.id
                , HA.href ("#" ++ targetId)
                , HE.onClick (SelectId targetId)
                ]
                [ Html.text label ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params settings acc args)


renderIndex : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderIndex _ _ _ _ meta =
    -- Index entries are invisible in the output
    Html.span [ HA.id meta.id, HA.style "display" "none" ] []


renderRef : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderRef _ _ acc args meta =
    case args of
        [ Text refId _ ] ->
            case Dict.get refId acc.reference of
                Just { numRef } ->
                    Html.a
                        [ HA.id meta.id
                        , HA.href ("#" ++ refId)
                        , HE.onClick (SelectId refId)
                        ]
                        [ Html.text numRef ]

                Nothing ->
                    Html.span [ HA.id meta.id, HA.style "color" "red" ] [ Html.text ("??" ++ refId) ]

        _ ->
            Html.span [ HA.id meta.id ] [ Html.text "[ref: invalid]" ]


renderEqRef : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderEqRef _ _ acc args meta =
    case args of
        [ Text refId _ ] ->
            case Dict.get refId acc.reference of
                Just { numRef } ->
                    Html.a
                        [ HA.id meta.id
                        , HA.href ("#" ++ refId)
                        , HE.onClick (SelectId refId)
                        ]
                        [ Html.text ("(" ++ numRef ++ ")") ]

                Nothing ->
                    Html.span [ HA.id meta.id, HA.style "color" "red" ] [ Html.text ("(??" ++ refId ++ ")") ]

        _ ->
            Html.span [ HA.id meta.id ] [ Html.text "[eqref: invalid]" ]


renderCite : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderCite params settings acc args meta =
    case args of
        [ Text key _ ] ->
            Html.span [ HA.id meta.id ] [ Html.text ("[" ++ key ++ "]") ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params settings acc args)


renderSup : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderSup params settings acc args meta =
    Html.sup [ HA.id meta.id ] (renderList params settings acc args)


renderSub : CompilerParameters -> RenderSettings -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderSub params settings acc args meta =
    Html.sub [ HA.id meta.id ] (renderList params settings acc args)
