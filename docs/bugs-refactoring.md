# Bugs & Refactoring Opportunities

Systematic code review of the Scripta Compiler V3 codebase.
Generated 2026-02-25.

## Overview

| Area | Critical | Medium | Low | Total |
|------|----------|--------|-----|-------|
| Render modules | 2 | 9 | 6 | 17 |
| ETeX / Generic | 3 | 8 | 5 | 16 |
| Parser modules | 0 | 5 | 8 | 13 |
| Utilities / Config | 2 | 5 | 4 | 11 |
| **Total** | **7** | **27** | **23** | **57** |

---

## Critical Issues

### C1. Debug.log left in production code
- **File:** `src/Render/Expression.elm:584`
- **Issue:** `Debug.log "@@renderRef(numRef)"` outputs to browser console
- **Also:** `src/Generic/Acc.elm:538,934` — `Debug.log "@@prefix"` and `Debug.log "@@updateWithOrdinarySectionBlock-content-level"`
- **Fix:** Remove all Debug.log calls

### C2. Silent error suppression in ETeX macro expansion
- **File:** `src/ETeX/Transform.elm:47-48,173-177`
- **Also:** `src/ETeX/MathMacros.elm:134-138`
- **Issue:** Both `transformETeX` and `evalStr` return the input unchanged on parse failure with no warning. The code has a TODO acknowledging this is a bad solution (line 176).
- **Fix:** Return `Result` type or log warnings on failure

### C3. Duplicate `parseNewCommand` functions with different signatures
- **Files:** `src/ETeX/Transform.elm:1247` vs `src/ETeX/MathMacros.elm:375`
- **Issue:** Transform version accepts `MathMacroDict` parameter; MathMacros version does not. They've evolved independently.
- **Fix:** Consolidate into single implementation in Transform module

### C4. Unused `maca/elm-rose-tree` dependency
- **File:** `elm.json:19`
- **Issue:** Package `maca/elm-rose-tree` is listed but never imported. Only `zwilias/elm-rosetree` is used.
- **Fix:** Remove from elm.json

---

## Medium Issues

### M1. Inconsistent tag defaults in reference system
- **File:** `src/Generic/Acc.elm:686,704`
- **Issue:** Line 686 defaults tag to `id`, but line 704 defaults to `"no-tag"`. Inconsistent behavior causes reference lookups to fail.
- **Fix:** Use `block.meta.id` as default consistently

### M2. Identical branches in section level determination
- **File:** `src/Generic/Acc.elm:805-813`
- **Issue:** All three branches of `case Dict.get "has-chapters"` produce identical results. Dead code path.
- **Fix:** Replace entire case with `Dict.get "level" properties |> Maybe.withDefault "1"`

### M3. Hardcoded vector size 4 in 8+ locations
- **File:** `src/Generic/Acc.elm:140,779,856,861,864,873,880,1097`
- **Issue:** `{ content = [ n, 0, 0, 0 ], size = 4 }` repeated everywhere
- **Fix:** Extract constant; use `InitialAccumulatorData.vectorSize` consistently

### M4. Missing arity validation in macro expansion
- **File:** `src/ETeX/Transform.elm:243-255`
- **Issue:** Multi-argument macros don't validate that argument count matches declared arity
- **Fix:** Add validation before expansion

### M5. Vector math edge case — negative index
- **File:** `src/Generic/Acc.elm:963`
- **Issue:** If `level` string is "0", the vector index becomes -1 (invalid)
- **Fix:** Add bounds check: `if vectorIndex < 0 then accumulator.headingIndex else Vector.increment vectorIndex ...`

### M6. Greedy regex in transformLabel
- **File:** `src/MiniLaTeX/Util.elm:22` (also `src/Tools/Util.elm`)
- **Issue:** `\\[label(.*)\\]` greedily matches from first `[label` to LAST `]`, breaking with multiple labels on one line
- **Fix:** Use non-greedy: `\\[label(.*?)\\]`

### M7. Inconsistent error message styles in parser
- **File:** `src/Parser/Expression.elm:265,293` vs `305-371`
- **Issue:** Some errors use plain `Text "error..."`, others use `errorMessage` wrapper with `Fun "errorHighlight"`. Lines 265,293 also omit line numbers.
- **Fix:** Use `errorMessage` consistently; always call `prependMessage`

### M8. Duplicate `getAt` function
- **Files:** `src/Parser/Expression.elm:443-449` and `src/Parser/Match.elm:173-179`
- **Issue:** Identical implementation in two modules
- **Fix:** Extract to shared utility

### M9. Duplicate `resolveSymbolName` function
- **Files:** `src/ETeX/MathMacros.elm:731-748` and `src/ETeX/Transform.elm:736-748`
- **Issue:** Nearly identical implementations
- **Fix:** Consolidate into one module

### M10. Duplicate `Step` type defined 3 times
- **Files:** `src/Tools/Loop.elm:7-9`, `src/Library/Forest.elm:73-75`, `src/Library/Tree.elm:153-155`
- **Issue:** Identical `type Step state a = Loop state | Done a` in three places
- **Fix:** Library modules should import from Tools.Loop

