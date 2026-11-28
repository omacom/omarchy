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
assertEqual(monitor.resolutionLabel('5120x2160'), '5K2K', 'monitor names ultrawide 5K2K rather than 4K')
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

assertEqual(
  monitor.displaySpecs({ width: 1920, height: 1200, physicalWidth: 300, physicalHeight: 190, refreshRate: 119.94 }),
  '1920×1200 · 120 Hz · 161 ppi',
  'monitor describes a display by resolution, rounded refresh rate, and pixel density'
)
assertEqual(
  monitor.displaySpecs({ width: 1920, height: 1080, physicalWidth: 0, physicalHeight: 0, refreshRate: 60 }),
  '1920×1080 · 60 Hz',
  'monitor leaves out the density of a display that reports no size'
)
assertEqual(
  monitor.displaySpecs({ width: 1920, height: 1080, physicalWidth: 600, physicalHeight: 150, refreshRate: 60 }),
  '1920×1080 · 60 Hz',
  'monitor leaves out the density of a display whose size disagrees with its shape'
)
assertEqual(
  monitor.displaySpecs({ width: 3840, height: 2160, physicalWidth: 16000, physicalHeight: 9000, refreshRate: 60 }),
  '3840×2160 · 60 Hz',
  'monitor leaves out the density of a display that reports an implausible size'
)

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

// Rapid text-size steps must queue the latest value while textScaleProc is
// running instead of dropping it and leaving textSizePreviewIndex stuck, and
// mouse slider release must keep the preview stop until Style catches up.
const fs = require('fs')
const vm = require('vm')
const panelSource = fs.readFileSync(path.join(root, 'shell/plugins/panels/monitor/Panel.qml'), 'utf8')
const extractFn = (name, required = true) => {
  const m = panelSource.match(new RegExp(`^( *)function ${name}\\([^)]*\\)\\s*\\{([\\s\\S]*?)\\n\\1\\}`, 'm'))
  if (!m) {
    if (required) throw new Error('missing function ' + name)
    return ''
  }
  return m[0]
}
const sliderBlock = panelSource.match(/PanelSlider\s*\{\s*id:\s*textSizeSlider[\s\S]*?\n\s*\}/)[0]
const sliderReleaseMatch = sliderBlock.match(/onReleased:\s*(function\([^)]*\)\s*\{[\s\S]*?\})/)
assert(sliderReleaseMatch, 'textSizeSlider defines an onReleased handler')
const procBlock = panelSource.match(/Process\s*\{\s*id:\s*textScaleProc[\s\S]*?\n  \}/)[0]
const runningMatch = procBlock.match(/onRunningChanged:\s*\{([\s\S]*?)\n    \}/)
const exitedMatch = procBlock.match(/onExited:\s*function\(exitCode\)\s*\{([\s\S]*?)\n    \}/)

const commands = []
const proc = {
  _running: false,
  command: [],
  get running() { return this._running },
  set running(v) {
    this._running = v
    if (v) commands.push(this.command.slice())
  },
}
const scope = {
  textSizeStops: [11, 12, 14, 16, 18],
  textSizePreviewIndex: -1,
  pendingTextSize: -1,
  reflows: 0,
  Style: { font: { baseSize: 12 } },
  textScaleProc: proc,
  markReflowing: () => { scope.reflows += 1 },
}
scope.root = scope
vm.createContext(scope)
vm.runInContext([
  extractFn('nearestTextStop'),
  extractFn('currentTextIndex'),
  extractFn('setTextSize'),
  extractFn('applyTextSizeStop', false),
  extractFn('adjustTextSize'),
  `var onSliderReleased = ${sliderReleaseMatch[1]}`,
  `function onProcRunningChanged(running) { ${runningMatch ? runningMatch[1] : ''} }`,
  `function onProcExited(exitCode) { ${exitedMatch ? exitedMatch[1] : ''} }`,
].filter(Boolean).join('\n'), scope)

