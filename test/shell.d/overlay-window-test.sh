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
const readySettling = new Function('shown', 'backingWindowVisible', 'width', 'height', 'targetScreen', 'targetMonitor', 'devicePixelRatio', 'reservedSpace', 'cooperationSettled', `return ${readyExpression}`)
const readyReserving = (...args) => readySettling(...args, true)
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

// Cooperative focus is off unless the overlay asks for it, and "auto" only
// turns it on while something other than the bar reserves screen space.
assert(overlay.includes('property var cooperativeFocus: false'), 'overlays keep exclusive focus by default')
const competingBody = /readonly property bool competingSurface: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const competingSurface = new Function('monitorReservedSpace', 'ownReservedSpace', competingBody)
assert(!competingSurface([0, 26, 0, 0], [0, 26, 0, 0]), 'the bar alone is not a competing surface')
assert(!competingSurface([0, 27, 0, 0], [0, 26, 0, 0]), 'a pixel of rounding is not a competing surface')
assert(competingSurface([0, 26, 0, 300], [0, 26, 0, 0]), 'a keyboard reserving the bottom edge competes')
assert(competingSurface([0, 60, 0, 0], [0, 26, 0, 0]), 'more than the bar on its own edge competes')
assert(competingSurface([0, 26, 0, 0], undefined), 'reserved space the shell cannot account for competes')
assert(!competingSurface([0, 0, 0, 0], [0, 26, 0, 0]), 'a hidden or absent reservation never competes')
const cooperativeExpression = /readonly property bool cooperative: ([^\n]+)/.exec(overlay)[1]
const isCooperativeSettled = new Function('cooperativeFocus', 'competingSurface', 'cooperationSettled', `return ${cooperativeExpression}`)
const isCooperative = (mode, competing) => isCooperativeSettled(mode, competing, true)
assert(isCooperative(true, false), 'true cooperates with nothing competing')
assert(isCooperative('auto', true), 'auto cooperates while a surface competes')
assert(!isCooperative('auto', false), 'auto is stock with nothing competing')
assert(!isCooperative(false, true), 'false never cooperates, whatever competes')
assert(!isCooperative(undefined, true), 'a plugin handed no setting never cooperates')
const cooperatingExpression = /readonly property bool cooperating: ([^\n]+)/.exec(overlay)[1]
const WlrKeyboardFocus = { None: 0, Exclusive: 1, OnDemand: 2 }
const cooperating = new Function('shown', 'cooperative', 'shownKeyboardFocus', 'WlrKeyboardFocus', `return ${cooperatingExpression}`)
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
const focusProbe = { active: false }
const nextTurn = []
const changeActiveNow = new Function('window', 'active', 'focusProbe', 'Qt', activeBody)
const changeActive = (window, active) => {
  focusProbe.active = active
  changeActiveNow(window, active, focusProbe, { callLater: (fn) => nextTurn.push(fn) })
  nextTurn.splice(0).forEach((fn) => fn())
}
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
focusProbe.active = false
changeActiveNow(cooperative, false, focusProbe, { callLater: (fn) => nextTurn.push(fn) })
assertEqual(dismissals, 0, 'dismissal waits for the next turn, outside the focus binding')
focusProbe.active = true
nextTurn.splice(0).forEach((fn) => fn())
assertEqual(dismissals, 0, 'focus that came straight back cancels the dismissal')
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
  overlay.includes('exclusionMode: cooperative ? ExclusionMode.Normal : ExclusionMode.Ignore') &&
    overlay.includes('readonly property var reservedSpace: cooperative ? monitorReservedSpace : [0, 0, 0, 0]'),
  'only cooperative overlays leave reserved space uncovered'
)
const reservedBody = /readonly property var monitorReservedSpace: \{([\s\S]*?)\n  \}/.exec(overlay)[1]
const reservedSpace = new Function('cooperativeFocus', 'targetMonitor', reservedBody)
assertDeepEqual(reservedSpace(false, { lastIpcObject: { reserved: [0, 26, 0, 300] } }), [0, 0, 0, 0],
  'stock overlays never read reserved space')
