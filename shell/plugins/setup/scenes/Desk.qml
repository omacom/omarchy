import QtQuick
import qs.Commons
import qs.Commons as Commons

// The miniature desktop every Welcome scene is drawn on: a subtle atmospheric
// surface, Omarchy's top bar with workspace pills, and the window stage below.
Item {
  id: root

  default property alias content: stage.data
  readonly property alias stage: stage

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent
  readonly property real gap: Style.space(7)

  clip: true
  // A picture of the desktop, which a right-to-left language does not mirror.
  LayoutMirroring.enabled: false
  LayoutMirroring.childrenInherit: true

  Rectangle {
    anchors.fill: parent
    border.color: Util.alpha(root.foreground, 0.2)
    border.width: Style.spacing.hairline
    radius: Style.cornerRadius
    gradient: Gradient {
      GradientStop { position: 0.0; color: Util.alpha(root.accent, 0.055) }
      GradientStop { position: 0.55; color: Util.alpha(root.foreground, 0.03) }
      GradientStop { position: 1.0; color: Util.alpha(root.foreground, 0.015) }
    }
  }

  Item {
    id: bar
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: Style.spacing.hairline
    height: Style.space(15)

    Rectangle {
      anchors.fill: parent
      color: Util.alpha(Commons.Color.menu.background, 0.45)
    }

    Row {
      anchors.left: parent.left
      anchors.leftMargin: Style.space(9)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(4)

      Repeater {
        model: 4

        Rectangle {
          required property int index
          width: index === 0 ? Style.space(10) : Style.space(4)
          height: Style.space(4)
          radius: Style.cornerRadius > 0 ? height / 2 : 0
          color: index === 0 ? root.accent : Util.alpha(root.foreground, 0.28)
        }
      }
    }

    Rectangle {
      anchors.centerIn: parent
      width: Style.space(38)
      height: Style.space(3)
      radius: Style.cornerRadius > 0 ? height / 2 : 0
      color: Util.alpha(root.foreground, 0.28)
    }

    Row {
      anchors.right: parent.right
      anchors.rightMargin: Style.space(9)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(4)

      Repeater {
        model: 3

        Rectangle {
          width: Style.space(4)
          height: width
          radius: width / 2
          color: Util.alpha(root.foreground, 0.28)
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
