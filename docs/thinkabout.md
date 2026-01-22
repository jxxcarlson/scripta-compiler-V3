# Parser.Pipeline

**`src/Parser/Pipeline.elm`** - Simplified from V2:

| V2 Complexity | V3 Simplification |
|---------------|-------------------|
| `(Int -> String -> List Expression)` parser parameter | Hardcoded `Parser.Expression.parse` |
| `itemList_`, `itemList`, `numberedList` variants | Simple `item` and `numbered` handling |
| Language-agnostic design | Single Scripta language |
| ~100 lines with helpers | ~70 lines total |

**Key behavior:**
- `Paragraph` / `Ordinary _` → `Right (List Expression)` (parsed)
- `Verbatim _` → `Left String` (raw text preserved)
- `item` / `numbered` → `Right [ExprList indent exprs meta]`
- Inserts block id into properties

**`tests/Parser/PipelineTest.elm`** - 4 tests covering:
- Paragraph with inline markup
- Verbatim block preservation
- Item block with ExprList wrapping
- Properties id insertion
