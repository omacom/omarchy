import QtQuick
import qs.Commons
import qs.Commons as Commons

// A key on a scene's keyboard: its cap, and its legend where it has one. Lit
// while it is held.
Rectangle {
  id: root

  property string legend: ""
  property bool held: false

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  implicitWidth: Math.max(implicitHeight, name.implicitWidth + Style.space(12))
  implicitHeight: Style.space(20)
  radius: Style.cornerRadius
  color: held ? Util.alpha(accent, 0.3) : Util.alpha(foreground, 0.05)
  border.width: Style.spacing.hairline
  border.color: held ? accent : Util.alpha(foreground, 0.3)

  Behavior on color { ColorAnimation { duration: Style.duration(120) } }

  Text {
    id: name
    textFormat: Text.PlainText
    text: root.legend
    color: Util.alpha(root.foreground, root.held ? 1 : 0.7)
    font.family: Style.font.menuFamily
    font.pixelSize: Math.min(Style.font.caption, root.height * 0.6)
    anchors.centerIn: parent
  }
}
