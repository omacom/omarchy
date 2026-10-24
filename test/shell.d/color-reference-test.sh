#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const source = fs.readFileSync(path.join(root, 'shell/Commons/Color.qml'), 'utf8')
const geometry = fs.readFileSync(path.join(root, 'shell/Commons/BorderGeometry.js'), 'utf8').replace(/^\.pragma library\n/, '')
const palette = { foreground: '#eeeeee', background: '#111111', accent: '#abcdef', urgent: '#ff0000', muted: '#777777' }
const context = vm.createContext({ ...palette, shellValues: {}, Geometry: {}, themeShellValues: {}, userShellValues: {}, Style: { applyShellValues() {} } })
context.root = context
vm.runInNewContext(geometry, context.Geometry)
for (const name of ['pick', 'pickAlpha', 'firstColorToken', 'flatColor', 'composed', 'fillSpec', 'parseShell', 'mergeShell', 'loadShell', 'loadUserShell']) {
  const fn = source.match(new RegExp(`  function ${name}\\([^]*?\\n  }`))
  if (!fn) fail(`Color.qml provides ${name}`)
  vm.runInContext(fn[0], context)
}

function check(values, input, expected, description) {
  context.root.shellValues = values
  context.input = input
  const result = vm.runInContext('flatColor(input, "#123456")', context, { timeout: 1000 })
  assertEqual(result, expected, description)
}

const cycle = context.parseShell('[bar]\nbackground = "menu.background"\n[menu]\nbackground = "bar.background"')
check(cycle, 'bar.background', '#123456', 'two-entry theme cycle returns the supplied fallback')
check({ 'a.color': 'b.color', 'b.color': 'c.color', 'c.color': 'a.color' }, 'a.color', '#123456', 'longer cycle returns fallback')
check({ 'start.color': 'a.color', 'a.color': 'b.color', 'b.color': 'a.color' }, 'start.color', '#123456', 'chain entering a cycle returns fallback')
check({ 'a.color': 'a.color' }, 'a.color', '#123456', 'direct self-reference returns fallback')
check({ 'a.color': ' A.COLOR ' }, 'a.color', '#123456', 'normalized self-reference returns fallback')
check({ 'a.color': '45deg b.color #ffffff', 'b.color': 'a.color' }, 'a.color', '#123456', 'gradient first-stop cycle returns fallback')

check({ 'a.color': 'b.color', 'b.color': '#abcdef' }, 'a.color', '#abcdef', 'acyclic references preserve the final color')
check({ 'a.color': ' B.COLOR ', 'b.color': '#abcdef' }, 'A.COLOR', '#abcdef', 'each reference keeps case and whitespace normalization')
check({ 'a.color': 'b.color', 'b.color': 'accent' }, 'a.color', palette.accent, 'acyclic references preserve palette roles')
check({ 'a.color': '45deg rgba(11223380) #ffffff' }, 'a.color', '#11223380', 'referenced gradient keeps its first color and alpha')
check({ 'a.color': 'missing.color' }, 'a.color', '#123456', 'missing reference returns fallback')
check({}, '', '#123456', 'empty input returns fallback')
for (const [role, color] of Object.entries(palette)) check({}, role, color, `palette role ${role} is unchanged`)
check({}, 'text', palette.foreground, 'text alias is unchanged')
for (const [input, output] of [['#abc', '#aabbcc'], ['#abcdef', '#abcdef'], ['rgb(abcdef)', '#abcdef'], ['rgba(11223380)', '#11223380']]) {
  check({}, input, output, `direct color ${input} is unchanged`)
}

const chain = {}
for (let i = 0; i < 10000; i++) chain[`chain.c${i}`] = `chain.c${i + 1}`
chain['chain.c10000'] = '#abcdef'
check(chain, 'chain.c0', '#abcdef', 'long acyclic chains do not exhaust the call stack')
check({ 'a.color': '#abcdef' }, 'a.color', '#abcdef', 'visited references do not leak between resolutions')

