import QtQuick
import qs.Commons
import qs.Commons as Commons

// A window on a scene's desktop: crisp accent border and subtle inner wash
// while focused, optional floating drop shadow and titlebar, and distinct
// understated miniature app interiors so windows feel alive instead of empty.
Rectangle {
  id: root

  default property alias content: body.data
  property bool active: false
  property real titlebar: 0
  property bool lines: true
  // Visual interior style when `lines` is true:
  // 0 = code editor, 1 = terminal, 2 = sidebar + document, 3 = preview + notes
  property int variant: 0
  property bool shadow: false

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent
  property color surface: Commons.Color.menu.background

  readonly property real titlebarHeight: Style.space(12) * titlebar

  color: surface
  radius: Style.cornerRadius
  border.width: active ? Math.max(1, Style.space(1.5)) : Style.spacing.hairline
  border.color: active ? accent : Util.alpha(foreground, 0.26)

  Behavior on border.color { ColorAnimation { duration: Style.duration(160) } }

  // Crisp elevation shadow for overlapping floating windows.
  Rectangle {
    visible: root.shadow
    z: -1
    x: Style.space(3)
    y: Style.space(4)
    width: parent.width
    height: parent.height
    radius: root.radius
    color: Qt.rgba(0, 0, 0, root.active ? 0.42 : 0.28)
  }

  // Subtle accent surface wash on the focused window so active focus reads
  // unmistakably on both dark and light themes.
  Rectangle {
    anchors.fill: parent
    anchors.margins: root.border.width
    radius: Math.max(0, root.radius - 1)
    color: Util.alpha(root.accent, root.active ? 0.05 : 0)
    Behavior on color { ColorAnimation { duration: Style.duration(160) } }
  }

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
      color: Util.alpha(root.active ? root.accent : root.foreground, root.active ? 0.22 : 0.09)
    }

    Rectangle {
      anchors.left: parent.left
      anchors.leftMargin: Style.space(6)
      anchors.verticalCenter: parent.verticalCenter
      width: Math.min(Style.space(36), parent.width * 0.26)
      height: Style.space(3)
      radius: Style.cornerRadius > 0 ? height / 2 : 0
      color: Util.alpha(root.foreground, root.active ? 0.55 : 0.25)
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
          color: Util.alpha(root.foreground, root.active ? 0.6 : 0.35)
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

    // Variant 0: miniature code editor with subtle gutter and indented lines.
    Item {
      visible: root.lines && root.variant % 4 === 0 && body.height > Style.space(34) && body.width > Style.space(44)
      anchors.fill: parent
      anchors.margins: Style.space(9)

      Column {
        anchors.fill: parent
        spacing: Style.space(5)

        Repeater {
          model: [
            { indent: 0, len: 0.42, hi: true },
            { indent: 0.08, len: 0.68, hi: false },
            { indent: 0.08, len: 0.52, hi: false },
            { indent: 0.16, len: 0.62, hi: true },
            { indent: 0.16, len: 0.44, hi: false },
            { indent: 0.08, len: 0.32, hi: false },
            { indent: 0, len: 0.22, hi: false }
          ]

          Row {
            required property var modelData
            width: parent.width
            spacing: Style.space(5)

            Rectangle {
              width: Style.space(4)
              height: Style.space(3)
              color: Util.alpha(root.foreground, 0.12)
            }

            Item {
              width: Math.max(0, parent.width * modelData.indent)
              height: 1
              visible: modelData.indent > 0
            }

            Rectangle {
              width: Math.min(Style.space(132), Math.max(Style.space(10), (parent.width - Style.space(12)) * modelData.len))
              height: Style.space(3)
              radius: Style.cornerRadius > 0 ? height / 2 : 0
              color: modelData.hi && root.active ? Util.alpha(root.accent, 0.55) : Util.alpha(root.foreground, modelData.hi ? 0.26 : 0.15)
            }
          }
        }
      }
    }

    // Variant 1: miniature terminal with prompt chevrons and command output.
    Column {
      visible: root.lines && root.variant % 4 === 1 && body.height > Style.space(34) && body.width > Style.space(44)
      anchors.fill: parent
      anchors.margins: Style.space(9)
      spacing: Style.space(6)

      Repeater {
        model: [
          { prompt: true, len: 0.48 },
          { prompt: false, len: 0.72 },
          { prompt: false, len: 0.56 },
          { prompt: true, len: 0.36 },
          { prompt: false, len: 0.64 }
        ]

        Row {
          required property var modelData
          width: parent.width
          spacing: Style.space(5)

          Rectangle {
            visible: modelData.prompt
            width: Style.space(6)
            height: Style.space(3)
            color: root.active ? Util.alpha(root.accent, 0.8) : Util.alpha(root.foreground, 0.32)
          }

          Rectangle {
            width: Math.min(Style.space(136), (parent.width - Style.space(12)) * modelData.len)
            height: Style.space(3)
            radius: Style.cornerRadius > 0 ? height / 2 : 0
            color: modelData.prompt ? Util.alpha(root.foreground, root.active ? 0.4 : 0.24) : Util.alpha(root.foreground, 0.14)
          }
        }
      }
    }

    // Variant 2: miniature split sidebar + content document.
    Item {
      visible: root.lines && root.variant % 4 === 2 && body.height > Style.space(34) && body.width > Style.space(52)
      anchors.fill: parent

      Rectangle {
        id: sidePane
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: Math.min(Style.space(44), parent.width * 0.28)
        color: Util.alpha(root.foreground, 0.03)

        Column {
          anchors.fill: parent
          anchors.margins: Style.space(7)
          spacing: Style.space(5)

          Repeater {
            model: [0.85, 0.65, 0.75, 0.55]

            Rectangle {
              required property int index
              required property real modelData
              width: parent.width * modelData
              height: Style.space(3)
              color: index === 1 && root.active ? Util.alpha(root.accent, 0.6) : Util.alpha(root.foreground, 0.18)
            }
          }
        }

        Rectangle {
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          width: Style.spacing.hairline
          color: Util.alpha(root.foreground, 0.1)
        }
      }

      Column {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: sidePane.right
        anchors.right: parent.right
        anchors.margins: Style.space(9)
        spacing: Style.space(5)

        Rectangle {
          width: parent.width * 0.55
          height: Style.space(4)
          color: root.active ? Util.alpha(root.accent, 0.5) : Util.alpha(root.foreground, 0.24)
        }

        Item { width: 1; height: Style.space(2) }

        Repeater {
          model: [0.9, 0.78, 0.84, 0.5]

          Rectangle {
            required property real modelData
            width: parent.width * modelData
            height: Style.space(3)
            color: Util.alpha(root.foreground, 0.14)
          }
        }
      }
    }

    // Variant 3: miniature preview block + caption bars.
    Column {
      visible: root.lines && root.variant % 4 === 3 && body.height > Style.space(34) && body.width > Style.space(44)
      anchors.fill: parent
      anchors.margins: Style.space(9)
      spacing: Style.space(7)

      Rectangle {
        width: parent.width
        height: Math.max(Style.space(18), parent.height * 0.46)
        radius: Style.cornerRadius
        color: Util.alpha(root.active ? root.accent : root.foreground, root.active ? 0.12 : 0.05)
        border.width: Style.spacing.hairline
        border.color: Util.alpha(root.active ? root.accent : root.foreground, root.active ? 0.3 : 0.12)
      }

      Column {
        width: parent.width
        spacing: Style.space(4)

        Rectangle {
          width: parent.width * 0.62
          height: Style.space(3)
          color: root.active ? Util.alpha(root.accent, 0.52) : Util.alpha(root.foreground, 0.22)
        }

        Rectangle {
          width: parent.width * 0.84
          height: Style.space(3)
          color: Util.alpha(root.foreground, 0.14)
        }
      }
    }
  }
}
