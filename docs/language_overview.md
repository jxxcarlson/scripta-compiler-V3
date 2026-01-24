# Scripta Language Reference

This document provides a comprehensive reference for the Scripta markup language, covering inline elements, ordinary blocks, and verbatim blocks.

---

## Table of Contents

1. [Inline Elements](#inline-elements)
   - [Text Formatting](#text-formatting)
   - [Colors](#colors)
   - [Links](#links)
   - [References](#references)
   - [Special Characters](#special-characters)
   - [Checkboxes](#checkboxes)
   - [Math](#math-inline)
   - [Code](#code-inline)
   - [Structure](#structure)
   - [Tables (Inline)](#tables-inline)
   - [Images (Inline)](#images-inline)
   - [Bibliography (Inline)](#bibliography-inline)
   - [Specialized Links](#specialized-links)
   - [Interactive](#interactive)
   - [Miscellaneous](#miscellaneous)

2. [Ordinary Blocks](#ordinary-blocks)
   - [Section Headings](#section-headings)
   - [Lists](#lists)
   - [Theorem-like Environments](#theorem-like-environments)
   - [Formatting Blocks](#formatting-blocks)
   - [Document Metadata](#document-metadata)
   - [Special Blocks](#special-blocks)
   - [Tables (Block)](#tables-block)
   - [Q&A](#qa)
   - [Additional Blocks](#additional-blocks)

3. [Verbatim Blocks](#verbatim-blocks)
   - [Math Blocks](#math-blocks)
   - [Code Blocks](#code-blocks)
   - [Verse](#verse)
   - [Macro Definitions](#macro-definitions)
   - [Data and Charts](#data-and-charts)
   - [Graphics](#graphics)
   - [Media](#media)
   - [Chemistry](#chemistry)
   - [Arrays](#arrays)
   - [Raw Verbatim](#raw-verbatim)

---

## Inline Elements

Inline elements are enclosed in square brackets: `[name content]` or `[name arg1 arg2]`.

### Text Formatting

#### strong / bold / b
Render bold/strong text.

**Syntax:**
```
[strong bold text]
[b bold text]
[bold bold text]
[textbf bold text]
```

**Example:**
```
This is [strong important] information.
```

---

#### italic / i / emph
Render italic/emphasized text.

**Syntax:**
```
[italic emphasized text]
[i emphasized text]
[emph emphasized text]
[textit italic text]
```

**Example:**
```
The word [italic entropy] comes from Greek.
```

---

#### strike
Render strikethrough text.

**Syntax:**
```
[strike deleted text]
```

**Example:**
```
This feature is [strike deprecated] removed.
```

---

#### underline / u / underscore
Render underlined text.

**Syntax:**
```
[underline important text]
[u underlined]
```

**Example:**
```
Please [underline read carefully].
```

---

#### bi / boldItalic
Render bold italic text.

**Syntax:**
```
[bi bold and italic]
[boldItalic text]
```

**Example:**
```
[bi Warning:] This is critical.
```

---

#### var
Render a variable (no special formatting, semantic markup).

**Syntax:**
```
[var x]
```

---

#### title (inline)
Render inline title text (32px).

**Syntax:**
```
[title Document Title]
```

---

#### subheading / sh
Render an inline subheading (18px).

**Syntax:**
```
[subheading Section Name]
[sh Section Name]
```

---

#### smallsubheading / ssh
Render a small subheading (16px, italic).

**Syntax:**
```
[smallsubheading Minor Heading]
[ssh Minor Heading]
```

---

#### large
Render large text (18px).

**Syntax:**
```
[large larger text]
```

---

### Colors

#### red / blue / green / pink / magenta / violet / gray
Render colored text.

**Syntax:**
```
[red warning text]
[blue info text]
[green success text]
[pink soft color]
[magenta bright color]
[violet purple shade]
[gray muted text]
```

**Example:**
```
[red Error:] Something went wrong.
[green Success!] Operation completed.
```

---

#### comment
Render text in blue (for comments/annotations).

**Syntax:**
```
[comment This is a comment]
```

---

#### highlight
Render highlighted text with background color.

**Syntax:**
```
[highlight important text]
[highlight [color blue] blue highlighted]
```

**Arguments:**
- `[color colorname]` - Optional color specification

**Available colors:** yellow (default), blue, green, pink, orange, purple, cyan, gray.

**Example:**
```
Please [highlight review this section].
The [highlight [color green] approved] items are listed below.
```

---

#### errorHighlight
Render error-highlighted text (red background).

**Syntax:**
```
[errorHighlight problematic text]
```

---

### Links

#### link
Render a hyperlink.

**Syntax:**
```
[link Label https://example.com]
[link https://example.com]
```

**Example:**
```
Visit [link our website https://example.com] for more info.
```

---

#### href
Render a URL as a clickable link (URL displayed as label).

**Syntax:**
```
[href https://example.com]
```

---

#### ilink
Render an internal document link.

**Syntax:**
```
[ilink Label targetId]
```

**Example:**
```
See [ilink Section 1 sec1] for details.
```

Clicking navigates within the document to the element with id `targetId`.

---

### References

#### ref
Render a cross-reference to a labeled element.

**Syntax:**
```
[ref labelId]
```

**Example:**
```
As shown in Theorem [ref theorem1], we have...
```

Displays the number of the referenced element.

---

#### eqref
Render a cross-reference to an equation.

**Syntax:**
```
[eqref eq1]
```

**Example:**
```
From equation [eqref einstein], we derive...
```

Displays as "(N)" where N is the equation number.

---

#### cite
Render a citation.

**Syntax:**
```
[cite key]
```

**Example:**
```
According to Einstein [cite einstein1905], time is relative.
```

Displays as "[key]".

---

### Special Characters

#### mdash
Render an em dash (—).

**Syntax:**
```
[mdash]
```

---

#### ndash
Render an en dash (–).

**Syntax:**
```
[ndash]
```

---

#### dollarSign / dollar / ds
Render a dollar sign ($).

**Syntax:**
```
[dollarSign]
[dollar]
[ds]
```

---

#### backTick / bt
Render a backtick (`).

**Syntax:**
```
[backTick]
[bt]
```

---

#### rb
Render a right bracket (]).

**Syntax:**
```
[rb]
```

---

#### lb
Render a left bracket ([).

**Syntax:**
```
[lb]
```

---

#### brackets
Render content in square brackets.

**Syntax:**
```
[brackets content]
```

**Example:**
```
The array [brackets 1, 2, 3] contains three elements.
```

---

### Checkboxes

#### box
Render an empty checkbox.

**Syntax:**
```
[box]
```

Displays: ☐

---

#### cbox
Render a checked checkbox.

**Syntax:**
```
[cbox]
```

Displays: ☑

---

#### rbox
Render a red empty checkbox.

**Syntax:**
```
[rbox]
```

Displays: ☐ (in red)

---

#### crbox
Render a red checked checkbox.

**Syntax:**
```
[crbox]
```

Displays: ☑ (in red)

---

#### fbox
Render a filled box.

**Syntax:**
```
[fbox]
```

Displays: ■

---

#### frbox
Render a red filled box.

**Syntax:**
```
[frbox]
```

Displays: ■ (in red)

---

### Math (Inline)

#### $ / math / m
Render inline math using ETeX notation.

**Syntax:**
```
$a^2 + b^2 = c^2$
`math a^2 + b^2 = c^2`
`m frac(1,2)`
```

ETeX notation is automatically converted to LaTeX. For example:
- `int_0^2` → `\int_0^2`
- `frac(1,n+1)` → `\frac{1}{n+1}`
- `sum_(i=1)^n` → `\sum_{i=1}^n`

---

#### chem
Render a chemistry formula using mhchem notation.

**Syntax:**
```
`chem H2O`
`chem 2H2 + O2 -> 2H2O`
```

---

### Code (Inline)

#### code / `
Render inline code.

**Syntax:**
```
`code function hello()`
`` `inline code` ``
```

**Example:**
```
Use the `code print()` function to output text.
```

---

### Structure

#### // / par
Render a paragraph break.

**Syntax:**
```
[//]
[par]
```

---

#### indent
Render inline indentation (2em).

**Syntax:**
```
[indent]
```

---

#### quote
Render quoted text with curly quotes.

**Syntax:**
```
[quote text here]
```

**Example:**
```
He said, [quote To be or not to be].
```

Renders with curly quotes: "To be or not to be"

---

#### vspace / break
Render vertical space.

**Syntax:**
```
[vspace 20]
[break 10]
```

**Arguments:**
- Height in pixels

---

#### qed
Render Q.E.D. marker (end of proof).

**Syntax:**
```
[qed]
```

Displays: Q.E.D.

---

#### abstract (inline)
Render inline abstract with "Abstract." prefix.

**Syntax:**
```
[abstract text here]
```

---

#### anchor
Render underlined text (for visual anchoring).

**Syntax:**
```
[anchor some text]
```

---

#### footnote
Render a footnote reference.

**Syntax:**
```
[footnote This is the footnote text.]
```

Displays as superscript number linking to endnotes.

---

#### marked
Render marked/labeled content.

**Syntax:**
```
[marked label content]
```

First argument is used as the element ID.

---

#### hrule
Render a horizontal rule.

**Syntax:**
```
[hrule]
```

---

#### mark
Render a mark with anchor.

**Syntax:**
```
[mark id [anchor text]]
```

Sets element ID for linking.

---

### Tables (Inline)

#### table (inline)
Render an inline table.

**Syntax:**
```
[table [tableRow [tableItem A][tableItem B]] [tableRow [tableItem 1][tableItem 2]]]
```

---

#### tableRow
Render a table row.

**Syntax:**
```
[tableRow [tableItem A][tableItem B]]
```

---

#### tableItem
Render a table cell.

**Syntax:**
```
[tableItem cell content]
```

---

### Images (Inline)

#### image (inline)
Render an inline image.

**Syntax:**
```
[image https://example.com/photo.jpg]
```

---

#### inlineimage
Render a small inline image (fits within text line).

**Syntax:**
```
[inlineimage https://example.com/icon.png]
```

Max height is 1.5em to fit inline.

---

### Bibliography (Inline)

#### bibitem (inline)
Render an inline bibliography reference.

**Syntax:**
```
[bibitem einstein1905]
```

---

### Specialized Links

#### ulink
Render a user-defined internal navigation link.

**Syntax:**
```
[ulink Label targetId]
```

Last word is the target ID.

**Example:**
```
[ulink Section 1 sec1]
```

---

#### reflink
Render a reference link with lookup.

**Syntax:**
```
[reflink Label key]
```

Last word is the reference key.

**Example:**
```
[reflink Theorem theorem1]
```

---

#### cslink
Render a cross-site link.

**Syntax:**
```
[cslink Label pageId]
```

---

### Interactive

#### scheme
Render Scheme code (monospace).

**Syntax:**
```
[scheme (+ 1 2)]
```

---

#### compute
Render a compute placeholder.

**Syntax:**
```
[compute expression]
```

Displays as "[compute: ...]".

---

#### data
Render a data placeholder.

**Syntax:**
```
[data key]
```

Displays as "[data: ...]".

---

#### button
Render a button.

**Syntax:**
```
[button Label, action]
```

First part before comma is the label.

---

### Miscellaneous

#### sup
Render superscript text.

**Syntax:**
```
[sup 2]
```

**Example:**
```
x[sup 2] + y[sup 2]
```

---

#### sub
Render subscript text.

**Syntax:**
```
[sub i]
```

**Example:**
```
a[sub 1], a[sub 2], ..., a[sub n]
```

---

#### term
Render a term (italicized, for definitions).

**Syntax:**
```
[term entropy]
```

---

#### term_
Render a hidden term (for index only, not displayed).

**Syntax:**
```
[term_ hidden entry]
```

---

#### index
Render an index entry (hidden in output).

**Syntax:**
```
[index term]
```

The term is collected for index generation but not displayed.

---

#### hide / author / date / today / lambda / setcounter / label / tags
Hidden elements (not displayed in output).

**Syntax:**
```
[hide content]
[author Author Name]
[date 2024-01-15]
[label theorem1]
[tags math, physics]
```

---

---

## Ordinary Blocks

Ordinary blocks begin with `| blockname` on a line by itself, followed by content.

### Section Headings

#### section
Render a numbered section heading.

**Syntax:**
```
| section
Introduction

| section 2
Background
```

**Properties:**
- `level`: Heading level (1-3, default 1). Level 1 = h2, Level 2 = h3, Level 3 = h4.

---

#### subsection
Render a subsection heading (level 2).

**Syntax:**
```
| subsection
Methods
```

---

#### subsubsection
Render a subsubsection heading (level 3).

**Syntax:**
```
| subsubsection
Details
```

---

#### section*
Render an unnumbered section heading.

**Syntax:**
```
| section*
Appendix

| section* 2
Sub-appendix
```

**Arguments:**
- Level (1-3, default 1)

---

#### chapter
Render a chapter heading (large h1).

**Syntax:**
```
| chapter
Introduction to Mathematics
```

---

#### subheading / sh (block)
Render a subheading (smaller than section, bold).

**Syntax:**
```
| subheading
Minor Heading

| sh
Minor Heading
```

---

### Lists

#### Bullet Lists
Render bullet list items using `- ` prefix.

**Syntax:**
```
- First item
- Second item
- Third item
```

Consecutive `- ` items are coalesced into a `<ul>` list.

---

#### Numbered Lists
Render numbered list items using `. ` prefix.

**Syntax:**
```
. First item
. Second item
. Third item
```

Consecutive `. ` items are coalesced into a numbered list.

---

#### desc
Render a description list item.

**Syntax:**
```
| desc Term
Definition of the term.
```

**Arguments:**
- Term label

---

### Theorem-like Environments

#### theorem / lemma / proposition / corollary / definition / example / remark / note / exercise / problem / question / axiom
Render theorem-like environments with automatic numbering.

**Syntax:**
```
| theorem
Every even number greater than 2 is the sum of two primes.

| theorem Goldbach's Conjecture
Every even number greater than 2 is the sum of two primes.
```

**Arguments:**
- Optional label (e.g., "Goldbach's Conjecture")

**Example:**
```
| definition Entropy
Entropy is a measure of disorder in a system.

| lemma
If n is even, then n^2 is even.

| proposition Key Result
The following inequality holds...
```

---

#### proof
Render a proof block with "Proof." prefix and QED marker.

**Syntax:**
```
| proof
By contradiction, assume...
```

---

### Formatting Blocks

#### indent (block)
Render indented content.

**Syntax:**
```
| indent
This paragraph is indented.
```

---

#### quotation / quote (block)
Render a block quotation with left border.

**Syntax:**
```
| quotation
To be or not to be, that is the question.

| quote
Four score and seven years ago...
```

---

#### center
Render centered content.

**Syntax:**
```
| center
Centered text here.
```

---

#### abstract (block)
Render an abstract with "Abstract" heading.

**Syntax:**
```
| abstract
This paper presents a new method for...
```

---

#### box
Render content in a bordered box.

**Syntax:**
```
| box
Important notice here.
```

---

#### compact
Render content with reduced line spacing.

**Syntax:**
```
| compact
Dense content with tighter line spacing.
```

---

#### identity
Render content with no special styling (identity transform).

**Syntax:**
```
| identity
This content is rendered as-is.
```

---

#### red / red2 / blue (block)
Render content in a specified color.

**Syntax:**
```
| red
This text is red.

| blue
This text is blue.
```

---

### Document Metadata

#### title (block)
Render the document title (centered h1).

**Syntax:**
```
| title
My Document Title
```

---

#### subtitle
Render the document subtitle (centered, lighter h2).

**Syntax:**
```
| subtitle
A Comprehensive Guide
```

---

#### author (block)
Render the document author (centered).

**Syntax:**
```
| author
John Doe
```

---

#### date (block)
Render the document date (centered, smaller).

**Syntax:**
```
| date
January 2024
```

---

### Special Blocks

#### contents
Render a table of contents placeholder.

**Syntax:**
```
| contents
```

The actual TOC is built automatically from section headings.

---

#### index (block)
Render an index placeholder (hidden in output).

**Syntax:**
```
| index
```

---

#### endnotes
Render collected endnotes at the end of a document.

**Syntax:**
```
| endnotes
```

Displays all footnotes collected from `[footnote ...]` expressions.

---

#### comment / hide (block)
Render nothing (comments are hidden).

**Syntax:**
```
| comment
This won't appear in output.

| hide
Also hidden.
```

---

#### document
Render document metadata block (hidden).

**Syntax:**
```
| document
type:article
```

---

#### collection
Render collection metadata block (hidden).

**Syntax:**
```
| collection
docs/chapter1.md
docs/chapter2.md
```

---

#### visibleBanner
Render a visible banner image.

**Syntax:**
```
| visibleBanner
/images/banner.jpg
```

---

### Tables (Block)

#### table (block)
Render a table with rows and cells.

**Syntax:**
```
| table format:l c r columnWidths:[100,80,80]
[table [row [cell A][cell B][cell C]] [row [cell 1][cell 2][cell 3]]]
```

**Properties:**
- `format`: Column alignment (l=left, c=center, r=right)
- `columnWidths`: Pixel widths for each column as array

---

### Q&A

#### q
Render a question block with "Q:" prefix.

**Syntax:**
```
| q
What is the meaning of life?
```

---

#### a
Render an answer block with "A:" prefix.

**Syntax:**
```
| a
42.
```

---

#### reveal
Render collapsible/expandable content.

**Syntax:**
```
| reveal Click to see answer
The hidden answer is here.
```

**Arguments:**
- Summary text (default: "Click to reveal")

---

### Additional Blocks

#### bibitem (block)
Render a bibliography item.

**Syntax:**
```
| bibitem einstein1905
Einstein, A. (1905). On the Electrodynamics of Moving Bodies.
```

**Arguments:**
- Citation key (e.g., "einstein1905")

---

#### env
Render a generic named environment.

**Syntax:**
```
| env Algorithm
Step 1: Initialize
Step 2: Process
Step 3: Output
```

**Arguments:**
- Environment name (displayed as title)

---

---

## Verbatim Blocks

Verbatim blocks begin with `| blockname` or `$$` and preserve content exactly as written. The content is not parsed for inline elements.

### Math Blocks

#### math
Render a display math block (unnumbered).

**Syntax:**
```
| math
\int_0^1 x^n dx = \frac{1}{n+1}
```

Or using `$$` shorthand:
```
$$
\int_0^1 x^n dx = \frac{1}{n+1}
```

ETeX notation is supported:
```
| math
int_0^1 x^n dx = frac(1,n+1)
```

---

#### equation
Render a numbered equation block.

**Syntax:**
```
| equation
E = mc^2
```

Supports alignment with `&` for multi-line equations:
```
| equation
a &= b + c \\
&= d
```

---

#### aligned
Render an aligned math block (unnumbered, multi-line).

**Syntax:**
```
| aligned
a &= b + c \\
&= d + e
```

---

### Code Blocks

#### code
Render a code block with syntax highlighting style.

**Syntax:**
```
| code
function hello() {
    console.log("Hello!");
}

| code javascript
const x = 42;
```

**Arguments:**
- Optional language name for syntax highlighting

---

### Verse

#### verse
Render a verse/poetry block preserving line breaks.

**Syntax:**
```
| verse
Roses are red,
Violets are blue,
Sugar is sweet,
And so are you.
```

---

### Macro Definitions

#### mathmacros
Define math macros for use in math blocks. Hidden in output.

**Syntax:**
```
| mathmacros
\newcommand{\R}{\mathbb{R}}
\newcommand{\norm}[1]{\left\| #1 \right\|}
```

---

#### textmacros
Define text macros for use in document. Hidden in output.

**Syntax:**
```
| textmacros
\newcommand{\version}{2.0}
```

---

### Data and Charts

#### datatable
Render raw data in a preformatted block.

**Syntax:**
```
| datatable
x, y, z
1, 2, 3
4, 5, 6
```

---

#### chart
Render a chart (placeholder, requires external JS library).

**Syntax:**
```
| chart
type: bar
data: ...
```

---

### Graphics

#### svg
Render inline SVG content (placeholder, requires JS integration).

**Syntax:**
```
| svg
<svg width="100" height="100">
  <circle cx="50" cy="50" r="40" fill="red" />
</svg>
```

---

#### quiver
Render a Quiver commutative diagram (placeholder, requires external integration).

**Syntax:**
```
| quiver
[quiver diagram data]
```

---

#### tikz
Render a TikZ diagram (placeholder, requires external integration).

**Syntax:**
```
| tikz
\begin{tikzpicture}
\draw (0,0) -- (1,1);
\end{tikzpicture}
```

---

#### image (block)
Render an image block.

**Syntax:**
```
| image [arguments] [properties]
<url>
```

**Arguments:**
- `expandable`: Click thumbnail to open full-size overlay; click overlay to close

**Properties:**
- `width`: Image width. Values: pixel number, "fill" (100%), or "to-edges" (120% of panel)
- `float`: Float image with text wrap. Values: "left" or "right"
- `ypadding`: Vertical padding in pixels (default 18, ignored when floated)
- `description`: Alt text for accessibility
- `figure`: Figure number (displays "Figure N")
- `caption`: Caption text (italic, below image)

**Examples:**
```
| image
https://example.com/photo.jpg

| image expandable width:400 caption:A lovely sunset
https://example.com/sunset.jpg

| image float:left width:200
https://example.com/portrait.jpg
```

---

### Media

#### iframe
Render an embedded iframe.

**Syntax:**
```
| iframe
https://www.youtube.com/embed/dQw4w9WgXcQ
```

**Properties:**
- `width`: Width in pixels (default: panel width)
- `height`: Height in pixels (default: 400)

---

#### load
Load external content (processed at higher level, hidden in output).

**Syntax:**
```
| load
/path/to/file.md
```

---

### Chemistry

#### chem (block)
Render chemical equations using mhchem notation.

**Syntax:**
```
| chem
2H2 + O2 -> 2H2O
```

---

### Arrays

#### array
Render a LaTeX-style math array.

**Syntax:**
```
| array ccc
a & b & c \\
d & e & f
```

**Arguments:**
- Column format (e.g., "ccc" for 3 centered columns, "lcr" for left/center/right)

---

#### textarray / table (verbatim)
Render a text table with `&` as column separator.

**Syntax:**
```
| textarray
Name & Age & City
Alice & 30 & NYC
Bob & 25 & LA
```

---

#### csvtable
Render a CSV table with comma-separated values.

**Syntax:**
```
| csvtable title:Sales Data
Product,Q1,Q2,Q3
Widgets,100,150,200
Gadgets,50,75,100
```

**Properties:**
- `title`: Optional table title

---

### Raw Verbatim

#### verbatim
Render raw verbatim text in a preformatted block.

**Syntax:**
```
| verbatim
This text is displayed exactly as written,
with all spacing and formatting preserved.
```

---

### Hidden/Configuration Blocks

The following blocks are hidden in output and used for configuration:

- `settings` - Application settings
- `load-data` - Load data files
- `hide` - Hidden content
- `texComment` - TeX comments
- `docinfo` - Document information
- `load-files` - Load multiple files
- `include` - Include content
- `setup` - Setup/configuration

---

## ETeX Notation

Scripta supports ETeX notation, a simplified syntax for math that is automatically converted to LaTeX:

| ETeX | LaTeX |
|------|-------|
| `int_0^1` | `\int_0^1` |
| `sum_(i=1)^n` | `\sum_{i=1}^n` |
| `frac(a,b)` | `\frac{a}{b}` |
| `sqrt(x)` | `\sqrt{x}` |
| `alpha`, `beta`, etc. | `\alpha`, `\beta`, etc. |

This allows writing math more naturally:

```
| math
int_0^1 x^n dx = frac(1, n+1)
```

Produces the same output as:

```
| math
\int_0^1 x^n dx = \frac{1}{n+1}
```
