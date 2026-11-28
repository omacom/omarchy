#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')
const overlay = read('shell/Ui/OverlayWindow.qml')

const liveExpression = /readonly property var liveTargetScreen: ([^\n]+)/.exec(overlay)[1]
const liveTarget = new Function('targetScreen', 'Quickshell', `return ${liveExpression}`)
const expectedScaleExpression = /readonly property real expectedScale: ([^\n]+)/.exec(overlay)[1]
const expectedScaleFn = new Function('queriedScale', 'targetMonitor', `return ${expectedScaleExpression}`)
const visibleExpression = /visible: ([^\n]+)/.exec(overlay)[1]
const visibleFn = new Function('shown', 'liveTargetScreen', `return ${visibleExpression}`)
const readyExpression = /readonly property bool contentReady: ([^\n]*(?:\n    [^\n]*)*)/.exec(overlay)[1]
const ready = new Function('shown', 'backingWindowVisible', 'width', 'height', 'liveTargetScreen', 'expectedScale', 'devicePixelRatio', 'scaleFallbackReady', `return ${readyExpression}`)

const screen = { name: 'eDP-1', width: 1200, height: 750 }
const external = { name: 'DP-1', width: 1920, height: 1080 }
const third = { name: 'HDMI-2', width: 1920, height: 1080 }
const monitor = { name: 'eDP-1', scale: 1.6 }

assertEqual(liveTarget(screen, { screens: [screen] }), screen,
  'a connected target screen remains live')
assertEqual(liveTarget(screen, { screens: [] }), null,
  'a removed target screen drops immediately instead of passing a dangling screen object')

for (const scale of [2, 1, 1.6]) {
  assertEqual(ready(true, true, 1200, 750, screen, expectedScaleFn(0, monitor), scale, false), scale === 1.6,
    `opening frames at ${scale}x wait for the monitor's 1.6x scale`)
}
for (const scale of [1, 1.25, 1.5, 2]) {
  assert(ready(true, true, 1200, 750, screen, expectedScaleFn(0, { scale }), scale, false),
    `overlay reveals at the correct ${scale}x scale`)
}
assert(ready(true, true, 1200, 750, screen, expectedScaleFn(0, { scale: 1.333333 }), 160 / 120, false),
  'scale comparison tolerates compositor floating point rounding')
assert(!ready(true, true, 500, 500, screen, expectedScaleFn(0, monitor), 1.6, false),
  'initial window geometry never stretches content across the screen')
assert(!ready(true, false, 1200, 750, screen, expectedScaleFn(0, monitor), 1.6, false),
  'content waits for a mapped backing window')
assert(!ready(false, true, 1200, 750, screen, expectedScaleFn(0, monitor), 1.6, false),
  'closed content stays transparent even at the correct scale')
assert(!ready(true, true, 1200, 750, null, expectedScaleFn(0, monitor), 1.6, false) &&
  !ready(true, true, 1200, 750, screen, expectedScaleFn(0, null), 1.6, false),
  'content waits for a connected screen and its monitor information')
assert(visibleFn(true, external) &&
  ready(true, true, 1920, 1080, external, expectedScaleFn(1.5, null), 1.5, false),
  'queried monitor scale maps and reveals even if Hyprland.monitors temporarily lacks the output')
assert(visibleFn(true, screen) &&
  ready(true, true, 1200, 750, screen, expectedScaleFn(0, { scale: 1 }), 2, true) &&
  !ready(true, true, 500, 500, screen, expectedScaleFn(0, { scale: 1 }), 2, true),
  'scale fallback reveals after timeout while preserving the geometry guard')

