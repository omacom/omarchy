import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property string label: ""

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  Process {
    id: statusProc
    command: ["omarchy-ml-gpu-status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.label = text.trim()
    }
    onExited: function(code) {
      if (code !== 0) root.label = ""
    }
  }

  // nvidia-smi and rocm-smi have no change signal. One service polls for
  // every monitor instead of each bar widget starting its own probe.
  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
