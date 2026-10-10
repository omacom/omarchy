#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')
const overlay = read('shell/Ui/OverlayWindow.qml')

// Closing must unmap, not leave a surface on an output that may disappear.
assert(
  overlay.includes('visible: shown && !!targetScreen && !!targetMonitor') &&
    overlay.includes('anchors { top: true; left: true; bottom: true; right: true }') &&
    !overlay.includes('implicitWidth: 1') && !overlay.includes('WlrLayer.Bottom'),
  'closed overlays unmap instead of parking a surface'
)

const readyExpression = /readonly property bool contentReady: ([^\n]*(?:\n    &&[^\n]*)*)/.exec(overlay)[1]
const readyReserving = new Function('shown', 'backingWindowVisible', 'width', 'height', 'targetScreen', 'targetMonitor', 'devicePixelRatio', 'reservedSpace', `return ${readyExpression}`)
const ready = (...args) => readyReserving(...args, [0, 0, 0, 0])
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
assert(
  /target: window\.contentItem\s*property: "opacity"\s*value: window\.contentRevealed \? 1 : 0/.test(overlay),
  'transparent opening frames preserve immediate keyboard handling'
)

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
const changeShown = new Function('shown', 'focusedScreen', 'Hyprland', `let targetScreen = null; ${shownHandler}; return targetScreen`)
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

const overlays = {
  'shell/plugins/menu/Menu.qml': 'shown: root.opened && root.rowsLoaded',
  'shell/plugins/emojis/Emojis.qml': 'shown: root.opened',
  'shell/plugins/clipboard/Clipboard.qml': 'shown: root.opened',
  'shell/plugins/osd/Osd.qml': 'shown: root.opened',
  'shell/plugins/reminders/ReminderFlow.qml': 'shown: root.opened',
  'shell/plugins/panels/wifiqr/Panel.qml': 'shown: root.opened',
  'shell/plugins/image-picker/ImagePicker.qml': 'shown: root.opened',
}
for (const [file, shown] of Object.entries(overlays)) {
  const qml = read(file)
  assert(
    qml.includes('OverlayWindow {') && qml.includes(shown) && !/PanelWindow \{\s*(id: panel\s*)?visible: root\.opened/.test(qml),
    `${file} uses the shared overlay scale and lifecycle handling`
  )
}

// Layout resets on a requested close, independent of mapping readiness.
const menuQml = read('shell/plugins/menu/Menu.qml')
assert(
  menuQml.includes('onShownChanged: if (!shown) { cardTop = -1; maxRowsHeight = -1 }') &&
    menuQml.includes('if (shown && cardTop < 0) {') &&
    !/onVisibleChanged: if \(!visible\) \{ cardTop/.test(menuQml),
  'the menu unfreezes its layout when the overlay hides'
)
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
for (const file of Object.keys(overlays)) {
  const namespace = /WlrLayershell\.namespace: "([^"]+)"/.exec(read(file))
  assert(namespace && unanimated.includes(namespace[1]), `${file} is exempt from Hyprland's layer animation`)
}

// Cooperative focus is off unless the overlay and the user both ask for it.
assert(overlay.includes('property bool cooperativeFocus: false'), 'overlays keep exclusive focus by default')
const cooperatingExpression = /readonly property bool cooperating: ([^\n]+)/.exec(overlay)[1]
const WlrKeyboardFocus = { None: 0, Exclusive: 1, OnDemand: 2 }
const cooperating = new Function('shown', 'cooperativeFocus', 'shownKeyboardFocus', 'WlrKeyboardFocus', `return ${cooperatingExpression}`)
assert(cooperating(true, true, WlrKeyboardFocus.Exclusive, WlrKeyboardFocus), 'a shown overlay that opted in cooperates')
assert(!cooperating(true, false, WlrKeyboardFocus.Exclusive, WlrKeyboardFocus), 'an overlay that did not opt in never cooperates')
assert(!cooperating(false, true, WlrKeyboardFocus.Exclusive, WlrKeyboardFocus), 'a closed overlay does not cooperate')
assert(!cooperating(true, true, WlrKeyboardFocus.None, WlrKeyboardFocus), 'an overlay without the keyboard has no focus to yield')
const focusExpression = /WlrLayershell\.keyboardFocus: ([^\n]+)/.exec(overlay)[1]
const focusMode = new Function('cooperating', 'focusHeld', 'shownKeyboardFocus', 'WlrKeyboardFocus', `return ${focusExpression}`)
assertEqual(focusMode(false, false, WlrKeyboardFocus.Exclusive, WlrKeyboardFocus), WlrKeyboardFocus.Exclusive, 'stock overlays stay exclusive')
assertEqual(focusMode(true, false, WlrKeyboardFocus.Exclusive, WlrKeyboardFocus), WlrKeyboardFocus.Exclusive, 'a cooperative overlay holds exclusive focus until the keyboard arrives')
assertEqual(focusMode(true, true, WlrKeyboardFocus.Exclusive, WlrKeyboardFocus), WlrKeyboardFocus.OnDemand, 'a cooperative overlay yields the pointer once it has the keyboard')
assertEqual(focusMode(false, true, WlrKeyboardFocus.None, WlrKeyboardFocus), WlrKeyboardFocus.None, 'an overlay waiting on its content stays keyboard-free')