// Share the production functions and palette above. Add Qt color values only
// for alpha arithmetic; the reference-chain checks also cover operation without Qt.
const rgba = (r, g, b, a) => ({ r, g, b, a })
const qtColor = value => {
  if (typeof value === 'object') return value
  if (value === 'transparent') return rgba(0, 0, 0, 0)
  if (!/^#[0-9a-f]{6}$/i.test(value)) throw new Error(`invalid test color: ${value}`)
  return rgba(...[1, 3, 5].map(i => parseInt(value.slice(i, i + 2), 16) / 255), 1)
}
context.Qt = context.Geometry.Qt = { rgba, color: qtColor }
context.Util = { clampAlpha: n => Math.max(0, Math.min(1, n)), alpha: (color, alpha) => { const c = qtColor(color); return rgba(c.r, c.g, c.b, alpha) } }
const spec = toml => {
  context.shellValues = context.parseShell(toml)
  return context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1)
}
let fill = spec('[popups]\nbackground = "#11223380 #445566 90deg"\nbackground-alpha = 0.5')
assert(fill.gradient.enabled && fill.gradient.colors.length === 2 && fill.gradient.angle === 90, 'parses popup gradient stops and angle')
assert(Math.abs(fill.color.a - 128 / 255 * 0.5) < 0.001, 'multiplies intrinsic and companion alpha once')
assert(spec('[popups]\nbackground = "accent foreground -45deg"').gradient.angle === -45, 'supports role colors and negative angles')
assert(spec('[popups]\nbackground = "#112233 #445566 #778899"').gradient.colors.length === 3, 'preserves three stops')
assert(spec('[popups]\nbackground = "' + Array(12).fill('#112233').join(' ') + '"').gradient.colors.length === 10, 'bounds gradients to ten stops')
assert(!spec('[popups]\nbackground = "#112233"').gradient.enabled, 'solid values use native renderer')
assert(!spec('').gradient.enabled, 'removing a gradient restores defaults')
assert(spec('[popups]\nbackground = "#112233 #445566"\nbackground-alpha = 0').gradient.colors.every(c => c.a === 0), 'zero alpha affects every stop')
assert(spec('[popups]\nbackground = "fill.alias"\n[fill]\nalias = "#112233 #445566 120deg"').gradient.angle === 120, 'resolves whole-gradient references')
assert(!spec('[popups]\nbackground = "fill.alias"\n[fill]\nalias = "popups.background"').gradient.enabled, 'cyclic references fall back without recursion')
fill = spec('[popups]\nbackground = "fill.a #445566"\n[fill]\na = "fill.b"\nb = "fill.a"')
assertDeepEqual(fill.color, qtColor(context.background), 'per-stop reference cycle falls back without recursion')
assert(fill.gradient.enabled && fill.gradient.colors.length === 2, 'per-stop cycle retains the remaining valid stop')
assertDeepEqual(spec('[popups]\nbackground = "#11223380 #445566"\nbackground-alpha = 1').color, rgba(17 / 255, 34 / 255, 51 / 255, 128 / 255), 'rendered first stop retains intrinsic alpha')
context.shellValues = context.parseShell('[popups]\nbackground = "#11223380 #445566"\nbackground-alpha = 1')
assertDeepEqual(context.composed('popups.background', 'popups.background-alpha', context.background, 1), rgba(17 / 255, 34 / 255, 51 / 255, 1), 'color-only consumers replace intrinsic alpha')
assert(!spec('[popups]\nbackground = "missing.key"').gradient.enabled, 'missing references fall back')
assert(!spec('[popups]\nbackground = "90deg"').gradient.enabled, 'angle-only value falls back')
assertDeepEqual(spec('[popups]\nbackground = "invalid"').color, qtColor(context.background), 'unknown role falls back')
assertDeepEqual(spec('[popups]\nbackground = "#broken"').color, qtColor(context.background), 'invalid hex falls back')
context.loadShell('[popups]\nbackground = "#112233 #445566 90deg"')
context.loadUserShell('[popups]\nbackground-alpha = 0.4')
const merged = context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1)
assert(merged.gradient.enabled && merged.color.a === 0.4, 'partial user overrides retain theme gradient')
context.loadUserShell('[popups]\nbackground = "#ffffff"')
assert(!context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1).gradient.enabled, 'user solid overrides theme gradient')
context.loadUserShell('')
assert(context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1).gradient.enabled, 'removing user override restores theme gradient')
context.loadShell('')
assert(!context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1).gradient.enabled, 'theme switch clears stale gradients')
JS

if ! command -v quickshell >/dev/null 2>&1; then
  skip "popup slider binding checks require Quickshell"
  exit 0
fi
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/home" "$test_tmp/cache"
ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"
cp "$ROOT/test/shell.d/fixtures/popup-gradient-bindings/shell.qml" "$test_tmp/shell.qml"
if ! timeout 15 env HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config" XDG_CACHE_HOME="$test_tmp/cache" QT_QPA_PLATFORM=offscreen quickshell -p "$test_tmp" --no-color >"$test_tmp/runtime.log" 2>&1; then
  fail "popup slider binding fixture exits cleanly" "$(<"$test_tmp/runtime.log")"
fi
grep -q 'RESULT pass' "$test_tmp/runtime.log" || fail "sliders follow their actual host fill" "$(<"$test_tmp/runtime.log")"
pass "sliders follow their host fill rather than unrelated popup settings"
