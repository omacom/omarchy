import QtQuick
import qs.Commons
import qs.Commons as Commons

// A key on a scene's keyboard or Ready shortcut strip: crisp cap, subtle
// bottom key depth, and accent illumination while held.
Rectangle {
  id: root

  property string legend: ""
  property bool held: false

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  implicitWidth: Math.max(implicitHeight, name.implicitWidth + Style.space(12))
  implicitHeight: Style.space(22)
  radius: Style.cornerRadius
  color: held ? Util.alpha(accent, 0.3) : Util.alpha(foreground, 0.08)
  border.width: Style.spacing.hairline
  border.color: held ? accent : Util.alpha(foreground, 0.34)

  Behavior on color { ColorAnimation { duration: Style.duration(120) } }
  Behavior on border.color { ColorAnimation { duration: Style.duration(120) } }

  // Subtle bottom lip for physical keycap presence.
  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: Style.spacing.hairline
    height: Math.max(1, Style.space(1.5))
    color: root.held ? Util.alpha(root.accent, 0.5) : Util.alpha(root.foreground, 0.14)
  }

  Text {
    id: name
    textFormat: Text.PlainText
    text: root.legend
    color: Util.alpha(root.foreground, root.held ? 1 : 0.86)
    font.family: Style.font.menuFamily
    font.pixelSize: Math.min(Style.font.caption, root.height * 0.56)
    anchors.centerIn: parent
  }
}
