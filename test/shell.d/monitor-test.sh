#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const monitor = requireFromRoot('shell/plugins/panels/monitor/Model.js')

assertEqual(monitor.clampBrightness(0), 1, 'monitor clamps minimum brightness')
assertEqual(monitor.clampBrightness(101), 100, 'monitor clamps maximum brightness')
assertEqual(monitor.clampBrightness(42.4), 42, 'monitor rounds brightness')
assertEqual(monitor.clampBrightness('nope'), 1, 'monitor rejects invalid brightness')

// The reported failure: hardware at 62, the panel still holding 72. One notch
// down has to land on 57, and a write already in flight has to keep stepping
// from the percent it will land on rather than from a new reading of the old one.
assertEqual(monitor.brightnessStep(false, null, 62, 72, -5).target, 57, 'a downward step uses the live brightness, not the cached one')
assertEqual(monitor.brightnessStep(true, 57, 62, 72, -5).target, 52, 'a step during a write follows the level already asked for')
assertEqual(monitor.brightnessStep(false, null, -1, 72, -5).target, 67, 'a failed live read falls back to the cached level')
assertEqual(monitor.brightnessStep(false, null, -1, -1, -5).target, -1, 'a step with no level does nothing')
assertEqual(monitor.brightnessStep(false, null, 0, 72, 5).target, 5, 'a live reading of zero is a real level')

assertEqual(monitor.parseBrightnessReading('62\n'), 62, 'a brightness read is the percent')
assertEqual(monitor.parseBrightnessReading('unavailable'), -1, 'a failed brightness read is not a percent')
assertEqual(monitor.parseBrightnessReading('62 extra'), -1, 'a brightness read with a trailing word is rejected')

assertEqual(monitor.focusedBrightness('62').percent, 62, 'focused brightness parses a percent')
assertEqual(monitor.focusedBrightness('62').keep, false, 'a numeric focused brightness is applied')
assertEqual(monitor.focusedBrightness('').keep, true, 'an empty focused brightness keeps the level on screen')
assertEqual(monitor.focusedBrightness('unavailable').available, false, 'unavailable focused brightness clears control')
assertEqual(monitor.focusedBrightness('nope').keep, true, 'an unexpected focused brightness keeps the level on screen')
assertEqual(monitor.focusedBrightness('', false).keep, false, 'an empty reading for a newly focused display does not keep the previous level')
assertEqual(monitor.focusedBrightness('', false).available, false, 'a newly focused display with no reading is not controllable')
assertEqual(monitor.focusedBrightness('40', false).percent, 40, 'a newly focused display applies its own reading')

const duringWrite = monitor.focusedStateAfterRead(true, 50, 'eDP-1', 'DP-1', '', false)
assertEqual(duringWrite.available, false, 'focus leaving during a brightness write drops the previous level')
assertEqual(duringWrite.percent, 0, 'focus leaving during a brightness write clears the previous percent')
const afterWrite = monitor.focusedStateAfterRead(duringWrite.available, duringWrite.percent, 'DP-1', 'DP-1', '', true)
assertEqual(afterWrite.available, false, 'the next empty reading stays not controllable after that focus change')
assertEqual(monitor.focusedStateAfterRead(true, 50, 'eDP-1', 'eDP-1', '', true).percent, 50, 'an empty reading for the same display keeps its level')
assertEqual(monitor.focusedStateAfterRead(true, 50, 'eDP-1', 'eDP-1', '40', false).percent, 50, 'a state read during a write does not replace the level')
assertEqual(monitor.focusedStateAfterRead(true, 50, 'eDP-1', 'DP-1', '', true).available, false, 'moving focus onto a display with no reading clears control')

