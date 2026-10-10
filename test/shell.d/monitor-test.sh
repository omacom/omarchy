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
assertEqual(monitor.cleanScale(1.25, 6016, 3384), String(4 / 3), 'monitor retains the precise physical display scale')
assertEqual(monitor.cleanScale(1.6, 0, 800), '', 'monitor rejects a missing display mode')
assertEqual(monitor.cleanScale(0.001, 1920, 1080), '', 'monitor rejects scales below one Wayland step')
assertEqual(monitor.normalizeScale('0.83'), '0.83', 'monitor preserves compositor precision for matching')
assertEqual(monitor.scaleLabel(5 / 6), '0.833x', 'monitor keeps the five-sixths button label compact')

const expandedScales = ['0.75', '0.8', String(5 / 6), '1', '1.25', '1.6', '2', '3', '4']
for (const [scale, size] of [['0.75', '2560 × 1440'], ['0.8', '2400 × 1350'], [String(5 / 6), '2304 × 1296']]) {
  assertEqual(monitor.cleanScale(scale, 1920, 1080), scale, `monitor preserves the precise ${scale} scale`)
  assertEqual(monitor.desktopSize(scale, 1920, 1080), size, `monitor shows the ${scale} desktop dimensions`)
}
assertDeepEqual(monitor.availableScales(expandedScales, 1920, 1080), expandedScales, 'monitor offers all nine presets on 1080p')
assertEqual(monitor.matchingScaleIndex(expandedScales, '0.83', 1920, 1080), 2, 'monitor selects five-sixths from rounded live state')
assertEqual(monitor.cleanScale(5 / 6, 1792, 1008), '0.875', 'monitor retains seven-eighths when a mode requires it')
assertEqual(monitor.matchingScaleIndex(expandedScales, '0.88', 1792, 1008), 2, 'monitor matches rounded seven-eighths without snapping it to another Wayland step')
assertEqual(monitor.matchingScaleIndex(expandedScales, '1', 1920, 1080), 3, 'monitor still selects native scale')
assertEqual(monitor.desktopSize('', 1920, 1080), '', 'monitor omits desktop dimensions until the scale is known')

for (const [width, height] of [[1366, 768], [2560, 1440], [3840, 2160]]) {
  const effective = monitor.availableScales(expandedScales, width, height).map(scale => Number(monitor.cleanScale(scale, width, height)))
  assertEqual(new Set(effective).size, effective.length, `monitor deduplicates expanded scales for ${width}x${height}`)
  assert(effective.every(scale => Math.abs(width / scale - Math.round(width / scale)) < 1e-6
    && Math.abs(height / scale - Math.round(height / scale)) < 1e-6), `monitor scales produce whole logical dimensions for ${width}x${height}`)
}
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
