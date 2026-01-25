# Editor-Rendered Text Synchronization

This document describes the bidirectional synchronization system between the CodeMirror source editor and the rendered HTML output in the Scripta Demo application.

## Overview

The sync system provides two modes of synchronization:

1. **Right-to-Left (RL) Sync**: Click or select text in the rendered output → highlight corresponding source in the editor
2. **Left-to-Right (LR) Sync**: Select text in the editor + press Ctrl+S → highlight corresponding rendered text

Both modes use a cyan highlight color and support clearing via the ESC key.

## Architecture

```
┌─────────────────┐                    ┌──────────────────┐
│                 │   RL Sync (click)  │                  │
│   Rendered      │ ─────────────────► │   CodeMirror     │
│   Output        │                    │   Editor         │
│                 │ ◄───────────────── │                  │
│                 │   LR Sync (Ctrl+S) │                  │
└─────────────────┘                    └──────────────────┘
```

## Data Structures

### Expression Metadata (ExprMeta)

Each parsed expression carries metadata defined in `Types.elm`:

```elm
type alias ExprMeta =
    { begin : Int    -- Start character position within the block
    , end : Int      -- End character position within the block
    , index : Int    -- Token index
    , id : String    -- Unique identifier: "e-{lineNumber}.{tokenIndex}"
    }
```

### Element IDs

Rendered text elements have IDs in the format:
```
e-{lineNumber}.{tokenIndex}
```

Examples:
- `e-1.0` - First expression on line 1
- `e-42.3` - Fourth expression on line 42

### Data Attributes

Rendered text spans include position data attributes:

```html
<span id="e-42.0" data-begin="0" data-end="794">
  Lorem ipsum dolor sit amet...
</span>
```

- `data-begin`: Start position within the block's content
- `data-end`: End position within the block's content

## Right-to-Left Sync (Rendered → Editor)

### Single Click

When the user clicks on rendered text:

1. **Elm Event Handler**: The `onClick` attribute triggers `SendMeta meta`
2. **Message Handling**: `Main.elm` receives `CompilerMsg (SendMeta meta)`
3. **Position Extraction**: Line number is parsed from `meta.id` (format: `e-{line}.{token}`)
4. **Port Communication**: `selectInEditor` port sends `{ lineNumber, begin, end }` to JavaScript
5. **CodeMirror Update**: JavaScript calculates absolute position and applies highlight decoration

```elm
-- In Render/Expression.elm
renderText params str meta =
    Html.span
        [ HA.id meta.id
        , HA.attribute "data-begin" (String.fromInt meta.begin)
        , HA.attribute "data-end" (String.fromInt meta.end)
        , HE.onClick (SendMeta meta)
        ]
        [ Html.text str ]
```

### Text Selection

When the user selects a range of text in the rendered output:

1. **mouseup Event**: JavaScript captures the selection via `window.getSelection()`
2. **Element Discovery**: Walks up DOM tree to find elements with `data-begin` attribute
3. **Position Calculation**: Combines element's `data-begin` with selection offsets
4. **Click Prevention**: Sets flag to prevent subsequent click event from overwriting
5. **Multi-line Handling**: Uses `findAbsolutePosition()` to count through source lines

```javascript
// Selection offset calculation
var startChar = startBegin + range.startOffset + 1;
var endChar = startBegin + range.endOffset + 1;
```

The `+1` adjustment accounts for off-by-one between rendered text positions and source positions.

### Multi-line Paragraph Handling

For paragraphs spanning multiple source lines:

```javascript
function findAbsolutePosition(lineNum, charOffset) {
    var pos = doc.line(lineNum).from;
    var remaining = charOffset;
    var currentLine = lineNum;

    while (remaining > 0 && currentLine <= doc.lines) {
        var lineLength = doc.line(currentLine).length;
        if (remaining <= lineLength) {
            return pos + remaining;
        }
        remaining -= (lineLength + 1); // +1 for newline
        currentLine++;
        if (currentLine <= doc.lines) {
            pos = doc.line(currentLine).from;
        }
    }
    return pos + Math.max(0, remaining);
}
```

## Left-to-Right Sync (Editor → Rendered)

When the user selects text in the editor and presses Ctrl+S:

1. **Keymap Handler**: CodeMirror intercepts Ctrl+S
2. **Selection Info**: Extracts line number and character offset from selection
3. **Custom Event**: Dispatches `sync-to-rendered` event with position data
4. **Element Search**: JavaScript searches rendered elements for best match
5. **Highlight Application**: Adds CSS class and scrolls element into view

