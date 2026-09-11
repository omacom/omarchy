import QtQuick
import qs.Commons

Item {
  id: root
  property var bar
  property var settings
  property string clock: Qt.formatTime(new Date(), "HH:mm:ss")
  implicitWidth: label.implicitWidth + 12
  implicitHeight: 26
  Text {
    id: label
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: "YOLO · " + root.clock
    color: Color.foreground
    font.family: Style.font.family
    font.pixelSize: Style.font.body
    font.features: { "tnum": 1 }
  }
  Timer { interval: 1000; running: true; repeat: true; onTriggered: root.clock = Qt.formatTime(new Date(), "HH:mm:ss") }
}
