#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')
const overlay = read('shell/Ui/OverlayWindow.qml')

// Closed, the surface parks 1x1, input-less and without keyboard below
// windows: off the overlay layer, so it never blocks direct scanout.
assert(
  overlay.includes('visible: true') &&
    overlay.includes('anchors { top: true; left: true; bottom: shown; right: shown }') &&
    overlay.includes('implicitWidth: 1') &&
    overlay.includes('implicitHeight: 1') &&
    overlay.includes('mask: shown ? null : emptyRegion') &&
    overlay.includes('WlrLayershell.layer: shown ? shownLayer : WlrLayer.Bottom') &&
    overlay.includes('WlrLayershell.keyboardFocus: shown ? shownKeyboardFocus : WlrKeyboardFocus.None'),
  'overlay window parks a 1x1 input-less surface below windows while hidden'
)

// Content stays hidden until the surface has grown, so no frame drawn at 1x1
// is stretched across the screen.
assert(
  /target: window\.contentItem\s*property: "visible"\s*value: window\.shown && window\.width > 1 && window\.height > 1/.test(overlay),
  'overlay window draws nothing until the surface has grown'
)

// Changing screen recreates the layer surface. Recreated in the same step that
// shows it, the surface came back on the bottom layer without keyboard focus,
// so the first open on another monitor was invisible (#13562). The parked
// surface follows focus instead, and never moves while shown.
assert(
  /function followFocusedScreen\(\) \{\s*if \(!shown\) targetScreen = focusedScreen\(\) \|\| targetScreen\s*\}/.test(overlay) &&
    /target: Hyprland\s*function onFocusedMonitorChanged\(\) \{ window\.followFocusedScreen\(\) \}/.test(overlay) &&
    overlay.includes('Component.onCompleted: followFocusedScreen()') &&
    overlay.includes('onShownChanged: Qt.callLater(followFocusedScreen)') &&
    !/onShownChanged: if \(shown\)/.test(overlay) &&
    overlay.includes('screen: targetScreen'),
  'overlay window moves to the focused monitor while parked, never in the step that shows it'
)

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
    `${file} keeps its surface through OverlayWindow`
  )
}

// Window visibility never changes now, so close-time resets key off shown.
const menuQml = read('shell/plugins/menu/Menu.qml')
assert(
  menuQml.includes('onShownChanged: if (!shown) { cardTop = -1; maxRowsHeight = -1 }') &&
    menuQml.includes('if (shown && cardTop < 0) {') &&
    !/onVisibleChanged: if \(!visible\) \{ cardTop/.test(menuQml),
  'the menu unfreezes its layout when the overlay hides'
)

// A kept surface grows from its parked 1x1 when shown, which Hyprland animates
// as a slide in from the corner unless its layer rule turns animation off.
const shellRules = read('default/hypr/apps/omarchy-shell.lua')
const noAnim = /namespace = "\^\(([^)]*)\)\$" \}, no_anim = true/.exec(shellRules)
assert(noAnim, 'the shell overlays share one no-animation layer rule')
const unanimated = noAnim ? noAnim[1].split('|') : []
for (const file of Object.keys(overlays)) {
  const namespace = /WlrLayershell\.namespace: "([^"]+)"/.exec(read(file))
  assert(namespace && unanimated.includes(namespace[1]), `${file} is exempt from Hyprland's layer animation`)
}

// The OSD never takes the keyboard or input, shown or not.
const osd = read('shell/plugins/osd/Osd.qml')
assert(
  osd.includes('shownKeyboardFocus: WlrKeyboardFocus.None') && osd.includes('mask: Region {}'),
  'the OSD stays click-through and keyboard-free while shown'
)
JS
