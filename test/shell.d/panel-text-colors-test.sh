#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const clock = fs.readFileSync(root + '/shell/plugins/panels/clock/Panel.qml', 'utf8')
const weather = fs.readFileSync(root + '/shell/plugins/panels/weather/Panel.qml', 'utf8')
const binding = clock.match(/readonly property color contentForeground: ([^\n]+)/)[1]

// Evaluate the production calendar binding with independently themed surfaces.
// This is a binding regression check, not a rendered QML acceptance test.
for (const [name, barText, popupText] of [
  ['dark bar / light popup', '#ffffff', '#202124'],
  ['light bar / dark popup', '#202124', '#ffffff'],
  ['custom popup text', '#ffffff', '#0067b8']
]) {
  const context = { bar: { foreground: barText }, Color: { foreground: '#777777', popups: { text: popupText } } }
  assertEqual(vm.runInNewContext(binding, context), popupText, 'calendar uses popup text: ' + name)
}
assertEqual(vm.runInNewContext(binding, { bar: null, Color: { foreground: '#777777', popups: { text: '#202124' } } }), '#202124', 'calendar uses popup text without a bar')
assert(!/\bbar\.(?:foreground|barForeground)\b/.test(weather), 'weather popup never inherits bar text')
assert(/color: Color\.popups\.text/.test(weather), 'weather labels use popup text')
assert(/foreground: Color\.popups\.text/.test(weather), 'weather input uses popup text')
assert(/Style\.hoverStateColor\(Color\.popups\.text, Color\.accent\)/.test(weather), 'weather hover state receives popup text')
JS
