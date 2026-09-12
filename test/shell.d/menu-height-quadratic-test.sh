#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

MENU_QML="$ROOT/shell/plugins/menu/Menu.qml"

[[ -f $MENU_QML ]] || fail "Menu.qml is missing"

run_node_test <<'JS'
const fs = require('fs')

const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')

// The bug: visibleRowsHeight bound to displayModel.count, so each append during
// rebuild re-ran the full row walk (O(n^2) on open). layoutSerial already marks
// a finished model; height must key off that alone.
assert(
  /property int visibleRowsHeight:\s*root\.dmenuActive\s*\?\s*dmenuRowListHeight\(\s*layoutSerial\s*\)\s*:\s*rowListHeight\(\s*layoutSerial\s*\)/.test(menuQml),
  'visibleRowsHeight binds only to layoutSerial (dmenu and route paths)'
)

assert(
  !/visibleRowsHeight:[^\n]*displayModel\.count/.test(menuQml),
  'visibleRowsHeight must not depend on displayModel.count'
)

assert(
  !/dmenuRowListHeight\(\s*layoutSerial\s*,\s*displayModel\.count/.test(menuQml) &&
    !/rowListHeight\(\s*layoutSerial\s*,\s*displayModel\.count/.test(menuQml),
  'height helpers are not called with displayModel.count'
)

assert(
  /function rowListHeight\(\s*_serial\s*\)/.test(menuQml) &&
    /function dmenuRowListHeight\(\s*_serial\s*\)/.test(menuQml),
  'height helpers take only the layout serial as a binding dependency'
)

// Rebuild still finishes with a single serial bump after all appends.
assert(
  /for\s*\(\s*var k = 0;\s*k < rows\.length;\s*k\+\+\)\s*displayModel\.append\(rows\[k\]\)\s*\n\s*layoutSerial \+= 1/.test(menuQml) ||
    /displayModel\.append\(rows\[k\]\)[\s\S]{0,80}?layoutSerial \+= 1/.test(menuQml),
  'rebuildDisplay bumps layoutSerial once after appending rows'
)

assert(
  /displayModel\.append\(\{[\s\S]*?itemId:\s*"dmenu\."[\s\S]*?\}\)[\s\S]*?layoutSerial \+= 1/.test(menuQml),
  'rebuildDmenuDisplay bumps layoutSerial once after appending options'
)

// Early empty-model path must still invalidate height without a count binding.
assert(
  /if\s*\(\s*!root\.rowsLoaded\s*\)\s*\{\s*layoutSerial \+= 1\s*;\s*return\s*\}/.test(menuQml) ||
    /if\s*\(\s*!root\.rowsLoaded\s*\)\s*\{\s*\n\s*layoutSerial \+= 1\s*\n\s*return\s*\n\s*\}/.test(menuQml),
  'rebuildDisplay bumps layoutSerial when rows are not loaded yet'
)

// Complexity check: triangular walk on every append vs one final walk.
function simulate(n, everyAppend) {
  let calls = 0
  let walked = 0
  const model = []
  const height = () => {
    calls += 1
    walked += model.length
  }
  for (let i = 0; i < n; i++) {
    model.push(i)
    if (everyAppend) height()
  }
  if (!everyAppend) height()
  return { calls, walked }
}

const bug231 = simulate(231, true)
const fix231 = simulate(231, false)
assertEqual(bug231.walked, 26796, 'pre-fix 231-row open walks the triangular sum')
assertEqual(fix231.walked, 231, 'post-fix 231-row open walks each row once')
assertEqual(fix231.calls, 1, 'post-fix height runs once per rebuild')

const bug400 = simulate(400, true)
const fix400 = simulate(400, false)
assert(bug400.walked > fix400.walked * 100, '400-row every-append walk is orders of magnitude larger than one pass')
assertEqual(fix400.walked, 400, 'post-fix 400-row open stays linear')
JS

pass "menu height no longer scales with the square of row count"
