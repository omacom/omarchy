pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Connected Ethernet can be a management-only link rather than the Internet
// route. Share one route listener/read across every monitor's network widget.
Singleton {
  id: root

  property string kind: ""
  property bool readPending: false

  function refresh() {
    if (reader.running) {
      readPending = true
      return
    }
    readPending = false
    reader.running = true
  }

  function update(raw) {
    // A route changed during the read: discard it and read the latest state.
    if (readPending || !events.running) return
    var value = String(raw || "").split("\t")[0]
    kind = value === "wifi" || value === "ethernet" ? value : ""
  }

  Process {
    id: reader
    command: ["omarchy-network-status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.update(text)
    }
    onExited: if (root.readPending) Qt.callLater(root.refresh)
  }

  Process {
    id: events
    // The status helper resolves an IPv4 Internet probe. IPv6 RA lifetime
    // updates do not change that lookup and must not wake the reader.
    command: ["ip", "-4", "monitor", "route", "rule"]
    running: true
    stdout: SplitParser {
      onRead: root.refresh()
    }
    // Fall back to native connection state if monitoring becomes unavailable.
    onExited: root.kind = ""
  }

  Component.onCompleted: refresh()
}
