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

assert(
  /onShownChanged: if \(shown\) targetScreen = focusedScreen\(\) \|\| targetScreen/.test(overlay) &&
    overlay.includes('screen: targetScreen'),
  'overlay window follows the focused monitor each time it is shown'
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

// The OSD never takes the keyboard or input, shown or not.
const osd = read('shell/plugins/osd/Osd.qml')
assert(
  osd.includes('shownKeyboardFocus: WlrKeyboardFocus.None') && osd.includes('mask: Region {}'),
  'the OSD stays click-through and keyboard-free while shown'
)
JS
