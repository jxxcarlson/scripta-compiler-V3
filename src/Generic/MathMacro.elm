module Generic.MathMacro exposing
    ( Deco(..)
    , MacroBody(..)
    , MathExpr(..)
    )

{-| Types for math macro processing.

Used by ETeX.Transform for macro expansion.

-}


{-| A macro body with arity and list of expressions.
-}
type MacroBody
    = MacroBody Int (List MathExpr)


{-| Mathematical expressions for macro processing.
-}
type MathExpr
    = AlphaNum String
    | F0 String
    | Arg (List MathExpr)
    | Sub Deco
    | Super Deco
    | Param Int
    | WS
    | MathSpace
    | MathSmallSpace
    | MathMediumSpace
    | LeftMathBrace
    | RightMathBrace
    | MathSymbols String
    | Macro String (List MathExpr)
    | Expr (List MathExpr)


{-| Decorations for subscripts and superscripts.
-}
type Deco
    = DecoM MathExpr
    | DecoI Int
