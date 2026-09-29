// Usage: node oracle.js path/to/oracle.js REPO
// Generates edits over every .scripta file and checks incremental == fresh.
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const [,, jsPath, repo] = process.argv;
const files = execSync(`find ${repo} -name "*.scripta" -not -path "*/elm-stuff/*" -not -path "*/node_modules/*"`).toString().trim().split('\n').sort();

const cases = [];
for (const f of files) {
  const src = fs.readFileSync(f, 'utf8');
  const lines = src.split('\n');
  const name = path.relative(repo, f);
  const step = Math.max(1, Math.floor(lines.length / 40));
  for (let k = 0; k < lines.length; k += step) {
    const edit = (kind, newLines) => cases.push([`${name}:${k + 1} ${kind}`, src, newLines.join('\n')]);
    const l = lines[k];
    const mid = Math.floor(l.length / 2);
    edit('insert char', lines.map((x, i) => (i === k ? x.slice(0, mid) + 'q' + x.slice(mid) : x)));
    edit('add line', lines.flatMap((x, i) => (i === k ? [x, 'extra line'] : [x])));
    edit('delete line', lines.filter((_, i) => i !== k));
    edit('append ref', lines.map((x, i) => (i === k ? x + ' [ref foo]' : x)));
  }
}

const { Elm } = require(jsPath);
const app = Elm.OracleMain.init({ flags: cases });
app.ports.out.subscribe(res => {
  const bad = res.filter(r => !r.startsWith('ok '));
  const skip = res.filter(r => r === 'ok skip').length;
  const full = res.filter(r => r === 'ok full').length;
  bad.forEach(r => console.log(r));
  console.log(`${res.length} edits: ${res.length - bad.length} ok (${skip} skip path, ${full} full path), ${bad.length} mismatches`);
  process.exitCode = bad.length ? 1 : 0;
});