const revealBody = /onContentReadyChanged: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const reveal = new Function('window', 'Qt', 'scaleFallbackTimer', `with (window) { ${revealBody} }`)
const reveals = []
const revealQt = { callLater(callback) { reveals.push(callback) } }
let revealTimerStops = 0
const revealTimer = { stop() { revealTimerStops++ } }
const content = { contentReady: true, contentRevealed: false }
reveal(content, revealQt, revealTimer)
assert(!content.contentRevealed, 'scale and resize notifications finish before content reveals')
assertEqual(revealTimerStops, 1, 'ready content stops the scale fallback timer')
reveals.shift()()
assert(content.contentRevealed, 'settled content reveals on the next event-loop turn')
content.contentReady = false
reveal(content, revealQt, revealTimer)
assert(!content.contentRevealed, 'losing readiness immediately hides content')
content.contentReady = true
reveal(content, revealQt, revealTimer)
content.contentReady = false
reveal(content, revealQt, revealTimer)
reveals.shift()()
assert(!content.contentRevealed, 'a close or screen loss cancels a pending reveal')

const extractFn = (sig) => {
  const escaped = sig.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const re = new RegExp(`function ${escaped} \\{([\\s\\S]*?)\\n  \\}`)
  const match = re.exec(overlay)
  assert(match, `extracted ${sig}`)
  return match[1]
}
const extractProcFn = (sig) => {
  const escaped = sig.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const re = new RegExp(`function ${escaped} \\{([\\s\\S]*?)\\n      \\}`)
  const match = re.exec(overlay)
  assert(match, `extracted Process.${sig}`)
  return match[1]
}
const screenByNameBody = extractFn('screenByName(name)')
const focusedScreenBody = extractFn('focusedScreen()')
const stopActiveBody = extractFn('stopActiveQuery()')
const applyResolvedBody = extractFn('applyResolvedScreen(serial, screen, scale, missingName)')
const applyFallbackBody = extractFn('applyFallbackScreen(serial, preferredName)')
const resolveQueryBody = extractFn('resolveMonitorQuery(serial, exitCode, output)')
const startQueryBody = extractFn('startMonitorQuery(serial)')
const runSelectionBody = extractFn('runScreenSelection(serial)')
const beginSelectionBody = extractFn('beginScreenSelection(defer)')
const maybeFinishBody = extractProcFn('maybeFinish()')
const revealedHandler = /onContentRevealedChanged: ([^\n]+)/.exec(overlay)[1]
const dprHandler = /onDevicePixelRatioChanged: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const visibleChangedHandler = /onVisibleChanged: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const screensChangedBody = /function onScreensChanged\(\) \{([\s\S]*?)\n    \}/.exec(overlay)[1]
const queryTimerBody = /id: monitorQueryTimer[\s\S]*?onTriggered: \{([\s\S]*?)\n    \}/.exec(overlay)[1]
const scaleTimerBody = /id: scaleFallbackTimer[\s\S]*?onTriggered: \{([\s\S]*?)\n    \}/.exec(overlay)[1]

