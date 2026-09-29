#!/usr/bin/env python3
"""Compare two harness outputs; list changed inputs and the first few differing fragments."""
import re, sys, difflib

def load(f):
    parts = re.split(r'^=== (\d+)\n', open(f).read(), flags=re.M)
    return {int(parts[i]): parts[i + 1] for i in range(1, len(parts), 2)}

def fragments(t):
    return re.split(r'(?=Tree \{|Text "|VFun "|Fun "|meta = )', t)

a, b = load(sys.argv[1]), load(sys.argv[2])
changed = [k for k in a if a[k] != b.get(k)]
if not changed:
    print("IDENTICAL")
    sys.exit(0)
print("changed inputs:", changed)
for k in changed:
    x, y = fragments(a[k]), fragments(b[k])
    ops = [o for o in difflib.SequenceMatcher(None, x, y).get_opcodes() if o[0] != 'equal']
    print(f"\n=== input {k}: {len(ops)} hunk(s)")
    for o in ops[:3]:
        print("  -", [s[:160] for s in x[o[1]:o[2]]][:3])
        print("  +", [s[:160] for s in y[o[3]:o[4]]][:3])
sys.exit(1)
