module Edit.Map exposing
    ( Edit
    , charDelta, lineDelta
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
