import QtQuick
import qs.Commons
import qs.Commons as Commons

// A model on this machine: the chip it runs on, and its answer crossing to the
// agent's window without leaving the screen.
Desk {
  id: root

  // Whether the model under the cursor would be set up, or left for later.
  property bool running: true

  property real turn: Style.reduceMotion ? 0.8 : 0
  readonly property color live: running ? accent : Util.alpha(foreground, 0.35)

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(3600)
    loops: Animation.Infinite
    running: root.visible && root.running && !Style.reduceMotion
  }

  Item {
    id: chip
    width: Style.space(62)
    height: width
    x: parent.width * 0.14 - width / 2
    y: parent.height * 0.5 - height / 2

    // The pins along each edge.
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
        color: Util.alpha(root.live, 0.6)
      }
    }

    Rectangle {
      anchors.fill: parent
      color: Commons.Color.menu.background
      radius: Style.cornerRadius
      border.width: Style.spacing.hairline
      border.color: root.live
    }

    Text {
      textFormat: Text.PlainText
      text: "\u{f035b}"
      color: root.live
      font.family: Style.font.menuFamily
      font.pixelSize: Style.space(26)
      anchors.centerIn: parent
    }
  }

  // Tokens on their way from the chip to the window.
  Repeater {
    model: 6

    Rectangle {
      required property int index
      readonly property real along: (root.turn * 2 + index / 6) % 1

      visible: root.running
      width: Style.space(5)
      height: width
      x: chip.x + chip.width + Style.space(14) + along * (reply.x - chip.x - chip.width - Style.space(32))
      y: chip.y + chip.height / 2 - height / 2
      color: root.accent
      opacity: Math.sin(Math.PI * along)
    }
  }

  Win {
    id: reply
    width: parent.width * 0.42
    height: parent.height * 0.78
    anchors.right: parent.right
    anchors.rightMargin: root.gap / 2
    anchors.verticalCenter: parent.verticalCenter
    active: root.running
    lines: false
    foreground: root.foreground
    accent: root.accent

    Column {
      anchors.fill: parent
      anchors.margins: Style.space(12)
      spacing: Style.space(7)

      Repeater {
        model: [0.86, 0.64, 0.92, 0.5, 0.74]

        Rectangle {
          required property int index
          required property real modelData
          width: parent.width * modelData * (root.running ? Util.clamp((root.turn - index * 0.16) / 0.16, 0, 1) : 0)
          height: Style.space(4)
          color: Util.alpha(root.foreground, 0.26)
        }
      }
    }
  }
}
