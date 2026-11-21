#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A slot that moves under a pressed pointer must not read as pointer motion:
# the module drag threshold is measured in scene coordinates, not in the
# slot's own.
run_node_test <<'JS'
const fs = require('fs')
const Qt = { LeftButton: 1 }
const bar = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
const scope = bar.slice(bar.indexOf('id: modulePointer'))
const pressedBody = scope.match(/onPressed: function\(mouse\) \{([\s\S]*?)\n      \}/)[1]
const positionBody = scope.match(/onPositionChanged: function\(mouse\) \{([\s\S]*?)\n      \}/)[1]

// Every handler-qualified identifier is a parameter except the MouseArea's
// own mutable properties, which sloppy mode binds as globals we seed and read
// back so the real component's state is what changes.
const params = ['mouse', 'slot', 'root', 'hold', 'canReorder', 'dragThreshold', 'Qt']
const onPress = new Function(...params, pressedBody)
const onPosition = new Function(...params, positionBody)

function makeSlot() {
  return {
    sceneX: 100, sceneY: 8,
    mapToItem(item, x, y) { return { x: this.sceneX + x, y: this.sceneY + y } },
    traySectionContains() { return false }
  }
}

const area = {
  barDragSource: null,
  beginBarDragCalls: [],
  beginBarDrag(slot, x, y) { this.beginBarDragCalls.push([x, y]) },
  moduleClickTargetAt() { return null },
  finishBarSettle() {}, clearBarDrag() {}, hideTooltip() {}
}

function pressOn(slot, x, y) {
  const mouse = { buttons: Qt.LeftButton, x, y, button: Qt.LeftButton, accepted: true }
  globalThis.dragging = false
  globalThis.suppressClick = false
  globalThis.pressedX = undefined
  globalThis.pressedY = undefined
  globalThis.pressedScene = undefined
  onPress(mouse, slot, area, () => {}, true, 4, Qt)
  return mouse
}

// Press at local (10, 5) on a slot whose scene origin is (100, 8).
const slot = makeSlot()
pressOn(slot, 10, 5)

// The slot slides 4px while the pointer stays still: local (10,5) became (6,5).
slot.sceneX = 104
const held = { buttons: Qt.LeftButton, x: 6, y: 5 }
onPosition(held, slot, area, () => {}, true, 4, Qt)
assert(!globalThis.dragging, 'a slot moving under a still pressed pointer does not start a drag')
assert(area.beginBarDragCalls.length === 0, 'no bar drag is opened for slot movement alone')

// A genuinely moving pointer still exceeds the threshold and starts the drag.
const moved = { buttons: Qt.LeftButton, x: 16, y: 5 }
onPosition(moved, slot, area, () => {}, true, 4, Qt)
assert(globalThis.dragging === true, 'pointer motion past the threshold still starts a drag')
assert(area.beginBarDragCalls.length === 1, 'beginBarDrag ran once for the real drag')
assert(area.beginBarDragCalls[0][0] === 10 && area.beginBarDragCalls[0][1] === 5,
  'the drag starts from the press point in slot coordinates')

// Same for a vertically sliding slot: press (10, 5), slot scene y 8 -> 12.
const slot2 = makeSlot()
pressOn(slot2, 10, 5)
slot2.sceneY = 12
const still = { buttons: Qt.LeftButton, x: 10, y: 1 }
onPosition(still, slot2, area, () => {}, true, 4, Qt)
assert(!globalThis.dragging, 'a vertically moving slot does not start a drag either')
JS

require_quickshell "bar drag test"

# The bar syncs the compositor's blur to its background as it starts.
qml_fixture_scratch
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-bar"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-bar"

run_qml_fixture bar-drag "dragged widgets land where dropped, as the instances dragged" Ui Commons
