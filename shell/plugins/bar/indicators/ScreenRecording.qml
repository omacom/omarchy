import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool recording: false

  active: recording
  activeText: "󰻂"
  inactiveText: "󰻂"
  activeTooltipText: "Stop recording"
  inactiveTooltipText: "Screen Recording"

  function refresh() {
    if (!root.bar || statusProc.running) return
    statusProc.command = ["omarchy-capture-screenrecording", "--status"]
    statusProc.running = true
  }

  onBarChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  Process {
    id: statusProc
    onExited: function(exitCode) {
      root.recording = exitCode === 0
    }
  }

  onPressed: function() {
    if (root.bar) {
      root.bar.run(root.recording ? "omarchy-capture-screenrecording --stop-recording" : "omarchy-menu toggle trigger.capture.screenrecord")
    }
  }
}
