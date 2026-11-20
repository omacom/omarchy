import QtQuick
import qs.Commons
import qs.Commons as Commons

// The screen every scene is drawn on: the bar along the top, as on the
// desktop, and the rest of it left for windows.
Item {
  id: root

  default property alias content: stage.data
  // Where the windows go: everything under the bar, inside the outer gap.
  readonly property alias stage: stage

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent
  // The gap between windows, and from them to the screen's edge.
  readonly property real gap: Style.space(6)

  clip: true
  // A picture of the desktop, which a right-to-left language does not mirror.
  LayoutMirroring.enabled: false
  LayoutMirroring.childrenInherit: true

  Rectangle {
    anchors.fill: parent
    color: Util.alpha(root.foreground, 0.035)
    border.color: Util.alpha(root.foreground, 0.2)
    border.width: Style.spacing.hairline
    radius: Style.cornerRadius
  }

  Item {
    id: bar
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: Style.spacing.hairline
    height: Style.space(13)

    Row {
      anchors.left: parent.left
      anchors.leftMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(4)

      Repeater {
        model: 4

        Rectangle {
          required property int index
          width: Style.space(4)
          height: width
          color: index === 0 ? root.accent : Util.alpha(root.foreground, 0.3)
        }
      }
    }

    Rectangle {
      anchors.centerIn: parent
      width: Style.space(34)
      height: Style.space(3)
      color: Util.alpha(root.foreground, 0.3)
    }

    Row {
      anchors.right: parent.right
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(4)

      Repeater {
        model: 3

        Rectangle {
          width: Style.space(4)
          height: width
          radius: width / 2
          color: Util.alpha(root.foreground, 0.3)
        }
      }
    }

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: Style.spacing.hairline
      color: Util.alpha(root.foreground, 0.12)
    }
  }

  Item {
    id: stage
    anchors.top: bar.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: root.gap / 2
  }
}