assertEqual(monitor.brightnessProbeCurrent(1, 2, true), false, 'a brightness read canceled before it returns does not apply')
assertEqual(monitor.brightnessProbeCurrent(2, 2, true), true, 'the brightness read still in flight applies')
assertEqual(monitor.brightnessProbeCurrent(2, 2, false), false, 'a brightness read that was dropped does not apply')
assertEqual(monitor.brightnessProbeAction({ running: true, settled: false, accepted: false }), 'hold', 'a canceled brightness read is drained before another starts')
assertEqual(monitor.brightnessProbeAction({ running: true, settled: false, accepted: true, sameMonitor: true }), 'accumulate', 'a second notch joins the brightness read already in flight')
assertEqual(monitor.brightnessProbeAction({ running: true, settled: false, accepted: true, sameMonitor: false }), 'drop', 'a step for another display leaves the brightness read alone')
assertEqual(monitor.brightnessProbeAction({ running: false, settled: true, accepted: false }), 'start', 'a finished brightness read leaves the next step free to start')

assertEqual(monitor.mergeBrightnessLevel(57, 62, false, 57), 57, 'a brightness read from before a write does not put the old level back')
assertEqual(monitor.mergeBrightnessLevel(57, null, true, 57), 57, 'a brightness read that returns nothing keeps a confirmed level')
assertEqual(monitor.mergeBrightnessLevel(57, null, true, null), null, 'a brightness read that returns nothing drops an optimistic level')
assertEqual(monitor.mergeBrightnessLevel(57, null, true, 70), 70, 'a failed read falls back to the last confirmed level, not an unconfirmed one on screen')
assertEqual(monitor.mergeBrightnessLevel(57, 40, true, 57), 40, 'a current brightness read replaces the level')
assertEqual(monitor.mergeBrightnessLevel(null, null, true, null), null, 'a display with no brightness stays without one')

// A write for one display does not hide the target of a write for another.
assertEqual(monitor.pendingBrightnessTarget('eDP-1', 50, [], 'eDP-1'), 50, 'an in-flight write names its own display')
assertEqual(monitor.pendingBrightnessTarget('eDP-1', 50, [{ monitor: 'DP-1', percent: 60 }], 'eDP-1'), 50, 'another display\'s queued write leaves the in-flight target alone')
assertEqual(monitor.pendingBrightnessTarget('eDP-1', 50, [{ monitor: 'DP-1', percent: 60 }], 'DP-1'), 60, 'a queued write names its own display')
assertEqual(monitor.pendingBrightnessTarget('eDP-1', 50, [{ monitor: 'eDP-1', percent: 55 }], 'eDP-1'), 55, 'the latest queued target for a display wins over its running write')
assertEqual(monitor.pendingBrightnessTarget('eDP-1', 50, [{ monitor: 'DP-1', percent: 60 }], 'HDMI-A-1'), -1, 'a display with no pending write has no target')

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

// A state read must drop an optimistic level that no write proved, while a
// confirmed level survives a transient read failure. This is the phantom row
// on a display with no brightness control.
const brightness = {
  brightnessLevels: {},
  brightnessConfirmed: {},
  queuedBrightness: [],
  brightnessWriteMonitor: "",
  brightnessWritePercent: 0,
  brightnessPreviewMonitor: "",
  brightnessPreviewPercent: 0,
  brightnessWritesDone: 0,
  brightnessAvailable: true,
  focusedMonitor: "eDP-1",
  brightnessProbeRunning: false,
  brightnessProbeMonitor: "",
  brightnessProbeDelta: 0,
  brightnessProbeShowOsd: false,
  brightnessProbe: { running: false },
  brightnessProbeSettled: true,
  brightnessProbeRestart: false,
  brightnessProbeRestartMonitor: "",
  brightnessProbeRestartDelta: 0,
  brightnessProbeRestartShowOsd: false,
  brightnessDebounce: {
    running: false,
    stops: 0,
    stop() {
      this.running = false
      this.stops += 1
    },
  },
  setBrightnessProc: { running: false, command: [] },
  refreshes: 0,
  refresh() {
    this.refreshes += 1
  },
  Model: monitor,
  readInternalBrightness: () => 70,
  showBrightnessOsd: () => {},
  startBrightnessProbe: () => {},
  abandonBrightnessProbe: () => {},
  brightnessOf: (name) => {
    const level = brightness.brightnessLevels[name]
    return level === undefined || level === null ? -1 : level
  },
}
const brightnessProcBlock = panelSource.match(/Process\s*\{\s*id:\s*setBrightnessProc[\s\S]*?\n  \}/)[0]
const brightnessExitedMatch = brightnessProcBlock.match(/onExited:\s*function\(exitCode\)\s*\{([\s\S]*?)\n    \}/)
assert(brightnessExitedMatch, 'setBrightnessProc defines an onExited handler')