function createHarness(initialScreens, initialFocused) {
  const Quickshell = { screens: initialScreens.slice() }
  const Hyprland = {
    focusedMonitor: initialFocused,
    refreshes: 0,
    refreshMonitors() { this.refreshes++ },
  }
  const pending = []
  const Qt = { callLater(cb) { pending.push(cb) } }
  const monitorQueryTimer = {
    running: false,
    restarts: 0,
    restart() { this.running = true; this.restarts++ },
    stop() { this.running = false },
  }
  const scaleFallbackTimer = {
    running: false,
    restart() { this.running = true },
    stop() { this.running = false },
  }
  const spawned = []
  const runScreenByName = new Function('name', 'Quickshell', screenByNameBody)
  const runFocusedScreen = new Function('Hyprland', 'Quickshell', 'screenByName', focusedScreenBody)
  const runStopActive = new Function('window', 'monitorQueryTimer', `with (window) { ${stopActiveBody} }`)
  const runApplyResolved = new Function('window', 'serial', 'screen', 'scale', 'missingName', 'monitorQueryTimer', 'scaleFallbackTimer', `with (window) { ${applyResolvedBody} }`)
  const runApplyFallback = new Function('window', 'serial', 'preferredName', 'Hyprland', `with (window) { ${applyFallbackBody} }`)
  const runResolveQuery = new Function('window', 'serial', 'exitCode', 'output', `with (window) { ${resolveQueryBody} }`)
  const runStartQuery = new Function('window', 'serial', 'monitorQueryComponent', 'monitorQueryTimer', `with (window) { ${startQueryBody} }`)
  const runSelection = new Function('window', 'serial', 'Quickshell', 'Hyprland', `with (window) { ${runSelectionBody} }`)
  const runBeginSelection = new Function('window', 'defer', 'Qt', 'scaleFallbackTimer', `with (window) { ${beginSelectionBody} }`)
  const runMaybeFinish = new Function('proc', 'window', 'monitorQueryTimer', `with (proc) { ${maybeFinishBody} }`)
  const runRevealedChanged = new Function('window', `with (window) { ${revealedHandler} }`)
  const runDprChanged = new Function('window', 'Hyprland', 'scaleFallbackTimer', `with (window) { ${dprHandler} }`)
  const runVisibleChanged = new Function('window', `with (window) { ${visibleChangedHandler} }`)
  const runScreensChanged = new Function('window', 'Quickshell', screensChangedBody)
  const runQueryTimeout = new Function('window', queryTimerBody)
  const runScaleTimeout = new Function('window', scaleTimerBody)

  const monitorQueryComponent = {
    createObject(_parent, props) {
      const proc = {
        serial: props.serial,
        running: false,
        destroyed: false,
        collected: '',
        streamDone: false,
        processExited: false,
        lastExitCode: -1,
        finished: false,
        destroy() { this.destroyed = true },
        finish(exitCode, stdoutText, stdoutFirst = true) {
          this.running = false
          const runStdout = () => {
            this.collected = stdoutText
            this.streamDone = true
            runMaybeFinish(this, window, monitorQueryTimer)
          }
          const runExit = () => {
            this.lastExitCode = exitCode
            this.processExited = true
            runMaybeFinish(this, window, monitorQueryTimer)
          }
          if (stdoutFirst) {
            runStdout()
            runExit()
          } else {
            runExit()
            runStdout()
          }
        },
      }
      spawned.push(proc)
      return proc
    },
  }

  let forcedVisible = null
  const window = {
    shown: false,
    targetScreen: null,
    targetMonitor: null,
    queriedScale: 0,
    scaleFallbackReady: false,
    selectionRevealed: false,
    selectionSerial: 0,
    selectionPending: false,
    pendingMonitorName: '',
    preferredMonitorName: '',
    activeMonitorQuery: null,
    backingWindowVisible: false,
    width: 0,
    height: 0,
    devicePixelRatio: 1,
    contentRevealed: false,
    get liveTargetScreen() { return liveTarget(this.targetScreen, Quickshell) },
    get expectedScale() { return expectedScaleFn(this.queriedScale, this.targetMonitor) },
    get visible() { return forcedVisible !== null ? forcedVisible : visibleFn(this.shown, this.liveTargetScreen) },
    get contentReady() {
      return ready(this.shown, this.backingWindowVisible, this.width, this.height,
        this.liveTargetScreen, this.expectedScale, this.devicePixelRatio, this.scaleFallbackReady)
    },
    screenByName(name) { return runScreenByName(name, Quickshell) },
    focusedScreen() { return runFocusedScreen(Hyprland, Quickshell, (n) => this.screenByName(n)) },
    stopActiveQuery() { runStopActive(this, monitorQueryTimer) },
    applyResolvedScreen(serial, s, scale, missing) {
      forcedVisible = null
      runApplyResolved(this, serial, s, scale, missing, monitorQueryTimer, scaleFallbackTimer)
    },
    applyFallbackScreen(serial, pref) { runApplyFallback(this, serial, pref, Hyprland) },
    resolveMonitorQuery(serial, code, out) { runResolveQuery(this, serial, code, out) },
    startMonitorQuery(serial) { runStartQuery(this, serial, monitorQueryComponent, monitorQueryTimer) },
    runScreenSelection(serial) { runSelection(this, serial, Quickshell, Hyprland) },
    beginScreenSelection(defer) {
      forcedVisible = null
      runBeginSelection(this, defer, Qt, scaleFallbackTimer)
    },
    setShown(val) {
      this.shown = val
      this.beginScreenSelection(false)
    },
    setContentRevealed(val) {
      this.contentRevealed = val
      runRevealedChanged(this)
    },
    simulateCompositorClose() {
      forcedVisible = false
      runVisibleChanged(this)
    },
    changeDpr() { runDprChanged(this, Hyprland, scaleFallbackTimer) },
    fireScreensChanged() { runScreensChanged(this, Quickshell) },
    fireQueryTimeout() { runQueryTimeout(this) },
    fireScaleTimeout() { runScaleTimeout(this) },
    flushLater() {
      while (pending.length > 0) pending.shift()()
    },
  }
  return { window, Quickshell, Hyprland, spawned, monitorQueryTimer, scaleFallbackTimer, pending }
}