scope.adjustTextSize(1)
assertEqual(scope.textSizePreviewIndex, 2, 'first step previews 14px stop')
assertDeepEqual(commands, [['omarchy-display-text-size', '14']], 'first step launches CLI')
// Second step while first CLI run is still in flight must be queued, not dropped.
scope.adjustTextSize(1)
assertEqual(scope.textSizePreviewIndex, 3, 'second rapid step advances preview to 16px stop')
assertDeepEqual(commands, [['omarchy-display-text-size', '14']], 'second rapid step waits for active process')
proc.running = false
scope.onProcExited(0)
scope.onProcRunningChanged(false)
assertDeepEqual(commands, [
  ['omarchy-display-text-size', '14'],
  ['omarchy-display-text-size', '16'],
], 'queued text size runs once the first command finishes')
scope.Style.font.baseSize = 16
proc.running = false
scope.onProcExited(0)
scope.onProcRunningChanged(false)
assertEqual(scope.textSizePreviewIndex, -1, 'preview clears once Style matches the applied stop')

// Releasing the mouse slider previews the target stop, guards reflow, and clears on failure.
const reflowsBefore = scope.reflows
scope.onSliderReleased(4)
assertEqual(scope.textSizePreviewIndex, 4, 'slider release previews target stop')
assertEqual(scope.reflows, reflowsBefore + 1, 'slider release arms reflow hover guard')
proc.running = false
scope.onProcExited(1)
scope.onProcRunningChanged(false)
assertEqual(scope.textSizePreviewIndex, -1, 'failed text size update clears preview')

// Brightness slider: internal displays apply immediately on drag via
// brightnessctl and coalesce in-flight moves; external displays throttle
// between drag writes and flush on release; stale state polls never snap back.
const brightnessSliderBlock = panelSource.match(/PanelSlider\s*\{\s*id:\s*brightnessSlider[\s\S]*?\n\s*\}/)[0]
const brightnessMovedMatch = brightnessSliderBlock.match(/onMoved:\s*(function\([^)]*\)\s*\{[\s\S]*?\})/)
const brightnessReleasedMatch = brightnessSliderBlock.match(/onReleased:\s*(function\([^)]*\)\s*\{[\s\S]*?\})/)
assert(brightnessMovedMatch && brightnessReleasedMatch, 'brightnessSlider defines onMoved and onReleased handlers')

const brightnessProcBlock = panelSource.match(/Process\s*\{\s*id:\s*setBrightnessProc[\s\S]*?\n  \}/)[0]
const brightnessRunningMatch = brightnessProcBlock.match(/onRunningChanged:\s*\{([\s\S]*?)\n    \}/)
const brightnessExitedMatch = brightnessProcBlock.match(/onExited:\s*function\(exitCode\)\s*\{([\s\S]*?)\n    \}/)
const stateProcBlock = panelSource.match(/Process\s*\{\s*id:\s*stateProc[\s\S]*?\n  \}/)[0]
const stateRunningMatch = stateProcBlock.match(/onRunningChanged:\s*\{([\s\S]*?)\n    \}/)
const stateFinishedMatch = stateProcBlock.match(/onStreamFinished:\s*\{([\s\S]*?)\n      \}/)

