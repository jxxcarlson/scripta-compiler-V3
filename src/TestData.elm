module TestData exposing (..)

import Parser.Pipeline
import Parser.PrimitiveBlock
import Types


q : String -> List Types.ExpressionBlock
q str =
    str
    |> String.lines
    |> Parser.PrimitiveBlock.parse
    |> List.map Parser.Pipeline.toExpressionBlock


{-| Parse a string to primitive blocks.
-}
pb : String -> List Types.PrimitiveBlock
pb str =
    str
    |> String.lines
    |> Parser.PrimitiveBlock.parse

defaultCompilerParameters: Types.CompilerParameters
defaultCompilerParameters =
    { filter = Types.NoFilter
    , windowWidth = 600
    , selectedId = "selectedId"
    , theme = Types.Dark
    , editCount = 0
    , width = 600
    , showTOC = False
    , paragraphSpacing = 18
    }

-- ppb str =  Parser.PrimitiveBlock.parse (String.words str)

str1 =
    """
This is a test:
One two three

| equation
a^2 + b^2 = c^2

| Theorem
There are infintelty many primes.

$$
int_0^1 x^n dx = frac(1,n+1)

"""


cl1 = "- One\n- Two\n- Three\n"

cl2 = """
. One
. Two
. Three
"""