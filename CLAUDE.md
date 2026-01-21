# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Scripta Compiler V3 is an Elm 0.19.1 application building a new compiler for the Scripta language, incorporating lessons learned from the V2 implementation. Currently in Phase 1: establishing foundational types.

**Related Project**: V2 Compiler at `/Users/carlson/dev/elm-work/scripta/scripta-compiler-v2`

## Build Commands

```bash
# Build to JavaScript
elm make src/Main.elm --output=main.js

# Optimized production build
elm make src/Main.elm --output=main.js --optimize

# Hot-reloading development
elm-watch hot

# Interactive REPL
elm repl

# Run tests (when test infrastructure is added)
elm-test
elm-test --watch

# Code review (when elm-review is configured)
npx elm-review --fix-all
```

## Architecture

The Scripta language is organized into **Blocks** and **Expressions**:

### Blocks (`src/Types.elm`)
- `GenericBlock` (lines 27-36): Parametric block structure with heading, indentation, arguments, properties, content, metadata, and optional styling
- `PrimitiveBlock` (line 45-46): Block with `List String` content (raw text lines)
- `ExpressionBlock` (line 50-51): Block with `Either String (List Expression)` content (parsed expressions or error)
- `Heading` type (lines 38-41): `Paragraph`, `Ordinary String`, or `Verbatim String`

### Expressions (`src/Types.elm`)
- `Expression` (line 56-57): Alias for `Expr ExprMeta`
- `Expr` type (lines 59-63):
  - `Text String metaData` - plain text
  - `Fun String (List (Expr metaData)) metaData` - function application
  - `VFun String String metaData` - verbatim function
  - `ExprList Int (List (Expr metaData)) metaData` - indentation-aware expression list

### Metadata
- `BlockMeta` (lines 69-77): position, lineNumber, numberOfLines, id, messages, sourceText, error
- `ExprMeta` (lines 80-81): begin, end, index, id

## Dependencies

- `elm/browser`, `elm/core`, `elm/html` - standard Elm packages
- `toastal/either` - Either type for error handling in ExpressionBlock content
