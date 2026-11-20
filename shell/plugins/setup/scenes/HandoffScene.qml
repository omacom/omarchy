import QtQuick
import qs.Commons
import qs.Commons as Commons
import ".."

// What picking a row opens: a terminal wizard, the editor on a config file, a
// list in the menu, or, where it opens nothing, the app or setting itself. Each
// is named for the row, so no two rows of a page show the same picture.
Desk {
  id: root

  // The row under the cursor, as SetupModel.optionFor describes it.
  property var option: null

  readonly property string kind: option ? option.handoff : ""
  property real caret: 1

  SequentialAnimation on caret {
    loops: Animation.Infinite
    running: root.visible && !Style.reduceMotion && (root.kind === "terminal" || root.kind === "editor")
    PauseAnimation { duration: Style.duration(520) }
    PropertyAction { value: 0 }
    PauseAnimation { duration: Style.duration(420) }
    PropertyAction { value: 1 }
  }

  // A row's mark and name, as the thing it opens is titled.
  component Named: Row {
    spacing: Style.space(6)

    Text {
      visible: text !== ""
      textFormat: Text.PlainText
      text: root.option ? root.option.icon : ""
      color: root.foreground
      font.family: root.option && root.option.iconFont !== "" ? root.option.iconFont : Style.font.menuFamily
      font.pixelSize: Style.font.bodySmall
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      textFormat: Text.PlainText
      text: root.option ? root.option.label : ""
      color: root.foreground
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.bodySmall
      font.bold: true
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  component Fading: Item {
    property bool shown: false
    anchors.fill: parent
    opacity: shown ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic } }
  }

  Win {
    id: frame
    width: parent.width * (root.kind === "terminal" ? 0.56 : root.kind === "editor" ? 0.6 : root.kind === "menu" ? 0.24 : 0.4)
    height: parent.height * (root.kind === "menu" ? 0.86 : root.kind === "editor" ? 0.82 : 0.76)
    anchors.centerIn: parent
    active: true
    lines: false
    foreground: root.foreground
    accent: root.accent

    Behavior on width { NumberAnimation { duration: Style.duration(220); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
    Behavior on height { NumberAnimation { duration: Style.duration(220); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }

    // A terminal wizard opens under the logo, as the real one does.
    Fading {
      shown: root.kind === "terminal"

      Column {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: Style.space(12)
        spacing: Style.space(9)

        Wordmark {
          width: Style.space(96)
          color: Util.alpha(root.accent, 0.9)
        }

        Named {}

        Rectangle {
          visible: frame.height > Style.space(110)
          width: Style.space(150)
          height: Style.space(4)
          color: Util.alpha(root.foreground, 0.26)
        }

        Row {
          spacing: Style.space(4)

          Rectangle {
            width: Style.space(54)
            height: Style.space(4)
            anchors.verticalCenter: parent.verticalCenter
            color: Util.alpha(root.foreground, 0.5)
          }

          Rectangle {
            width: Style.space(5)
            height: Style.space(9)
            color: root.accent
            opacity: root.caret
          }
        }
      }
    }

    // The editor, on the file the row names.
    Fading {
      shown: root.kind === "editor"

      Rectangle {
        id: tab
        height: Style.space(18)
        width: Math.min(parent.width, tabName.implicitWidth + Style.space(20))
        color: Util.alpha(root.foreground, 0.08)

        Text {
          id: tabName
          textFormat: Text.PlainText
          text: root.option ? root.option.file : ""
          color: root.foreground
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.caption
          anchors.centerIn: parent
        }
      }

      Column {
        anchors.top: tab.bottom
        anchors.left: parent.left
        anchors.margins: Style.space(10)
        spacing: Style.space(6)

        Repeater {
          // Lines of a config file: how far each is indented, and how long it is.
          model: [[0, 86], [1, 128], [1, 72], [2, 104], [1, 40], [0, 24]]

          Row {
            required property int index
            required property var modelData
            spacing: Style.space(4)

            Item { width: Style.space(12) * modelData[0]; height: 1 }

            Rectangle {
              width: Style.space(modelData[1])
              height: Style.space(4)
              color: Util.alpha(index === 3 ? root.accent : root.foreground, index === 3 ? 0.8 : 0.26)
            }

            Rectangle {
              visible: index === 3
              width: Style.space(2)
              height: Style.space(9)
              anchors.verticalCenter: parent.verticalCenter
              color: root.accent
              opacity: root.caret
            }
          }
        }
      }
    }

    // The menu, opened on the list to pick from.
    Fading {
      shown: root.kind === "menu"

      Column {
        anchors.fill: parent
        anchors.margins: Style.space(8)
        spacing: Style.space(5)

        Named {
          width: parent.width
          clip: true
        }

        Rectangle {
          width: parent.width
          height: Style.spacing.hairline
          color: Util.alpha(root.foreground, 0.2)
        }

        Repeater {
          model: [0.6, 0.78, 0.5, 0.7]

          Rectangle {
            required property int index
            required property real modelData
            width: parent.width
            height: Style.space(13)
            color: index === 1 ? Commons.Color.menu.selectedBackground : "transparent"

            Rectangle {
              width: Style.space(5)
              height: width
              x: Style.space(5)
              anchors.verticalCenter: parent.verticalCenter
              color: Util.alpha(index === 1 ? root.accent : root.foreground, index === 1 ? 0.9 : 0.4)
            }

            Rectangle {
              width: (parent.width - Style.space(22)) * modelData
              height: Style.space(4)
              x: Style.space(16)
              anchors.verticalCenter: parent.verticalCenter
              color: Util.alpha(index === 1 ? root.accent : root.foreground, index === 1 ? 0.9 : 0.3)
            }
          }
        }
      }
    }

    // Nothing opens: the choice itself, as the app or setting it names.
    Fading {
      shown: root.kind === ""

      Column {
        anchors.centerIn: parent
        width: parent.width - Style.space(16)
        spacing: Math.min(Style.space(8), frame.height * 0.06)

        Text {
          textFormat: Text.PlainText
          text: root.option ? root.option.icon : ""
          color: root.accent
          font.family: root.option && root.option.iconFont !== "" ? root.option.iconFont : Style.font.menuFamily
          font.pixelSize: Math.min(Style.space(40), frame.height * 0.36)
          horizontalAlignment: Text.AlignHCenter
          width: parent.width
        }

        Text {
          textFormat: Text.PlainText
          text: root.option ? root.option.label : ""
          color: root.foreground
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.bodySmall
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
          width: parent.width
        }
      }
    }
  }
}