// 1. focusedScreen selection & fallback.
{
  const h = createHarness([screen, external], { name: 'DP-1' })
  assertEqual(h.window.focusedScreen(), external, 'overlay selects the focused output')
  h.Quickshell.screens = [screen]
  assertEqual(h.window.focusedScreen(), screen, 'disconnecting the focused output falls back to a connected screen')
  h.Quickshell.screens = []
  h.Hyprland.focusedMonitor = null
  assertEqual(h.window.focusedScreen(), null, 'no outputs leaves the overlay unmapped')
}

// 2. Single-output open/close, opening DPR vs post-reveal resize-before-DPR, and missing wl_output tracking.
{
  const h = createHarness([screen], { name: 'eDP-1' })
  h.window.targetScreen = external
  h.window.setShown(false)
  assertEqual(h.window.targetScreen, null, 'closing drops the previous screen reference')
  assertEqual(h.Hyprland.refreshes, 0, 'closing does not refresh monitor data')
  h.window.changeDpr()
  assertEqual(h.Hyprland.refreshes, 0, 'scale changes on hidden windows do not refresh monitor data')

  h.window.setShown(true)
  assertEqual(h.window.targetScreen, screen, 'single-output open selects the screen immediately')
  assertEqual(h.spawned.length, 0, 'single-output open does not spawn hyprctl')
  assertEqual(h.Hyprland.refreshes, 1, 'opening refreshes monitor scales after a live change while closed')

  // Opening DPR change before initial reveal preserves visibility and queriedScale.
  h.window.targetMonitor = null
  h.window.queriedScale = 1.6
  h.window.backingWindowVisible = true
  h.window.width = 1200
  h.window.height = 750
  h.window.devicePixelRatio = 1.6
  h.window.setContentRevealed(false)
  h.window.changeDpr()
  assert(h.window.visible && h.window.queriedScale === 1.6 && h.window.contentReady,
    'opening DPR notification keeps visibility and queriedScale intact before initial reveal')
  assertEqual(h.Hyprland.refreshes, 2, 'opening DPR change still refreshes Hyprland monitor scales')

  // Post-reveal resize-before-DPR: contentRevealed drops first on geometry mismatch,
  // but selectionRevealed stays true so the following DPR clears queriedScale immediately.
  h.window.setContentRevealed(true)
  h.window.setContentRevealed(false)
  h.window.targetMonitor = { name: 'eDP-1', scale: 2 }
  h.window.devicePixelRatio = 2
  h.window.changeDpr()
  assertEqual(h.window.queriedScale, 0, 'post-reveal resize-before-DPR still clears stale queriedScale')
  assert(h.window.visible && h.window.contentReady,
    'post-reveal scale change reveals immediately once geometry, DPR, and refreshed monitor scale match')
  assertEqual(h.Hyprland.refreshes, 3, 'a showing window refreshes monitor scales when Qt receives a live change')

  const hLag = createHarness([screen], { name: 'DP-1' })
  hLag.window.setShown(true)
  assertEqual(hLag.window.targetScreen, screen, 'single-output open maps onto connected screen while new wl_output lags')
  assertEqual(hLag.window.pendingMonitorName, 'DP-1', 'single-output open retains missing focused monitor name')
}

