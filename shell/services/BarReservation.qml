import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  required property var bar
  required property bool supported
  required property bool contentReady
  readonly property bool configured: Quickshell.env("OMARCHY_BAR_SOCKET") !== ""
  readonly property bool managed: configured && socket.connected
  property bool acknowledged: false
  property bool startupExpired: false
  readonly property bool waiting: configured && (!acknowledged || !contentReady) && !startupExpired
  readonly property string snapshot: {
    if (!bar || (supported && !bar.hiddenStateKnown)) return JSON.stringify({ version: 1, loading: true })
    var screens = []
    if (supported) for (var i = 0; i < Quickshell.screens.length; i++) screens.push(Quickshell.screens[i].name)
    return JSON.stringify({ version: 1, screens: screens,
      position: supported ? bar.position : "top", size: supported ? bar.barSize : 0,
      hidden: !supported || bar.barHidden, ready: !supported || contentReady || startupExpired,
      background: supported ? String(Qt.rgba(bar.background.r, bar.background.g, bar.background.b, 1)) : "#202020",
      foreground: supported ? String(Qt.rgba(bar.foreground.r, bar.foreground.g, bar.foreground.b, 1)) : "#ffffff" })
  }
  onSnapshotChanged: publish()
  function publish() {
    if (socket.connected) { socket.write(snapshot + "\n"); socket.flush() }
  }
  Socket {
    id: socket
    path: Quickshell.env("OMARCHY_BAR_SOCKET")
    connected: root.configured
    onConnectedChanged: {
      root.acknowledged = false
      if (connected) root.publish()
    }
    parser: SplitParser {
      onRead: function(line) { if (line === "ok") root.acknowledged = true }
    }
  }
  Timer {
    interval: 2000
    running: root.configured
    onTriggered: root.startupExpired = true
  }
  Timer {
    interval: 1000
    running: root.configured && !socket.connected
    repeat: true
    onTriggered: socket.connected = true
  }
}
