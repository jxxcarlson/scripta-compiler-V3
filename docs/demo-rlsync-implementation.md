# Plan: Disable click-sync, keep selection-sync for right-to-left

## Context

Two right-to-left sync mechanisms exist:
1. **Click sync**: Click rendered text → `SendMeta`/`SendBlockMeta` Elm msg → `selectInEditor` port → highlight paragraph in editor. **Working but causes timing conflict.**
2. **Selection sync**: Select text in rendered output → JS `mouseup` handler finds `data-begin`/`data-end` attrs → highlight exact snippet in editor via CodeMirror `setSyncHighlight`. **Broken by timing conflict with (1).**

The conflict: after a mouse-drag selection, both `mouseup` and `click` fire. The `mouseup` handler sets up selection sync, but the `click` handler (Elm's `stopPropagationOn "click"` in `rlSync`) fires `SendMeta`, which overwrites the selection highlight with a paragraph-level highlight. A `handledTextSelection` flag + capture-phase click blocker exists as a workaround but doesn't reliably prevent Elm's handler.

**Fix**: Disable (1) entirely so (2) works without interference.

## Changes

### 1. Remove click handlers from `rlSync` and `rlBlockSync`
**File**: `src/Render/Utility.elm`

- `rlSync` (line 15-35): Remove the `HE.stopPropagationOn "click"` handler. Keep `HA.id`, `HA.attribute "data-begin"`, `HA.attribute "data-end"` (needed by selection sync JS).
- `rlBlockSync` (line 38-57): Remove the `HE.stopPropagationOn "click"` handler. Keep `HA.attribute "data-begin"` and `"data-end"`.

### 2. Simplify Main.elm CompilerMsg handlers
**File**: `Demo/src/Main.elm`

- `SendMeta` case (line 590-611): Change to no-op (no `selectInEditor` call, no `selectedId` update).
- `SendBlockMeta` case (line 613-623): Change to no-op.

### 3. Remove JS timing workaround
**File**: `Demo/index.html`

- Remove the `handledTextSelection` flag (line 292) and capture-phase click blocker (lines 295-302). No longer needed since no Elm click handler competes with the mouseup selection handler.

## Verification

1. `cd /Users/carlson/dev/elm-work/scripta/scripta-compiler-v3 && elm make Demo/src/Main.elm --output=Demo/main.js`
2. Open Demo in browser, select text in rendered output → should highlight corresponding snippet in editor
3. Plain click on rendered text → should do nothing (no editor sync)
4. Citations, footnotes, Q-block clicks → should still work (they use their own `HE.custom "click"` handlers, not `rlSync`)