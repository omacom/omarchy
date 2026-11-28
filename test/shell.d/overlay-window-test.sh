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

// Hyprland keeps a layer surface on the layer it was created with until its
// first frame, so a new surface is only created a turn after the open, once
// the layer bindings have followed shown, and only a surface that has shown
// is raised in place.
const attachBody = /function attach\(\) \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const attach = new Function('window', `with (window) { ${attachBody} }`)
const overlayWindow = (shown, targetScreen, focused) => {
  const created = { shown, targetScreen, focusedScreen: () => focused }
  created.attach = () => attach(created)
  return created
}
const shownHandler = /onShownChanged: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
let refreshed = 0
const Hyprland = { refreshMonitors() { refreshed++ } }
const opening = []
const changeShown = new Function('window', 'Hyprland', 'Qt', `with (window) { ${shownHandler} }`)
const openQt = { callLater(callback) { opening.push(callback) } }
const closing = overlayWindow(false, screen, external)
changeShown(closing, Hyprland, openQt)
assertEqual(closing.targetScreen, screen, 'closing keeps the parked surface on its current screen')
assertEqual(refreshed, 0, 'closing does not refresh monitor data')
const reopening = overlayWindow(true, screen, screen)
changeShown(reopening, Hyprland, openQt)
assertEqual(reopening.targetScreen, screen, 'reopening on the parked screen raises the parked surface in place')
assertEqual(opening.length, 0, 'raising a parked surface creates no new one')
assertEqual(refreshed, 1, 'opening refreshes monitor scales after a live change while closed')
const first = overlayWindow(true, null, screen)
changeShown(first, Hyprland, openQt)
assertEqual(first.targetScreen, null, 'a first open maps nothing until the overlay layer is in place')
opening.shift()()
assertEqual(first.targetScreen, screen, 'a first open creates its surface on the next turn')
const moving = overlayWindow(true, screen, external)
changeShown(moving, Hyprland, openQt)
assertEqual(moving.targetScreen, null, 'opening on another screen drops the surface parked on the old one')
opening.shift()()
assertEqual(moving.targetScreen, external, 'opening on another screen creates its surface there on the next turn')
assertEqual(refreshed, 3, 'opening on another screen refreshes monitor scales')
const abandoned = overlayWindow(true, screen, external)
changeShown(abandoned, Hyprland, openQt)
abandoned.shown = false
opening.shift()()
assertEqual(abandoned.targetScreen, null, 'closing before the new surface is created leaves the overlay unmapped')
const scaleHandler = /onDevicePixelRatioChanged: ([^\n]+)/.exec(overlay)[1]
const changeScale = new Function('shown', 'Hyprland', scaleHandler)
changeScale(false, Hyprland)
assertEqual(refreshed, 4, 'scale changes on hidden windows do not refresh monitor data')
const changedScreen = { name: 'eDP-1', width: 960, height: 600 }
assert(!ready(true, true, 960, 600, changedScreen, monitor, 2),
  'a stale monitor scale keeps content transparent after a live scale change')
Hyprland.refreshMonitors = () => { refreshed++; monitor.scale = 2 }
changeScale(true, Hyprland)
assertEqual(refreshed, 5, 'a showing window refreshes monitor scales when Qt receives a live change')
assert(ready(true, true, 960, 600, changedScreen, monitor, 2),
  'fresh monitor data lets content reveal at the new scale')

const screensChangedBody = /function onScreensChanged\(\) \{([\s\S]*?)\n    \}/.exec(overlay)[1]
const screensChanged = new Function('window', 'Quickshell', 'Qt', screensChangedBody)
const pending = []
const Qt = { callLater(callback) { pending.push(callback) } }
const window = overlayWindow(true, external, screen)
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
pending.shift()()
assertEqual(window.targetScreen, null, 'screen changes leave a never-opened overlay unmapped')
window.targetScreen = external
window.focusedScreen = () => screen
screensChanged(window, { screens: [screen] }, Qt)
assertEqual(window.targetScreen, null, 'removing a parked overlay screen unmaps before teardown')
pending.shift()()
assertEqual(window.targetScreen, null, 'a parked overlay waits for its next open to map on a remaining screen')
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

// Moving an open menu to another output drops the old output's layout.
const menuQml = read('shell/plugins/menu/Menu.qml')
const screenHandler = /onTargetScreenChanged: \{([^\n]*)\}/.exec(menuQml)[1]
const changeScreen = new Function('panel', `with (panel) { ${screenHandler} }`)
const menuPanel = { shown: true, cardTop: 945, maxRowsHeight: 510 }
changeScreen(menuPanel)
assertEqual(menuPanel.cardTop, -1, 'moving an open menu off a disconnected output unfreezes its old top edge')
assertEqual(menuPanel.maxRowsHeight, -1, 'moving an open menu drops the old output row-height limit')
assert(menuPanel.shown, 'resetting the layout keeps the menu open')

// The menu shows before its rows have loaded, so a search typed then must not
// freeze the card around the empty list's single row.
const freezeBody = /function freezeCardTop\(\) \{([\s\S]*?)\n    \}/.exec(menuQml)[1]
const freezeCardTop = new Function('panel', 'root', `with (panel) { ${freezeBody} }`)
const menuRoot = { mode: 'menu', keybindingsLoaded: false, rowsLoaded: false, visibleRowsHeight: 34 }
const loadingPanel = { shown: true, cardTop: -1, effectiveCardTop: 523, maxRowsHeight: -1 }
freezeCardTop(loadingPanel, menuRoot)
assertEqual(loadingPanel.cardTop, -1, 'a search typed before the rows load leaves the card centered')
assertEqual(loadingPanel.maxRowsHeight, -1, 'the empty list never becomes the row-height limit')
menuRoot.rowsLoaded = true
menuRoot.visibleRowsHeight = 510
loadingPanel.effectiveCardTop = 285
freezeCardTop(loadingPanel, menuRoot)
assertEqual(loadingPanel.cardTop, 285, 'the first search after the rows load freezes the top edge')
assertEqual(loadingPanel.maxRowsHeight, 510, 'the loaded menu sets the row-height limit')

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
