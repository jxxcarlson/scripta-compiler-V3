module TestData exposing (..)

import Types



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