// 3. Multi-output open ignores stale cached Hyprland.focusedMonitor and maps onto queried focused output.
{
  const h = createHarness([screen, external], { name: 'eDP-1' })
  h.window.setShown(true)
  assertEqual(h.window.targetScreen, null, 'multi-output open waits for its own hyprctl query before mapping')
  assertEqual(h.spawned.length, 1, 'multi-output open spawns one per-request hyprctl process')
  assert(h.spawned[0].running && h.monitorQueryTimer.running, 'multi-output open arms bounded query timer')
  h.spawned[0].finish(0, JSON.stringify([
    { name: 'eDP-1', focused: false, scale: 1.6 },
    { name: 'DP-1', focused: true, scale: 1.25 },
  ]), false)
  assertEqual(h.window.targetScreen, external, 'multi-output open maps directly onto queried focused output despite stale cache')
  assertEqual(h.window.queriedScale, 1.25, 'multi-output open records queried output scale')
  assert(!h.monitorQueryTimer.running && h.spawned[0].destroyed, 'completed query stops timer and destroys its process')
}

// 4. Busy reopen when older child stalls: superseded child is destroyed, new child gets its own watchdog and timeout fallback.
{
  const h = createHarness([screen, external], { name: 'DP-1' })
  h.window.setShown(true)
  const first = h.spawned[0]
  h.window.setShown(false)
  assert(first.destroyed && !first.running && !h.monitorQueryTimer.running,
    'closing destroys any in-flight monitor query and stops its timer')
  h.window.setShown(true)
  assertEqual(h.spawned.length, 2, 'reopening starts an independent monitor query')
  const second = h.spawned[1]
  assert(second.running && h.monitorQueryTimer.running, 'reopened query arms a fresh watchdog timer')
  first.finish(0, JSON.stringify([{ name: 'eDP-1', focused: true, scale: 1 }]))
  assertEqual(h.window.targetScreen, null, 'late reply from superseded query is ignored')
  assert(h.monitorQueryTimer.running, 'late reply from superseded query does not stop the current watchdog')
  h.window.fireQueryTimeout()
  assertEqual(h.window.targetScreen, external, 'stalled reopened query falls back via watchdog instead of stranding')
  assert(second.destroyed && !second.running, 'watchdog destroys stalled query process')
}

// 5. Query failure and timeout retain known focused output when its wl_output is delayed; scale fallback unlocks reveal.
{
  for (const [label, resolve] of [
    ['failed monitor query', (h) => h.spawned[0].finish(1, '')],
    ['timed-out monitor query', (h) => h.window.fireQueryTimeout()],
  ]) {
    const h = createHarness([screen, external], { name: 'HDMI-2' })
    h.window.setShown(true)
    resolve(h)
    assertEqual(h.window.targetScreen, screen, `${label} falls back to a connected screen`)
    assertEqual(h.window.pendingMonitorName, 'HDMI-2', `${label} retains known focused output awaiting wl_output`)
    h.Quickshell.screens = [screen, external, third]
    h.window.fireScreensChanged()
    h.window.flushLater()
    assertEqual(h.spawned.length, 2, `${label} re-selects once delayed focused wl_output arrives`)
    h.spawned[1].finish(0, JSON.stringify([{ name: 'HDMI-2', focused: true, scale: 1 }]))
    assertEqual(h.window.targetScreen, third, `${label} lands on delayed focused output`)
  }
  const hScale = createHarness([screen], { name: 'eDP-1' })
  hScale.window.setShown(true)
  hScale.window.fireScaleTimeout()
  assert(hScale.window.scaleFallbackReady, 'scale fallback timer unlocks reveal if scale never settles')
}

