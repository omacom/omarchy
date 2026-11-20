import QtQuick
import qs.Commons
import qs.Commons as Commons

// A thing on a scene that is not a window: a machine, a key, a service, a
// file. Its mark, in a box that lights while it has something to do.
Rectangle {
  id: root

  property string glyph: ""
  property string glyphFont: ""
  property bool lit: false

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  width: Style.space(58)
  height: Style.space(46)
  color: Commons.Color.menu.background
  radius: Style.cornerRadius
  border.width: Style.spacing.hairline
  border.color: lit ? accent : Util.alpha(foreground, 0.3)

  Behavior on border.color { ColorAnimation { duration: Style.duration(160) } }

  Text {
    textFormat: Text.PlainText
    text: root.glyph
    color: Util.alpha(root.foreground, root.lit ? 1 : 0.6)
    font.family: root.glyphFont !== "" ? root.glyphFont : Style.font.menuFamily
    font.pixelSize: Math.min(Style.space(22), root.height * 0.5)
    anchors.centerIn: parent
  }
}
