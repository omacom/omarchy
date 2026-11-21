import QtQuick

Timer {
  id: root

  required property bool deviceReady
  property bool checksReady: false

  interval: 5000
  running: deviceReady && !checksReady
  repeat: false
  onTriggered: checksReady = true
}
