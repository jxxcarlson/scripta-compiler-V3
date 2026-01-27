# Shift-ESC to Remove All Highlights

## Overview

Pressing **Shift+ESC** clears all highlighting in the rendered document without scrolling. This complements the **ESC** key which returns to the previous position.

## The Problem

When a user clicks on a cross-reference (like an index entry), the document scrolls to the target and highlights it. The user may want to clear this highlighting without changing their scroll position.

Initial attempts to implement this revealed a subtle browser behavior: when clearing the highlight state, the browser would scroll back to the original click location (the "departure point"). This happened because:

1. Clicking a link (`<a href="#target">`) gives that link focus
2. When Elm re-renders the DOM (to remove highlighting), the browser attempts to keep the focused element visible
3. Even after blurring the focused element, scroll restoration could occur due to browser history/hash handling

## The Solution

The solution required three components working together:

### 1. Blur the Active Element

When Shift+ESC is pressed, we blur the currently focused element to prevent focus-based scroll restoration:

```elm
-- Demo/src/Main.elm
port blurActiveElement : () -> Cmd msg
```

```javascript
// Demo/index.html
app.ports.blurActiveElement.subscribe(function() {
    if (document.activeElement && document.activeElement !== document.body) {
        document.activeElement.blur();
    }
});
```

### 2. Preserve Scroll Position

Blurring alone wasn't sufficient. We also explicitly capture and restore the scroll position:

```elm
-- Demo/src/Main.elm
port preserveScrollPosition : () -> Cmd msg
```

```javascript
// Demo/index.html
app.ports.preserveScrollPosition.subscribe(function() {
    var renderedOutput = document.getElementById('rendered-output');
    if (renderedOutput) {
        var scrollTop = renderedOutput.scrollTop;
        // Use requestAnimationFrame to restore after DOM updates
        requestAnimationFrame(function() {
            requestAnimationFrame(function() {
                renderedOutput.scrollTop = scrollTop;
            });
        });
    }
});
```

The double `requestAnimationFrame` is necessary because:
- The first frame waits for Elm's virtual DOM diff to be applied
- The second frame ensures the browser's layout/paint cycle is complete
- Only then do we restore the scroll position, overriding any browser-initiated scrolling

### 3. Elm Update Handler

The Shift+ESC handler clears the selection state and invokes both ports:

```elm
ShiftEscapePressed ->
    ( { model
        | selectedId = ""
        , previousId = ""
      }
    , Cmd.batch [ blurActiveElement (), preserveScrollPosition () ]
    )
```

## Keyboard Event Detection

We use `onKeyUp` rather than `onKeyDown` because text editors (like CodeMirror) often capture keydown events but allow keyup to propagate:

```elm
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize WindowResized
        , Browser.Events.onKeyUp escapeKeyDecoder
        ]

escapeKeyDecoder : Decode.Decoder Msg
escapeKeyDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "key" Decode.string)
        (Decode.field "shiftKey" Decode.bool)
        |> Decode.andThen
            (\( key, shiftKey ) ->
                if key == "Escape" then
                    if shiftKey then
                        Decode.succeed ShiftEscapePressed
                    else
                        Decode.succeed EscapePressed
                else
                    Decode.fail "not escape"
            )
```

## Summary

| Key | Action |
|-----|--------|
| **ESC** | Return to previous position (toggle between two positions) |
| **Shift+ESC** | Clear all highlighting, stay at current scroll position |

## Files Modified

- `Demo/src/Main.elm` - Added `ShiftEscapePressed` message, ports, and handler
- `Demo/index.html` - Added JavaScript port handlers for blur and scroll preservation