### M11. Duplicate utility functions across modules
- **Files:** `src/Tools/Utility.elm` and `src/MiniLaTeX/Util.elm`
- **Issue:** `userReplace` and `removeNonAlphaNum` have identical implementations
- **Fix:** Consolidate to single location

### M12. Typo in function name: `fractionaRescale`
- **File:** `src/Render/Export/Image.elm:194,303`
- **Issue:** Should be `fractionalRescale`
- **Fix:** Rename function

### M13. Unsafe string operations in KV parser
- **File:** `src/Tools/KV.elm:66,71,87,96`
- **Issue:** `String.dropRight 1 item` assumes string ends with `:` but no validation
- **Fix:** Validate format before dropping characters

### M14. `"table"` appears twice in `verbatimNames`
- **File:** `src/Parser/PrimitiveBlock.elm:26,50`
- **Issue:** Duplicate entry in the list
- **Fix:** Remove duplicate

### M15. Scattered ID generation prefixes
- **Files:** Expression.elm (`"e-"`), Pipeline.elm (`"list"`), Table.elm (`"row-"`, `"cell-"`)
- **Issue:** Hardcoded string prefixes for ID generation scattered across modules
- **Fix:** Create centralized ID generation module

### M16. Unresolved TODO comments indicating design uncertainty
- `src/Generic/Acc.elm:465` — "not at all sure that the below is correct"
- `src/Generic/Acc.elm:621` — "TODO: review!"
- `src/Generic/Acc.elm:945` — "the below is a bad solution"
- `src/Generic/Acc.elm:989,1034` — "take care of numberedItemIndex = 0"
- `src/Render/Export/LaTeX.elm:966` — "TODO: equation numbers and label"
- `src/ETeX/KaTeX.elm:21` — missing symbols (ldots, ellipsis)

---

## Low Priority Issues

### L1. Module in wrong directory
- **File:** `src/Tools/Util.elm` declares `module MiniLaTeX.Util`
- **Fix:** Move to `src/MiniLaTeX/Util.elm` or rename module

### L2. Unused import in Forest.elm
- **File:** `src/Parser/Forest.elm:17` — `import Dict` never used
- **Fix:** Remove

### L3. Dead code: `balance` function in Symbol module
- **File:** `src/Parser/Symbol.elm:41-43` — defined but not exported
- **Fix:** Export or remove

### L4. Dead code: `mapChildren` in ForestTransform
- **File:** `src/Generic/ForestTransform.elm:60-72` — has explicit "TODO: Keep for now"
- **Fix:** Document why it's kept or remove

### L5. Commented-out dict entries
- **File:** `src/Render/Expression.elm:160-161` — `-- , ( "term", renderIndex_ )`
- **Fix:** Remove dead commented code

### L6. Incomplete language support in code highlighting
- **File:** `src/Render/VerbatimBlock.elm:430-464`
- **Issue:** Documentation mentions kotlin/go support but only 7 of listed languages are implemented
- **Fix:** Implement missing languages or update documentation

### L7. Division-by-zero risk in sizing
- **File:** `src/Render/Sizing.elm:100-115`
- **Issue:** `toFloat rawIndent / toFloat config.indentUnit` — if `indentUnit` is 0
- **Fix:** Add validation

### L8. Empty label generation for images
- **File:** `src/Render/Export/Image.elm:73-79`
- **Issue:** Label from caption (first 2 words, filtered) can produce empty string, causing LaTeX errors
- **Fix:** Add fallback label

### L9. Parser assumes input ends with blank line
- **File:** `src/Parser/PrimitiveBlock.elm:5-6`
- **Issue:** Documented assumption with no enforcement
- **Fix:** Either enforce or make parser robust to missing final blank line

### L10. `gen` parameter undocumented in Table
- **File:** `src/Parser/Table.elm:8,13,19`
- **Issue:** `gen : Int` parameter threaded through functions with no documentation
- **Fix:** Document purpose

### L11. Hardcoded colors and dimensions
- **Files:** `src/Render/VerbatimBlock.elm:403-406,1354,1361`, `src/Render/Block.elm:42`
- **Issue:** Background colors like `#f5f5f5`, `#1e1e1e`, error color `red` are hardcoded
- **Fix:** Extract to Constants module

### L12. Inconsistent naming conventions
- **File:** `src/Generic/ASTTools.elm` — `filterExpressionsOnName_` vs `filterExprs`
- **File:** `src/Parser/Expression.elm` — `pushOrCommit` vs `pushOnStack_`
- **Fix:** Standardize naming

---

## Priority Order for Fixes

1. **Immediate:** Remove Debug.log statements (C1)
2. **Immediate:** Remove unused elm-rose-tree dependency (C4)
3. **Immediate:** Remove duplicate "table" in verbatimNames (M14)
4. **High:** Fix greedy regex in transformLabel (M6)
5. **High:** Fix inconsistent tag defaults (M1)
6. **High:** Consolidate duplicate parseNewCommand (C3)
7. **High:** Fix identical branches dead code (M2)
8. **Medium:** Consolidate duplicate Step type (M10)
9. **Medium:** Consolidate duplicate utility functions (M8, M9, M11)
10. **Medium:** Address vector bounds checking (M5)
11. **Low:** Clean up dead code (L2-L5)
12. **Low:** Resolve TODO comments (M16)
