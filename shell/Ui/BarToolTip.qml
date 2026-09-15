import QtQuick
import Quickshell
import qs.Commons

// Shared presentation for trusted bars and private worker bars. The caller
// owns the hover delay and validates that the target belongs to this window.
PopupWindow {
  id: root

  property var target: null
  property var ownerWindow: null
  property string position: "top"
  property string text: ""
  property string fontFamily: Style.font.family
  readonly property real availableWidth: ownerWindow && ownerWindow.screen
    ? ownerWindow.screen.width - 12 - (position === "left" || position === "right" ? ownerWindow.width : 0)
    : 4096

  color: "transparent"
  implicitWidth: Math.ceil(bubble.implicitWidth)
  implicitHeight: Math.ceil(bubble.implicitHeight)
  mask: Region {}

  anchor {
    id: tooltipAnchor
    window: root.ownerWindow
    adjustment: PopupAdjustment.Slide
    edges: Edges.Top | Edges.Left
    gravity: Edges.Bottom | Edges.Right
    rect.width: 1
    rect.height: 1

    onAnchoring: {
      var target = root.target
      if (!target || !root.ownerWindow || target.QsWindow.window !== root.ownerWindow) return

      var localX = target.width / 2 - root.implicitWidth / 2
      var localY = target.height + 6
      if (root.position === "bottom") {
        localY = -root.implicitHeight - 6
      } else if (root.position === "left") {
        localX = target.width + 6
        localY = target.height / 2 - root.implicitHeight / 2
      } else if (root.position === "right") {
        localX = -root.implicitWidth - 6
        localY = target.height / 2 - root.implicitHeight / 2
      }
      var point = root.ownerWindow.contentItem.mapFromItem(target, localX, localY)
      tooltipAnchor.rect.x = Math.round(point.x)
      tooltipAnchor.rect.y = Math.round(point.y)
    }
  }

  BorderSurface {
    id: bubble
    implicitWidth: Math.min(label.implicitWidth + 20, Math.max(20, root.availableWidth))
    implicitHeight: label.implicitHeight + 14
    color: Color.tooltip.background
    borderSpec: Border.surfaceSpec("tooltip", "border", Color.tooltip.border, 1)
    radius: Style.cornerRadius

    Text {
      id: label
      textFormat: Text.PlainText
      anchors.centerIn: parent
      width: bubble.implicitWidth - 20
      text: root.text
      wrapMode: Text.Wrap
      color: Color.tooltip.text
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
  }
}
