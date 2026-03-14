This is an interesting problem with several viable approaches. The central tension is that PDF is a page-based, fixed-layout format while your AST is a logical document — so you need layout and pagination somewhere in the pipeline. Here are the main strategies, ordered from most pragmatic to most ambitious.

**Approach 1: AST → HTML → print-to-PDF**

You already render the AST to HTML for the browser, and KaTeX already works there. The simplest path is to create a print-oriented stylesheet and use the browser's built-in print:

```javascript
// Render your AST to a hidden iframe or new window
// KaTeX renders math as usual
// Apply print CSS, then:
window.print();  // or window.open(...) and print from there
```

Pair this with CSS `@page` rules and `break-before`/`break-after` for pagination. The library **Paged.js** polyfills the W3C Paged Media spec in the browser, giving you proper headers, footers, page numbers, and controlled page breaks — all via CSS. This is probably the fastest path to something that works. The downside is limited control over the exact PDF structure, and print rendering varies across browsers.

**Approach 2: AST → HTML → jsPDF's html plugin**

jsPDF has an `html()` method that renders a DOM element to PDF:

```javascript
const doc = new jsPDF();
doc.html(document.getElementById('scripta-output'), {
    callback: function(doc) {
        doc.save('document.pdf');
    },
    x: 15,
    y: 15,
    width: 170  // content width in mm
});
```

This uses html2canvas under the hood, which **rasterizes** the content. Math will look fine at high DPI but it's not vector — the PDF won't have selectable text in equations. Probably not what you want for a mathematical document.

**Approach 3: AST → pdf-lib with KaTeX SVG (the most promising)**

KaTeX can render to SVG strings directly, without the DOM:

```javascript
import katex from 'katex';

// Returns an SVG string — no DOM needed
const svg = katex.renderToString('\\int_0^1 f(x)\\,dx', {
    output: 'mathml'  // or you can get the HTML and extract SVG
});
```

Actually, more precisely — use KaTeX's `renderToString` and then extract the SVG, or use a KaTeX-to-SVG pipeline. Then in pdf-lib:

```javascript
import { PDFDocument } from 'pdf-lib';

async function buildPdf(ast) {
    const doc = await PDFDocument.create();
    const font = await doc.embedFont(StandardFonts.TimesRoman);

    let page = doc.addPage([595, 842]); // A4
    let y = 800; // cursor position

    for (const node of ast) {
        switch (node.type) {
            case 'paragraph':
                // Draw text, track y position
                // When y gets too low, add a new page
                y = drawParagraph(page, font, node.text, y);
                if (y < 50) {
                    page = doc.addPage([595, 842]);
                    y = 800;
                }
                break;

            case 'math':
                // Render via KaTeX to SVG, embed in page
                const svgString = katex.renderToString(node.content, {
                    throwOnError: false
                });
                // Convert SVG string to PDF-embeddable form
                // (this is the hard part — see below)
                break;

            case 'heading':
                // Larger font, spacing, etc.
                break;
        }
    }
    return doc.save();
}
```

The hard part here is embedding SVGs in pdf-lib. pdf-lib doesn't natively parse SVG. You have two sub-options: convert KaTeX SVG to PDF drawing operations (using something like **svg-to-pdfkit** adapted for pdf-lib), or rasterize the SVG to PNG at high resolution and embed as an image.

**Approach 4: AST → react-pdf (if you're willing to have a React layer)**

The `@react-pdf/renderer` library provides a flexbox layout engine that outputs PDF directly. You'd walk your AST and produce react-pdf components. It handles pagination automatically. Math is still the challenge — you'd embed KaTeX SVGs as images.

**My recommendation for your situation:**

Given that you're in Elm, I'd suggest a two-layer architecture:

1. **Elm side:** Walk the AST and produce an intermediate representation — a list of "PDF commands" as a JSON value. Something like your existing AST but flattened for layout purposes: paragraphs with style info, math blocks with their LaTeX source, headings, images, etc.

2. **JS side (via ports):** Receive that IR in JavaScript. Use pdf-lib for document construction. Use KaTeX to render math to SVG. Use **canvg** or an `OffscreenCanvas` to convert those SVGs to PNG at 300+ DPI for embedding.

```elm
-- Elm side: encode the document structure
type PdfBlock
    = PdfParagraph String FontStyle
    | PdfMath String          -- LaTeX source
    | PdfHeading Int String
    | PdfImage String
    | PdfPageBreak

port sendToPdfGenerator : List PdfBlock -> Cmd msg
```

```javascript
// JS side: receive and build
app.ports.sendToPdfGenerator.subscribe(async (blocks) => {
    const doc = await PDFDocument.create();
    // ... walk blocks, build pages
    const bytes = await doc.save();
    // Trigger download
    const blob = new Blob([bytes], { type: 'application/pdf' });
    const url = URL.createObjectURL(blob);
    // send URL back through a port, or trigger download
});
```

The SVG-to-image conversion for math is the trickiest piece. A pragmatic path: render the KaTeX HTML into a hidden DOM element, use `html-to-image` or `dom-to-image` to capture just the math as a high-res PNG, then embed that in pdf-lib. It's not pure vector, but at 300 DPI it's indistinguishable in print.

If vector math is essential (selectable, zoomable equations), you'd need to either find or build an SVG-to-PDF-operators converter, which is a substantially bigger project.

Want to dig into any of these approaches in more detail?
