import QtQuick
import qs.Commons
import qs.Commons as Commons

// A window on a scene's screen: the border Hyprland draws, in the accent color
// while focused, and a titlebar where the workspace floats.
Rectangle {
  id: root

  default property alias content: body.data
  property bool active: false
  // From 0, no titlebar, to 1, the one floating windows carry.
  property real titlebar: 0
  // A few lines standing in for whatever the window shows.
  property bool lines: true

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent
  property color surface: Commons.Color.menu.background

  readonly property real titlebarHeight: Style.space(11) * titlebar

  color: surface
  radius: Style.cornerRadius
  border.width: Style.spacing.hairline
  border.color: active ? accent : Util.alpha(foreground, 0.3)

  Behavior on border.color { ColorAnimation { duration: Style.duration(160) } }

  Item {
    id: bar
    visible: root.titlebar > 0
    opacity: root.titlebar
    clip: true
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: root.border.width
    height: root.titlebarHeight

    Rectangle {
      anchors.fill: parent
      color: Util.alpha(root.active ? root.accent : root.foreground, root.active ? 0.2 : 0.08)
    }

    Row {
      anchors.right: parent.right
      anchors.rightMargin: Style.space(5)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(3)

      Repeater {
        model: 3

        Rectangle {
          width: Style.space(4)
          height: width
          radius: width / 2
          color: Util.alpha(root.foreground, 0.45)
        }
      }
    }
  }

  Item {
    id: body
    clip: true
    anchors.fill: parent
    anchors.margins: root.border.width
    anchors.topMargin: root.border.width + root.titlebarHeight

    Column {
      visible: root.lines && body.height > Style.space(28) && body.width > Style.space(40)
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.margins: Style.space(8)
      spacing: Style.space(5)

      Repeater {
        model: [0.5, 0.78, 0.36]

        Rectangle {
          required property real modelData
          width: Math.min(Style.space(120), (body.width - Style.space(16)) * modelData)
          height: Style.space(3)
          color: Util.alpha(root.foreground, 0.16)
        }
      }
    }
  }
}
