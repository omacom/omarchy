#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const monitor = requireFromRoot('shell/plugins/panels/monitor/Model.js')

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
JS

run_node_test <<'JS'
const Model = requireFromRoot('shell/plugins/panels/monitor/BrightnessModel.js')

function model() {
  let state = Model.initial()
  const writes = []
  const osds = []
  const p = {
    writes, osds,
    get state() { return state },
    generation() { return Model.readGeneration(state) },
    read(raw, monitor = 'DP-1', generation = Model.readGeneration(state)) {
      state = Model.acceptRead(state, monitor, raw, generation)
    },
    request(value, osd = false) {
      state = Model.request(state, value, osd)
      p.start()
    },
    preview(value) { state = Model.request(state, value, false) },
    step() { p.request(state.percent + 5, true) },
    start() {
      const previous = state.active
      state = Model.start(state)
      if (state.active && state.active !== previous) writes.push(state.active)
    },
    complete(success, request = state.active) {
      const result = Model.finish(state, request, success)
      state = result.state
      if (result.verified !== null) osds.push(result.verified)
    },
    targets() { return writes.map(request => request.target) }
  }
  p.read('30')
  return p
}

function brightness(p, displayed, confirmed, available, description) {
  assertDeepEqual([p.state.percent, p.state.confirmed, p.state.available],
    [displayed, confirmed, available], description)
}

{
  const p = model()
  p.request(50)
  p.request(65)
  p.step()
  p.complete(false)
  p.start()
  assertDeepEqual(p.targets(), [50, 70], 'a failed earlier write preserves the latest target')
  brightness(p, 70, 30, true, 'failure preserves the latest preview and last confirmed value')
  assertEqual(p.osds.length, 0, 'an earlier failure does not verify the queued OSD')
  p.complete(true)
  brightness(p, 70, 70, true, 'the trailing successful write confirms the latest target')
  assertDeepEqual(p.osds, [70], 'the latest success retains the wheel OSD after an earlier failure')
}

{
  const p = model()
  p.step()
  assertEqual(p.osds.length, 0, 'wheel intent has no unconfirmed OSD')
  p.complete(false)
  brightness(p, 30, 30, true, 'a final failure rolls back locally')
  assertEqual(p.osds.length, 0, 'a final failure discards the pending OSD')
  p.request(40)
  p.complete(true)
  assertEqual(p.osds.length, 0, 'a later keyboard success does not inherit a failed wheel OSD')
}

{
  const p = model()
  p.step()
  p.step()
  p.step()
  assertDeepEqual(p.targets(), [35], 'wheel bursts coalesce behind the active request')
  p.complete(true)
  assertDeepEqual(p.targets(), [35], 'completion leaves the latest target available for the next start')
  p.start()
  assertDeepEqual(p.targets(), [35, 45], 'the next start promotes only the newest coalesced target')
  brightness(p, 45, 35, true, 'only the completed request becomes confirmed')
  assertEqual(p.osds.length, 0, 'an intermediate success does not verify the OSD')
  p.complete(true)
  assertDeepEqual(p.osds, [45], 'the final success verifies one OSD for the final target')
}

for (const startDuringWrite of [false, true]) {
  for (const raw of ['5', 'unavailable', '']) {
    const p = model()
    let generation = p.generation()
    p.request(50)
    if (startDuringWrite) generation = p.generation()
    p.complete(true)
    p.read(raw, 'DP-1', generation)
    brightness(p, 50, 50, true, 'a stale poll captured ' + (startDuringWrite ? 'during' : 'before') + ' a write cannot replace brightness with ' + JSON.stringify(raw))
  }
}

for (const success of [true, false]) {
  const p = model()
  p.step()
  p.step()
  const active = p.state.active
  p.read('70', 'DP-2')
  brightness(p, 70, 70, true, 'a monitor switch adopts its snapshot during an old write')
  assertEqual(p.state.epoch.monitor, 'DP-2', 'brightness and target monitor switch together')
  assertEqual(p.state.active, active, 'an old active request remains until its process ends')
  assertEqual(p.state.latest, null, 'a monitor switch discards old queued input')
  p.complete(success)
  p.start()
  brightness(p, 70, 70, true, 'old completion cannot confirm or roll back the new monitor')
  assertDeepEqual(p.targets(), [35], 'old queued input cannot become a new monitor write')
  assertEqual(p.osds.length, 0, 'old completion cannot verify its OSD on the new monitor')
  p.step()
  assertDeepEqual([p.writes.at(-1).epoch.monitor, p.writes.at(-1).target], ['DP-2', 75], 'new input uses the new monitor and brightness')
  p.complete(true)
  brightness(p, 75, 75, true, 'new monitor input completes after the old write')
}

