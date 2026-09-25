#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const read = file => fs.readFileSync(path.join(root, file), 'utf8')
const source = read('shell/Commons/Color.qml')
const rgba = (r, g, b, a) => ({ r, g, b, a })
const qtColor = value => {
  if (typeof value === 'object') return value
  if (value === 'transparent') return rgba(0, 0, 0, 0)
  if (!/^#[0-9a-f]{6}$/i.test(value)) throw new Error(`invalid test color: ${value}`)
  return rgba(...[1, 3, 5].map(i => parseInt(value.slice(i, i + 2), 16) / 255), 1)
}
const context = { Qt: { rgba, color: qtColor }, shellValues: {}, foreground: '#eeeeee', background: '#101010', accent: '#aabbcc' }
context.root = context
context.Util = { clampAlpha: n => Math.max(0, Math.min(1, n)) }
vm.createContext(context)
vm.runInContext(read('shell/Commons/BorderGeometry.js').replace(/^\.pragma library\s*/, ''), context)
context.Geometry = { canonicalColor: context.canonicalColor }
context.Style = { applyShellValues() {} }
context.themeShellValues = {}
context.userShellValues = {}
for (const name of ['pick', 'pickAlpha', 'firstColorToken', 'flatColor', 'fillSpec', 'parseShell', 'mergeShell', 'loadShell', 'loadUserShell']) {
  const start = source.indexOf(`  function ${name}(`)
  const end = source.indexOf('\n  }', start) + 4
  vm.runInContext(source.slice(start, end), context)
}
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
assert(!spec('[popups]\nbackground = "missing.key"').gradient.enabled, 'missing references fall back')
assert(!spec('[popups]\nbackground = "90deg"').gradient.enabled, 'angle-only value falls back')
assertDeepEqual(spec('[popups]\nbackground = "invalid"').color, qtColor(context.background), 'unknown role falls back')
assertDeepEqual(spec('[popups]\nbackground = "#broken"').color, qtColor(context.background), 'invalid hex falls back')
context.loadShell('[popups]\nbackground = "#112233 #445566 90deg"')
context.loadUserShell('[popups]\nbackground-alpha = 0.4')
let merged = context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1)
assert(merged.gradient.enabled && merged.color.a === 0.4, 'partial user overrides retain theme gradient')
context.loadUserShell('[popups]\nbackground = "#ffffff"')
assert(!context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1).gradient.enabled, 'user solid overrides theme gradient')
context.loadUserShell('')
assert(context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1).gradient.enabled, 'removing user override restores theme gradient')
context.loadShell('')
assert(!context.fillSpec('popups.background', 'popups.background-alpha', context.background, 1).gradient.enabled, 'theme switch clears stale gradients')
const surface = read('shell/Ui/BorderSurface.qml')
assert(surface.includes('color: usesGradientFill ? "transparent" : fillColor'), 'gradient replaces rather than covers fallback fill')
assert(surface.includes('active: root.usesGradientFill'), 'gradient renderer is lazy')
assert(surface.includes('(usesGradientFill && !Border.isNone(borderSpec))'), 'borders render above gradient fills')
for (const file of ['PopupCard', 'KeyboardPanel']) {
  const qml = read(`shell/Ui/${file}.qml`)
  assert(qml.includes('fillSpec: Color.popups.backgroundSpec') && qml.includes('fillColor: Color.popups.background'), `${file} opts into popup fills with compatible solid fallback`)
}
assert(!source.includes('fillSpec("menu.background"'), 'menu gradient support stays outside this PR')
JS
