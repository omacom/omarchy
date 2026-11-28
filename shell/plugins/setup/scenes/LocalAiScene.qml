import QtQuick
import qs.Commons
import qs.Commons as Commons

// A local coding model on this machine: a custom pinned silicon die with a
// pulsing 3x3 neural core streaming tokens over local traces into the agent
// window, with a quiet lock badge emphasizing private offline execution.
Desk {
  id: root

  property bool running: true
  property real turn: Style.reduceMotion ? 0.78 : 0

  readonly property color live: running ? accent : Util.alpha(foreground, 0.34)
  readonly property real presence: running ? 1 - Util.clamp((turn - 0.89) / 0.11, 0, 1) : 1

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(3800)
    loops: Animation.Infinite
    running: root.visible && root.running && !Style.reduceMotion
  }

  Item {
    id: chipGroup
    width: Style.space(76)
    height: chip.height + Style.space(24)
    x: parent.width * 0.17 - width / 2
    anchors.verticalCenter: parent.verticalCenter

    Item {
      id: chip
      width: Style.space(62)
      height: width
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top

      // Outer pins along all four sides.
      Repeater {
        model: 16

        Rectangle {
          required property int index
          readonly property int side: Math.floor(index / 4)
          readonly property real along: (index % 4 + 0.5) / 4 * chip.width - width / 2

          width: side < 2 ? Style.space(3) : Style.space(6)
          height: side < 2 ? Style.space(6) : Style.space(3)
          x: side === 0 ? along : side === 1 ? along : side === 2 ? -Style.space(6) : chip.width
          y: side === 0 ? -Style.space(6) : side === 1 ? chip.height : along
          color: Util.alpha(root.live, root.running ? 0.65 : 0.4)
          Behavior on color { ColorAnimation { duration: Style.duration(160) } }
        }
      }

      // Silicon package body.
      Rectangle {
        anchors.fill: parent
        color: Commons.Color.menu.background
        radius: Style.cornerRadius
        border.width: root.running ? Math.max(1, Style.space(1.5)) : Style.spacing.hairline
        border.color: root.live
        Behavior on border.color { ColorAnimation { duration: Style.duration(160) } }

        // Inner die frame.
        Rectangle {
          anchors.fill: parent
          anchors.margins: Style.space(6)
          color: Util.alpha(root.live, root.running ? 0.08 : 0.03)
          border.width: Style.spacing.hairline
          border.color: Util.alpha(root.live, 0.35)

          // 3x3 pulsing neural core cells (replaces nested chip-in-chip icon).
          Grid {
            anchors.centerIn: parent
            columns: 3
            spacing: Style.space(4)

            Repeater {
              model: 9

              Rectangle {
                required property int index
                readonly property real pulse: root.running && !Style.reduceMotion
                  ? 0.3 + 0.7 * Math.pow(Math.max(0, Math.sin(root.turn * Math.PI * 4 - index * 0.65)), 2)
                  : (root.running ? (index === 4 ? 0.95 : 0.55) : 0.25)

                width: Style.space(9)
                height: width
                color: Util.alpha(root.live, pulse)
              }
            }
          }
        }
      }
    }

    // Subtle offline / private lock cue under the processor.
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      spacing: Style.space(5)
      opacity: root.running ? 0.82 : 0.4

      Text {
        textFormat: Text.PlainText
        text: "\uf023"
        color: root.live
        font.family: Style.font.menuFamily
        font.pixelSize: Style.space(11)
        anchors.verticalCenter: parent.verticalCenter
      }

      Rectangle {
        width: Style.space(26)
        height: Style.space(3)
        anchors.verticalCenter: parent.verticalCenter
        color: Util.alpha(root.foreground, 0.34)
      }
    }
  }

  // Dual local bus traces between processor and output window.
  Repeater {
    model: [-Style.space(8), Style.space(8)]

    Rectangle {
      required property real modelData
      x: chipGroup.x + chipGroup.width + Style.space(6)
      y: chipGroup.y + chip.height / 2 + modelData
      width: Math.max(Style.space(20), reply.x - x - Style.space(8))
      height: Style.spacing.hairline
      color: root.running ? Util.alpha(root.accent, 0.24) : Util.alpha(root.foreground, 0.14)
      Behavior on color { ColorAnimation { duration: Style.duration(160) } }
    }
  }

  // Tokens streaming along the dual traces from the die to the local window.
  Repeater {
    model: 6

    Rectangle {
      required property int index
      readonly property real along: (root.turn * 2 + index / 6) % 1
      readonly property real lane: (index % 2 === 0 ? -1 : 1) * Style.space(8)
      readonly property real startX: chipGroup.x + chipGroup.width + Style.space(6)
      readonly property real span: Math.max(Style.space(20), reply.x - startX - Style.space(12))

      visible: root.running && !Style.reduceMotion
      width: Style.space(5)
      height: width
      radius: Style.cornerRadius > 0 ? width / 2 : 0
      x: startX + along * span
      y: chipGroup.y + chip.height / 2 + lane - height / 2
      color: root.accent
      opacity: Math.sin(Math.PI * along)
    }
  }

  // Miniature local inference output window.
  Win {
    id: reply
    width: parent.width * 0.48
    height: parent.height * 0.8
    anchors.right: parent.right
    anchors.rightMargin: root.gap
    anchors.verticalCenter: parent.verticalCenter
    active: root.running
    lines: false
    foreground: root.foreground
    accent: root.accent

    // Window header with local inference status strip.
    Item {
      id: replyHead
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: Style.space(22)

      Rectangle {
        anchors.fill: parent
        color: Util.alpha(root.running ? root.accent : root.foreground, root.running ? 0.08 : 0.03)
      }

      Row {
        anchors.left: parent.left
        anchors.leftMargin: Style.space(10)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(5)

        Rectangle {
          width: Style.space(6)
          height: width
          radius: width / 2
          color: root.live
          anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
          width: Style.space(44)
          height: Style.space(3.5)
          color: Util.alpha(root.foreground, root.running ? 0.45 : 0.2)
          anchors.verticalCenter: parent.verticalCenter
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

    Column {
      opacity: root.presence
      anchors.top: replyHead.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: Style.space(12)
      spacing: Style.space(7)

      Repeater {
        model: [
          { len: 0.78, accent: true },
          { len: 0.9, accent: false },
          { len: 0.62, accent: false },
          { len: 0.84, accent: false },
          { len: 0.52, accent: false },
          { len: 0.72, accent: false }
        ]

        Row {
          required property int index
          required property var modelData
          readonly property real progress: root.running ? Util.clamp((root.turn - index * 0.13) / 0.13, 0, 1) : 1
          width: parent.width
          spacing: Style.space(3)

          Rectangle {
            width: Math.max(0, (parent.width - Style.space(6)) * modelData.len * progress)
            height: Style.space(4)
            radius: Style.cornerRadius > 0 ? height / 2 : 0
            anchors.verticalCenter: parent.verticalCenter
            color: modelData.accent
              ? Util.alpha(root.running ? root.accent : root.foreground, root.running ? 0.68 : 0.2)
              : Util.alpha(root.foreground, root.running ? 0.32 : 0.14)
          }

          Rectangle {
            visible: root.running && progress > 0.05 && progress < 1
            width: Style.space(2)
            height: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            color: root.accent
          }
        }
      }
    }
  }
}