const brightnessCommands = []
const brightnessProc = {
  _running: false,
  command: [],
  get running() { return this._running },
  set running(v) {
    this._running = v
    if (v) brightnessCommands.push(this.command.slice())
  },
}
const brightnessThrottle = {
  running: false,
  start() { this.running = true },
  restart() { this.running = true },
  stop() { this.running = false },
}
const bScope = {
  Model: monitor,
  backlightDevice: 'intel_backlight',
  backlightDeviceProbed: true,
  brightnessAvailable: false,
  brightnessPercent: 50,
  brightnessLevels: { 'eDP-1': 50, 'DP-1': 60 },
  focusedMonitor: 'eDP-1',
  internalMonitor: '',
  externalMonitor: '',
  internalEnabled: false,
  monitorScale: '',
  displaysJson: '',
  displays: [],
  current: { name: 'eDP-1' },
  brightnessDragging: true,
  pendingBrightnessMonitor: '',
  pendingBrightnessPercent: 0,
  brightnessSetQueued: false,
  inFlightBrightnessMonitor: '',
  inFlightBrightnessPercent: 0,
  inFlightInternalBacklight: false,
  inFlightExitCode: -1,
  lastWrittenMonitor: '',
  lastWrittenPercent: 0,
  brightnessWrites: 0,
  readAfterBrightnessWrites: 0,
  actionsDone: 0,
  readAfterActions: 0,
  rereadState: false,
  awaitingFreshState: false,
  pendingMirror: '',
  actionBusy: false,
  pendingRects: null,
  mirrorManaged: false,
  setBrightnessProc: brightnessProc,
  brightnessThrottle: brightnessThrottle,
  deviceProc: { running: false },
  stateProc: { running: false },
  Qt: { callLater: (fn) => fn() },
  refresh: () => {},
  normalizeScale: monitor.normalizeScale,
}
bScope.root = bScope
vm.createContext(bScope)
vm.runInContext([
  extractFn('isInternalBacklight'),
  extractFn('ensureBacklightDevice'),
  extractFn('brightnessCommand'),
  extractFn('startBrightnessWrite'),
  extractFn('applyBrightness'),
  extractFn('showBrightness'),
  extractFn('setDisplayBrightness'),
  extractFn('dragBrightness'),
  extractFn('commitBrightness'),
  extractFn('updateDisplays'),
  `var onBrightnessMoved = ${brightnessMovedMatch[1]}`,
  `var onBrightnessReleased = ${brightnessReleasedMatch[1]}`,
  `function onBrightnessProcRunningChanged(running) { ${brightnessRunningMatch ? brightnessRunningMatch[1] : ''} }`,
  `function onBrightnessProcExited(exitCode) { ${brightnessExitedMatch ? brightnessExitedMatch[1] : ''} }`,
  `function onStateProcRunningChanged(running) { ${stateRunningMatch ? stateRunningMatch[1] : ''} }`,
  `function onStateStreamFinished(text) { ${stateFinishedMatch ? stateFinishedMatch[1] : ''} }`,
].join('\n'), bScope)

// Internal panel drag updates immediately without waiting for slider release.
bScope.onBrightnessMoved(48)
assertDeepEqual(
  brightnessCommands,
  [['brightnessctl', '-q', '-d', 'intel_backlight', 'set', '48%']],
  'internal brightness drag writes immediately on first move'
)
bScope.onBrightnessMoved(45)
bScope.onBrightnessMoved(42)
assertDeepEqual(
  brightnessCommands,
  [['brightnessctl', '-q', '-d', 'intel_backlight', 'set', '48%']],
  'in-flight moves coalesce instead of spawning concurrent processes'
)
// A state poll finishing while dragging/writing must not revert the slider level.
bScope.onStateProcRunningChanged(true)
bScope.onStateStreamFinished('50\neDP-1\nDP-1\neDP-1\n\neDP-1\n1\n[{"name":"eDP-1","enabled":true,"focused":true,"width":1920,"height":1080,"brightness":50},{"name":"DP-1","enabled":true,"focused":false,"width":2560,"height":1440,"brightness":60}]\noff\n')
assertEqual(bScope.brightnessLevels['eDP-1'], 42, 'stale state poll preserves active drag brightness')
assertEqual(bScope.brightnessPercent, 42, 'stale state poll preserves active focused brightness percent')

