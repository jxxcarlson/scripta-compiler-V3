module TestData exposing (..)

import Parser.Pipeline
import Parser.PrimitiveBlock
import V3.Types


q : String -> List V3.Types.ExpressionBlock
q str =
    str
        |> String.lines
        |> Parser.PrimitiveBlock.parse
        |> List.map Parser.Pipeline.toExpressionBlock


{-| Parse a string to primitive blocks.
-}
p : String -> List V3.Types.PrimitiveBlock
p str =
    str
        |> String.lines
        |> Parser.PrimitiveBlock.parse


defaultCompilerParameters : V3.Types.CompilerParameters
defaultCompilerParameters =
    { filter = V3.Types.NoFilter
    , windowWidth = 600
    , selectedId = "selectedId"
    , theme = V3.Types.Dark
    , editCount = 0
    , width = 600
    , showTOC = False
    , sizing = { baseFontSize = 14.0, paragraphSpacing = 18.0, marginLeft = 0.0, marginRight = 0.0, scale = 1.0 }
    , maxLevel = 1
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


cl1 =
    "- One\n- Two\n- Three\n"


cl2 =
    """
. One
. Two
. Three
"""


imgStr =
    """
| image
https://foo.com/yada.jpg
"""


imgStr2 =
    """
| image width:400 caption:Captain Yada
https://foo.com/yada.jpg
"""
