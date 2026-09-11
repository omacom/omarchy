import QtQuick
import QtQuick.Layouts
import qs.Commons

ColumnLayout {
  id: root

  property string label: ""
  property string valueLabel: ""
  property real value: 0
  property color gaugeColor: Color.accent

  spacing: 4

  RowLayout {
    Layout.fillWidth: true

    Text {
      Layout.fillWidth: true
      text: root.label
      textFormat: Text.PlainText
      color: Color.muted
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.letterSpacing: 1
    }

    Text {
      text: root.valueLabel
      textFormat: Text.PlainText
      color: Color.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }

  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 3
    radius: 2
    color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.1)

    Rectangle {
      width: parent.width * Math.max(0, Math.min(1, root.value))
      height: parent.height
      radius: parent.radius
      color: root.gaugeColor
    }
  }
}