brightnessProc.running = false
bScope.onBrightnessProcExited(0)
bScope.onBrightnessProcRunningChanged(false)
assertDeepEqual(
  brightnessCommands,
  [
    ['brightnessctl', '-q', '-d', 'intel_backlight', 'set', '48%'],
    ['brightnessctl', '-q', '-d', 'intel_backlight', 'set', '42%'],
  ],
  'latest coalesced internal brightness runs as soon as the active write completes'
)
brightnessProc.running = false
bScope.onBrightnessProcExited(0)
bScope.onBrightnessProcRunningChanged(false)
bScope.brightnessDragging = false
bScope.onBrightnessReleased(42)
assertEqual(brightnessCommands.length, 2, 'releasing on the already-written value avoids a duplicate write')

// External monitor drag writes immediately, throttles subsequent drag steps,
// and flushes immediately on release.
brightnessCommands.length = 0
bScope.current = { name: 'DP-1' }
bScope.brightnessDragging = true
bScope.onBrightnessMoved(58)
assertDeepEqual(
  brightnessCommands,
  [['omarchy-brightness-display', '--no-osd', '--monitor', 'DP-1', '58%']],
  'external brightness drag writes immediately on first move'
)
brightnessProc.running = false
bScope.onBrightnessProcExited(0)
bScope.onBrightnessProcRunningChanged(false)
assert(brightnessThrottle.running, 'external brightness write arms drag cooldown')
bScope.onBrightnessMoved(55)
assertEqual(brightnessCommands.length, 1, 'subsequent external drag step waits for cooldown')
bScope.brightnessDragging = false
bScope.onBrightnessReleased(55)
assertDeepEqual(
  brightnessCommands,
  [
    ['omarchy-brightness-display', '--no-osd', '--monitor', 'DP-1', '58%'],
    ['omarchy-brightness-display', '--no-osd', '--monitor', 'DP-1', '55%'],
  ],
  'releasing external brightness slider flushes final value immediately'
)
brightnessProc.running = false
bScope.onBrightnessProcExited(0)
bScope.onBrightnessProcRunningChanged(false)
brightnessThrottle.stop()

// A poll that started during an in-flight write and finishes only after the
// write and cooldown end must still be discarded so it cannot snap back.
bScope.onBrightnessMoved(52)
bScope.onStateProcRunningChanged(true)
brightnessProc.running = false
bScope.onBrightnessProcExited(0)
bScope.onBrightnessProcRunningChanged(false)
brightnessThrottle.stop()
bScope.onStateStreamFinished('55\neDP-1\nDP-1\neDP-1\n\neDP-1\n1\n[{"name":"eDP-1","enabled":true,"focused":true,"width":1920,"height":1080,"brightness":42},{"name":"DP-1","enabled":true,"focused":false,"width":2560,"height":1440,"brightness":55}]\noff\n')
assertEqual(bScope.brightnessLevels['DP-1'], 52, 'poll overlapping a completed write does not revert brightness')

// An idle poll with no overlapping write updates external brightness normally.
bScope.onStateProcRunningChanged(true)
bScope.onStateStreamFinished('70\neDP-1\nDP-1\neDP-1\n\neDP-1\n1\n[{"name":"eDP-1","enabled":true,"focused":true,"width":1920,"height":1080,"brightness":42},{"name":"DP-1","enabled":true,"focused":false,"width":2560,"height":1440,"brightness":70}]\noff\n')
assertEqual(bScope.brightnessLevels['DP-1'], 70, 'idle poll picks up external brightness changes')

// Dragging away and back to the value already being written must not run a
// duplicate write after the in-flight write succeeds.
brightnessCommands.length = 0
bScope.brightnessDragging = true
bScope.onBrightnessMoved(48)
bScope.onBrightnessMoved(45)
bScope.onBrightnessMoved(48)
bScope.brightnessDragging = false
bScope.onBrightnessReleased(48)
brightnessProc.running = false
bScope.onBrightnessProcExited(0)
bScope.onBrightnessProcRunningChanged(false)
assertDeepEqual(
  brightnessCommands,
  [['omarchy-brightness-display', '--no-osd', '--monitor', 'DP-1', '48%']],
  'returning to the in-flight target before completion skips a duplicate write'
)
JS
