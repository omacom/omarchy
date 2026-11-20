import QtQuick
import qs.Commons
import qs.Commons as Commons

// What a default app is the default for: a link, a prompt or a text file on
// the left, and the app under the cursor opening it.
Desk {
  id: root

  // The row under the cursor, as SetupModel.optionFor describes it.
  property var option: null

  // browser, terminal or editor: the submenu the row sits in.
  readonly property string kind: option ? String(option.id).split(".")[2] || "" : ""
  readonly property string opened: kind === "browser" ? "\u{f0c1}" : kind === "terminal" ? "\u{f120}" : kind === "editor" ? "\u{f15c}" : ""
  // A row under Defaults that is none of the three is shown as itself.
  readonly property bool known: opened !== ""

  // One opening: the thing is picked up, crosses, and the app has it.
  property real turn: Style.reduceMotion ? 0.7 : 0
  readonly property real crossing: Util.clamp((turn - 0.14) / 0.24, 0, 1)
  readonly property bool taken: !known || (turn > 0.38 && turn < 0.94)

  NumberAnimation on turn {
    from: 0
    to: 1
    duration: Style.duration(3400)
    loops: Animation.Infinite
    running: root.visible && root.known && !Style.reduceMotion
  }

  Tile {
    id: thing
    visible: root.known
    height: Math.min(Style.space(46), parent.height * 0.6)
    x: parent.width * 0.2 - width / 2
    y: (parent.height - height) / 2
    glyph: root.opened
    lit: root.turn > 0.06 && !root.taken
    foreground: root.foreground
    accent: root.accent
  }

  Way {
    visible: root.known
    x: thing.x + thing.width + Style.space(8)
    y: (parent.height - height) / 2
    width: app.x - x - Style.space(8)
    along: root.crossing
    foreground: root.foreground
    accent: root.accent
  }

  Win {
    id: app
    width: parent.width * 0.4
    height: parent.height * 0.78
    x: root.known ? parent.width * 0.68 - width / 2 : (parent.width - width) / 2
    y: (parent.height - height) / 2
    active: root.taken
    lines: false
    foreground: root.foreground
    accent: root.accent

    Column {
      anchors.centerIn: parent
      width: parent.width - Style.space(16)
      spacing: Math.min(Style.space(8), app.height * 0.06)

      Text {
        textFormat: Text.PlainText
        text: root.option ? root.option.icon : ""
        color: Util.alpha(root.foreground, root.taken ? 1 : 0.5)
        font.family: root.option && root.option.iconFont !== "" ? root.option.iconFont : Style.font.menuFamily
        font.pixelSize: Math.min(Style.space(40), app.height * 0.36)
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }

      Text {
        textFormat: Text.PlainText
        text: root.option ? root.option.label : ""
        color: Util.alpha(root.foreground, root.taken ? 1 : 0.5)
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.bodySmall
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }
    }
  }
}
