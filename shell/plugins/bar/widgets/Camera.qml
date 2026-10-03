import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.camera"

  // "absent", "idle", or "busy". The probe is the only presence signal:
  // Quickshell's Video/Source flag also matches a screen-share producer.
  property string cameraState: "absent"
  readonly property bool present: cameraState !== "absent"
  readonly property bool inUse: cameraState === "busy"

  visible: present
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function probePath() {
    var path = Qt.resolvedUrl("camera-busy.sh").toString()
    if (path.indexOf("file://") === 0)
      path = decodeURIComponent(path.substring(7))
    return path
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (busyProc.running) return
      busyProc.command = [root.probePath()]
      busyProc.running = true
    }
  }

  Process {
    id: busyProc
    stdout: StdioCollector {
      id: busyOut
      waitForEnd: true
    }
    onExited: function(code) {
      var state = String(busyOut.text || "").trim()
      if (state === "busy" || state === "idle" || state === "absent")
        root.cameraState = state
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.inUse ? "󰻂" : "󰄀"
    active: root.inUse
    tooltipText: root.inUse ? "Camera in use" : "Camera live"
  }
}
