import QtQuick
import qs.Commons

Item {
  property var bar
  property var settings
  implicitWidth: 32
  implicitHeight: 26
  Text {
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: "!"
    color: Color.urgent
    font.bold: true
    font.pixelSize: 20
  }
  MouseArea {
    anchors.fill: parent
    onClicked: bar.shell.toggle("demo.ward-hostile", "{}")
  }
}
