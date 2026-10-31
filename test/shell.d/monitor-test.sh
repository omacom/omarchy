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
  monitor.generateScalePresets(0, 0),
  ['1', '1.25', '1.6', '2', '3', '4'],
  'generateScalePresets falls back when display dimensions are unknown'
)
assertDeepEqual(
  monitor.generateScalePresets(1920, 1080),
  ['1', '1.25', '1.5', '1.6667', '1.875', '2'],
  'generateScalePresets generates clean scales for 1080p'
)
assertDeepEqual(
  monitor.generateScalePresets(1920, 1080).map(s => monitor.cleanScale(s, 1920, 1080)),
  ['1', '1.25', '1.5', '1.67', '1.88', '2'],
  'generateScalePresets produces distinct clean effective scale labels'
)
assertDeepEqual(
  monitor.generateScalePresets(1920, 1080, '1.33'),
  ['1', '1.2', '1.3333', '1.6', '1.875', '2'],
  'generateScalePresets includes active scale for 1080p'
)
assertDeepEqual(
  monitor.generateScalePresets(2560, 1440),
  ['1', '1.3333', '1.6667', '2', '2.1333', '2.5'],
  'generateScalePresets generates clean scales for 1440p'
)
assertDeepEqual(
  monitor.generateScalePresets(3840, 2160),
  ['1', '1.5', '2', '2.6667', '3.3333', '4'],
  'generateScalePresets generates clean scales for 4K'
)
assertDeepEqual(
  monitor.generateScalePresets(1280, 804),
  ['1', '1.3333', '2'],
  'generateScalePresets yields fewer buttons when clean divisors are limited'
)
assert(
  monitor.generateScalePresets(2100, 1575, '1.05').includes('1.05'),
  'generateScalePresets anchors closest candidate when adjacent clean divisors exist'
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
