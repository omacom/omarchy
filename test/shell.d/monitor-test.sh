#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const monitor = requireFromRoot('shell/plugins/panels/monitor/Model.js')
const arrangement = requireFromRoot('shell/plugins/panels/monitor/ArrangementModel.js')

const screens = [
  {name:'DP-1', x:0, y:0, logicalWidth:1920, logicalHeight:1080},
  {name:'DP-2', x:1920, y:0, logicalWidth:1280, logicalHeight:720},
  {name:'DP-3', x:3200, y:0, logicalWidth:1920, logicalHeight:1080}
]
assertDeepEqual(arrangement.positions(arrangement.snap(screens, 'DP-2', 1911, 123, 20).layout),
  {'DP-1':[0,0], 'DP-2':[1920,123], 'DP-3':[3200,0]}, 'drag snaps an edge and retains an intermediate offset')
assertDeepEqual(arrangement.positions(arrangement.snap(screens, 'DP-2', 1915, 354, 20).layout),
  {'DP-1':[0,0], 'DP-2':[1920,360], 'DP-3':[3200,0]}, 'drag snaps bottom alignment')
assertEqual(arrangement.snap(screens, 'DP-2', 1000, 400, 20), null, 'drag rejects a colliding drop')
assertEqual(arrangement.snap(screens, 'DP-2', 7000, 5000, 20), null, 'drag requires a nearby screen edge')
assertEqual(arrangement.overlaps(arrangement.place(screens, 'DP-2', 2500, 0)), true, 'third-screen overlap is detected')
const draft = arrangement.place(screens, 'DP-3', 0, 1080)
assertDeepEqual(arrangement.positions(arrangement.preset(draft, 'DP-2', 'DP-1', 'left', 'center')),
  {'DP-1':[0,0], 'DP-2':[-1280,180], 'DP-3':[0,1080]}, 'presets retain other draft moves')

assertDeepEqual(arrangement.pair([{name:'eDP-1'}, {name:'DP-1'}, {name:'DP-2'}], '', ''),
  {moving:'DP-2', reference:'eDP-1'}, 'arrangement chooses a distinct laptop pair')
assertDeepEqual(arrangement.pair([{name:'DP-1'}, {name:'DP-2'}], '', ''),
  {moving:'DP-2', reference:'DP-1'}, 'arrangement supports desktop-only screens')
assertDeepEqual(arrangement.pair([{name:'DSI-1'}, {name:'DP-1'}], '', ''),
  {moving:'DP-1', reference:'DSI-1'}, 'arrangement recognizes an internal DSI display')
assertDeepEqual(arrangement.pair([{name:'DP-1'}], 'disconnected', 'DP-1'),
  {moving:'', reference:'DP-1'}, 'arrangement clears a disconnected selection')
assertDeepEqual(arrangement.pair([], '', ''), {moving:'', reference:''}, 'arrangement handles no screens')
assertDeepEqual(arrangement.bounds([
  {x:-1152, y:-200, logicalWidth:1152, logicalHeight:2048},
  {x:0, y:-200, logicalWidth:1920, logicalHeight:1080}
]), {x:-1152, y:-200, width:3072, height:2048}, 'diagram fits scaled rotated screens at negative coordinates')

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
JS
