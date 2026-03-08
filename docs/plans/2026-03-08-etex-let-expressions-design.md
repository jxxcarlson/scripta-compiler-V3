# ETeX Let-Expressions Design

## Motivation

Building complicated LaTeX expressions is error-prone. Let-expressions allow users to name sub-expressions and compose them incrementally, with the final result computed by repeated substitution.

## Example

```
| equation
LET
  A = e1
  B = e2
  p = A + B
  q = A - B
IN
  pq
```

Reduces to `(e1 + e2)(e1 - e2)` via sequential substitution.

## Syntax

- `LET` keyword on its own line, followed by indented definitions
- Each definition: `<uppercase letter> = <expression>` (one per line)
- `IN` keyword on its own line
- Body: everything after `IN`
- Content before `LET` is preserved and prepended to the result

## Design Decisions

### Variables
Single uppercase letters only (A-Z). This avoids collisions with lowercase math content and Greek letter names, and eliminates self-reference ambiguity (e.g., `a = a + 2` is impossible since `a` is not a valid variable).

### Sequential definitions
Definitions are processed top-to-bottom. Each definition can reference variables defined above it. In the example above, `p = A + B` is resolved to `p = (e1) + (e2)` before processing `q`.

### No nesting
LET blocks cannot appear inside definitions. Flatten into a single LET block instead. This may be revisited in a future version.

### Parenthesization
Substituted expressions are wrapped in parentheses only when the expression contains `+` or `-` at the top level (not inside nested braces/parens) and the expression is not already fully wrapped in parentheses. This avoids excessive nesting like `((x^2))` while preserving correctness for compound expressions.

Examples:
- `x^2` substituted bare → `x^2`
- `a + b` substituted with parens → `(a + b)`
- `\frac{1}{2}` substituted bare → `\frac{1}{2}`
- `(a + b)` substituted bare → `(a + b)` (already parenthesized)

### Boundary detection
Variable `A` is replaced only when the characters immediately before and after are not alphanumeric. So `AB` is left alone; `A+B` has both replaced.

### Error handling
If the LET block fails to parse (e.g., lowercase variable, missing IN), `reduce` returns the input unchanged. Errors surface downstream through existing ETeX error reporting.

## Architecture

### New file: `src/ETeX/Let.elm`

```elm
module ETeX.Let exposing (reduce)
```

**Types:**

```elm
type alias Definition =
    { variable : Char
    , expr : String
    }

type alias LetBlock =
    { definitions : List Definition
    , body : String
    }
```

**Parser** (using `Parser.Advanced`):

- `letBlockParser`: Matches `LET`, one or more definitions, `IN`, then body
- `definitionParser`: Matches `<whitespace><uppercase><whitespace>=<whitespace><rest of line>`
- `bodyParser`: Consumes everything after `IN\n`

**Reduction:**

1. Parse input into `LetBlock`. If no LET block found, return input unchanged.
2. Process definitions sequentially: for each definition, substitute all previously-defined variables into its RHS.
3. Substitute all resolved definitions into the body.
4. Prepend any content that preceded `LET`.

**Helpers:**

- `needsParens : String -> Bool` — scan expression tracking brace/paren nesting depth. Return `True` only if `+` or `-` appears at depth 0 and expression is not already fully wrapped in parens.
- `substituteVariable : Char -> String -> String -> String` — replace isolated occurrences of a variable with its (possibly parenthesized) expression.

### Modified file: `src/ETeX/Transform.elm`

Insert `ETeX.Let.reduce` as a preprocessing step in both `evalStr` and `transformETeX`, before existing parsing/transformation logic.

```elm
evalStr dict str =
    str
        |> ETeX.Let.reduce
        |> ... existing logic ...
```

### No other files modified

LET reduction is transparent to the rest of the pipeline. All math contexts (| equation, | aligned, | math, inline $...$) get LET support automatically.