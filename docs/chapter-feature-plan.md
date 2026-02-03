# Chapter Feature Implementation Plan

## Overview

Add a chapter numbering system that prefixes all numbering (sections, theorems, equations) with the chapter number when chapters are in use.

## Behavior

### When chapterCounter = 0 (default)
- No chapters in use
- Numbering works exactly as it does now
- Sections: 1, 1.1, 2, etc.
- Theorems: 1.1, 1.2, 2.1, etc.
- Equations: 1.1, 1.2, 2.1, etc.

### When chapterCounter > 0 (chapters in use)
- Chapter block encountered increments counter
- All numbering prefixed with chapter number:
  - Sections: 1.1, 1.2, 2.1 (chapter.section)
  - Theorems: 1.1.1, 1.1.2 (chapter.section.theorem)
  - Equations: 1.1.1, 1.1.2 (chapter.section.equation)
- Chapter block renders as: "Chapter 1. Plants"

## Files to Modify

### 1. src/Types.elm
Add to `Accumulator` type:
```elm
, chapterCounter : Int
```

### 2. src/Generic/Acc.elm

#### InitialAccumulatorData
Add field:
```elm
, chapterCounter : Int
```

#### initialData
Add:
```elm
, chapterCounter = 0
```

#### init function
Add:
```elm
, chapterCounter = data.chapterCounter
```

#### New helper function
```elm
chapterPrefix : Accumulator -> String
chapterPrefix acc =
    if acc.chapterCounter > 0 then
        String.fromInt acc.chapterCounter
    else
        ""
```

#### Handle chapter block in updateAccumulator
In the case statement (around line 600), add handling for `Ordinary "chapter"`:
- Increment chapterCounter
- Reset headingIndex to [0,0,0,0] (sections restart per chapter)
- Reset blockCounter to 0
- Reset equation counter to 0
- Create reference for chapter

#### Modify numbering formulas

**Theorem labels in transformBlock (~line 396):**
```elm
-- Before:
prefix ++ punctuation ++ String.fromInt acc.blockCounter

-- After:
chapterPrefix acc ++
    (if acc.chapterCounter > 0 && prefix /= "" then "." else "") ++
    prefix ++ punctuation ++ String.fromInt acc.blockCounter
```

**Theorem references in updateWithOrdinaryBlock (~line 987):**
Same formula change.

**Equation numbers in transformBlock (~line 326):**
Similar change to include chapter prefix.

**Equation references in updateWithVerbatimBlock (~line 1054):**
Same formula change.

**Section numbers in updateWithOrdinarySectionBlock (~line 829):**
Prefix section number with chapter number.

### 3. src/Render/OrdinaryBlock.elm

Add `renderChapter` function:
```elm
renderChapter : CompilerParameters -> Accumulator -> ExpressionBlock -> Html Msg
renderChapter params acc block =
    let
        chapterNum =
            Dict.get "chapter-number" block.properties
                |> Maybe.withDefault ""

        title =
            getTitle block  -- extract from block body
    in
    Html.div [ chapterStyles ]
        [ Html.text ("Chapter " ++ chapterNum ++ ". " ++ title) ]
```

Add to block rendering dispatch.

### 4. src/Generic/Settings.elm (if exists) or inline
Ensure "chapter" is recognized as a block name.

## Resets on Chapter Boundary

When a `| chapter` block is encountered:
1. `chapterCounter` → increment by 1
2. `headingIndex` → reset to [0,0,0,0]
3. `blockCounter` → reset to 0
4. `counter["equation"]` → reset to 0

## Implementation Order

1. Add `chapterCounter` to Types.elm
2. Add to InitialAccumulatorData and initialData
3. Add to init function
4. Add `chapterPrefix` helper function
5. Handle `Ordinary "chapter"` case
6. Update theorem label formula in transformBlock
7. Update theorem reference formula in updateWithOrdinaryBlock
8. Update equation number formula in transformBlock
9. Update equation reference formula in updateWithVerbatimBlock
10. Update section number formula
11. Add renderChapter in OrdinaryBlock.elm
12. Test with sample document

## Test Document

```
| chapter
Plants

# Flowers
| theorem
All flowers are beautiful.

| equation label:flower-eq
f(x) = x^2

# Trees
| theorem
Trees are tall.

| chapter
Animals

# Mammals
| theorem
Mammals are warm-blooded.
```

Expected output:
- Chapter 1. Plants
  - 1.1 Flowers
    - Theorem 1.1.1
    - Equation (1.1.1)
  - 1.2 Trees
    - Theorem 1.1.2
- Chapter 2. Animals
  - 2.1 Mammals
    - Theorem 2.1.1
