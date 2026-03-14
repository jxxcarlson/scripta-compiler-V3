# Scripta Language Overview

Scripta is a two-level markup language designed for mathematical and technical writing. Documents are composed of **blocks** (structural elements) and **expressions** (inline markup within blocks).

## Block Syntax

Blocks are separated by blank lines. There are three kinds:

**Paragraphs** — plain text lines with no prefix:
```
This is a paragraph with [b bold] and [i italic] text.
```

**Ordinary blocks** — `| name` prefix, content is parsed for inline expressions:
```
| theorem
There are infinitely many primes.
```

**Verbatim blocks** — `| name` prefix, content preserved as-is (math, code, etc.):
```
| equation
a^2 + b^2 = c^2
```

Blocks accept arguments and key:value properties on the header line(s):
```
| image expandable float:left width:300
| caption:My Image
https://example.com/image.jpg
```

## Markdown Shortcuts

- `# Heading` / `## Heading` / `### Heading` → section levels
- `- item` → bullet list (`| item`)
- `. item` → numbered list (`| numbered`)
- `$$` ... `$$` → math block
- `` ``` `` → code block

## Inline Expression Syntax

Inline elements use bracket notation: `[function args...]`

**Formatting:** `[b bold]`, `[i italic]`, `[bi bold-italic]`, `[strike text]`, `[underline text]`

**Colors:** `[red text]`, `[blue text]`, `[green text]`, `[highlight text]`

**Math:** `$a^2 + b^2$` or `[m frac(1,2)]` — uses ETeX notation (simplified LaTeX)

**Links:** `[link Label URL]`, `[ilink Label targetId]`

**References:** `[ref label]`, `[eqref label]`, `[cite key]`

**Special:** `[footnote text]`, `[sup x]`, `[sub x]`, `[code snippet]`, `[image URL]`

**Symbols:** `[mdash]`, `[ndash]`, `[dollarSign]`, `[lb]`, `[rb]`, checkboxes (`[box]`, `[cbox]`, etc.)

## Block Types

| Category | Blocks |
|----------|--------|
| **Structure** | `section`, `chapter`, `title`, `subtitle`, `author`, `date`, `contents`, `index`, `endnotes` |
| **Theorem-like** | `theorem`, `lemma`, `corollary`, `proposition`, `definition`, `proof`, `remark`, `example`, `exercise`, `note`, `problem`, `question`, `answer`, `axiom` |
| **Math** | `math`, `equation`, `aligned`, `array` |
| **Code** | `code` (with language argument, e.g. `| code elm`) |
| **Lists** | `item`, `numbered`, `desc`, `itemList`, `numberedList` |
| **Formatting** | `indent`, `quotation`, `quote`, `center`, `abstract`, `box`, `compact`, `color` |
| **Media** | `image`, `iframe`, `svg`, `tikz`, `quiver`, `chart` |
| **Data** | `table`, `datatable`, `csvtable`, `textarray` |
| **Macros** | `mathmacros`, `textmacros` |
| **Document** | `document`, `book`, `article`, `bibitem`, `collection`, `settings` |

## ETeX Math Notation

Scripta uses ETeX, a simplified notation that compiles to LaTeX:

| ETeX | LaTeX |
|------|-------|
| `frac(a,b)` | `\frac{a}{b}` |
| `sqrt(x)` | `\sqrt{x}` |
| `int_0^1` | `\int_0^1` |
| `sum_(i=1)^n` | `\sum_{i=1}^n` |
| `alpha`, `beta` | `\alpha`, `\beta` |

## Cross-References

Blocks can be labeled and referenced:
```
| equation label:pythag
a^2 + b^2 = c^2

See equation [eqref pythag] for the Pythagorean theorem.
```

The accumulator resolves labels to display numbers (e.g., "Theorem 2.1", equation "(3)").
