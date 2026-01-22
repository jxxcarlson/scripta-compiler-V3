# ETeX.* Module Streamlining Opportunities

Analysis of redundant or unnecessary code in the ETeX modules.

## 1. Duplicate Type Definitions (Major)

Three separate but similar `MathExpr` types exist:

| Module | Location | Variants |
|--------|----------|----------|
| `ETeX.Transform` | lines 43-66 | 24 variants |
| `ETeX.MathMacros` | lines 64-84 | 17 variants |
| `Generic.MathMacro` | lines 13-31 | 15 variants |

Similarly duplicated: `Deco` type (3 copies) and `MacroBody` type (2 copies).

**Impact**: `ETeX.Transform.elm` has ~275 lines (937-1215) of conversion functions just to translate between these types:
- `convertToGenericMacroBody`
- `convertToGenericMathExpr`
- `convertToGenericDeco`
- `convertToETeXMathExpr`
- `convertToETeXDeco`
- `convertFromETeXMathExpr`
- `convertFromETeXDeco`

**Recommendation**: Consolidate to a single canonical `MathExpr` type, likely in `ETeX.MathMacros` or a new `ETeX.Types` module.

## 2. ETeX.Dictionary.elm - Unused Import

**Line 4:**
```elm
import Generic.MathMacro exposing (MacroBody, MathExpr)
```

Neither `MacroBody` nor `MathExpr` are used anywhere in this module.

**Recommendation**: Remove the unused import.

## 3. Duplicate Greek Letter Data

Greek letters are defined in two places:

- `ETeX.Dictionary.symbolDict` (lines 34-91)
- `ETeX.KaTeX.greekLetters` (lines 52-112)

**Recommendation**: Use a single source of truth, have one module import from the other.

## 4. ETeX.MathMacros.elm - Unused/Test Code

| Lines | Code | Issue |
|-------|------|-------|
| 99-106 | `lines` | Hardcoded test data |
| 108-110 | `macroDict` | Uses hardcoded `lines` |
| 113-122 | `defs` | Hardcoded test string |
| 53-57 | `parseA` | Appears unused |
| 125-136 | `evalStr` | Duplicates `ETeX.Transform.evalStr` |

**Recommendation**: Remove test data or move to test directory.

## 5. Duplicate Functions Between MathMacros and Transform

Both modules have nearly identical implementations of:

### Macro expansion:
- `expandMacroWithDict`
- `expandMacro_`
- `replaceParam_`
- `replaceParam`
- `replaceParams`

### Printing:
- `print`
- `printList`
- `printDeco`
- `enclose` / `encloseB`

### Parsing:
- `parseNewCommand`
- `newCommandParser` / `newCommandParser1` / `newCommandParser2`
- `many`, `manyHelp`
- `second`
- `mathExprParser`
- `argParser`
- `macroParser`
- `subscriptParser`, `superscriptParser`
- `decoParser`, `numericDecoParser`
- `mathSpaceParser`, `mathSmallSpaceParser`, `mathMediumSpaceParser`
- `leftBraceParser`, `rightBraceParser`
- `alphaNumParser`, `alphaNumParser_`
- `f0Parser`, `paramParser`
- `whitespaceParser`, `mathSymbolsParser`

**Recommendation**: Keep implementations in one module, have the other import from it.

## 6. ETeX.KaTeX.elm - Internal Duplicates

Within the KaTeX command lists, several items appear multiple times:

| Command | Appears in |
|---------|------------|
| `"subset"` | `relationSymbols`, `logicAndSetTheory` |
| `"emptyset"` | `logicAndSetTheory`, `miscSymbols` |
| `"complement"` | `logicAndSetTheory` (twice) |
| `"overline"` | `accents`, `textOperators` |
| `"maltese"` | `miscSymbols` (twice) |
| `"setminus"` | `binaryOperators`, `logicAndSetTheory` |
| `"smallsetminus"` | `binaryOperators`, `logicAndSetTheory` |

**Recommendation**: Remove duplicates from lists.

## 7. ETeX.Test.elm - Broken Function

**Lines 15-16:**
```elm
evalStr str =
    ETeX.Transform.evalStr
```

This function takes `str` as a parameter but returns `ETeX.Transform.evalStr` partially applied, never actually using `str`.

**Recommendation**: Fix or remove.

## 8. ETeX.Test.elm - Should Not Be in Production

This module contains only test/example data and should either:
- Be moved to the `tests/` directory
- Be removed entirely

## Summary Table

| Priority | Item | Action |
|----------|------|--------|
| High | Duplicate MathExpr/Deco/MacroBody types | Consolidate to single module |
| High | Duplicate functions in MathMacros/Transform | Keep in one place |
| Medium | Unused import in Dictionary | Remove |
| Medium | Duplicate Greek letter data | Single source of truth |
| Medium | Test code in MathMacros | Remove or relocate |
| Low | Duplicate KaTeX commands | Remove duplicates |
| Low | ETeX.Test.elm | Remove or relocate |
