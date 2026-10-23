#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const geometry = requireFromRoot('shell/Commons/ShadowGeometry.js')
const make = values => geometry.spec(Object.fromEntries(Object.entries(values).map(([k,v]) => ['popups.shadow-' + k, v])), 'popups')
const insets = s => [s.left, s.right, s.top, s.bottom]

assert(!make({}).enabled, 'old themes have no shadows')
assertDeepEqual(insets(make({})), [0,0,0,0], 'disabled shadows do not change window geometry')
assertDeepEqual(insets(make({alpha: '0.5'})), [25,25,19,31], 'default geometry includes blur and downward offset')
assertDeepEqual(insets(make({alpha: 1, blur: 10, spread: 2, 'offset-x': -4, 'offset-y': 6})), [17,9,7,19], 'negative and positive offsets reserve asymmetric space')
assertDeepEqual(insets(make({alpha: 1, blur: 4.5, spread: 0, 'offset-x': 0.25, 'offset-y': -0.25})), [6,6,6,6], 'fractional extents round outward')
assertDeepEqual(insets(make({alpha: 1, blur: 0, spread: -64, 'offset-x': 128, 'offset-y': -128})), [0,129,129,0], 'shrunk offset shadows never produce negative insets')
assert(!make({alpha: -2}).enabled, 'negative alpha disables shadows')
assert(!make({alpha: 'invalid'}).enabled, 'invalid alpha preserves opt-in default')
for (const raw of ['NaN', 'Infinity', '-Infinity', 'bad', '']) {
  const s = make({alpha: 1, blur: raw, spread: raw, 'offset-x': raw, 'offset-y': raw})
  assertDeepEqual([s.blur,s.spread,s.offsetX,s.offsetY], [24,0,0,6], `invalid geometry falls back: ${raw}`)
}
const max = make({alpha: 9, blur: 1e10, spread: 1e10, 'offset-x': -1e10, 'offset-y': 1e10})
assertDeepEqual([max.alpha,max.blur,max.spread,max.offsetX,max.offsetY], [1,128,64,-128,128], 'render extents are bounded')
assert(!geometry.spec({'bar.shadow-alpha': 1}, 'bar').enabled, 'the bar cannot opt in')
assert(!geometry.spec({'.shadow-alpha': 1}, '').enabled, 'ordinary controls cannot opt in')

// Exercise the actual parser and merge functions, not a parallel TOML parser.
const color = fs.readFileSync(path.join(root, 'shell/Commons/Color.qml'), 'utf8')
function qmlFunction(source, name) {
  const start = source.indexOf('  function ' + name + '(')
  if (start < 0) throw new Error(`Missing production function ${name}`)
  const end = source.indexOf('\n  }', start)
  return source.slice(start, end + 4)
}
const scope = { themeShellValues: {}, userShellValues: {}, shellValues: {}, Style: { applyShellValues() {} } }
vm.createContext(scope)
for (const name of ['parseShell', 'mergeShell', 'loadShell', 'loadUserShell']) vm.runInContext(qmlFunction(color, name), scope)
scope.loadShell('[popups]\nshadow-alpha = 0.4\nshadow-color = "#334455"\nshadow-offset-y = -4\n')
scope.loadUserShell('[popups]\nshadow-alpha = 0\n')
assert(!geometry.spec(scope.shellValues, 'popups').enabled, 'user override disables theme shadow')
scope.loadShell('[popups]\nshadow-alpha = 0.8\nshadow-offset-y = 2\n')
assert(!geometry.spec(scope.shellValues, 'popups').enabled, 'user disable survives a theme switch')
scope.loadUserShell('')
assertEqual(geometry.spec(scope.shellValues, 'popups').alpha, 0.8, 'removing override restores theme shadow')
scope.loadShell('')
assert(!geometry.spec(scope.shellValues, 'popups').enabled, 'switching to an old theme removes shadow')
JS

if ! command -v quickshell >/dev/null 2>&1; then
  skip "live shadow layout checks require Quickshell"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/home" "$test_tmp/cache"
cp -a "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"
cp "$ROOT/test/shell.d/fixtures/surface-shadow-layout/shell.qml" "$test_tmp/shell.qml"
# Expose the production popup for observations, without altering its behavior.
python3 - "$test_tmp/Ui/MultiSelect.qml" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
source = p.read_text()
end = source.rfind('\n}')
p.write_text(source[:end] + '\n  property alias testedPopup: popup\n' + source[end:])
PY
if ! timeout 15 env HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config" XDG_CACHE_HOME="$test_tmp/cache" QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software quickshell -p "$test_tmp" --no-color >"$test_tmp/runtime.log" 2>&1; then
  fail "shadow layout fixture exits cleanly" "$(<"$test_tmp/runtime.log")"
fi
grep -q 'RESULT pass' "$test_tmp/runtime.log" || fail "open lists follow live shadow geometry" "$(<"$test_tmp/runtime.log")"
pass "open lists shrink and recover while live shadow margins change"
