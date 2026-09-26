import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.camera"

  property bool present: false
  property bool disabled: false
  property bool inUse: false
  property var apps: []

  readonly property string appNames: apps.join(", ")

  visible: present
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function update(line) {
    try {
      var state = JSON.parse(line)
      present = state.present === true
      disabled = state.disabled === true
      inUse = state.inUse === true
      apps = Array.isArray(state.apps) ? state.apps : []
    } catch (e) {}
  }

  Process {
    id: statusProc
    command: ["omarchy-camera-status", "--watch"]
    running: true
    stdout: SplitParser {
      onRead: function(line) { root.update(line) }
    }
    onExited: restartTimer.start()
  }

  Timer {
    id: restartTimer
    interval: 5000
    onTriggered: statusProc.running = true
  }

  // A toggle reaches the watcher only through driver bind and unbind events,
  // and a camera with no driver bound sends none.
  Process {
    id: toggleProc
    command: ["omarchy-toggle-camera"]
    onExited: refreshProc.running = true
  }

  Process {
    id: refreshProc
    command: ["omarchy-camera-status"]
    stdout: SplitParser {
      onRead: function(line) { root.update(line) }
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.disabled ? "󱜷" : "󰖠"
    active: root.inUse && !root.disabled
    tooltipText: root.disabled ? "Camera disabled" : (root.inUse ? "Camera in use by " + root.appNames : "Camera ready")
    onPressed: if (!toggleProc.running) toggleProc.running = true
  }
}
