import QtQuick
import qs.Commons
import qs.Commons as Commons

// For a resolver, a name going out from this machine and its address coming
// back from whoever the row under the cursor names. For the Wi-Fi code, the
// code itself and a phone taking it in.
Desk {
  id: root

  // The row under the cursor, as SetupModel.optionFor describes it.
  property var option: null

  // The Wi-Fi code is the one row here that is not a resolver.
  readonly property bool code: !!option && /\.qr$/.test(String(option.id))
  // One lookup: the name out, the address back, and a moment to read it.
  property real turn: Style.reduceMotion ? 0.8 : 0
  readonly property real out: Util.clamp((turn - 0.08) / 0.24, 0, 1)
  readonly property real back: Util.clamp((turn - 0.4) / 0.24, 0, 1)
  readonly property bool answered: turn > 0.64 && turn < 0.95

  // Which squares of the code are filled: its three corner marks, and enough
  // of the rest to look like one.
  function filled(index) {
    var column = index % 9
    var row = Math.floor(index / 9)
    var inCorner = (column < 3 && row < 3) || (column > 5 && row < 3) || (column < 3 && row > 5)
    if (inCorner) return !((column % 6 === 1 || column === 7) && (row % 6 === 1 || row === 7))
    return (index * 7 + row * 3) % 5 < 2
  }

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(3400)
    loops: Animation.Infinite
    running: root.visible && !Style.reduceMotion
  }

  // ----------------------------------------------------------- a resolver

  Item {
    anchors.fill: parent
    visible: !root.code

    Tile {
      id: machine
      x: parent.width * 0.2 - width / 2
      y: (parent.height - height) / 2
      glyph: "\u{f109}"
      lit: root.answered
      foreground: root.foreground
      accent: root.accent
    }

    Tile {
      id: resolver
      x: parent.width * 0.8 - width / 2
      y: (parent.height - height) / 2
      glyph: root.option ? root.option.icon : ""
      glyphFont: root.option ? root.option.iconFont : ""
      lit: root.out >= 1 && root.back < 1
      foreground: root.foreground
      accent: root.accent
    }

    // The question on its way, then the answer.
    Way {
      id: wire
      x: machine.x + machine.width + Style.space(8)
      y: (parent.height - height) / 2
      width: resolver.x - x - Style.space(8)
      along: root.out < 1 ? root.out : 1 - root.back
      foreground: root.foreground
      accent: root.accent
    }

    // A name asked for, and the address it turns out to have.
    Column {
      anchors.horizontalCenter: wire.horizontalCenter
      anchors.bottom: wire.top
      anchors.bottomMargin: Style.space(10)
      spacing: Style.space(4)

      Text {
        textFormat: Text.PlainText
        text: "omarchy.org"
        color: Util.alpha(root.foreground, 0.7)
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.bodySmall
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        textFormat: Text.PlainText
        text: "203.0.113.7"
        color: root.foreground
        opacity: root.answered ? 1 : 0
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.bodySmall
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity { NumberAnimation { duration: Style.duration(root.answered ? 180 : 120); easing.type: Easing.OutCubic } }
      }
    }
  }

  // ----------------------------------------------------------- the Wi-Fi code

  Item {
    anchors.fill: parent
    visible: root.code

    Rectangle {
      id: card
      width: Math.min(parent.height * 0.78, parent.width * 0.3)
      height: width
      x: parent.width * 0.4 - width / 2
      y: (parent.height - height) / 2
      color: Commons.Color.menu.background
      radius: Style.cornerRadius
      border.width: Style.spacing.hairline
      border.color: Util.alpha(root.foreground, 0.3)

      Grid {
        id: squares
        readonly property real cell: Math.floor((card.width - Style.space(20)) / 9)

        anchors.centerIn: parent
        columns: 9

        Repeater {
          model: 81

          Rectangle {
            required property int index
            width: squares.cell
            height: squares.cell
            color: root.filled(index) ? root.foreground : "transparent"
          }
        }
      }

      // The line a camera draws down a code as it reads it.
      Rectangle {
        visible: !Style.reduceMotion
        width: parent.width - Style.space(8)
        height: Math.max(1, Style.space(2))
        x: Style.space(4)
        y: Style.space(4) + (parent.height - Style.space(8) - height) * (0.5 - 0.5 * Math.cos(root.turn * Math.PI * 2))
        color: root.accent
      }
    }

    Tile {
      x: card.x + card.width + parent.width * 0.1
      y: (parent.height - height) / 2
      glyph: "\u{f10b}"
      lit: true
      foreground: root.foreground
      accent: root.accent
    }
  }
}