const activeBody = /onActiveChanged: \{([\s\S]*?)\n    \}/.exec(overlay)[1]
const changeActive = new Function('window', 'active', activeBody)
let dismissals = 0
const cooperative = { shown: true, visible: true, cooperating: true, focusHeld: false, dismissRequested() { dismissals++ } }
changeActive(cooperative, false)
assertEqual(dismissals, 0, 'an overlay still waiting for the keyboard is not dismissed')
changeActive(cooperative, true)
assert(cooperative.focusHeld, 'keyboard focus arriving releases exclusive pointer routing')
changeActive(cooperative, false)
assertEqual(dismissals, 1, 'losing the keyboard asks the owner to dismiss')
assert(cooperative.focusHeld, 'a dismissed overlay does not return to exclusive and take focus back')
dismissals = 0
changeActive({ ...cooperative, shown: false }, false)
changeActive({ ...cooperative, visible: false }, false)
changeActive({ ...cooperative, cooperating: false }, false)
assertEqual(dismissals, 0, 'closing, unmapping and stock overlays never request dismissal')
assert(
  /model: window\.cooperating \? Quickshell\.screens : \[\]/.test(overlay) &&
    /WlrLayershell\.namespace: "omarchy-overlay-dismiss"[\s\S]*?WlrLayershell\.keyboardFocus: WlrKeyboardFocus\.None[\s\S]*?onPressed: window\.dismissRequested\(\)/.test(overlay),
  'only cooperative overlays map keyboard-free dismissal surfaces on other outputs'
)

// A cooperative overlay sits beside reserved space instead of covering it.
assert(
  overlay.includes('exclusionMode: cooperativeFocus ? ExclusionMode.Normal : ExclusionMode.Ignore'),
  'only cooperative overlays leave reserved space uncovered'
)
const reservedBody = /readonly property var reservedSpace: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const reservedSpace = new Function('cooperativeFocus', 'targetMonitor', reservedBody)
assertDeepEqual(reservedSpace(false, { lastIpcObject: { reserved: [0, 26, 0, 300] } }), [0, 0, 0, 0],
  'stock overlays still measure against the whole screen')
assertDeepEqual(reservedSpace(true, { lastIpcObject: { reserved: [0, 26, 0, 300] } }), [0, 26, 0, 300],
  'a cooperative overlay reads the reserved space Hyprland reports')
assertDeepEqual(reservedSpace(true, { lastIpcObject: {} }), [0, 0, 0, 0],
  'missing reserved space falls back to the whole screen')
assertDeepEqual(reservedSpace(true, null), [0, 0, 0, 0], 'reserved space waits for monitor information')
const tablet = { name: 'eDP-1', width: 1200, height: 750 }
const tabletMonitor = { name: 'eDP-1', scale: 1.6 }
assert(readyReserving(true, true, 1200, 424, tablet, tabletMonitor, 1.6, [0, 26, 0, 300]),
  'a cooperative overlay reveals at the size left above an on-screen keyboard')
assert(!readyReserving(true, true, 1200, 724, tablet, tabletMonitor, 1.6, [0, 26, 0, 300]),
  'a stale reserved space keeps content transparent until Hyprland is asked again')
assert(
  overlay.includes('onWidthChanged: if (shown && cooperativeFocus) Hyprland.refreshMonitors()') &&
    overlay.includes('onHeightChanged: if (shown && cooperativeFocus) Hyprland.refreshMonitors()'),
  'a keyboard appearing or leaving refreshes the reserved space'
)

const shellQml = read('shell/shell.qml')
const switchExpression = /readonly property bool overlaysCooperativeFocus: ([^\n]+\n[^\n]+)/.exec(shellQml)[1]
const cooperativeSwitch = new Function('shellConfig', 'Util', `return ${switchExpression}`)
const plainObject = { isPlainObject: (value) => !!value && typeof value === 'object' && !Array.isArray(value) }
assert(!cooperativeSwitch({ version: 1 }, plainObject), 'cooperative focus is off without a shell.json setting')
assert(!cooperativeSwitch({ overlays: { cooperativeFocus: 'yes' } }, plainObject), 'cooperative focus needs an explicit true')
assert(cooperativeSwitch({ overlays: { cooperativeFocus: true } }, plainObject), 'shell.json turns cooperative focus on')

const dismissPaths = {
  'shell/plugins/menu/Menu.qml': 'cancel',
  'shell/plugins/emojis/Emojis.qml': 'dismiss',
  'shell/plugins/clipboard/Clipboard.qml': 'close',
  'shell/plugins/image-picker/ImagePicker.qml': 'cancel',
}
for (const file of Object.keys(overlays)) {
  const qml = read(file)
  if (dismissPaths[file]) {
    assert(
      qml.includes('cooperativeFocus: !!root.shell && root.shell.overlaysCooperativeFocus === true') &&
        qml.includes(`onDismissRequested: root.${dismissPaths[file]}()`),
      `${file} cooperates only on the user's setting and dismisses through its own ${dismissPaths[file]} path`
    )
  } else {
    assert(!qml.includes('cooperativeFocus'), `${file} keeps exclusive focus`)
  }
}
assert(!read('shell/plugins/polkit/PolkitAgent.qml').includes('cooperativeFocus'), 'the password prompt never yields exclusive focus')

// The OSD never takes the keyboard or input, shown or not.
const osd = read('shell/plugins/osd/Osd.qml')
assert(
  osd.includes('shownKeyboardFocus: WlrKeyboardFocus.None') && osd.includes('mask: Region {}'),
  'the OSD stays click-through and keyboard-free while shown'
)
JS
