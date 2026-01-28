# Parser Change: Preserve Brackets in Verbatim Functions

## Problem

The two syntaxes for inline code produce different results when the content contains brackets:

```
> parse 0 "`[foo bar]`"
[VFun "code" ("[foo bar]") ...]

> parse 0 "[code [foo bar]]"
[VFun "code" ("foo bar") ...]
```

The backtick syntax preserves brackets, but the `[code ...]` syntax loses them.

## Root Cause

In `src/Parser/Expression.elm`, the `tokenToString` function (lines 462-472) only handles `S` (string) and `W` (whitespace) tokens:

```elm
tokenToString : Token -> Maybe String
tokenToString token =
    case token of
        S str _ ->
            Just str

        W str _ ->
            Just str

        _ ->
            Nothing
```

When content like `[foo bar]` is inside a verbatim function, the tokenizer parses it into separate tokens: `LB`, `S "foo"`, `W " "`, `S "bar"`, `RB`. The `tokenToString` function returns `Nothing` for `LB` and `RB`, so they're filtered out when joining the content.

## Solution

Extend `tokenToString` to convert bracket tokens to their literal string representations:

```elm
tokenToString : Token -> Maybe String
tokenToString token =
    case token of
        S str _ ->
            Just str

        W str _ ->
            Just str

        LB _ ->
            Just "["

        RB _ ->
            Just "]"

        _ ->
            Nothing
```

## Impact Analysis

This change only affects verbatim functions (`m`, `math`, `chem`, `code`) since `tokenToString` is only used in that code path (lines 233-237).

**Unaffected cases:**
- `[code foo bar]` - No brackets in content
- `[m x^2]` - No brackets
- `[b [i nested]]` - Not a verbatim function, uses recursive parsing

**Fixed cases:**
- `[code [foo bar]]` - Now produces `"[foo bar]"` instead of `"foo bar"`
- `[math [a,b]]` - Preserves brackets (correct for LaTeX notation)
- `[code a[b]c]` - Produces `"a[b]c"` with interior brackets preserved

## Note

`MathToken` ($) and `CodeToken` (`) within verbatim content would still be filtered out. This is a separate edge case that could be addressed later if needed.
