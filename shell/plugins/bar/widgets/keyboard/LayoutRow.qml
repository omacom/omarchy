import QtQuick
import qs.Ui as Ui
import qs.Commons

Ui.Button {
  id: root
  property string title: ""
  property string subtitle: ""
  property string suffix: ""
  property bool marked: false
  focusable: true
  foreground: Color.popups.text
  implicitHeight: Math.max(Style.spacing.controlHeight, lines.implicitHeight + Style.spacing.controlPaddingY * 2)
  Accessible.role: Accessible.Button
  Accessible.name: title + (subtitle ? ", " + subtitle : "") + (marked ? ", active" : "")
  Column {
    id: lines
    anchors.left: parent.left
    anchors.right: trailing.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: root.horizontalPadding
    anchors.rightMargin: Style.spacing.controlGap
    Text {
      width: parent.width
      text: root.title
      textFormat: Text.PlainText
      elide: Text.ElideRight
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      color: root.foreground
    }
    Text {
      width: parent.width
      visible: root.subtitle !== ""
      text: root.subtitle
      textFormat: Text.PlainText
      elide: Text.ElideRight
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      color: root.foreground
      opacity: 0.65
    }
  }
  Text {
    id: trailing
    anchors.right: parent.right
    anchors.rightMargin: root.horizontalPadding
    anchors.verticalCenter: parent.verticalCenter
    text: root.marked ? "✓" : root.suffix
    textFormat: Text.PlainText
    font.family: Style.font.family
    font.pixelSize: Style.font.body
    color: root.foreground
  }
}