brightness.root = brightness
vm.createContext(brightness)
vm.runInContext([
  extractFn('showBrightness'),
  extractFn('rememberBrightness'),
  extractFn('forgetBrightness'),
  extractFn('restoreBrightness'),
  extractFn('queueBrightness'),
  extractFn('startNextBrightnessWrite'),
  extractFn('setDisplayBrightness'),
  extractFn('stepDisplayBrightness'),
  extractFn('setBrightness'),
  extractFn('updateDisplays'),
  `function onBrightnessExited(exitCode) { ${brightnessExitedMatch[1]} }`,
].join('\n'), brightness)

brightness.brightnessLevels = { 'eDP-1': 50 }
brightness.updateDisplays(JSON.stringify([{ name: 'eDP-1', enabled: true, brightness: null }]), true)
assertEqual(brightness.brightnessLevels['eDP-1'], undefined, 'an unconfirmed level is dropped when its display reports no brightness')
assertDeepEqual(brightness.brightnessConfirmed, {}, 'a dropped optimistic level is not remembered')

brightness.brightnessLevels = { 'eDP-1': 50 }
brightness.brightnessConfirmed = { 'eDP-1': 50 }
brightness.updateDisplays(JSON.stringify([{ name: 'eDP-1', enabled: true, brightness: null }]), true)
assertEqual(brightness.brightnessLevels['eDP-1'], 50, 'a confirmed level survives a transient empty read')

brightness.brightnessLevels = { 'eDP-1': 50 }
brightness.brightnessConfirmed = { 'eDP-1': 70 }
brightness.updateDisplays(JSON.stringify([{ name: 'eDP-1', enabled: true, brightness: null }]), true)
assertEqual(brightness.brightnessLevels['eDP-1'], 70, 'a failed read falls back to the confirmed level')

brightness.updateDisplays(JSON.stringify([{ name: 'eDP-1', enabled: true, brightness: 40 }]), true)
assertEqual(brightness.brightnessLevels['eDP-1'], 40, 'a numeric state read replaces the level')
assertEqual(brightness.brightnessConfirmed['eDP-1'], 40, 'a numeric state read confirms the level')

// A failed write drops its optimistic level, or restores the last one a read
// or successful write proved.
brightness.setBrightnessProc.running = false
brightness.queuedBrightness = []
brightness.brightnessLevels = { 'eDP-1': 50 }
brightness.brightnessConfirmed = {}
brightness.brightnessWriteMonitor = 'eDP-1'
brightness.brightnessWritePercent = 50
brightness.brightnessAvailable = true
brightness.onBrightnessExited(1)
assertEqual(brightness.brightnessLevels['eDP-1'], undefined, 'a failed unconfirmed write drops its optimistic level')
assertEqual(brightness.brightnessAvailable, false, 'a failed unconfirmed write clears focused availability')

brightness.brightnessLevels = { 'eDP-1': 50 }
brightness.brightnessConfirmed = { 'eDP-1': 70 }
brightness.brightnessWriteMonitor = 'eDP-1'
brightness.brightnessWritePercent = 50
brightness.brightnessAvailable = true
brightness.onBrightnessExited(1)
assertEqual(brightness.brightnessLevels['eDP-1'], 70, 'a failed write restores the last confirmed level')
assertEqual(brightness.brightnessAvailable, true, 'a restored level stays controllable')

