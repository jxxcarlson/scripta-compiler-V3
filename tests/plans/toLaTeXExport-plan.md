# Plan: LaTeX Export Test Tool

## Context

We need a CLI tool to test the Scripta-to-LaTeX export pipeline. Given a `.scripta` source file, the tool converts it to LaTeX using the V3 compiler, sends the LaTeX to the PDF server at `localhost:3000`, and captures the error report (if any) as a JSON file. This enables iterative improvement of the LaTeX export without manually going through the V3 app UI.

## Prerequisites: Fix Missing Modules

Three modules imported by `Render.Export.LaTeX` don't exist yet in V3. These must be created before the export pipeline can compile.

### P1. Create `src/Render/Types.elm`

Port directly from V2 (`/Users/carlson/dev/elm-work/scripta/scripta-compiler-v2/src/Render/Types.elm`). It's 19 lines defining `PublicationData` and `DocumentKind(DKArticle|DKChapter|DKBook)`.

### P2. Create `src/Render/Settings.elm`

Minimal version. The export code only accesses `settings.properties` (Dict String String), `settings.windowWidth` (Int), and uses `isStandaloneDocument` conceptually. Define:

```elm
module Render.Settings exposing (RenderSettings, defaultRenderSettings)

type alias RenderSettings =
    { windowWidth : Int
    , properties : Dict String String
    , isStandaloneDocument : Bool
    }
```

### P3. Move `src/Tools/Util.elm` → `src/MiniLaTeX/Util.elm`

The file declares `module MiniLaTeX.Util` but lives at the wrong path. Elm requires the file path to match the module name.

### P4. Verify compilation

Run `elm make src/Render/Export/LaTeX.elm --output=/dev/null` and fix any remaining errors.

## Implementation Steps

### Step 1. Create `tests/toLaTeXExport/elm.json`

Separate elm.json referencing `../../src`. Copy dependency versions from the root `elm.json` and `Demo/elm.json` (they match). Source directories: `[".", "../../src"]`.

### Step 2. Create `tests/toLaTeXExport/Worker.elm`

An Elm `Platform.worker` with two ports:

- **Incoming** `receiveSourceText : (String -> msg) -> Sub msg` — receives the .scripta source
- **Outgoing** `sendLaTeX : String -> Cmd msg` — emits the generated LaTeX

On receiving source text:
1. Parse: `Parser.Forest.parseToForestWithAccumulator params (String.lines sourceText)`
2. Resolve publication data: `Render.Export.LaTeX.getPublicationData defaultPubData forest`
3. Export: `Render.Export.LaTeX.export resolvedPubData settings forest`
4. Send LaTeX string via outgoing port

Defaults: `DKArticle`, `"test-author"`, standalone document, 600px width.

### Step 3. Create `tests/toLaTeXExport/run.js`

Node.js script:

```
Usage: node run.js <path-to-scripta-file>
```

1. Read the `.scripta` file from disk
2. Boot the compiled Elm worker (`require('./worker.js')`)
3. Send source text to Elm via `receiveSourceText.send()`
4. Receive LaTeX from `sendLaTeX.subscribe()`
5. POST JSON to `http://localhost:3000/pdf`:
   ```json
   {"id": "FILENAME.tex", "content": "<latex>", "urlList": [], "packageList": []}
   ```
6. Parse response. If `hasErrors`:
   - Fetch error JSON from `http://localhost:3000/outbox/FILENAME-errors.json`
   - Write to `tests/toLaTeXExportTestDocs/FILENAME-errors.json`
7. If no errors: write `{"hasErrors": false}` to that same path
8. Also write the generated LaTeX to `tests/toLaTeXExportTestDocs/FILENAME.tex` for debugging

### Step 4. Create `tests/toLaTeXExport/Makefile`

Targets:
- `build` — `elm make Worker.elm --output=worker.js`
- `test` — build + `node run.js ../toLaTeXExportTestDocs/welcome.scripta`
- `clean` — remove worker.js and elm-stuff

### Step 5. Verify end-to-end

1. Start the PDF server: `cd /Users/carlson/dev/elm-work/scripta/pdfServer2 && stack run`
2. `cd tests/toLaTeXExport && make test`
3. Check `tests/toLaTeXExportTestDocs/welcome-errors.json` and `welcome.tex`

## Files Created

| File | Purpose |
|------|---------|
| `src/Render/Types.elm` | PublicationData, DocumentKind types (port from V2) |
| `src/Render/Settings.elm` | RenderSettings type and defaults |
| `src/MiniLaTeX/Util.elm` | Copy from `src/Tools/Util.elm` (fix path mismatch) |
| `tests/toLaTeXExport/elm.json` | Elm project config for the worker |
| `tests/toLaTeXExport/Worker.elm` | Platform.worker: Scripta → LaTeX |
| `tests/toLaTeXExport/run.js` | Node.js CLI: file I/O + HTTP to PDF server |
| `tests/toLaTeXExport/Makefile` | Build and run targets |

## Key Existing Code Reused

- `Parser.Forest.parseToForestWithAccumulator` (`src/Parser/Forest.elm:53`) — parsing pipeline
- `Render.Export.LaTeX.export` (`src/Render/Export/LaTeX.elm:108`) — LaTeX export
- `Render.Export.LaTeX.getPublicationData` (`src/Render/Export/LaTeX.elm:42`) — title/author resolution
- `TestData.defaultCompilerParameters` (`src/TestData.elm:25`) — compiler defaults
