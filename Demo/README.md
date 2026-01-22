# Scripta Compiler Demo

A simple demo app for testing the Scripta compiler with live preview.

## Features

- Side-by-side editor and rendered output
- Resizable window (both panels scale)
- Light/Dark theme toggle
- KaTeX math rendering via custom element

## Running

```bash
# Compile the Elm app
elm make src/Main.elm --output=main.js

# Open index.html in a browser
open index.html
# or use a local server:
python3 -m http.server 8080
```

Then open http://localhost:8080 in your browser.

## Structure

- `src/Main.elm` - Main Elm application
- `index.html` - HTML host with KaTeX and math-text custom element
- `elm.json` - Project config (references parent src for compiler modules)