// 6. Focused output appears in Quickshell.screens AFTER hyprctl reports it focused.
{
  const h = createHarness([screen, third], { name: 'eDP-1' })
  h.window.setShown(true)
  h.spawned[0].finish(0, JSON.stringify([
    { name: 'eDP-1', focused: false, scale: 1 },
    { name: 'DP-1', focused: true, scale: 1 },
  ]))
  assertEqual(h.window.targetScreen, screen, 'missing wl_output falls back immediately so overlay is not stranded')
  assertEqual(h.window.pendingMonitorName, 'DP-1', 'remembers focused output awaiting wl_output arrival')
  h.Quickshell.screens = [screen, third, external]
  h.window.fireScreensChanged()
  h.window.flushLater()
  assertEqual(h.spawned.length, 2, 'arriving focused wl_output triggers re-selection onto the focused output')
  h.spawned[1].finish(0, JSON.stringify([{ name: 'DP-1', focused: true, scale: 1 }]))
  assertEqual(h.window.targetScreen, external, 'overlay lands on the newly arrived focused screen')

  // If the follow-up query fails or times out after the delayed output arrives while Hyprland.focusedMonitor is still stale,
  // the preserved preferredMonitorName still lands the overlay on the now-live focused output.
  for (const [label, failRetry] of [
    ['failed retry query', (hr) => hr.spawned[1].finish(1, '')],
    ['timed-out retry query', (hr) => hr.window.fireQueryTimeout()],
  ]) {
    const hr = createHarness([screen, third], { name: 'eDP-1' })
    hr.window.setShown(true)
    hr.spawned[0].finish(0, JSON.stringify([
      { name: 'eDP-1', focused: false, scale: 1 },
      { name: 'DP-1', focused: true, scale: 1 },
    ]))
    hr.Quickshell.screens = [screen, third, external]
    hr.window.fireScreensChanged()
    hr.window.flushLater()
    failRetry(hr)
    assertEqual(hr.window.targetScreen, external, `${label} still maps onto the newly arrived preferred output`)
    assertEqual(hr.window.preferredMonitorName, '', `${label} clears preferredMonitorName once resolved`)
  }
}

