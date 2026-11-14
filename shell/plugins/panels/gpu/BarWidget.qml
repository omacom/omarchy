import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.gpu"

  property string label: ""

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  visible: label !== ""
  implicitWidth: visible ? row.implicitWidth + Style.space(10) : 0
  implicitHeight: barSize

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

  // nvidia-smi and rocm-smi have no change signal, so the bar polls.
  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(4)
    visible: root.label !== ""

    Text {
      text: "\uf2db"
      textFormat: Text.PlainText
      font.family: root.bar ? root.bar.fontFamily : ""
      font.pixelSize: Style.font.body
      color: root.bar ? root.bar.barForeground : "white"
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: root.label
      textFormat: Text.PlainText
      font.family: root.bar ? root.bar.fontFamily : ""
      font.pixelSize: Style.font.body
      color: root.bar ? root.bar.barForeground : "white"
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  TapHandler {
    onTapped: {
      if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation 'nvtop || btop'")
    }
  }
}
