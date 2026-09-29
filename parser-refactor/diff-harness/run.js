const fs = require('fs');
const { execSync } = require('child_process');
const [,, jsPath, repo] = process.argv;
const files = execSync(`find ${repo} -name "*.scripta" -not -path "*/elm-stuff/*" -not -path "*/node_modules/*" -not -path "*/diff-harness/*"`).toString().trim().split('\n').sort();
const sources = files.map(f => fs.readFileSync(f, 'utf8'));
// Variants: without trailing blank lines (EOF path), and synthetic edge cases.
const variants = sources.map(s => s.replace(/\s+$/, ''));
const synthetic = [
  "a [b c", "a ]b", "[ x]", "[]", "[b [i x] y] z", "$a$ `c` [b $x$] $y", "[b `c` d] `e $f$ g`",
  "`unclosed code $x$", "$unclosed math `c`", "[[wiki link]] and [[", "[[a [b]]]", "\\alpha \\(x\\) [m \\beta]",
  "[b x] `code [y] z` w", "[i `a` $b$ `c`]", "- one\n- two\n  continued\n. three\n\n| section 02\nTitle\n\n# H\n## H2\n### H3",
  "| theorem\n| numbered label:thm\nbody\n\n|| code\n| lang:elm\nx = 1\n\n| table\na & b\nc & [b d]",
  "- a\n  more\n- b\n\n. x\n. y\nz",
  // error recovery in mid-line, followed by more content
  "[ x] then [b y] and $z$", "a ] b [i c] d", "[b x] ] [i y] [ z [b w]", "[] [i ok] `c` $m$",
  "p [b q $r s] t [i u]", "[b x `y] z [i w]", "[[ a ] b [i c]", "x [b [i y] z", "[b ] [i] []] [c d]",
];
const all = [...sources, ...variants, ...synthetic];

// Incremental reparse cases: [before, after] pairs, per real source.
// Output indices continue after `all`.
const isProseLine = l => l.includes(' the ') && !/^\s*(\||\$\$|```|-|\.|#)/.test(l);
const edits = [];
for (const src of sources) {
  const lines = src.split('\n');
  const k = lines.findIndex(isProseLine);
  const withLine = text => lines.map((l, i) => (i === k ? text : l)).join('\n');
  edits.push([src, src]);                                              // no-op
  if (k >= 0) {
    edits.push([src, withLine(lines[k].replace(' the ', ' THE '))]);    // plain word change
    edits.push([src, withLine(lines[k] + ' [ref foo]')]);               // accumulator-dependent change
  }
  edits.push([src, 'New paragraph.\n\n' + src]);                     // structure change
}

const { Elm } = require(jsPath);
const app = Elm.DiffMain.init({ flags: { sources: all, edits } });
app.ports.out.subscribe(res => { process.stdout.write(res.map((r, i) => `=== ${i}\n${r}\n`).join('')); });
