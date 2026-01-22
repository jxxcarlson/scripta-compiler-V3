# Comprehensive Code Review

Review of all commits in Scripta Compiler V3:

- 7584e32 - Initial implementation of PrimitiveBlock parser
- f204a73 - Add comprehensive verbatimNames list for block classification
- 478bf68 - Add PrimitiveBlock parser tests
- f7e09c1 - Add README with project description
- 310a0ee - Add Expression parser with tokenizer and tests

---

## Overview

The codebase implements a two-phase parsing pipeline for the Scripta markup language:

1. **Block parsing** (`Parser.PrimitiveBlock`): Converts raw text into structured blocks based on indentation and heading markers (`|`, `||`, `$$`, etc.)
2. **Expression parsing** (`Parser.Expression`): Parses inline markup within blocks (`[b bold]`, `$math$`, `` `code` ``)

The architecture is clean with good separation of concerns across modules.

---

## Code Quality Analysis

### Strengths

- **Good module separation**: `Types`, `PrimitiveBlock`, `Line`, `Expression`, `Tokenizer`, `Symbol`, `Match` each have clear responsibilities
- **Helpful REPL examples** in module docs (`Parser.Expression` lines 3-17)
- **Error recovery**: The expression parser gracefully handles malformed input with informative error messages
- **State machine pattern**: Consistent use of `Tools.Loop` for state-based parsing
- **Comprehensive verbatim block list**: Good coverage of block types (math, code, tikz, etc.)
- **Tests pass**: All 6 tests run successfully

### Issues & Suggestions

#### 1. Missing type annotations

**Tokenizer.elm:365-374**
```elm
languageChars =
    [ '[', ']', '`', '$', '\\' ]
```
These top-level values lack type signatures. Should be:
```elm
languageChars : List Char
```

**PrimitiveBlock.elm:456-457**
```elm
isVerbatimName : String -> Bool
isVerbatimName str = List.member  str verbatimNames
```
Has double space before `str`. Minor formatting issue.

#### 2. Duplicated helper functions

`getAt` is defined identically in:
- `Parser/Expression.elm:430-436`
- `Parser/Match.elm:173-179`

`dropLast` and `takeWhile` in `Match.elm` are also common utilities.

Consider creating `Tools/ListExtra.elm` or using `elm-community/list-extra`.

#### 3. Bug: Hardcoded `lineNumber = 0` (Expression.elm:272)

```elm
Text str (boostMeta 0 (Token.indexOf (S str meta)) meta) :: reduceRestOfTokens lineNumber (List.drop 1 tokens)
```
The `lineNumber` parameter is passed through the function chain but gets hardcoded to `0` here. Should use the `lineNumber` argument.

#### 4. Inconsistent error message formatting (Expression.elm:352)

```elm
"[ - can't have space after the bracket "  -- trailing space
```
Trailing space in error message looks unintentional.

#### 5. Unused `step` field in State (Expression.elm:27)

The `step` counter is incremented but never read. Either use it for debugging/loop limits or remove it.

#### 6. Tokenizer mode inconsistency (Tokenizer.elm:432-434)

```elm
mathTextParser start index =
    PT.text (\c -> not <| List.member c (' ' :: mathChars))
            (\c -> not <| List.member c (' ' :: languageChars))  -- uses languageChars, not mathChars
```
The `continue` predicate uses `languageChars` instead of `mathChars`. This may be intentional (to stop at any language char while in math mode) but should be documented.

#### 7. Message truncation (Expression.elm:427)

```elm
prependMessage lineNumber message messages =
    (message ++ " (line " ++ String.fromInt lineNumber ++ ")") :: List.take 2 messages
```
Silently drops messages after the third error. Consider making this limit configurable or documented.

#### 8. TODO in PrimitiveBlock.elm (lines 5-6)

```elm
NOTE (TODO) for the moment we assume that the input ends with
a blank line.
```
This assumption should be documented more prominently or fixed.

#### 9. Line.classify stores redundant data (Line.elm:28-29)

```elm
content =
    str  -- stores full line including leading spaces
```
The `content` field stores the full line while `prefix` stores the leading spaces. Consider whether `content` should be the trimmed content (without leading spaces) for consistency.

#### 10. PrimitiveBlock position tracking

The `position` field tracks character position in source, but block IDs are generated as `lineNumber-blocksCommitted` (PrimitiveBlock.elm:310). Consider using position in the ID for more precise error reporting.

---

## Test Coverage

Current tests cover:
- Plain text parsing
- Function syntax `[b bold text]`
- Math syntax `$a^2 + b^2 = c^2$`
- PrimitiveBlock parsing (position, lineNumber, headings)
- Line position calculation

**Missing coverage:**
- Code syntax (backticks)
- Nested expressions `[b [i nested]]`
- Error cases (unmatched brackets, empty brackets)
- Edge cases (empty input, whitespace-only)
- Markdown headings (`#`, `##`, `###`)
- List items (`-`, `.`)
- Verbatim blocks (`||`, code fences)
- Indented/nested blocks

---

## Architecture Notes

### Parser Pipeline

```
Raw Text
    |
    v
[String.lines]
    |
    v
List String
    |
    v
[Parser.PrimitiveBlock.parse]
    |
    v
List PrimitiveBlock  (content = List String)
    |
    v
[Parser.Expression.parse on each block]
    |
    v
List ExpressionBlock (content = Either String (List Expression))
```

### Expression Parser Pipeline

```
String
    |
    v
[Token.run]
    |
    v
List Token
    |
    v
[Symbol.toSymbols]
    |
    v
List Symbol  (for bracket matching)
    |
    v
[Match.isReducible / Match.match]
    |
    v
[reduceTokens]
    |
    v
List Expression
```

---

## Security Considerations

No issues. This is a pure parser with no I/O or external interactions.

---

## Summary Table

| Priority | Issue | Location |
|----------|-------|----------|
| High | Fix hardcoded `lineNumber = 0` in `reduceRestOfTokens` | Expression.elm:272 |
| High | Document or fix "input must end with blank line" assumption | PrimitiveBlock.elm:5-6 |
| Medium | Add missing type annotations | Tokenizer.elm:365-374 |
| Medium | Deduplicate `getAt`, `dropLast`, `takeWhile` helpers | Expression.elm, Match.elm |
| Medium | Add tests for error cases and nested expressions | tests/ |
| Low | Clean up trailing space in error message | Expression.elm:352 |
| Low | Remove unused `step` field or use it | Expression.elm:27 |
| Low | Document tokenizer mode behavior | Tokenizer.elm:432-434 |
| Low | Fix double space in `isVerbatimName` | PrimitiveBlock.elm:457 |
