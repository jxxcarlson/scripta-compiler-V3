# Theorem Numbering Mechanism

## Where is blockCounter reset to 0?

`blockCounter` is reset to 0 in two places:

1. **`init`** (line 149) - when the accumulator is first created

2. **`updateWithOrdinarySectionBlock`** (lines 792-793, 801) - when a new section is encountered

```elm
updateWithOrdinarySectionBlock accumulator name content level id =
    let
        ...
        blockCounter =
            0
        ...
    in
    { accumulator
        | headingIndex = headingIndex
        , blockCounter = blockCounter
        , counter = Dict.insert "equation" 0 accumulator.counter
    }
```

This means **theorem numbering restarts at each section**:

```
# Section 1
| theorem        → Theorem 1.1
| theorem        → Theorem 1.2

# Section 2      ← blockCounter reset to 0 here
| theorem        → Theorem 2.1
| theorem        → Theorem 2.2
```

Note: The equation counter (`acc.counter["equation"]`) is also reset to 0 at section boundaries.

## Where is a theorem number assigned?

The theorem number is assigned in **`transformBlock`** at lines 381-387:

```elm
-- Default insertion of "label" property (used for block numbering)
(if List.member name Generic.Settings.numberedBlockNames then
    { block
        | properties =
            Dict.insert "label"
                (vectorPrefix acc.headingIndex ++ String.fromInt acc.blockCounter)
                block.properties
    }
 else
    block
)
```

This inserts the number into `block.properties["label"]` as:
- `vectorPrefix acc.headingIndex` → e.g., `"1.2."` (the section prefix)
- `String.fromInt acc.blockCounter` → e.g., `"3"` (the theorem count within section)
- Result: `"1.2.3"`
