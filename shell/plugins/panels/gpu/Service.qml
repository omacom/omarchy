import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property var manifest: null
  property string label: ""

  readonly property string widgetId: manifest?.id ?? "omarchy.gpu"
  readonly property bool inBar: shell?.pluginRegistry?.inBar(widgetId) ?? false

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
    running: root.inBar
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