brightness.brightnessLevels = { 'eDP-1': 55 }
brightness.brightnessConfirmed = {}
brightness.brightnessWriteMonitor = 'eDP-1'
brightness.brightnessWritePercent = 55
brightness.onBrightnessExited(0)
assertEqual(brightness.brightnessConfirmed['eDP-1'], 55, 'a successful write confirms its level')

// A step for the display whose write is running must follow that write's
// target even when another display's set is queued behind it.
brightness.setBrightnessProc.running = true
brightness.brightnessWriteMonitor = 'eDP-1'
brightness.brightnessWritePercent = 50
brightness.queuedBrightness = [{ monitor: 'DP-1', percent: 60 }]
brightness.stepDisplayBrightness('eDP-1', 5, false)
assertDeepEqual(
  brightness.queuedBrightness,
  [{ monitor: 'DP-1', percent: 60 }, { monitor: 'eDP-1', percent: 55 }],
  'a step follows the in-flight target instead of reading stale hardware'
)
assertEqual(brightness.brightnessLevels['eDP-1'], 55, 'the stepped target is shown')

// A step for the queued display updates its target in place.
brightness.stepDisplayBrightness('DP-1', 5, false)
assertDeepEqual(
  brightness.queuedBrightness,
  [{ monitor: 'DP-1', percent: 65 }, { monitor: 'eDP-1', percent: 55 }],
  'a queued display keeps one latest target'
)

// With nothing in flight, a step reads live and starts the write.
brightness.setBrightnessProc.running = false
brightness.brightnessWriteMonitor = ''
brightness.queuedBrightness = []
brightness.readInternalBrightness = () => 62
brightness.stepDisplayBrightness('eDP-1', 5, false)
assertDeepEqual(
  brightness.setBrightnessProc.command,
  ['omarchy-brightness-display', '--no-osd', '--monitor', 'eDP-1', '67%'],
  'a step with no write in flight uses the live level'
)

// The IPC absolute set is refused for a display with no brightness control,
// and the refusal re-reads state so a stale cached level heals.
brightness.setBrightnessProc.running = false
brightness.queuedBrightness = []
brightness.brightnessAvailable = false
brightness.refreshes = 0
const accepted = brightness.setBrightness(50)
assertEqual(accepted, false, 'an absolute set is refused when the focused display has no brightness control')
assertEqual(brightness.refreshes, 1, 'a refused absolute set refreshes the cached state')
assertEqual(brightness.queuedBrightness.length, 0, 'a refused absolute set queues no write')

brightness.brightnessAvailable = true
brightness.refreshes = 0
assertEqual(brightness.setBrightness(50), true, 'an absolute set is accepted when the display has brightness control')
assertEqual(brightness.refreshes, 0, 'an accepted absolute set relies on its own write instead of refreshing')

// A newer absolute set cancels a slider preview still waiting on its debounce,
// so the timer cannot write the older preview afterwards.
brightness.setBrightnessProc.running = false
brightness.brightnessWriteMonitor = ''
brightness.queuedBrightness = []
brightness.brightnessDebounce.running = true
brightness.brightnessPreviewMonitor = 'eDP-1'
brightness.brightnessPreviewPercent = 40
brightness.brightnessAvailable = true
brightness.focusedMonitor = 'eDP-1'
brightness.setDisplayBrightness('eDP-1', 60)
assertEqual(brightness.brightnessDebounce.running, false, 'an absolute set stops the pending preview')
assertEqual(brightness.brightnessPreviewMonitor, '', 'an absolute set clears the pending preview display')
assertEqual(brightness.brightnessPreviewPercent, 0, 'an absolute set clears the pending preview level')
assertDeepEqual(
  brightness.setBrightnessProc.command,
  ['omarchy-brightness-display', '--no-osd', '--monitor', 'eDP-1', '60%'],
  'the newer absolute set is the write that lands'
)
JS
