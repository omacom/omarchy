#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const monitor = requireFromRoot('shell/plugins/panels/monitor/Model.js')
const fs = require('fs')

assertEqual(monitor.clampBrightness(0), 1, 'monitor clamps minimum brightness')
assertEqual(monitor.clampBrightness(101), 100, 'monitor clamps maximum brightness')
assertEqual(monitor.clampBrightness(42.4), 42, 'monitor rounds brightness')
assertEqual(monitor.clampBrightness('nope'), 1, 'monitor rejects invalid brightness')

assertEqual(monitor.normalizeScale('1.250'), '1.25', 'monitor normalizes fractional scale')
assertEqual(monitor.normalizeScale('nope'), '', 'monitor rejects invalid scale')
assertEqual(monitor.cleanScale(3, 1280, 800), '3.2', 'monitor matches clean VM scale')
assertEqual(monitor.cleanScale(1.25, 1280, 800), '1.25', 'monitor preserves an already clean scale')
assertEqual(monitor.cleanScale(1.25, 6016, 3384), '1.33', 'monitor matches clean physical display scale')
assertEqual(monitor.cleanScale(1.6, 0, 800), '', 'monitor rejects a missing display mode')
assertEqual(
  monitor.matchingScaleIndex(['1', '1.25', '1.6', '2', '3', '4'], 3.2, 1280, 800),
  4,
  'monitor selects an approximated VM scale'
)
assertEqual(
  monitor.matchingScaleIndex(['1', '1.25', '1.6', '2', '3', '4'], 4, 4, 4),
  5,
  'monitor selects an exact preset'
)
assertDeepEqual(
  monitor.availableScales(['1', '1.25', '1.6', '2', '3', '4'], 1280, 800),
  ['1', '1.25', '1.6', '2', '3', '4'],
  'monitor keeps distinct approximated VM scales'
)
assertDeepEqual(
  monitor.availableScales(['1', '1.25', '1.6', '2', '3', '4'], 6016, 3384),
  ['1', '1.25', '1.6', '2', '3', '4'],
  'monitor keeps distinct approximated physical display scales'
)
assertDeepEqual(
  monitor.availableScales(['1', '1.25', '1.6', '2', '3', '4'], 1280, 804),
  ['1', '1.25', '2', '4'],
  'monitor collapses presets with duplicate effective scales'
)
assertDeepEqual(
  monitor.availableScales(['1', '1.25', '1.6', '2', '3', '4'], 5968, 3230),
  ['1', '2'],
  'monitor hides presets the current mode cannot reach'
)
assertDeepEqual(
  monitor.availableScales(['1', '1.25', '1.6', '2', '3', '4'], 0, 0),
  ['1', '1.25', '1.6', '2', '3', '4'],
  'monitor keeps presets until display dimensions are known'
)

assertEqual(monitor.brightnessName(96), 'Sun blast', 'monitor names very bright displays')
assertEqual(monitor.brightnessName(12), 'Candlelit', 'monitor names dim displays')

assertDeepEqual(
  monitor.parseDisplays(JSON.stringify([
    { name: 'eDP-1', enabled: true, focused: false, width: 1920, height: 1080 },
    { name: 'HDMI-A-1', enabled: false, focused: false, width: 0, height: 0 },
    { name: 'DP-1', enabled: true, focused: true, width: 1280, height: 800 }
  ])),
  {
    displays: [
      { name: 'eDP-1', enabled: true, focused: false, width: 1920, height: 1080 },
      { name: 'HDMI-A-1', enabled: false, focused: false, width: 0, height: 0 },
      { name: 'DP-1', enabled: true, focused: true, width: 1280, height: 800 }
    ],
    enabledDisplayCount: 2
  },
  'monitor parses display state'
)

assertDeepEqual(monitor.parseDisplays('{'), { displays: [], enabledDisplayCount: 0 }, 'monitor handles invalid display JSON')

const twoDisplays = [
  { name: 'eDP-1', enabled: true, focused: true, width: 2880, height: 1800, scale: 2 },
  { name: 'DP-1', enabled: true, focused: false, width: 2560, height: 1440, scale: 1.25 }
]
assertEqual(monitor.scaleDisplay(twoDisplays, 'DP-1', 'eDP-1').scale, 1.25,
  'monitor uses the selected, unfocused display scale')
assertEqual(monitor.scaleDisplay(twoDisplays, '', 'eDP-1').name, 'eDP-1',
  'monitor starts with the focused display')
assertEqual(monitor.scaleDisplay(twoDisplays, 'DP-1', 'eDP-1').width, 2560,
  'monitor uses the selected display mode for scale presets')
assertEqual(monitor.scaleDisplay([twoDisplays[0], { ...twoDisplays[1], enabled: false }], 'DP-1', 'eDP-1').name, 'eDP-1',
  'monitor falls back when the selected display is disabled')

const panelSource = fs.readFileSync(root + '/shell/plugins/panels/monitor/Panel.qml', 'utf8')
const movement = panelSource.match(/onMoveRequested: function\(dx, dy\) \{([\s\S]*?)\n      \}\n      onActivateRequested:/)
assert(movement, 'monitor panel exposes its keyboard movement handler')
const cursor = { cursorActive: true, focusSection: 'scaleTargets', selectedIndex: 0,
  moveCursorH(delta) { this.selectedIndex += delta } }
new Function('root', 'dx', 'dy', movement[1])(cursor, 1, 0)
assertEqual(cursor.selectedIndex, 1, 'keyboard right reaches the second display selector')
JS
