module Edit.Map exposing
    ( Edit
    , charDelta, lineDelta
    , shiftBlockId, shiftExprId
    )

{-| Fast, pure metadata shift for RL-sync. See mydocs/diff-update-map-strategy.md.

@docs Edit
@docs charDelta, lineDelta

-}


{-| A single edit against the pre-edit document (CodeMirror-style change).
-}
type alias Edit =
    { offset : Int
    , removed : String
    , inserted : String
    }


{-| Net change in character count produced by the edit.
-}
charDelta : Edit -> Int
charDelta edit =
    String.length edit.inserted - String.length edit.removed


{-| Net change in newline count produced by the edit.
-}
lineDelta : Edit -> Int
lineDelta edit =
    countNewlines edit.inserted - countNewlines edit.removed


countNewlines : String -> Int
countNewlines s =
    List.length (String.indexes "\n" s)


{-| Bump the leading line-number component of a block id ("L-I") by dL.
Leaves the id unchanged if it is not of the expected form.
-}
shiftBlockId : Int -> String -> String
shiftBlockId dL id =
    case String.split "-" id of
        lineStr :: rest ->
            case String.toInt lineStr of
                Just l ->
                    String.join "-" (String.fromInt (l + dL) :: rest)

                Nothing ->
                    id

        _ ->
            id


{-| Bump the line-number component of an expression id ("e-L.T") by dL.
Leaves the id unchanged if it is not of the expected form.
-}
shiftExprId : Int -> String -> String
shiftExprId dL id =
    if String.startsWith "e-" id then
        case String.split "." (String.dropLeft 2 id) of
            lineStr :: rest ->
                case String.toInt lineStr of
                    Just l ->
                        "e-" ++ String.fromInt (l + dL) ++ "." ++ String.join "." rest

                    Nothing ->
                        id

            _ ->
                id

    else
        id
