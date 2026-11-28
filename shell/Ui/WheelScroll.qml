import QtQuick
import qs.Commons

// Mouse-wheel and touchpad scrolling for Flickable/ListView popups.
// Resets `gate` before moving contentY so rows scrolling under a stationary
// pointer cannot steal hover selection.
WheelHandler {
  id: root

  required property Flickable flickable
  property real stepHeight: Style.spacing.popupRowHeight
  property PointerMoveGate gate: null

  acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
  target: null

  onWheel: function(event) {
    var delta = event.pixelDelta.y * Style.touchpadScrollFactor
      || event.angleDelta.y / 120 * root.stepHeight * 3
    if (delta === 0) { event.accepted = false; return }
    var bottom = root.flickable.originY + Math.max(0, root.flickable.contentHeight - root.flickable.height)
    var nextY = Math.max(root.flickable.originY, Math.min(bottom, root.flickable.contentY - delta))
    if (nextY !== root.flickable.contentY) {
      if (root.gate) root.gate.reset()
      root.flickable.contentY = nextY
    }
    event.accepted = true
  }
}
