# Numbering Bug Analysis

## Problem

Given this source text:

```
| title
Equation Test B

# AAA

| theorem label:primes
There are infinitely many primes!

Let's think about theorem [ref primes].
```

With `maxLevel = 0`:
- Theorem renders as "Theorem 2." (wrong, should be "Theorem 1.")
- `[ref primes]` renders as "1" (correct)

## Root Cause

The bug is in `updateWithOrdinarySectionBlock` at lines 821-826 in `src/Generic/Acc.elm`:

```elm
blockCounter =
    if levelAsInt <= accumulator.maxLevel then
        0
    else
        levelAsInt  -- BUG: should be accumulator.blockCounter
```

With `maxLevel = 0`:
- Section `# AAA` has `levelAsInt = 1`
- `1 <= 0` is **false**
- So `blockCounter` is incorrectly set to `1` (the level value)

Then when the theorem is processed in `updateWithOrdinaryBlock`, `blockCounter` gets incremented from 1 to 2.

## The Fix

Change the `else` branch to preserve the existing `blockCounter` value:

```elm
blockCounter =
    if levelAsInt <= accumulator.maxLevel then
        0
    else
        accumulator.blockCounter  -- preserve existing value
```

## Why [ref primes] Shows Correct Value

The reference shows "1" because `updateWithOrdinaryBlock` (line 988) stores the reference using `itemVector`, not `blockCounter`:

```elm
referenceDatum =
    makeReferenceDatum block.meta.id (getTag block) (String.fromInt (Vector.get level itemVector))
```

The `itemVector` is independent of `blockCounter` and happens to have the correct value.

## Secondary Inconsistency (Not Fixed Here)

There are two different counting mechanisms being used:
1. `updateWithOrdinaryBlock` stores references using `itemVector`
2. `transformBlock` sets the display label using `blockCounter`

This could cause mismatches in other scenarios. The `getTag` function (line 1380) reads from the `label` property first, so `[ref primes]` finds the value stored via `itemVector`, while the rendered theorem uses `blockCounter`.
