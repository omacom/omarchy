pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  required property var bar
  required property bool supported
  required property bool contentReady
  readonly property bool configured: !!Quickshell.env("OMARCHY_BAR_SOCKET")
  readonly property string client: Quickshell.env("OMARCHY_BAR_CLIENT") || ""
  property var socket: null
  // A connected transport does not mean the host has adopted our reservation.
  // Keep the fallback zone until it acknowledges the published snapshot.
  readonly property bool managed: configured && socket !== null && socket.connected && acknowledged
  property bool acknowledged: false
  property bool startupExpired: false
  property int retryDelay: 1000
  readonly property bool waiting: configured && (!acknowledged || !contentReady) && !startupExpired
  readonly property string snapshot: {
    if (!bar || (supported && !bar.hiddenStateKnown)) return JSON.stringify({ version: 1, client: root.client, loading: true })
    var screens = []
    if (supported) for (var i = 0; i < Quickshell.screens.length; i++) screens.push(Quickshell.screens[i].name)
    return JSON.stringify({ version: 1, client: root.client, screens: screens,
      position: supported ? bar.position : "top", size: supported ? bar.barSize : 0,
      hidden: !supported || bar.barHidden, ready: !supported || contentReady || startupExpired,
      background: supported ? String(Qt.rgba(bar.background.r, bar.background.g, bar.background.b, 1)) : "#202020",
      foreground: supported ? String(Qt.rgba(bar.foreground.r, bar.foreground.g, bar.foreground.b, 1)) : "#ffffff" })
  }
  onSnapshotChanged: {
    publish()
    // A corrected configuration should not wait out an earlier rejection.
    if (!managed) retryDelay = 1000
  }
  function publish() {
    if (socket && socket.connected) { socket.write(snapshot + "\n"); socket.flush() }
  }
  function reconnect() {
    // Quickshell 0.3.1 cannot retry a failed connect on the same Socket.
    // Replace it even when its connected property is already false.
    if (socket) socket.destroy()
    acknowledged = false
    socket = socketComponent.createObject(root)
    socket.connected = true
  }
  Component.onCompleted: { if (configured) reconnect() }
  Component {
    id: socketComponent
    Socket {
      id: connection
      path: Quickshell.env("OMARCHY_BAR_SOCKET")
      onConnectedChanged: {
        if (root.socket !== connection) return
        root.acknowledged = false
        if (connected) root.publish()
      }
      parser: SplitParser {
        onRead: function(line) {
          if (root.socket === connection && line === "ok") {
            root.acknowledged = true
            root.retryDelay = 1000
          }
        }
      }
    }
  }
  Timer {
    interval: 2000
    running: root.configured
    onTriggered: root.startupExpired = true
  }
  Timer {
    interval: root.retryDelay
    running: root.configured && !root.managed
    repeat: true
    onTriggered: {
      // Rejected snapshots and unavailable hosts must not spin indefinitely.
      root.retryDelay = Math.min(30000, root.retryDelay * 2)
      root.reconnect()
    }
  }
}
