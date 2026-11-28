import QtQuick
import qs.Commons

// Consistent mouse-wheel and touchpad scrolling for Flickable/ListView
// popups. Applies Style.touchpadScrollFactor to pixel deltas and falls back
// to three rows per wheel notch, optionally resetting a PointerMoveGate
// before mutating contentY so rows scrolling under a stationary pointer
// cannot steal hover selection.
WheelHandler {
  id: root

  property Flickable flickable: null
  property real stepHeight: Style.spacing.popupRowHeight
  property PointerMoveGate pointerGate: null

  acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
  target: null

  onWheel: function(event) {
    if (!root.flickable) return
    var delta = event.pixelDelta.y * Style.touchpadScrollFactor
      || event.angleDelta.y / 120 * root.stepHeight * 3
    if (delta === 0) return
    var bottom = root.flickable.originY + Math.max(0, root.flickable.contentHeight - root.flickable.height)
    var nextY = Math.max(root.flickable.originY, Math.min(bottom, root.flickable.contentY - delta))
    if (nextY !== root.flickable.contentY) {
      if (root.pointerGate) root.pointerGate.reset()
      root.flickable.contentY = nextY
    }
    event.accepted = true
  }
}