```javascript
// In codemirror-element.js
{ key: 'Ctrl-s', run: (view) => {
    const sel = view.state.selection.main;
    if (sel.empty) return false;

    const fromLine = view.state.doc.lineAt(sel.from);
    const lineNum = fromLine.number;
    const charInLine = sel.from - fromLine.from;

    const event = new CustomEvent('sync-to-rendered', {
        detail: {
            lineNumber: lineNum,
            charOffset: charInLine,
            selectionLength: sel.to - sel.from
        },
        bubbles: true,
        composed: true
    });
    view.dom.dispatchEvent(event);
    return true;
}}
```

### Element Matching Algorithm

The LR sync finds the best matching rendered element:

```javascript
allElements.forEach(function(el) {
    var elLineStr = el.id.substring(2).split('.')[0];
    var elLine = parseInt(elLineStr, 10);

    // Element's line should be <= selected line
    // (block starts before or at selection)
    if (elLine <= lineNumber) {
        var distance = lineNumber - elLine;
        if (distance < bestLineDistance) {
            bestLineDistance = distance;
            bestMatch = el;
        }
    }
});
```

This handles multi-line paragraphs where the element's line number is the start of the block, but the selection may be on a later line within that block.

## CodeMirror Decoration System

The editor uses CodeMirror 6's decoration system for persistent highlights:

### State Effects

```javascript
const setSyncHighlight = StateEffect.define();
const clearSyncHighlight = StateEffect.define();
```

### State Field

```javascript
const syncHighlightField = StateField.define({
    create() {
        return Decoration.none;
    },
    update(decorations, tr) {
        decorations = decorations.map(tr.changes);
        for (let effect of tr.effects) {
            if (effect.is(setSyncHighlight)) {
                const { from, to } = effect.value;
                decorations = Decoration.set([syncHighlightMark.range(from, to)]);
            } else if (effect.is(clearSyncHighlight)) {
                decorations = Decoration.none;
            }
        }
        return decorations;
    },
    provide: f => EditorView.decorations.from(f)
});
```

### CSS Styling

```css
.cm-sync-highlight {
    background-color: rgba(0, 255, 255, 0.5);  /* cyan */
}

.rendered-sync-highlight {
    background-color: rgba(0, 255, 255, 0.5) !important;
    outline: 2px solid cyan;
}
```

## Clearing Highlights

The ESC key clears all highlights:

```javascript
{ key: 'Escape', run: (view) => {
    // Clear editor highlight
    view.dispatch({ effects: clearSyncHighlight.of(null) });

    // Clear rendered output highlight
    document.querySelectorAll('.rendered-sync-highlight').forEach(el => {
        el.classList.remove('rendered-sync-highlight');
    });
    return true;
}}
```

## Port Definitions

### Outgoing Port (Elm → JavaScript)

```elm
port selectInEditor : { lineNumber : Int, begin : Int, end : Int } -> Cmd msg
```

### Port Subscription (JavaScript)

```javascript
app.ports.selectInEditor.subscribe(function(selection) {
    // Handle sync to editor
});
```

## Click vs Selection Disambiguation

To prevent click events from overwriting selection highlights:

```javascript
var handledTextSelection = false;

document.addEventListener('click', function(e) {
    if (handledTextSelection) {
        handledTextSelection = false;
        e.stopPropagation();
        e.preventDefault();
        return false;
    }
}, true); // Capture phase

document.addEventListener('mouseup', function(e) {
    handledTextSelection = false;
    // ... selection handling ...
    if (hasSelection) {
        handledTextSelection = true;
    }
});
```

## File Locations

| File | Purpose |
|------|---------|
| `Demo/codemirror-element.js` | CodeMirror custom element, keymaps, decorations |
| `Demo/index.html` | JavaScript event handlers, ports, CSS |
| `Demo/src/Main.elm` | Port definitions, message handling |
| `src/Render/Expression.elm` | Text rendering with data attributes and click handlers |
| `src/Types.elm` | ExprMeta type definition, Msg types |

## Known Limitations

1. **Multi-line Block Position**: For paragraphs spanning many lines, the LR sync finds the block but may not pinpoint the exact position within it.

2. **Character Position Accuracy**: The +1 offset adjustment is empirical; complex markup may require refinement.

3. **Nested Elements**: Deeply nested markup elements may require walking up multiple DOM levels to find position data.

4. **Math Content**: Math elements rendered via KaTeX use Shadow DOM and may require special handling for sync.

## Future Improvements

1. **Bidirectional Cursor Sync**: Real-time cursor position sync without requiring click/Ctrl+S
2. **Range Highlighting**: Highlight exact character ranges in LR sync, not just the containing block
3. **Visual Indicators**: Add line markers or minimap indicators for sync targets
4. **Error Position Sync**: Click on error messages to jump to source location
