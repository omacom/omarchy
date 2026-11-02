import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool recording: false
  // A refresh asked for while a check is still running, such as the one a
  // starting recording sends, must not be dropped: that check may predate it
  property bool refreshPending: false

  active: recording
  activeText: "󰍰"
  inactiveText: "󰍰"
  activeTooltipText: "Stop voice recording"
  inactiveTooltipText: "Voice Recording"

  function refresh() {
    if (!root.bar) return
    if (statusProc.running) {
      root.refreshPending = true
      return
    }
    statusProc.running = true
  }

  onBarChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  // Only this user's recorder, which runs as ffmpeg renamed to
  // omarchy-voicerecorder
  Process {
    id: statusProc
    command: ["bash", "-c", "pgrep --quiet -u \"$UID\" -f '^omarchy-voicerecorder '"]
    onExited: function(exitCode) {
      root.recording = exitCode === 0
      if (root.refreshPending) {
        root.refreshPending = false
        Qt.callLater(root.refresh)
      }
    }
  }

  // Catches a recorder that exits on its own, such as when the microphone goes
  // away, instead of showing a recording that is no longer running.
  Timer {
    interval: 5000
    running: root.recording
    repeat: true
    onTriggered: root.refresh()
  }

  onPressed: function() {
    if (root.bar) {
      root.bar.run(root.recording ? "omarchy-capture-voicerecording --stop-recording" : "omarchy-capture-voicerecording")
    }
  }
}
