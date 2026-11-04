import QtQuick
import qs.Commons

Item {
  id: root

  required property string text
  required property string previousText
  required property real progress
  required property string fontFamily
  required property real pointSize
  required property color color

  implicitHeight: incoming.implicitHeight
  clip: true

  Text {
    width: parent.width
    text: root.previousText
    textFormat: Text.PlainText
    font: incoming.font
    color: root.color
    opacity: 1 - root.progress
    x: -Style.space(16) * root.progress
    elide: Text.ElideRight
  }

  Text {
    id: incoming
    width: parent.width
    text: root.text
    textFormat: Text.PlainText
    font.family: root.fontFamily
    font.pointSize: root.pointSize
    color: root.color
    opacity: root.progress
    x: Style.space(16) * (1 - root.progress)
    elide: Text.ElideRight
  }
}
