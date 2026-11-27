import QtQuick
import qs.Commons
import qs.Commons as Commons

// Crisp miniature pictogram for each workspace layout mode inside its choice card.
// Replaces the generic geometric menu glyphs with an unmistakable visual preview.
Item {
  id: root

  property string mode: "dwindle"
  property bool active: false
  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  readonly property color line: Util.alpha(foreground, active ? 0.42 : 0.24)
  readonly property color paneFill: Util.alpha(foreground, active ? 0.08 : 0.04)
  readonly property color hotFill: Util.alpha(accent, active ? 0.28 : 0.14)
  readonly property color hotLine: active ? accent : Util.alpha(foreground, 0.42)
  readonly property real r: Math.min(Style.cornerRadius, Style.space(3))

  implicitWidth: Style.space(58)
  implicitHeight: Style.space(36)
  clip: true
  LayoutMirroring.enabled: false
  LayoutMirroring.childrenInherit: true

  Rectangle {
    anchors.fill: parent
    radius: Math.min(Style.cornerRadius, Style.space(4))
    color: Util.alpha(root.foreground, 0.03)
    border.width: Style.spacing.hairline
    border.color: Util.alpha(root.foreground, root.active ? 0.28 : 0.16)
  }

  // Tiling (dwindle): left half + top-right + bottom-right.
  Item {
    visible: root.mode === "dwindle"
    anchors.fill: parent
    anchors.margins: Style.space(4)

    Rectangle {
      x: 0; y: 0
      width: (parent.width - Style.space(3)) * 0.52
      height: parent.height
      radius: root.r
      color: root.paneFill
      border.width: Style.spacing.hairline
      border.color: root.line
    }

    Rectangle {
      x: (parent.width - Style.space(3)) * 0.52 + Style.space(3)
      y: 0
      width: parent.width - x
      height: (parent.height - Style.space(3)) * 0.5
      radius: root.r
      color: root.paneFill
      border.width: Style.spacing.hairline
      border.color: root.line
    }

    Rectangle {
      x: (parent.width - Style.space(3)) * 0.52 + Style.space(3)
      y: (parent.height - Style.space(3)) * 0.5 + Style.space(3)
      width: parent.width - x
      height: parent.height - y
      radius: root.r
      color: root.hotFill
      border.width: Style.spacing.hairline
      border.color: root.hotLine
    }
  }

  // Scrolling: horizontal columns extending past the edge.
  Item {
    visible: root.mode === "scrolling"
    anchors.fill: parent
    anchors.margins: Style.space(4)
    clip: true

    Repeater {
      model: 3

      Rectangle {
        required property int index
        readonly property real colW: parent.width * 0.39
        x: index * (colW + Style.space(3))
        y: 0
        width: colW
        height: parent.height
        radius: root.r
        color: index === 1 ? root.hotFill : root.paneFill
        border.width: Style.spacing.hairline
        border.color: index === 1 ? root.hotLine : root.line
      }
    }
  }

  // Floating: overlapping windows with titlebars and a miniature dock.
  Item {
    visible: root.mode === "floating"
    anchors.fill: parent
    anchors.margins: Style.space(4)

    Rectangle {
      x: Style.space(1)
      y: Style.space(1)
      width: parent.width * 0.56
      height: parent.height * 0.62
      radius: root.r
      color: Commons.Color.menu.background
      border.width: Style.spacing.hairline
      border.color: root.line

      Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.spacing.hairline
        height: Style.space(4)
        color: Util.alpha(root.foreground, 0.14)
      }
    }

    Rectangle {
      x: parent.width * 0.36
      y: parent.height * 0.2
      width: parent.width * 0.6
      height: parent.height * 0.62
      radius: root.r
      color: Commons.Color.menu.background
      border.width: Style.spacing.hairline
      border.color: root.hotLine

      Rectangle {
        anchors.fill: parent
        anchors.margins: Style.spacing.hairline
        radius: Math.max(0, root.r - 1)
        color: root.hotFill
      }

      Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.spacing.hairline
        height: Style.space(4)
        color: Util.alpha(root.accent, root.active ? 0.45 : 0.25)
      }
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      width: parent.width * 0.44
      height: Style.space(4)
      radius: Math.min(root.r, height / 2)
      color: Util.alpha(root.foreground, root.active ? 0.45 : 0.28)
    }
  }
}
