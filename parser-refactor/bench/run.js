// Usage: node run.js path/to/bench.js
// For each input shape and size, time Parser.Expression.parse (median of 5 runs).
const { Elm } = require(process.argv[2]);

const shapes = {
  'inline functions   "a [b x] " * n': n => 'a [b x] '.repeat(n),
  'nested in one fn   "[b " + "a [i x] " * n + "]"': n => '[b ' + 'a [i x] '.repeat(n) + ']',
  'unclosed fn        "[b " + "x [i y] " * n': n => '[b ' + 'x [i y] '.repeat(n),
  'inline math        "$x$ " * n': n => '$x$ '.repeat(n),
  'math inside fn     "[b " + "$x$ " * n + "]"': n => '[b ' + '$x$ '.repeat(n) + ']',
};
const sizes = (process.argv[3] || '250,500,1000,2000').split(',').map(Number);

function time(input) {
  const runs = [];
  for (let i = 0; i < 5; i++) {
    const t0 = process.hrtime.bigint();
    const app = Elm.BenchMain.init({ flags: [input] });
    runs.push(Number(process.hrtime.bigint() - t0) / 1e6);
  }
  runs.sort((a, b) => a - b);
  return runs[2];
}

for (const [name, make] of Object.entries(shapes)) {
  const cells = sizes.map(n => time(make(n)).toFixed(1).padStart(8));
  console.log(name.padEnd(52), cells.join(' '), ' ms');
}
console.log(''.padEnd(52), sizes.map(n => ('n=' + n).padStart(8)).join(' '));
