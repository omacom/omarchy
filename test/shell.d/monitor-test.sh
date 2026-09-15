#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const monitor = requireFromRoot('shell/plugins/panels/monitor/Model.js')

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

assertDeepEqual(
  monitor.scalesWithCurrent(['1', '1.25', '1.6', '2', '3', '4'], 3.2, 1280, 800),
  ['1', '1.25', '1.6', '2', '3', '4'],
  'monitor leaves the preset ladder alone when the current scale is already a pill'
)
assertDeepEqual(
  monitor.scalesWithCurrent(['1', '1.25', '1.6', '2', '3', '4'], 1.5, 1920, 1080),
  ['1', '1.25', '1.5', '1.6', '2', '3', '4'],
  'monitor inserts a non-preset current scale in numeric order'
)
assertDeepEqual(
  monitor.scalesWithCurrent(['1', '1.25', '1.6', '2', '3', '4'], '', 1920, 1080),
  ['1', '1.25', '1.6', '2', '3', '4'],
  'monitor leaves the ladder alone without a current scale'
)
assertDeepEqual(
  monitor.scalesWithCurrent(['1', '1.25', '1.6', '2', '3', '4'], 'nope', 1920, 1080),
  ['1', '1.25', '1.6', '2', '3', '4'],
  'monitor leaves the ladder alone for an invalid current scale'
)
assertDeepEqual(
  monitor.scalesWithCurrent(
    monitor.availableScales(['1', '1.25', '1.6', '2', '3', '4'], 5968, 3230),
    1.5, 5968, 3230
  ),
  ['1', '1.5', '2'],
  'monitor inserts the current scale into a mode-filtered ladder'
)
assertEqual(
  monitor.matchingScaleIndex(
    monitor.scalesWithCurrent(['1', '1.25', '1.6', '2', '3', '4'], 1.5, 1920, 1080),
    1.5, 1920, 1080
  ),
  2,
  'monitor marks the inserted current-scale pill active'
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
JS

# Textual assertions over Panel.qml: own-screen targeting, argv shape, and the
# header/row bindings can't run headless, so pin the invariants in the source.
run_node_test <<'JS'
const fs = require('fs')
const panelQml = fs.readFileSync(path.join(root, 'shell/plugins/panels/monitor/Panel.qml'), 'utf8')

assert(
  panelQml.includes('root.QsWindow') &&
    panelQml.includes('readonly property string ownScreenName'),
  'monitor panel resolves its own screen from the hosting window'
)

const setScaleMatch = panelQml.match(/function setScale\(scale\) \{([\s\S]*?)\n  \}/)
assert(setScaleMatch, 'monitor panel setScale function exists')
assert(
  setScaleMatch[1].includes('"omarchy-hyprland-monitor-scaling"'),
  'monitor panel applies scale through the scaling CLI'
)
assert(
  setScaleMatch[1].includes('ownScreenName'),
  'monitor panel passes its own screen name to the scaling CLI'
)
assert(
  setScaleMatch[1].includes('!actionProc.running'),
  'monitor panel keeps the actionProc re-spawn guard'
)
assert(
  !setScaleMatch[1].includes('"bash"') &&
    !setScaleMatch[1].includes('"omarchy-hyprland-monitor-scaling '),
  'monitor panel builds the scaling command as direct argv'
)

const scaleMonitorMatch = panelQml.match(/id: scaleMonitor[\s\S]*?anchors\.right: parent\.right/)
assert(scaleMonitorMatch, 'monitor panel scaleMonitor header exists')
assert(
  scaleMonitorMatch[0].includes('root.ownScreenName') &&
    scaleMonitorMatch[0].includes('root.ownScale'),
  'monitor panel scale header names the hosting screen and its scale'
)
assert(
  !scaleMonitorMatch[0].includes('root.focusedMonitor') &&
    !scaleMonitorMatch[0].includes('enabledDisplayCount'),
  'monitor panel scale header does not follow the focused monitor or display count'
)
assert(
  scaleMonitorMatch[0].includes('visible: root.ownScreenName !== "" && root.ownScale !== ""'),
  'monitor panel scale header shows only when the own screen and its scale are known'
)

const monitorRowTextMatch = panelQml.match(/text: monitorRow\.display\.name[^\n]*/)
assert(monitorRowTextMatch, 'monitor row name binding exists')
assert(
  monitorRowTextMatch[0].includes('normalizeScale(monitorRow.display.scale)'),
  'monitor row appends the display scale'
)
assert(
  monitorRowTextMatch[0].includes('monitorRow.display.focused ? " · focused" : ""'),
  'monitor row keeps the focused suffix'
)
assert(
  monitorRowTextMatch[0].indexOf('normalizeScale(monitorRow.display.scale)') <
    monitorRowTextMatch[0].indexOf('" · focused"'),
  'monitor row renders name, scale, then focused'
)

assert(
  panelQml.includes('Model.parseDisplays') &&
    !panelQml.includes('"hyprctl", "monitors"'),
  'monitor panel keeps a single displays-JSON path through omarchy-monitor-state'
)
JS
