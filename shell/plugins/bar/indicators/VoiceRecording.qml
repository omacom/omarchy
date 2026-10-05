import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool recording: false

  active: recording
  activeText: "󰍰"
  inactiveText: "󰍰"
  activeTooltipText: "Stop voice recording"
  inactiveTooltipText: "Voice Recording"

  function refresh() {
    if (!root.bar || statusProc.running) return
    statusProc.command = ["pgrep", "--quiet", "-f", "^omarchy-voicerecorder "]
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
      root.bar.run(root.recording ? "omarchy-capture-voicerecording --stop-recording" : "omarchy-capture-voicerecording")
    }
  }
}
