import QtQuick
import qs.Commons
import "FontSyntax.js" as FontSyntax

Item {
  id: root

  required property string text
  required property string previousText
  required property real progress
  required property string fontFamily
  required property real pointSize
  required property color color
  property var syntaxColors: ({})
  property bool syntaxEnabled: false
  property bool previousSyntaxEnabled: false

  implicitHeight: incoming.implicitHeight
  clip: true

  Text {
    width: parent.width
    text: FontSyntax.highlight(root.previousText, root.previousSyntaxEnabled, root.syntaxColors)
    textFormat: Text.StyledText
    font: incoming.font
    color: root.color
    opacity: 1 - root.progress
    x: -Style.space(16) * root.progress
    elide: Text.ElideRight
  }

  Text {
    id: incoming
    width: parent.width
    text: FontSyntax.highlight(root.text, root.syntaxEnabled, root.syntaxColors)
    textFormat: Text.StyledText
    font.family: root.fontFamily
    font.pointSize: root.pointSize
    color: root.color
    opacity: root.progress
    x: Style.space(16) * (1 - root.progress)
    elide: Text.ElideRight
  }
}
