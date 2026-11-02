#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')
const overlay = read('shell/Ui/OverlayWindow.qml')

const readyExpression = /readonly property bool contentReady: ([^\n]*(?:\n    &&[^\n]*)*)/.exec(overlay)[1]
const ready = new Function('shown', 'backingWindowVisible', 'width', 'height', 'targetScreen', 'targetMonitor', 'devicePixelRatio', `return ${readyExpression}`)
const screen = { name: 'eDP-1', width: 1200, height: 750 }
const monitor = { name: 'eDP-1', scale: 1.6 }
for (const scale of [2, 1, 1.6]) {
  assertEqual(ready(true, true, 1200, 750, screen, monitor, scale), scale === 1.6,
    `opening frames at ${scale}x wait for the monitor's 1.6x scale`)
}
for (const scale of [1, 1.25, 1.5, 2]) {
  assert(ready(true, true, 1200, 750, screen, { scale }, scale),
    `overlay reveals at the correct ${scale}x scale`)
}
assert(ready(true, true, 1200, 750, screen, { scale: 1.333333 }, 160 / 120),
  'scale comparison tolerates compositor floating point rounding')
assert(!ready(true, true, 500, 500, screen, monitor, 1.6),
  'initial window geometry never stretches content across the screen')
assert(!ready(true, false, 1200, 750, screen, monitor, 1.6),
  'content waits for a mapped backing window')
assert(!ready(false, true, 1200, 750, screen, monitor, 1.6),
  'closed content stays transparent even at the correct scale')
assert(!ready(true, true, 1200, 750, null, monitor, 1.6) &&
  !ready(true, true, 1200, 750, screen, null, 1.6),
  'content waits for a connected screen and its monitor information')

const revealBody = /onContentReadyChanged: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const reveal = new Function('window', 'Qt', `with (window) { ${revealBody} }`)
const reveals = []
const revealQt = { callLater(callback) { reveals.push(callback) } }
const content = { contentReady: true, contentRevealed: false }
reveal(content, revealQt)
assert(!content.contentRevealed, 'scale and resize notifications finish before content reveals')
reveals.shift()()
assert(content.contentRevealed, 'settled content reveals on the next event-loop turn')
content.contentReady = false
reveal(content, revealQt)
assert(!content.contentRevealed, 'losing readiness immediately hides content')
content.contentReady = true
reveal(content, revealQt)
content.contentReady = false
reveal(content, revealQt)
reveals.shift()()
assert(!content.contentRevealed, 'a close or screen loss cancels a pending reveal')

const focusedScreenBody = /function focusedScreen\(\) \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const focusedScreen = new Function('Hyprland', 'Quickshell', focusedScreenBody)
const external = { name: 'DP-1', width: 1920, height: 1080 }
assertEqual(focusedScreen({ focusedMonitor: { name: 'DP-1' } }, { screens: [screen, external] }), external,
  'overlay selects the focused output')
assertEqual(focusedScreen({ focusedMonitor: { name: 'DP-1' } }, { screens: [screen] }), screen,
  'disconnecting the focused output falls back to a connected screen')
assertEqual(focusedScreen({ focusedMonitor: null }, { screens: [] }), null,
  'no outputs leaves the overlay unmapped')

const shownHandler = /onShownChanged: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
let refreshed = 0
const Hyprland = { refreshMonitors() { refreshed++ } }
const changeShown = new Function('shown', 'focusedScreen', 'Hyprland', `let targetScreen = null; let focusPrimed = true; const beginFocusPrime = () => {}; ${shownHandler}; return targetScreen`)
assertEqual(changeShown(false, () => external, Hyprland), null, 'closing drops the previous screen reference')
assertEqual(refreshed, 0, 'closing does not refresh monitor data')
assertEqual(changeShown(true, () => screen, Hyprland), screen, 'reopening selects a current screen')
assertEqual(refreshed, 1, 'opening refreshes monitor scales after a live change while closed')
const scaleHandler = /onDevicePixelRatioChanged: ([^\n]+)/.exec(overlay)[1]
const changeScale = new Function('shown', 'Hyprland', scaleHandler)
changeScale(false, Hyprland)
assertEqual(refreshed, 1, 'scale changes on hidden windows do not refresh monitor data')
const changedScreen = { name: 'eDP-1', width: 960, height: 600 }
assert(!ready(true, true, 960, 600, changedScreen, monitor, 2),
  'a stale monitor scale keeps content transparent after a live scale change')