for (const success of [true, false]) {
  for (const value of [30, 70]) {
    const p = model()
    p.step()
    p.read(String(value), 'DP-2')
    p.step()
    assertDeepEqual(p.targets(), [35], 'new monitor input waits behind the old active request')
    p.complete(success)
    p.start()
    assertDeepEqual([p.writes.at(-1).epoch.monitor, p.writes.at(-1).target], ['DP-2', value + 5], 'new monitor intent survives even when its target equals the old request')
    brightness(p, value + 5, value, true, 'old completion cannot confirm the new monitor value')
    assertEqual(p.osds.length, 0, 'old completion cannot verify the new monitor OSD')
    p.complete(true)
    assertDeepEqual(p.osds, [value + 5], 'new monitor success owns its OSD')
  }
}

{
  const p = model()
  p.preview(60)
  const previousEpoch = p.state.epoch
  p.read('70', 'DP-2')
  brightness(p, 70, 70, true, 'a monitor switch replaces a pending preview with its snapshot')
  assert(p.state.epoch !== previousEpoch, 'a monitor switch creates a new epoch')
  assertEqual(p.state.latest, null, 'switching monitors discards the pending preview')
  p.start()
  assertDeepEqual(p.targets(), [], 'a cancelled preview cannot start on the new monitor')
}

for (const success of [true, false]) {
  const p = model()
  p.step()
  p.step()
  p.complete(success)
  p.read('70', 'DP-2')
  p.start()
  brightness(p, 70, 70, true, 'switching before the next start retains the new snapshot')
  assertDeepEqual(p.targets(), [35], 'a deferred old target is discarded after a switch')
  assertEqual(p.osds.length, 0, 'a deferred old OSD is discarded after a switch')
}

for (const success of [true, false]) {
  const p = model()
  const originalEpoch = p.state.epoch
  p.step()
  p.read('70', 'DP-2')
  p.read('32', 'DP-1')
  assert(p.state.epoch !== originalEpoch, 'returning to the original monitor creates another epoch')
  p.complete(success)
  p.start()
  brightness(p, 32, 32, true, 'A-B-A focus changes reject completion from the first A epoch')
  assertDeepEqual(p.targets(), [35], 'returning to a monitor creates no unsolicited write')
  assertEqual(p.osds.length, 0, 'returning to a monitor cannot revive its old OSD')
}

for (const raw of ['unavailable', '']) {
  const p = model()
  p.step()
  p.read(raw, 'DP-2')
  p.complete(false)
  p.start()
  brightness(p, 0, 0, false, 'an unavailable new monitor cannot inherit old brightness or rollback state')
  assertEqual(p.state.latest, null, 'an unavailable new monitor has no pending request')
}

{
  const p = model()
  p.step()
  p.read('70', 'DP-2')
  p.step()
  p.complete(true)
  p.start()
  p.complete(false)
  brightness(p, 70, 70, true, 'new monitor failure rolls back to its own snapshot after an old success')
  assertEqual(p.osds.length, 0, 'new monitor failure cannot verify an old or new OSD')
}

{
  const p = model()
  p.request(50)
  p.read('unavailable')
  brightness(p, 50, 30, true, 'a same-monitor poll cannot hide an active write')
  p.complete(false)
  brightness(p, 30, 30, true, 'stale polling cannot corrupt rollback')
}

for (const startDuringPreview of [false, true]) {
  const p = model()
  let generation = p.generation()
  p.preview(60)
  if (startDuringPreview) generation = p.generation()
  p.read('unavailable', 'DP-1', generation)
  brightness(p, 60, 30, true, 'polls cannot replace a pending preview')
  assertEqual(p.generation(), -1, 'pending previews mark poll snapshots stale')
  p.start()
  assertDeepEqual(p.targets(), [60], 'starting promotes the preserved preview')
  p.preview(80)
  p.complete(true)
  p.start()
  assertDeepEqual(p.targets(), [60, 80], 'completion preserves a newer drag preview')
  assertEqual(p.state.latest, null, 'starting consumes the newest preview')
  p.complete(true)
  const epoch = p.state.epoch
  p.read('42')
  brightness(p, 42, 42, true, 'a fresh idle read updates displayed and confirmed brightness')
  assertEqual(p.state.epoch, epoch, 'a same-monitor read retains the epoch identity')
  p.read('unavailable')
  brightness(p, 0, 42, false, 'a fresh unavailable read hides brightness while retaining its confirmed value')
}

