// Usage: node span.js path/to/span.js REPO
const fs = require('fs'), path = require('path'), { execSync } = require('child_process');
const [,, js, repo] = process.argv;
const files = execSync(`find ${repo} -name "*.scripta" -not -path "*/elm-stuff/*" -not -path "*/node_modules/*"`).toString().trim().split('\n').sort();
const docs = files.map(f => [path.relative(repo, f), fs.readFileSync(f, 'utf8')]);
const { Elm } = require(js);
Elm.SpanCheck.init({ flags: docs }).ports.out.subscribe(r => {
  const bad = r.filter(x => x.startsWith('SPAN MISMATCH'));
  const total = r.filter(x => x.startsWith('checked ')).reduce((n, x) => n + Number(x.split(' ')[1]), 0);
  bad.forEach(x => console.log(x));
  console.log(`${total} blocks in ${docs.length} documents: ${bad.length} span mismatches`);
  process.exitCode = bad.length ? 1 : 0;
});
