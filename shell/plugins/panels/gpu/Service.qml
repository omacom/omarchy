import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var shell: null
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

  // nvidia-smi and rocm-smi have no change signal, so one shared service polls.
  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