assertDeepEqual(reservedSpace('auto', { lastIpcObject: { reserved: [0, 26, 0, 300] } }), [0, 26, 0, 300],
  'an auto overlay reads reserved space to decide')
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
  overlay.includes('onWidthChanged: if (shown && cooperativeFocus !== false) Hyprland.refreshMonitors()') &&
    overlay.includes('onHeightChanged: if (shown && cooperativeFocus !== false) Hyprland.refreshMonitors()'),
  'a keyboard appearing or leaving refreshes the reserved space'
)
// "auto" opens as a stock overlay and decides afterwards, so it has the
// keyboard from the first keystroke.
const settledExpression = /readonly property bool cooperationSettled: ([^\n]+)/.exec(overlay)[1]
const settled = new Function('cooperativeFocus', 'reservedSpaceFresh', 'openingSizeSettled', `return ${settledExpression}`)
assert(settled(false, false, false) && settled(true, false, false), 'only an auto overlay has a decision to wait for')
assert(!settled('auto', true, false), 'an auto overlay waits for its first size before deciding')
assert(!settled('auto', false, true), 'an auto overlay waits for Hyprland to answer before deciding')
assert(settled('auto', true, true), 'an auto overlay decides once both are in')
assert(!isCooperativeSettled('auto', true, false), 'a competing surface does not turn an unsettled auto overlay cooperative')
assert(isCooperativeSettled('auto', true, true) && isCooperativeSettled(true, false, false), 'settled auto and explicit true cooperate')
const openingExpression = /readonly property bool openingSize: ([^\n]*(?:\n    &&[^\n]*)*)/.exec(overlay)[1]
const openingSize = new Function('shown', 'backingWindowVisible', 'targetScreen', 'width', 'height', `return ${openingExpression}`)
assert(openingSize(true, true, { width: 1200, height: 750 }, 1200, 750), 'the first size has arrived at the full screen')
assert(!openingSize(true, true, { width: 1200, height: 750 }, 500, 500) && !openingSize(true, false, { width: 1200, height: 750 }, 1200, 750),
  'a default or unmapped size is not the first size')
assert(!readySettling(true, true, 1200, 750, screen, monitor, 1.6, [0, 0, 0, 0], false), 'content stays transparent until an auto overlay has decided')
assert(
  /onShownChanged: \{\n    reservedSpaceFresh = false\n    openingSizeSettled = false/.test(overlay) &&
    /running: window\.shown && window\.cooperativeFocus === "auto" && !window\.reservedSpaceFresh\n    onTriggered: window\.reservedSpaceFresh = true/.test(overlay),
  'every open decides afresh, and an answer that never comes does not hold content back'
)
assert(
  /running: window\.shown && window\.cooperative && window\.backingWindowVisible && !window\.contentReady\n    onTriggered: Hyprland\.refreshMonitors\(\)/.test(overlay),
  'a cooperative overlay keeps asking until its size and the reserved space agree'
)
assert(
  /enabled: window\.shown && window\.cooperativeFocus === "auto"\n    function onRawEvent\(event\) \{\n      if \(event\.name === "openlayer" \|\| event\.name === "closelayer"\) Hyprland\.refreshMonitors\(\)/.test(overlay),
  'an open auto overlay looks again when a layer surface comes or goes'
)

const shellQml = read('shell/shell.qml')
const switchBody = /readonly property var overlaysCooperativeFocus: \{([\s\S]*?)\n  \}/.exec(shellQml)[1]
const cooperativeSwitch = new Function('shellConfig', 'Util', switchBody)
const plainObject = { isPlainObject: (value) => !!value && typeof value === 'object' && !Array.isArray(value) }
assertEqual(cooperativeSwitch({ version: 1 }, plainObject), 'auto', 'cooperative focus is automatic without a shell.json setting')
assertEqual(cooperativeSwitch({ overlays: { cooperativeFocus: 'yes' } }, plainObject), 'auto', 'an unknown setting falls back to automatic')
assertEqual(cooperativeSwitch({ overlays: { cooperativeFocus: true } }, plainObject), true, 'shell.json turns cooperative focus on')
assertEqual(cooperativeSwitch({ overlays: { cooperativeFocus: false } }, plainObject), false, 'shell.json turns cooperative focus off')
const barReservedBody = /readonly property var barReservedSpace: \{([\s\S]*?)\n  \}/.exec(shellQml)[1]
const barReserved = new Function('bar', barReservedBody)
assertDeepEqual(barReserved({ position: 'top', barSize: 26, barHidden: false }), [0, 26, 0, 0], 'a top bar reserves the top edge')
assertDeepEqual(barReserved({ position: 'left', barSize: 40 }), [40, 0, 0, 0], 'a side bar reserves its own edge')
assertDeepEqual(barReserved({ position: 'bottom', barSize: 26, barHidden: true }), [0, 0, 0, 0], 'a hidden bar reserves nothing')
assertDeepEqual(barReserved(null), [0, 0, 0, 0], 'no bar reserves nothing')

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
      qml.includes('cooperativeFocus: root.shell ? root.shell.overlaysCooperativeFocus : false') &&
        qml.includes('ownReservedSpace: root.shell ? root.shell.barReservedSpace : [0, 0, 0, 0]') &&
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
