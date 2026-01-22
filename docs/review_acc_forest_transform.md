# Code Review: Commits d216cda, b61e132, 6237ccd

Review of Pipeline, Types/Vector, and Generic.Acc/ForestTransform commits.

## Overview

These three commits establish the core compilation pipeline:

1. **d216cda** - Add Pipeline module (PrimitiveBlock → ExpressionBlock)
2. **b61e132** - Add Accumulator types and fix Vector module
3. **6237ccd** - Add Generic.Acc and ForestTransform with supporting modules

**Total:** 17 files changed, 2177 insertions

---

## Code Quality Analysis

### Strengths

- **Good V3 simplification**: Removed multi-language support from V2, hardcoded Scripta language
- **Clean module separation**: Each module has a clear, focused responsibility
- **Comprehensive type definitions**: Types.elm centralizes all core types
- **Helpful doc comments**: Most public functions have documentation

### Issues & Suggestions

#### 1. Duplicate type definitions

`InListState` is defined in two places with different constructor names:

| Location | Constructors |
|----------|--------------|
| `Types.elm:126-128` | `InList \| NotInList` |
| `Generic.Acc.elm:91-93` | `SInList \| SNotInList` |

**Recommendation:** Use single definition from `Types` module.

#### 2. Duplicate `Accumulator` type

The `Accumulator` type is defined identically in both:
- `Types.elm:102-121`
- `Generic.Acc.elm:69-88`

**Recommendation:** Export only from `Types`, import in `Generic.Acc`.

#### 3. Duplicate `TermLoc` / `TermLoc2` types

Defined in both `Types.elm` and `Generic.Acc.elm`.

**Recommendation:** Use definitions from `Types` only.

#### 4. Stub functions need implementation (Low priority)

| Function | Location | Status |
|----------|----------|--------|
| `makeMathMacroDict` | Generic.Acc.elm:1198 | Returns `Dict.empty` |
| `expand` | Generic.TextMacro.elm:27 | No-op, returns input |
| `buildDictionary` | Generic.TextMacro.elm:35 | Returns `Dict.empty` |

These are acceptable stubs for now but need implementation for full functionality.

#### 5. Missing type annotation (Generic.Acc.elm:163)

```elm
mapper ast_ ( acc_, tree_ ) =
    ( acc_, tree_ :: ast_ )
```

Should have explicit type signature.

#### 6. Unused parameter in `updateAccumulator` (Generic.Acc.elm:686)

```elm
Verbatim name_ ->
    case block.body of
        Left str ->  -- 'str' is not used
```

The `str` binding is unused. Consider using `Left _` instead.

#### 7. TODO comments to address

| Location | Comment |
|----------|---------|
| Generic.Acc.elm:313 | "not at all sure that the below is correct" |
| Generic.Acc.elm:432 | "TODO: review!" |
| Generic.Acc.elm:509,516 | "TODO: REVIEW!" |
| Generic.Acc.elm:722 | "the below is a bad solution" |
| Generic.Acc.elm:745,790 | "take care of numberedItemIndex = 0" |
| Generic.Acc.elm:867 | "fix thereom labels" (typo: theorem) |

#### 8. `itemsNotNumbered` missing type annotation (Generic.Acc.elm:754)

```elm
itemsNotNumbered =
    [ "preface", "introduction", ... ]
```

Should be `itemsNotNumbered : List String`.

---

## Architecture Notes

### Pipeline Flow

```
List String (source lines)
    │
    ▼
[Parser.PrimitiveBlock.parse]
    │
    ▼
List PrimitiveBlock
    │
    ▼
[Parser.Pipeline.toExpressionBlock] (map)
    │
    ▼
List ExpressionBlock
    │
    ▼
[Generic.ForestTransform.forestFromBlocks]
    │
    ▼
Forest ExpressionBlock (List (Tree ExpressionBlock))
    │
    ▼
[Generic.Acc.transformAccumulate]
    │
    ▼
(Accumulator, Forest ExpressionBlock)
```

### Type Centralization

`Types.elm` now contains:
- Block types: `GenericBlock`, `PrimitiveBlock`, `ExpressionBlock`, `Heading`
- Expression types: `Expr`, `Expression`, `ExprMeta`
- Metadata: `BlockMeta`, `ExprMeta`
- Accumulator types: `Accumulator`, `InListState`, `TermLoc`, `TermLoc2`, `Macro`, `MathMacroDict`

---

## Test Coverage

Current tests (10 total):
- Expression parser: 3 tests
- PrimitiveBlock parser: 3 tests
- Pipeline: 4 tests

**Missing coverage:**
- `Generic.Acc.transformAccumulate`
- `Generic.ForestTransform.forestFromBlocks`
- `Generic.Vector` operations
- Supporting modules (ASTTools, BlockUtilities, etc.)

---

## Summary Table

| Priority | Issue | Location |
|----------|-------|----------|
| High | Duplicate `Accumulator` type definition | Types.elm, Generic.Acc.elm |
| High | Duplicate `InListState` with different names | Types.elm, Generic.Acc.elm |
| Medium | Duplicate `TermLoc`/`TermLoc2` definitions | Types.elm, Generic.Acc.elm |
| Medium | Missing type annotations | Generic.Acc.elm:163, 754 |
| Medium | Add tests for Acc and ForestTransform | tests/ |
| Low | Implement stub functions | Generic.Acc, Generic.TextMacro |
| Low | Address TODO comments | Generic.Acc.elm |
| Low | Fix typo "thereom" → "theorem" | Generic.Acc.elm:867 |
