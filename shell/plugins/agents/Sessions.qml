import QtQuick
import Quickshell.Io

// Independent of usage refresh: this only reads small, local session records.
Item {
  id: root
  visible: false
  property var sessions: []
  property double scannedAt: 0
  property bool available: false

  onEnabledChanged: {
    sessions = []
    scannedAt = 0
    available = false
    if (!enabled) scan.running = false
    else if (!scan.running) scan.running = true
  }

  Timer {
    interval: 5000
    repeat: true
    running: root.enabled
    triggeredOnStart: true
    onTriggered: if (!scan.running) scan.running = true
  }

  Process {
    id: scan
    command: ["omarchy-agent-sessions"]
    stdout: StdioCollector {
      onStreamFinished: {
        if (!root.enabled) return
        try {
          var data = JSON.parse(text)
          root.sessions = Array.isArray(data.sessions) ? data.sessions : []
          root.available = data.available === true
          root.scannedAt = Date.now()
        } catch (e) {
          root.sessions = []
          root.available = false
          root.scannedAt = 0
        }
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.sessions = []
        root.available = false
        root.scannedAt = 0
      }
    }
  }
}
