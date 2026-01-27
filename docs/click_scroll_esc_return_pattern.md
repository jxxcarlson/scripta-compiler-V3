# Click-Scroll-ESC-Return Navigation Pattern

This document describes the bidirectional navigation pattern used for cross-references in Scripta documents.

## Overview

When a user clicks on a cross-reference (like `[ref label]`, `[eqref label]`, `[cite key]`, or a footnote), the document scrolls to the referenced element and highlights it.

**Keyboard shortcuts:**
- **ESC** - Return to the previous position (toggles between current and previous)
- **Shift+ESC** - Clear all highlighting

## Architecture

### Components

1. **Model State** (`Demo/src/Main.elm`)
   - `selectedId : String` - Currently selected/highlighted element ID
   - `previousId : String` - Previous position for ESC-return navigation

2. **Message Types** (`Types.elm` and `Demo/src/Main.elm`)
   - `SelectId String` - Compiler message for selecting an element (triggers scroll)
   - `EscapePressed` - App message for ESC key press (triggers return scroll)
   - `ShiftEscapePressed` - App message for Shift+ESC (clears all highlighting)

3. **Ports** (`Demo/src/Main.elm`)
   - `scrollToElement : String -> Cmd msg` - Scrolls element into view

4. **Subscriptions** (`Demo/src/Main.elm`)
   - `Browser.Events.onKeyDown` - Listens for ESC key

### Flow

```
User clicks [ref foo]
    |
    v
SelectId "foo" message
    |
    v
Update handler:
  1. Save model.selectedId to model.previousId
  2. Set model.selectedId = "foo"
  3. Call scrollToElement "foo"
    |
    v
JavaScript port scrolls to element
    |
    v
User presses ESC
    |
    v
EscapePressed message
    |
    v
Update handler:
  1. Swap selectedId and previousId
  2. Call scrollToElement model.previousId
    |
    v
Document returns to original position
```

## Implementation Details

### Rendering Cross-References (`src/Render/Expression.elm`)

Cross-references emit `SelectId` on click:

```elm
renderRef : CompilerParameters -> Accumulator -> List Expression -> ExprMeta -> Html Msg
renderRef _ acc args meta =
    case args of
        [ Text refId _ ] ->
            case Dict.get refId acc.reference of
                Just { numRef } ->
                    Html.a
                        [ HA.id meta.id
                        , HA.href ("#" ++ refId)
                        , HE.preventDefaultOn "click" (Decode.succeed ( SelectId refId, True ))
                        ...
                        ]
                        [ Html.text numRef ]
```

Key points:
- `HA.href` provides fallback for non-JS browsers
- `HE.preventDefaultOn "click"` prevents default anchor behavior
- `SelectId refId` triggers the Elm scroll handling

### Handling SelectId (`Demo/src/Main.elm`)

```elm
Types.SelectId id ->
    ( { model
        | selectedId = id
        , previousId = model.selectedId  -- Save current position
        , debugClickCount = newClickCount
      }
    , scrollToElement id
    )
```

### Handling ESC Key (`Demo/src/Main.elm`)

```elm
EscapePressed ->
    if model.previousId /= "" then
        ( { model
            | selectedId = model.previousId
            , previousId = model.selectedId  -- Enable toggling back
          }
        , scrollToElement model.previousId
        )
    else
        ( model, Cmd.none )

ShiftEscapePressed ->
    -- Clear all highlighting
    ( { model
        | selectedId = ""
        , previousId = ""
      }
    , Cmd.none
    )
```

### JavaScript Port (`Demo/index.html`)

```javascript
app.ports.scrollToElement.subscribe(function(id) {
    requestAnimationFrame(function() {
        var element = document.getElementById(id);
        if (element) {
            element.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    });
});
```

## Elements Using This Pattern

| Element | Render Function | Target Lookup |
|---------|-----------------|---------------|
| `[ref label]` | `renderRef` | `acc.reference[label].id` (uses label as slug) |
| `[eqref label]` | `renderEqRef` | `acc.reference[label].id` |
| `[cite key]` | `renderCite` | `key + ":" + number` |
| `[footnote ...]` | `renderFootnote` | `textMeta.id + "_"` |
| Index entries | `renderIndexBlock` | `loc.id` |

## Highlighting

The `selectedId` is passed to render functions via `CompilerParameters.selectedId`. Blocks check if their ID matches and apply highlight styling:

```elm
selectedStyle : String -> String -> Theme -> List (Html.Attribute msg)
selectedStyle selectedId blockId theme =
    if selectedId == blockId then
        [ HA.style "background-color" highlightColor ]
    else
        []
```

## Notes

- The pattern supports repeated ESC presses to toggle between two positions
- Empty `previousId` means no return position is available (ESC does nothing)
- Each new `SelectId` overwrites the previous return position (no history stack)
