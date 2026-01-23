module Render.Expression exposing (renderList)

{-| Render expressions to HTML.
-}

import Dict exposing (Dict)
import ETeX.Transform
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Render.Math exposing (DisplayMode(..), mathText)
import Types exposing (Accumulator, CompilerParameters, Expr(..), ExprMeta, Expression, Msg(..))


{-| Render a list of expressions.
-}
renderList : CompilerParameters -> Accumulator -> List Expression -> List (Html Msg)
renderList params acc expressions =
    List.map (render params acc) expressions


{-| Render a single expression.
-}
render : CompilerParameters -> Accumulator -> Expression -> Html Msg
render params acc expr =
    case expr of
        Text str meta ->
            renderText str meta

        Fun name args meta ->
            renderFun params acc name args meta

        VFun name content meta ->
            renderVFun params acc name content meta

        ExprList _ exprs meta ->
            Html.span [ HA.id meta.id ]
                (renderList params acc exprs)


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
renderFun : CompilerParameters -> Accumulator -> String -> List Expression -> ExprMeta -> Html Msg
renderFun params acc name args meta =
    case Dict.get name markupDict of
        Just renderer ->
            renderer params acc args meta

        Nothing ->
            -- Default rendering for unknown functions
            renderDefaultFun params acc name args meta


{-| Render a verbatim function.
-}
renderVFun : CompilerParameters -> Accumulator -> String -> String -> ExprMeta -> Html Msg
renderVFun params acc name content meta =
    case name of
        "$" ->
            -- Inline math (legacy) - apply ETeX transform
            mathText params.editCount meta.id InlineMathMode (applyETeXTransform content)

        "math" ->
            -- Inline math - apply ETeX transform
            mathText params.editCount meta.id InlineMathMode (applyETeXTransform content)

        "code" ->
            Html.code [ HA.id meta.id ] [ Html.text content ]

        _ ->
            -- Default: just show the content
            Html.span [ HA.id meta.id ] [ Html.text content ]


{-| Transform ETeX notation to LaTeX using ETeX.Transform.evalStr.

Converts notation like `int_0^2`, `frac(1,n+1)` to `\int_0^2`, `\frac{1}{n+1}`.

-}
applyETeXTransform : String -> String
applyETeXTransform content =
    ETeX.Transform.evalStr Dict.empty content


{-| Default rendering for unknown function names.
-}
renderDefaultFun : CompilerParameters -> Accumulator -> String -> List Expression -> ExprMeta -> Html Msg
renderDefaultFun params acc name args meta =
    Html.span [ HA.id meta.id ]
        (Html.span [ HA.style "color" "blue" ] [ Html.text ("[" ++ name ++ " ") ]
            :: renderList params acc args
            ++ [ Html.text "]" ]
        )



-- MARKUP DICTIONARY


{-| Dictionary of markup function renderers.
-}
markupDict : Dict String (CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg)
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
        , ( "term", renderTerm )
        , ( "term_", renderTermHidden )
        , ( "vspace", renderVspace )
        , ( "break", renderVspace )
        ]



-- MARKUP RENDERERS


renderStrong : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderStrong params acc args meta =
    Html.strong [ HA.id meta.id ] (renderList params acc args)


renderItalic : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderItalic params acc args meta =
    Html.em [ HA.id meta.id ] (renderList params acc args)


renderStrike : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderStrike params acc args meta =
    Html.span [ HA.id meta.id, HA.style "text-decoration" "line-through" ] (renderList params acc args)


renderUnderline : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderUnderline params acc args meta =
    Html.span [ HA.id meta.id, HA.style "text-decoration" "underline" ] (renderList params acc args)


renderColor : String -> CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderColor color params acc args meta =
    Html.span [ HA.id meta.id, HA.style "color" color ] (renderList params acc args)


renderHighlight : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderHighlight params acc args meta =
    Html.span [ HA.id meta.id, HA.style "background-color" "yellow" ] (renderList params acc args)


renderLink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderLink params acc args meta =
    case args of
        [ Text label _, Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text label ]

        [ Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text url ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params acc args)


renderHref : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderHref params acc args meta =
    case args of
        [ Text url _ ] ->
            Html.a [ HA.id meta.id, HA.href url, HA.target "_blank" ] [ Html.text url ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params acc args)


renderImage : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderImage params _ args meta =
    case args of
        [ Text src _ ] ->
            Html.img
                [ HA.id meta.id
                , HA.src src
                , HA.style "max-width" (String.fromInt params.width ++ "px")
                ]
                []

        _ ->
            Html.text "[image: invalid args]"


renderIlink : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderIlink params acc args meta =
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
            Html.span [ HA.id meta.id ] (renderList params acc args)


renderIndex : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderIndex _ _ _ meta =
    -- Index entries are invisible in the output
    Html.span [ HA.id meta.id, HA.style "display" "none" ] []


renderRef : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderRef _ acc args meta =
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


renderEqRef : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderEqRef _ acc args meta =
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


renderCite : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderCite params acc args meta =
    case args of
        [ Text key _ ] ->
            Html.span [ HA.id meta.id ] [ Html.text ("[" ++ key ++ "]") ]

        _ ->
            Html.span [ HA.id meta.id ] (renderList params acc args)


renderSup : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderSup params acc args meta =
    Html.sup [ HA.id meta.id ] (renderList params acc args)


renderSub : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderSub params acc args meta =
    Html.sub [ HA.id meta.id ] (renderList params acc args)


renderTerm : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderTerm params acc args meta =
    Html.em
        [ HA.id meta.id
        , HA.style "padding-right" "2px"
        ]
        (renderList params acc args)


renderTermHidden : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderTermHidden _ _ _ meta =
    -- Hidden term for index entries that shouldn't display inline
    Html.span [ HA.id meta.id, HA.style "display" "none" ] []


renderVspace : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderVspace _ _ args meta =
    let
        h =
            args
                |> List.filterMap getTextContent
                |> String.concat
                |> String.toInt
                |> Maybe.withDefault 1
    in
    Html.div
        [ HA.id meta.id
        , HA.style "height" (String.fromInt h ++ "px")
        ]
        []


getTextContent : Expression -> Maybe String
getTextContent expr =
    case expr of
        Text str _ ->
            Just str

        _ ->
            Nothing
