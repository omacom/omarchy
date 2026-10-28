import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons

// Scrolling page body. Children stack in a column; the page keeps the item
// with keyboard focus in view, and sliders hand it their wheel events.
Flickable {
  id: root

  default property alias content: column.data
  property real padding: Style.spacing.panelPadding

  contentWidth: width
  contentHeight: column.implicitHeight + padding * 2
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  flickableDirection: Flickable.VerticalFlick

  ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

  function clampY(y) {
    return Math.max(0, Math.min(Math.max(0, contentHeight - height), y))
  }

  // Touchpads report pixel deltas; wheels only report angles.
  function scrollBy(wheel) {
    var delta = wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : wheel.angleDelta.y / 2
    contentY = clampY(contentY - delta)
  }

  function ensureVisible(item) {
    if (!item || !root.contentItem) return
    var point = item.mapToItem(root.contentItem, 0, 0)
    if (point.y === undefined) return
    var margin = Style.spacing.xxl
    if (point.y < contentY + margin) contentY = clampY(point.y - margin)
    else if (point.y + item.height > contentY + height - margin) contentY = clampY(point.y + item.height + margin - height)
  }

  function isInside(item) {
    for (var node = item; node; node = node.parent) {
      if (node === column) return true
    }
    return false
  }

  Connections {
    target: root.Window
    function onActiveFocusItemChanged() {
      var item = root.Window.activeFocusItem
      if (root.visible && root.isInside(item)) root.ensureVisible(item)
    }
  }

  ColumnLayout {
    id: column
    x: root.padding
    y: root.padding
    width: root.width - root.padding * 2
    spacing: Style.spacing.panelGap
  }
}