{
  const p = model()
  p.request(50)
  const completed = p.state.active
  p.request(70)
  p.complete(true)
  p.complete(true, completed)
  p.preview(80)
  p.start()
  assertDeepEqual(p.targets(), [50, 80], 'duplicate completion cannot start twice or capture an obsolete preview')
  brightness(p, 80, 50, true, 'duplicate completion cannot confirm the trailing request')
  const active = p.state.active
  const unchanged = p.state
  p.complete(false, completed)
  assertEqual(p.state, unchanged, 'a deferred failed-start completion cannot finish another active request')
  assertEqual(p.state.active, active, 'the trailing request retains its own completion identity')
  p.complete(true)
  brightness(p, 80, 80, true, 'the trailing request completes after duplicate earlier signals')
}

{
  const p = model()
  p.step()
  p.complete(false)
  brightness(p, 30, 30, true, 'a failure completion rolls back through the failure path')
  assertEqual(p.osds.length, 0, 'a failure completion cannot verify an OSD')
  p.request(60)
  const completed = p.state.active
  p.complete(true)
  p.complete(false, completed)
  brightness(p, 60, 60, true, 'a successful completion wins over a later fallback for the same request')
}

{
  const p = model()
  p.request(50)
  p.request(70)
  p.complete(false)
  p.start()
  assertDeepEqual(p.targets(), [50, 70], 'failure preserves a newer target for the next start')
  p.complete(true)
  brightness(p, 70, 70, true, 'the newest target succeeds after an earlier failure')
}

for (const success of [true, false]) {
  const p = model()
  p.request(50)
  p.request(50, true)
  p.complete(success)
  p.start()
  assertDeepEqual(p.targets(), [50], 'a same-epoch same-target intent needs no duplicate write after completion')
  brightness(p, success ? 50 : 30, success ? 50 : 30, true, 'same-target completion confirms or rolls back the burst')
  assertDeepEqual(p.osds, success ? [50] : [], 'a same-target burst verifies its OSD only on success')
}

{
  const p = model()
  for (const [value, target] of [[0, 1], [-4, 1], [101, 100], [42.4, 42], [47.6, 48], ['nope', 1]]) {
    p.request(value)
    assertEqual(p.state.percent, target, 'brightness input clamps ' + JSON.stringify(value))
    p.complete(true)
  }
  const snapshot = p.state
  p.preview(75)
  assertEqual(snapshot.latest, null, 'a new request does not mutate an earlier state snapshot')
  assertEqual(snapshot.percent, 1, 'earlier state snapshots retain their displayed brightness')
}

{
  const p = model()
  p.request(70)
  const write = p.state.active
  p.read('20', 'DP-2')
  const result = Model.finish(p.state, write, true)
  assertDeepEqual(result.written, { monitor: 'DP-1', percent: 70 }, 'a write verified after switching displays keeps its own display')
  p.request(40)
  assertEqual(Model.finish(p.state, p.state.active, false).written, null, 'a rejected write records no level')
}
JS

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping native brightness lifecycle"
else
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT
  quickshell_binary=$(command -v quickshell)
  timeout_binary=$(command -v timeout)
  mkdir -p "$work/config" "$work/bin" "$work/runtime" "$work/home"
  chmod 700 "$work/runtime"
  cp "$SHELL_TEST_DIR/fixtures/brightness/shell.qml" "$work/config/shell.qml"
  ln -s "$ROOT/shell/Ui" "$work/config/Ui"
  ln -s "$ROOT/shell/Commons" "$work/config/Commons"
  ln -s "$ROOT/shell/plugins/panels/monitor" "$work/config/Monitor"
  ln -s "$(command -v sleep)" "$work/bin/sleep"

  cat >"$work/bin/omarchy-brightness-display" <<'SH'
#!/bin/bash
sleep 0.15
case ${4:-} in
  80%) exit 1 ;;
  60%) kill -KILL "$$" ;;
esac
SH
  chmod +x "$work/bin/omarchy-brightness-display"

  for mode in normal missing; do
    if [[ $mode == "missing" ]]; then
      mv "$work/bin/omarchy-brightness-display" "$work/writer"
    fi
    HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" PATH="$work/bin" \
      OMARCHY_PATH="$ROOT" OMARCHY_BRIGHTNESS_TEST_MODE="$mode" \
      QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
      "$timeout_binary" 20 "$quickshell_binary" -p "$work/config" --no-color >"$work/log" 2>&1 || {
        cat "$work/log" >&2
        fail "native brightness lifecycle runs ($mode)"
      }
    if ! rg -q 'BRIGHTNESS_RUNTIME_PASS' "$work/log" || rg -q 'FAIL!|BRIGHTNESS_RUNTIME_FAIL' "$work/log"; then
      cat "$work/log" >&2
      fail "native brightness lifecycle assertions pass ($mode)"
    fi
    pass "native brightness process and slider lifecycle ($mode)"
  done
fi
