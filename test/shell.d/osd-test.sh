#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const osd = requireFromRoot('shell/plugins/osd/OsdModel.js')

assertEqual(osd.iconFor('', 0), osd.iconFor('muted', 50), 'osd falls back to muted icon at zero percent')
assertEqual(osd.iconFor('volume-high', 1), osd.iconFor('', 100), 'osd maps high volume aliases')
assertEqual(osd.iconFor('logout', 50), '󰍃', 'osd maps logout icon')
assertEqual(osd.iconFor('custom-symbol', 50), 'custom-symbol', 'osd preserves unknown explicit icons')
assertEqual(osd.widestIcon, osd.iconFor('volume-high', 100), 'osd sizes the icon column to a glyph it can show')

assertDeepEqual(
  osd.stateForShow('volume', '', '75', '100', '', '800'),
  {
    iconKey: 'volume',
    maxValue: 100,
    hasProgress: true,
    value: 75,
    message: '75%',
    icon: osd.iconFor('volume', 75),
    duration: 800
  },
  'osd builds progress state'
)

assertDeepEqual(
  osd.stateForShow('media-pause', 'Paused', '', '100', '', 'nope'),
  {
    iconKey: 'media-pause',
    maxValue: 100,
    hasProgress: false,
    value: 0,
    message: 'Paused',
    icon: osd.iconFor('media-pause', -1),
    duration: 1200
  },
  'osd builds message state'
)
JS

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const colorSource = fs.readFileSync(path.join(root, 'shell/Commons/Color.qml'), 'utf8')
const utilSource = fs.readFileSync(path.join(root, 'shell/Commons/Util.qml'), 'utf8')
const osdSource = fs.readFileSync(path.join(root, 'shell/plugins/osd/Osd.qml'), 'utf8')
const geometry = fs.readFileSync(path.join(root, 'shell/Commons/BorderGeometry.js'), 'utf8').replace(/^\.pragma library\n/, '')
const Qt = {
  rgba: (r, g, b, a) => ({ r, g, b, a }),
  color: value => {
    if (!/^#[0-9a-f]{6}$/i.test(value)) fail(`Qt color stub supports ${value}`)
    return { r: parseInt(value.slice(1, 3), 16) / 255, g: parseInt(value.slice(3, 5), 16) / 255, b: parseInt(value.slice(5, 7), 16) / 255, a: 1 }
  }
}
const utilContext = vm.createContext({ Qt })
const context = vm.createContext({
  Qt,
  Util: utilContext,
  Geometry: {},
  root: { foreground: '#111111', background: '#ffffff', shellValues: {} }
})
vm.runInNewContext(geometry, context.Geometry)
function extractFunctions(source, names, target) {
  for (const name of names) {
    const fn = source.match(new RegExp(`  function ${name}\\([^]*?\\n  }`))
    if (!fn) fail(`QML provides ${name}`)
    vm.runInContext(fn[0], target)
  }
}
extractFunctions(utilSource, ['clamp', 'clampAlpha', 'alpha'], utilContext)
extractFunctions(colorSource, ['pick', 'pickAlpha', 'firstColorToken', 'flatColor', 'composed', 'parseShell'], context)
// Read both bindings so the test exercises the color actually used by the card.
const popupBinding = colorSource.match(/readonly property QtObject popups: QtObject \{\s*property color background: ([^\n]+)/)
const cardBinding = osdSource.match(/id: card\n[^]*?\n      color: ([^\n]+)/)
if (!popupBinding || !cardBinding) fail('popup and OSD card color bindings exist')
context.root.composed = context.composed
for (const [background, alpha, expected, description] of [
  ['transparent', 0, Qt.rgba(0, 0, 0, 0), 'transparent popup stays transparent'],
  ['#336699', 0.5, Qt.rgba(0.2, 0.4, 0.6, 0.5), 'translucent popup preserves RGB and alpha'],
  ['#ffffff', 1, Qt.rgba(1, 1, 1, 1), 'opaque popup stays opaque']
]) {
  context.root.shellValues = context.parseShell(`[popups]\nbackground = "${background}"\nbackground-alpha = ${alpha}\ntext = "#111111"`)
  context.shellValues = context.root.shellValues
  context.Color = { popups: {
    background: vm.runInContext(popupBinding[1], context),
    text: context.pick('popups.text', context.root.foreground)
  } }
  assertEqual(context.Color.popups.text, '#111111', 'light theme uses dark popup text')
  assertDeepEqual(vm.runInContext(cardBinding[1], context), expected, `OSD ${description}`)
}
JS
