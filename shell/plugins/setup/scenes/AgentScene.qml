import QtQuick
import qs.Commons
import qs.Commons as Commons

// The Omarchy Agents panel at work: the shortcut chord summons the panel, a
// prompt is sent, and the coding agent streams an answer with a miniature
// code diff and live cursor.
Desk {
  id: root

  property var option: null
  property real turn: Style.reduceMotion ? 0.85 : 0

  readonly property bool picked: !!option && option.id !== ""
  readonly property real presence: picked ? 1 - Util.clamp((turn - 0.91) / 0.09, 0, 1) : 1
  readonly property var chord: ["Super", "Shift", "Ctrl", "A"]
  readonly property bool chordHeld: picked && !Style.reduceMotion && turn < 0.22

  function stretch(from, length) {
    return picked ? Util.clamp((turn - from) / length, 0, 1) : 1
  }

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(4600)
    loops: Animation.Infinite
    running: root.visible && root.picked && !Style.reduceMotion
  }

  // Hotkey chord on the left, visibly triggering the panel.
  Column {
    id: leftGroup
    x: (terminal.x - width) / 2
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(8)

    Row {
      id: keys
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: Style.space(4)

      Repeater {
        model: root.chord

        Keycap {
          required property string modelData
          legend: modelData
          held: root.chordHeld
          foreground: root.foreground
          accent: root.accent
        }
      }
    }
  }

  Way {
    x: leftGroup.x + leftGroup.width + Style.space(10)
    width: Math.max(Style.space(12), terminal.x - x - Style.space(8))
    anchors.verticalCenter: parent.verticalCenter
    along: root.picked && !Style.reduceMotion && root.turn < 0.34 ? Util.clamp(root.turn / 0.34, 0, 1) : 0
    active: root.chordHeld
    foreground: root.foreground
    accent: root.accent
  }

  // Miniature Omarchy Agents coding panel.
  Win {
    id: terminal
    width: parent.width * 0.56
    height: parent.height * 0.82
    x: parent.width - width - root.gap
    anchors.verticalCenter: parent.verticalCenter
    active: root.picked
    lines: false
    foreground: root.foreground
    accent: root.accent

    // Compact agent panel header bar.
    Item {
      id: panelHead
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: Style.space(26)

      Rectangle {
        anchors.fill: parent
        color: Util.alpha(root.picked ? root.accent : root.foreground, root.picked ? 0.08 : 0.03)
      }

      Row {
        anchors.left: parent.left
        anchors.leftMargin: Style.space(10)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(7)

        Text {
          textFormat: Text.PlainText
          text: root.picked && root.option.icon !== "" ? root.option.icon : "\u{f06a9}"
          color: root.picked ? root.accent : Util.alpha(root.foreground, 0.45)
          font.family: root.picked && root.option.iconFont !== "" ? root.option.iconFont : Style.font.menuFamily
          font.pixelSize: Style.space(15)
          anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
          width: Style.space(52)
          height: Style.space(4)
          radius: Style.cornerRadius > 0 ? height / 2 : 0
          color: Util.alpha(root.foreground, root.picked ? 0.5 : 0.2)
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      // Live working status indicator in header corner.
      Rectangle {
        width: Style.space(6)
        height: width
        radius: width / 2
        anchors.right: parent.right
        anchors.rightMargin: Style.space(10)
        anchors.verticalCenter: parent.verticalCenter
        color: root.picked ? root.accent : Util.alpha(root.foreground, 0.2)
        opacity: root.picked && !Style.reduceMotion ? 0.45 + 0.55 * Math.abs(Math.sin(root.turn * Math.PI * 6)) : 0.8
      }

      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Style.spacing.hairline
        color: Util.alpha(root.foreground, 0.12)
      }
    }

    // Session transcript + miniature code diff.
    Column {
      opacity: root.presence
      anchors.top: panelHead.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: Style.space(12)
      spacing: Style.space(8)

      // User prompt row (`>` chevron + typed prompt)
      Row {
        width: parent.width
        spacing: Style.space(6)

        Rectangle {
          width: Style.space(7)
          height: Style.space(4)
          anchors.verticalCenter: parent.verticalCenter
          color: root.picked ? root.accent : Util.alpha(root.foreground, 0.28)
        }

        Rectangle {
          width: (parent.width - Style.space(16)) * 0.62 * root.stretch(0.14, 0.16)
          height: Style.space(4)
          radius: Style.cornerRadius > 0 ? height / 2 : 0
          anchors.verticalCenter: parent.verticalCenter
          color: Util.alpha(root.foreground, root.picked ? 0.62 : 0.22)
        }
      }

      // Agent response summary lines
      Column {
        width: parent.width
        spacing: Style.space(5)

        Repeater {
          model: [0.88, 0.64]

          Rectangle {
            required property int index
            required property real modelData
            width: parent.width * modelData * root.stretch(0.24 + index * 0.08, 0.1)
            height: Style.space(3.5)
            radius: Style.cornerRadius > 0 ? height / 2 : 0
            color: Util.alpha(root.foreground, root.picked ? 0.36 : 0.16)
          }
        }
      }

      // Miniature code diff block produced by the agent
      Rectangle {
        width: parent.width
        height: Style.space(48)
        radius: Style.cornerRadius
        color: Util.alpha(root.foreground, root.picked ? 0.055 : 0.02)
        border.width: Style.spacing.hairline
        border.color: Util.alpha(root.picked ? root.accent : root.foreground, root.picked ? 0.36 : 0.12)
        opacity: root.picked ? Util.clamp((root.turn - 0.34) / 0.08, 0, 1) : 0.65

        Column {
          anchors.fill: parent
          anchors.margins: Style.space(7)
          spacing: Style.space(5)

          Repeater {
            model: [
              { kind: "ctx", len: 0.56 },
              { kind: "add", len: 0.78 },
              { kind: "add", len: 0.62 },
              { kind: "ctx", len: 0.42 }
            ]

            Row {
              required property int index
              required property var modelData
              readonly property real progress: root.stretch(0.36 + index * 0.065, 0.085)
              width: parent.width
              spacing: Style.space(5)

              Rectangle {
                width: Style.space(4)
                height: Style.space(3.5)
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.kind === "add"
                  ? Util.alpha(root.accent, root.picked ? 0.95 : 0.32)
                  : Util.alpha(root.foreground, 0.28)
                opacity: progress > 0 ? 1 : 0
              }

              Rectangle {
                width: (parent.width - Style.space(14)) * modelData.len * progress
                height: Style.space(3.5)
                radius: Style.cornerRadius > 0 ? height / 2 : 0
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.kind === "add"
                  ? Util.alpha(root.accent, root.picked ? 0.75 : 0.22)
                  : Util.alpha(root.foreground, 0.28)
              }

              Rectangle {
                visible: root.picked && index === 2 && progress > 0.1 && progress < 1
                width: Style.space(2)
                height: Style.space(7)
                anchors.verticalCenter: parent.verticalCenter
                color: root.accent
              }
            }
          }
        }
      }
    }
  }
}
