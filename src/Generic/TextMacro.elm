module Generic.TextMacro exposing (Macro, buildDictionary, expand)

{-| Text macro handling for the Scripta compiler.

NOTE: This is a simplified stub. Full macro expansion is not yet implemented.

-}

import Dict exposing (Dict)
import Types exposing (Expression)


{-| A text macro with name and body.
-}
type alias Macro =
    { name : String
    , body : String
    }


{-| Expand macros in an expression.

NOTE: Currently a no-op stub - returns expression unchanged.

-}
expand : Dict String Macro -> Expression -> Expression
expand _ expr =
    -- TODO: Implement macro expansion
    expr


{-| Build a macro dictionary from lines of macro definitions.

NOTE: Currently a stub - returns empty dictionary.

-}
buildDictionary : List String -> Dict String Macro
buildDictionary _ =
    -- TODO: Implement macro parsing
    Dict.empty
