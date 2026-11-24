import QtQuick
import qs.Commons
import qs.Commons as Commons

// An agent at work in a window of its own: the keys that summon it, its mark,
// a prompt typed to it and the answer arriving. The mark is that of the
// option being shown, and where that adds no agent the window sits empty.
Desk {
  id: root

  property var option: null
  // One exchange, from the keys going down to the finished answer.
  property real turn: Style.reduceMotion ? 0.9 : 0

  readonly property bool picked: !!option && option.id !== ""
  // Out with the last of one exchange, so the next doesn't cut in.
  readonly property real presence: 1 - Util.clamp((turn - 0.93) / 0.07, 0, 1)
  // The hotkey, as the keybindings list names its keys in every language.
  readonly property var chord: ["Super", "Shift", "Ctrl", "A"]
  readonly property bool chordHeld: picked && !Style.reduceMotion && turn < 0.1

  function stretch(from, length) {
    return picked ? Util.clamp((turn - from) / length, 0, 1) : 0
  }

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(4400)
    loops: Animation.Infinite
    running: root.visible && root.picked && !Style.reduceMotion
  }

  Row {
    id: keys
    x: (terminal.x - width) / 2
    anchors.verticalCenter: parent.verticalCenter
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

  Win {
    id: terminal
    width: parent.width * 0.52
    height: parent.height * 0.8
    x: parent.width - width - parent.width * 0.05
    anchors.verticalCenter: parent.verticalCenter
    active: root.picked
    lines: false
    foreground: root.foreground
    accent: root.accent

    Text {
      id: mark
      textFormat: Text.PlainText
      text: root.picked && root.option.icon !== "" ? root.option.icon : "\u{f06a9}"
      color: Util.alpha(root.foreground, root.picked ? 1 : 0.4)
      font.family: root.picked && root.option.iconFont !== "" ? root.option.iconFont : Style.font.menuFamily
      font.pixelSize: Math.min(Style.space(44), parent.height * 0.42)
      horizontalAlignment: Text.AlignHCenter
      width: parent.width * 0.3
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
    }

    Column {
      opacity: root.presence
      anchors.left: mark.right
      anchors.right: parent.right
      anchors.rightMargin: Style.space(14)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(7)

      // What was asked, typed out.
      Rectangle {
        width: parent.width * 0.62 * root.stretch(0.12, 0.18)
        height: Style.space(4)
        color: Util.alpha(root.accent, 0.85)
      }

      Item { width: 1; height: Style.space(2) }

      // What came back, a line at a time.
      Repeater {
        model: [0.92, 0.7, 0.84, 0.46]

        Rectangle {
          required property int index
          required property real modelData
          width: parent.width * modelData * root.stretch(0.36 + index * 0.12, 0.12)
          height: Style.space(4)
          color: Util.alpha(root.foreground, 0.26)
        }
      }
    }
  }
}