// 7. Unplug recovery, unplug during active query, compositor close recovery, unplug -> close -> reopen, and settled invariance.
{
  const h = createHarness([screen, external], { name: 'eDP-1' })
  h.window.shown = true
  h.window.targetScreen = external
  h.Quickshell.screens = [screen]
  h.window.fireScreensChanged()
  assertEqual(h.window.targetScreen, null, 'screen removal unmaps before Qt finishes destroying the old window')
  h.window.flushLater()
  assertEqual(h.window.targetScreen, screen, 'a showing overlay moves off a disconnected screen')

  // Compositor layer-surface close while shown and liveTargetScreen is still set recovers onto a fresh surface.
  h.window.simulateCompositorClose()
  assertEqual(h.window.targetScreen, null, 'compositor layer close triggers clean remap')
  h.window.flushLater()
  assertEqual(h.window.targetScreen, screen, 'compositor layer close remaps onto a live screen')
  assert(h.window.visible, 'remapped overlay is visible again after compositor layer close')

  h.Quickshell.screens = [screen, external]
  h.Hyprland.focusedMonitor = { name: 'DP-1' }
  h.window.fireScreensChanged()
  assertEqual(h.window.targetScreen, screen, 'connecting another screen does not move a settled showing overlay')

  h.window.setShown(false)
  h.window.fireScreensChanged()
  assertEqual(h.window.targetScreen, null, 'screen changes leave a closed overlay unmapped')

  h.window.targetScreen = external
  h.Quickshell.screens = [screen]
  h.window.fireScreensChanged()
  assertEqual(h.window.targetScreen, null, 'removing a screen clears any stale reference even while closed')

  // Unplug during an active query followed by a replacement output before the deferred turn:
  // routing through beginScreenSelection(true) observes the live 2-output count and queries hyprctl.
  const hActiveUnplug = createHarness([screen, external], { name: 'eDP-1' })
  hActiveUnplug.window.setShown(true)
  assertEqual(hActiveUnplug.spawned.length, 1, 'initial multi-output open starts query')
  hActiveUnplug.Quickshell.screens = [screen]
  hActiveUnplug.window.fireScreensChanged()
  hActiveUnplug.Quickshell.screens = [screen, third]
  hActiveUnplug.window.fireScreensChanged()
  hActiveUnplug.window.flushLater()
  assertEqual(hActiveUnplug.spawned.length, 2, 'unplug during active query followed by replacement starts fresh query')
  hActiveUnplug.spawned[1].finish(0, JSON.stringify([
    { name: 'eDP-1', focused: false, scale: 1 },
    { name: 'HDMI-2', focused: true, scale: 1 },
  ]))
  assertEqual(hActiveUnplug.window.targetScreen, third, 'replacement output receives the overlay')

  // Unplug -> queue remap -> close -> reopen before deferred remap callback runs.
  const hRace = createHarness([screen, external, third], { name: 'eDP-1' })
  hRace.window.shown = true
  hRace.window.targetScreen = external
  hRace.Quickshell.screens = [screen, third]
  hRace.window.fireScreensChanged()
  hRace.window.setShown(false)
  hRace.window.setShown(true)
  hRace.pending.shift()()
  assertEqual(hRace.window.targetScreen, null, 'stale unplug remap callback does not bypass a newer open')
  assertEqual(hRace.spawned.length, 1, 'stale unplug remap callback does not spawn a duplicate query')
  hRace.spawned[0].finish(0, JSON.stringify([
    { name: 'eDP-1', focused: false, scale: 1 },
    { name: 'HDMI-2', focused: true, scale: 1 },
  ]))
  assertEqual(hRace.window.targetScreen, third, 'newer open resolves cleanly to the focused output')
}

// Moving an open menu to another output drops the old output's layout.
const menuQml = read('shell/plugins/menu/Menu.qml')
const screenHandler = /onTargetScreenChanged: \{([^\n]*)\}/.exec(menuQml)[1]
const changeScreen = new Function('panel', `with (panel) { ${screenHandler} }`)
const menuPanel = { shown: true, cardTop: 945, maxRowsHeight: 510 }
changeScreen(menuPanel)
assertEqual(menuPanel.cardTop, -1, 'moving an open menu off a disconnected output unfreezes its old top edge')
assertEqual(menuPanel.maxRowsHeight, -1, 'moving an open menu drops the old output row-height limit')
assert(menuPanel.shown, 'resetting the layout keeps the menu open')

// Fullscreen overlays open without an additional compositor animation.
const shellRules = read('default/hypr/apps/omarchy-shell.lua')
const noAnim = /namespace = "\^\(([^)]*)\)\$" \}, no_anim = true/.exec(shellRules)
assert(noAnim, 'the shell overlays share one no-animation layer rule')
const unanimated = noAnim ? noAnim[1].split('|') : []
const overlayFiles = fs.readdirSync(path.join(root, 'shell/plugins'), { recursive: true })
  .filter(file => file.endsWith('.qml'))
  .map(file => 'shell/plugins/' + file)
  .filter(file => read(file).includes('OverlayWindow {'))
assert(overlayFiles.length > 0, 'shell plugins use the shared overlay window')
for (const file of overlayFiles) {
  const namespace = /WlrLayershell\.namespace: "([^"]+)"/.exec(read(file))
  assert(namespace && unanimated.includes(namespace[1]), `${file} is exempt from Hyprland's layer animation`)
}
JS
