import QtQuick
import qs.Commons
import qs.Commons as Commons

// A prompt for a password that is never typed: what the row under the cursor
// sets up answers it instead, and the lock opens. For SSHD the answer comes
// from another machine, which is who that row lets in.
Desk {
  id: root

  // The row under the cursor, as SetupModel.optionFor describes it.
  property var option: null

  readonly property bool remote: !!option && /\.sshd$/.test(String(option.id))
  // One approval: the key is shown, its word crosses, the lock opens and holds.
  property real turn: Style.reduceMotion ? 0.7 : 0
  readonly property bool shown: turn > 0.12
  readonly property real crossing: Util.clamp((turn - 0.2) / 0.25, 0, 1)
  readonly property bool opened: turn > 0.45 && turn < 0.94

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(3800)
    loops: Animation.Infinite
    running: root.visible && !Style.reduceMotion
  }

  Tile {
    id: key
    x: parent.width * 0.22 - width / 2
    y: (parent.height - height) / 2
    glyph: root.remote ? "\u{f109}" : root.option ? root.option.icon : ""
    glyphFont: root.remote || !root.option ? "" : root.option.iconFont
    lit: root.shown
    foreground: root.foreground
    accent: root.accent
  }

  Way {
    x: key.x + key.width + Style.space(8)
    y: (parent.height - height) / 2
    width: prompt.x - x - Style.space(8)
    along: root.crossing
    foreground: root.foreground
    accent: root.accent
  }

  Win {
    id: prompt
    width: parent.width * 0.36
    height: parent.height * 0.74
    x: parent.width * 0.7 - width / 2
    y: (parent.height - height) / 2
    active: root.opened
    lines: false
    foreground: root.foreground
    accent: root.accent

    Column {
      anchors.centerIn: parent
      width: parent.width - Style.space(28)
      spacing: Math.min(Style.space(14), parent.height * 0.12)

      Text {
        textFormat: Text.PlainText
        text: root.opened ? "\u{f09c}" : "\u{f023}"
        color: root.opened ? root.accent : Util.alpha(root.foreground, 0.6)
        font.family: Style.font.menuFamily
        font.pixelSize: Math.min(Style.space(34), prompt.height * 0.3)
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }

      // Where the password would go, left empty.
      Rectangle {
        width: parent.width
        height: Style.space(20)
        color: Util.alpha(root.foreground, 0.05)
        radius: Style.cornerRadius
        border.width: Style.spacing.hairline
        border.color: Util.alpha(root.foreground, 0.3)

        Text {
          visible: root.opened
          textFormat: Text.PlainText
          text: "\u{f00c}"
          color: root.accent
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.caption
          anchors.centerIn: parent
        }
      }
    }
  }
}