Hyprland.refreshMonitors = () => { refreshed++; monitor.scale = 2 }
changeScale(true, Hyprland)
assertEqual(refreshed, 2, 'a showing window refreshes monitor scales when Qt receives a live change')
assert(ready(true, true, 960, 600, changedScreen, monitor, 2),
  'fresh monitor data lets content reveal at the new scale')

const screensChangedBody = /function onScreensChanged\(\) \{([\s\S]*?)\n    \}/.exec(overlay)[1]
const screensChanged = new Function('window', 'Quickshell', 'Qt', screensChangedBody)
const pending = []
const Qt = { callLater(callback) { pending.push(callback) } }
const window = { shown: true, targetScreen: external, focusedScreen: () => screen }
screensChanged(window, { screens: [screen] }, Qt)
assertEqual(window.targetScreen, null, 'screen removal unmaps before Qt finishes destroying the old window')
pending.shift()()
assertEqual(window.targetScreen, screen, 'a showing overlay moves off a disconnected screen')
window.targetScreen = screen
window.focusedScreen = () => external
screensChanged(window, { screens: [screen, external] }, Qt)
assertEqual(window.targetScreen, screen, 'connecting another screen does not move a showing overlay')
window.shown = false
window.targetScreen = null
screensChanged(window, { screens: [screen, external] }, Qt)
assertEqual(window.targetScreen, null, 'screen changes leave a closed overlay unmapped')
window.shown = true
window.targetScreen = external
screensChanged(window, { screens: [screen] }, Qt)
window.shown = false
pending.shift()()
assertEqual(window.targetScreen, null, 'closing before a deferred remap prevents a stale reopen')
window.shown = true
window.targetScreen = external
screensChanged(window, { screens: [screen] }, Qt)
window.targetScreen = screen
window.focusedScreen = () => external
pending.shift()()
assertEqual(window.targetScreen, screen, 'a deferred remap preserves the screen chosen by a newer open')

// Clicking another output closes an overlay instead of leaving that output
// dead to the pointer. Hyprland routes every click to an Exclusive layer, so the
// overlay primes with Exclusive and settles on OnDemand, as KeyboardPanel does.
const WlrKeyboardFocus = { None: 0, OnDemand: 1, Exclusive: 2 }
const focusExpression = /WlrLayershell\.keyboardFocus: (exclusive[^\n]+)/.exec(overlay)[1]
const exclusiveExpression = /readonly property bool exclusive: ([^\n]+)/.exec(overlay)[1]
const keyboardFocus = new Function('focusPrimed', 'shownKeyboardFocus', 'WlrKeyboardFocus',
  `const exclusive = ${exclusiveExpression}; return ${focusExpression}`)
assertEqual(keyboardFocus(false, WlrKeyboardFocus.Exclusive, WlrKeyboardFocus), WlrKeyboardFocus.Exclusive,
  'an exclusive overlay opens with Exclusive focus')
assertEqual(keyboardFocus(true, WlrKeyboardFocus.Exclusive, WlrKeyboardFocus), WlrKeyboardFocus.OnDemand,
  'a primed exclusive overlay settles on OnDemand so other outputs get the pointer back')
assertEqual(keyboardFocus(true, WlrKeyboardFocus.None, WlrKeyboardFocus), WlrKeyboardFocus.None,
  'a keyboard-free overlay never takes focus')

// The prime runs on every open, once the surface is mapped, and only while shown.
const primeTimer = /id: focusPrimeTimer[\s\S]*?onTriggered: ([^\n]+)/.exec(overlay)[1]
const fire = new Function('window', primeTimer)
const primed = { shown: true, focusPrimed: false }
fire(primed)
assert(primed.focusPrimed, 'the prime timer settles a showing overlay on OnDemand')
const closed = { shown: false, focusPrimed: false }
fire(closed)
assert(!closed.focusPrimed, 'a prime that outlives a close does not change the next open')
const primeReset = new Function('shown', 'focusedScreen', 'Hyprland', 'beginFocusPrime',
  `let targetScreen = null; let focusPrimed = true; ${shownHandler}; return focusPrimed`)
