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

// A 6K panel also advertises a tiled half-width mode and legacy sizes.
const sixK = ['6016x3384@60.00Hz', '3840x2160@60.00Hz', '6016x3384@59.94Hz', '5120x2880@60.00Hz',
  '2560x2880@60.00Hz', '2560x1440@60.00Hz', '1920x1080@60.00Hz', '1280x720@60.00Hz', '1024x768@60.00Hz']
assertDeepEqual(
  monitor.resolutionOptions(sixK, 6016, 3384),
  ['1920x1080', '2560x1440', '3840x2160', '5120x2880', '6016x3384'],
  'monitor offers the native resolution and its same-shape modes, capped'
)
assertDeepEqual(
  monitor.resolutionOptions(sixK, 1024, 768),
  ['1024x768', '1920x1080', '2560x1440', '3840x2160', '5120x2880', '6016x3384'],
  'monitor keeps an odd current resolution in the list'
)
assertDeepEqual(
  monitor.resolutionOptions(['3840x2160@60.00Hz', '2560x1440@60.00Hz', '1920x1080@60.00Hz', '1600x900@60.00Hz', '1280x720@60.00Hz'], 3840, 2160),
  ['1920x1080', '2560x1440', '3840x2160'],
  'monitor offers nothing below 1080p'
)
assertDeepEqual(monitor.resolutionOptions(undefined, 0, 0), [], 'monitor offers no resolutions without modes')
assertEqual(monitor.resolutionLabel('6016x3384'), '6K', 'monitor names 6K')
assertEqual(monitor.resolutionLabel('3840x2160'), '4K', 'monitor names 4K')
assertEqual(monitor.resolutionLabel('2560x1440'), '1440p', 'monitor names smaller modes by height')

// A gaming monitor advertises several rates at its resolution, and others at
// smaller ones and below 60Hz.
const gaming = ['2560x1440@143.98Hz', '2560x1440@120.00Hz', '2560x1440@59.95Hz', '2560x1440@60.00Hz',
  '2560x1440@50.00Hz', '1920x1080@240.00Hz']
assertDeepEqual(
  monitor.refreshOptions(gaming, 2560, 1440),
  [{ label: '60', rate: '60' }, { label: '120', rate: '120' }, { label: '144', rate: '143.98' }],
  'monitor offers its resolution\'s rates from 60Hz up, one per whole rate, keeping the exact one'
)
assertDeepEqual(
  monitor.refreshOptions(['3840x2160@60.00Hz', '3840x2160@59.94Hz', '3840x2160@30.00Hz'], 3840, 2160),
  [],
  'monitor offers no rates when none is faster than 60Hz'
)

assertEqual(monitor.displayTitle({ name: 'eDP-1', make: 'LG Display', model: '0x0804' }), 'Built-in Display', 'monitor names the built-in panel by what it is')
assertEqual(monitor.displayTitle({ name: 'DP-1', make: 'Apple Computer Inc', model: 'ProDisplayXDR' }), 'ProDisplayXDR', 'monitor names an external display by its model')
assertEqual(monitor.displayTitle({ name: 'HDMI-A-1', make: 'Dell Inc.', model: '0x40F3' }), 'Dell Inc.', 'monitor falls back to the make when the model is a code')

assertDeepEqual(
  monitor.logicalRect({ name: 'DP-1', x: 1280, y: 0, width: 6016, height: 3384, scale: 2, transform: 1 }),
  { name: 'DP-1', x: 1280, y: 0, w: 1692, h: 3008 },
  'monitor lays out a rotated display by its scaled, turned size'
)

// A laptop at 1280x800 with a 6K at 3008x1692 to its right, tops aligned.
const desk = [{ name: 'eDP-1', x: 0, y: 0, w: 1280, h: 800 }, { name: 'DP-1', x: 1280, y: 0, w: 3008, h: 1692 }]
assertDeepEqual(
  monitor.dropDisplay(desk, 'eDP-1', 1000, 1650, 40),
  [{ name: 'eDP-1', x: 0, y: 1692, w: 1280, h: 800 }, { name: 'DP-1', x: 280, y: 0, w: 3008, h: 1692 }],
  'monitor drops a display against the nearest side and starts the layout at 0x0'
)
assertDeepEqual(
  monitor.dropDisplay(desk, 'eDP-1', 2120, 1700, 40).find((r) => r.name === 'eDP-1'),
  { name: 'eDP-1', x: 864, y: 1692, w: 1280, h: 800 },
  'monitor snaps a dropped display to the center of the one it lands against'
)
assertDeepEqual(
  monitor.placeDisplay(desk, 'eDP-1', 'right'),
  [{ name: 'eDP-1', x: 3008, y: 446, w: 1280, h: 800 }, { name: 'DP-1', x: 0, y: 0, w: 3008, h: 1692 }],
  'monitor moves a display to the right of the rest, centered'
)
assert(monitor.sameLayout(monitor.normalizeLayout(desk), desk), 'monitor sees an unmoved layout as the same')

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
