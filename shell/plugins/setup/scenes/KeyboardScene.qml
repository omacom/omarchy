import QtQuick
import qs.Commons
import qs.Commons as Commons

// A keyboard and what it reaches. For keybindings a chord is held and a window
// opens; for layouts the legends on the keys change; for input methods the
// keys typed come out in another script.
Desk {
  id: root

  // The row under the cursor, as SetupModel.optionFor describes it.
  property var option: null

  // The last part of the row's id: keybindings, inputs or input-methods.
  readonly property string verb: option ? String(option.id).replace(/^.*\./, "") : ""
  readonly property bool binding: verb === "keybindings"
  readonly property bool layouts: verb === "inputs"
  readonly property bool methods: verb === "input-methods"

  // One hotkey: held, the window it opens, and let go.
  property real turn: Style.reduceMotion ? 0.3 : 0
  readonly property bool held: binding && turn > 0.1 && turn < 0.42
  readonly property bool opened: binding && turn > 0.2 && turn < 0.9
  // Which layout or script is showing.
  property int beat: 0

  // The top row of three layouts, and the codes they go by.
  readonly property var legends: ["QWERTY", "QWERTZ", "AZERTY"]
  readonly property var codes: ["us", "de", "fr"]
  // A syllable each of Japanese, Korean and Chinese.
  readonly property var scripts: ["\u{3042}", "\u{d55c}", "\u{4e2d}"]

  readonly property real key: Util.clamp(root.stage.height * 0.1, Style.space(11), Style.space(22))
  readonly property real pitch: key + Style.space(3)

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(2600)
    loops: Animation.Infinite
    running: root.visible && root.binding && !Style.reduceMotion
  }

  Timer {
    interval: 1300
    repeat: true
    running: root.visible && (root.layouts || root.methods) && !Style.reduceMotion
    onTriggered: root.beat = (root.beat + 1) % 3
  }

  Win {
    id: screen
    width: parent.width * 0.4
    height: board.y - y - Style.space(10)
    x: (parent.width - width) / 2
    y: root.gap / 2
    opacity: root.binding && !root.opened ? 0 : 1
    scale: root.binding && !root.opened ? 0.97 : 1
    active: true
    lines: root.binding
    foreground: root.foreground
    accent: root.accent

    Behavior on opacity { NumberAnimation { duration: Style.duration(root.opened ? 180 : 120); easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: Style.duration(root.opened ? 180 : 120); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }

    // The layout in use, by its code.
    Rectangle {
      visible: root.layouts
      anchors.centerIn: parent
      width: code.implicitWidth + Style.space(22)
      height: code.implicitHeight + Style.space(10)
      color: Util.alpha(root.accent, 0.3)
      radius: Style.cornerRadius
      border.width: Style.spacing.hairline
      border.color: root.accent

      Text {
        id: code
        textFormat: Text.PlainText
        text: root.codes[root.beat]
        color: root.foreground
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.body
        font.bold: true
        anchors.centerIn: parent
      }
    }

    // What the input method makes of the keys.
    Text {
      visible: root.methods
      textFormat: Text.PlainText
      text: root.scripts[root.beat]
      color: root.foreground
      font.family: Style.font.menuFamily
      font.pixelSize: Math.min(Style.space(46), screen.height * 0.5)
      anchors.centerIn: parent
    }
  }

  Column {
    id: board
    anchors.horizontalCenter: parent.horizontalCenter
    y: parent.height - height - root.gap / 2
    spacing: Style.space(3)

    Row {
      spacing: Style.space(3)

      Repeater {
        model: 10

        Keycap {
          required property int index
          width: root.key
          height: root.key
          legend: root.layouts && index < 6 ? root.legends[root.beat].charAt(index) : ""
          held: root.methods && index === 2 + root.beat * 2
          foreground: root.foreground
          accent: root.accent
        }
      }
    }

    Row {
      x: root.pitch / 2
      spacing: Style.space(3)

      Repeater {
        model: 9

        Keycap {
          required property int index
          width: root.key
          height: root.key
          held: root.held && index === 4
          foreground: root.foreground
          accent: root.accent
        }
      }
    }

    Row {
      spacing: Style.space(3)

      Repeater {
        // The bottom row: a key's width in keys, the space bar the widest.
        model: [1.5, 1.5, 4, 1.5, 1.5]

        Keycap {
          required property int index
          required property real modelData
          width: root.pitch * modelData - Style.space(3)
          height: root.key
          // Super, second from the left.
          held: root.held && index === 1
          foreground: root.foreground
          accent: root.accent
        }
      }
    }
  }
}