let primeStarts = 0
assert(!primeReset(true, () => screen, Hyprland, () => primeStarts++), 'every open starts from Exclusive')
assertEqual(primeStarts, 1, 'opening schedules the prime')
const beginBody = /function beginFocusPrime\(\) \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const begin = new Function('shown', 'backingWindowVisible', 'focusPrimeTimer', beginBody)
let restarts = 0
const timer = { restart() { restarts++ } }
begin(true, false, timer)
assertEqual(restarts, 0, 'the prime waits for the surface to map, as Hyprland focuses on map')
begin(true, true, timer)
assertEqual(restarts, 1, 'a mapped, showing overlay primes')
const focusChange = /onShownKeyboardFocusChanged: \{([^\n]*)\}/.exec(overlay)[1]
const changeFocus = new Function('window', `with (window) { ${focusChange} }`)
const later = { focusPrimed: true, beginFocusPrime() { restarts++ } }
changeFocus(later)
assert(!later.focusPrimed && restarts === 2,
  'an overlay that asks for the keyboard after mapping (image picker) primes again')

// Every other output gets a twin that catches the click the overlay's own
// surface can never see; the overlay's output must stay uncovered.
const twinWindow = /\n  Variants \{[\s\S]*?model: ([^\n]+)[\s\S]*?PanelWindow \{[\s\S]*?visible: ([^\n]+)[\s\S]*?onPressed: ([^\n]+)/.exec(overlay)
assert(twinWindow, 'other outputs get a dismiss twin window')
const twinModel = new Function('window', 'Quickshell', `return ${twinWindow[1]}`)
const screens = [screen, external]
assertDeepEqual(twinModel({ shown: true, exclusive: true }, { screens }), screens, 'a showing exclusive overlay twins every output')
assertDeepEqual(twinModel({ shown: false, exclusive: true }, { screens }), [], 'closing drops the twins')
assertDeepEqual(twinModel({ shown: true, exclusive: false }, { screens }), [],
  'a keyboard-free overlay blocks no clicks and so needs no twins')
const twinVisible = new Function('window', 'modelData', `return ${twinWindow[2]}`)
assert(twinVisible({ shown: true, targetScreen: external }, screen), 'the other output is covered')
assert(!twinVisible({ shown: true, targetScreen: external }, external), "the overlay's own output is not")
assert(!twinVisible({ shown: true, targetScreen: null }, screen),
  'no twin maps before the overlay knows its output, or it could cover the overlay')
const requests = []
new Function('window', twinWindow[3])({ dismissRequested() { requests.push(1) } })
assertEqual(requests.length, 1, 'a press on a twin asks the overlay to close')

// A click on another output does what a click on the overlay's own scrim does.
function handlerBody(qml, from, name) {
  const at = qml.indexOf(name, from)
  if (at < 0) return null
  let body = qml.slice(at + name.length).replace(/^\s*/, '')
  if (!body.startsWith('{')) return body.slice(0, body.indexOf('\n'))
  let depth = 0
  for (let i = 0; i < body.length; i++) {
    if (body[i] === '{') depth++
    if (body[i] === '}' && --depth === 0) return body.slice(1, i)
  }
  return null
}
function calls(body) {
  const seen = []
  const root = new Proxy({}, { get: (_, key) => (key === 'menuEntry' ? null : () => seen.push(key)) })
  new Function('root', body)(root)
  return seen
}
const overlayFiles = fs.readdirSync(path.join(root, 'shell/plugins'), { recursive: true })
  .filter(file => file.endsWith('.qml'))
  .map(file => 'shell/plugins/' + file)
  .filter(file => read(file).includes('OverlayWindow {'))
assert(overlayFiles.length > 0, 'shell plugins use the shared overlay window')
for (const file of overlayFiles) {
  const qml = read(file)
  const window = qml.indexOf('OverlayWindow {')
  const dismiss = handlerBody(qml, window, 'onDismissRequested:')
  if (file.endsWith('Osd.qml')) {
    assert(dismiss === null, `${file} takes no keyboard and so needs no dismiss`)
  } else {
    const scrim = handlerBody(qml, window, 'onClicked:')
    assert(dismiss !== null && scrim !== null, `${file} handles a click on another output`)
    assertDeepEqual(calls(dismiss), calls(scrim), `${file} closes from another output as from its own scrim`)
    assert(calls(dismiss).length === 1, `${file} closes on a click on another output`)
  }
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
for (const file of overlayFiles) {
  const namespace = /WlrLayershell\.namespace: "([^"]+)"/.exec(read(file))
  assert(namespace && unanimated.includes(namespace[1]), `${file} is exempt from Hyprland's layer animation`)
}
JS
