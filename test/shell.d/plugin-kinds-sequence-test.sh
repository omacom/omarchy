#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const util = fs.readFileSync(root + '/shell/Commons/Util.qml', 'utf8')
const containsBody = util.match(/function kindsContain\(kinds, kind\) \{([\s\S]*?)\n  \}/)[1]
const hasKindBody = util.match(/function manifestHasKind\(manifest, kind\) \{([\s\S]*?)\n  \}/)[1]
assert(hasKindBody.includes('kindsContain(manifest.kinds, kind)'),
  'Util.manifestHasKind delegates to the sequence-tolerant kindsContain')
const kindsContain = new Function('kinds', 'kind', containsBody)
const manifestHasKind = (manifest, kind) => !!manifest && kindsContain(manifest.kinds, kind)

// The regression: a manifest passed through a QML model exposes kinds as an
// array-like sequence, which Array.isArray rejects (#15617).
const sequence = { length: 2, 0: 'menu', 1: 'bar-widget' }
assert(!Array.isArray(sequence), 'the simulated QML sequence is not an Array')

assert(kindsContain(['menu', 'bar-widget'], 'menu'), 'plain array kinds are searched')
assert(!kindsContain(['menu', 'bar-widget'], 'panel'), 'a missing kind is not found in a plain array')
assert(kindsContain(sequence, 'menu'), 'array-like sequence kinds are searched (#15617)')
assert(kindsContain(sequence, 'bar-widget'), 'every entry of an array-like sequence is searched')
assert(!kindsContain(sequence, 'panel'), 'a missing kind is not found in a sequence')

assert(!kindsContain(null, 'menu'), 'null kinds contain nothing')
assert(!kindsContain(undefined, 'menu'), 'undefined kinds contain nothing')
assert(!kindsContain([], 'menu'), 'empty kinds contain nothing')
assert(!kindsContain(42, 'menu'), 'non-array-like kinds contain nothing')

assert(manifestHasKind({ kinds: sequence }, 'menu'), 'manifestHasKind accepts a sequence kinds (#15617)')
assert(!manifestHasKind({ kinds: ['menu'] }, 'overlay'), 'manifestHasKind still rejects missing kinds')
assert(!manifestHasKind(null, 'menu'), 'manifestHasKind rejects a null manifest')
assert(!manifestHasKind({}, 'menu'), 'manifestHasKind rejects a manifest without kinds')

// Every host-side kind check must route through the sequence-tolerant helper;
// a new Array.isArray(...kinds) gate silently reintroduces #15617.
const allowed = {
  // Raw manifests arrive from JSON.parse, so this validation can keep the
  // strict Array check.
  'shell/services/PluginRegistry.qml': [
    'if (!Array.isArray(manifest.kinds) || manifest.kinds.length === 0) {',
    'if (Array.isArray(manifest.kinds))'
  ],
  'shell/Commons/Util.qml': ['if (Array.isArray(kinds)) return kinds.indexOf(kind) !== -1'],
  'shell/shell.qml': []
}
for (const file of Object.keys(allowed)) {
  const content = fs.readFileSync(root + '/' + file, 'utf8')
  const hits = content.split('\n')
    .map((line, i) => ({ line: line.trim(), number: i + 1 }))
    .filter(row => /Array\.isArray\([^)]*kinds\)/.test(row.line))
  assertDeepEqual(
    hits.map(row => row.line).sort(),
    allowed[file].slice().sort(),
    file + ' gates no kind check on Array.isArray outside the allowed sites'
  )
}
JS
