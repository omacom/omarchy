pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "State.js" as State

// This process never imports plugins or the main shell's service tree. Its
// surfaces own the exclusive zones even while the plugin host is gone.
ShellRoot {
  id: root
  property var snapshot: ({ screens: [], position: "top", size: 0, hidden: true,
    background: "#202020", foreground: "#ffffff" })
  property var owner: null
  property bool ready: false
  property string message: "Shell starting…"

  // The user can hide the bar while the main shell is down. Keep honoring the
  // same flag, without waiting for the plugin host to recover.
  property bool flagKnown: false
  property bool flagHidden: false
  Process {
    id: hiddenProbe
    running: true
    command: ["bash", "-c", "[[ -f $HOME/.local/state/omarchy/toggles/bar-off ]] && echo yes || echo no"]
    stdout: SplitParser {
      onRead: function(line) { root.flagHidden = line === "yes"; root.flagKnown = true }
    }
  }
  FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/toggles"
    watchChanges: true
    printErrors: false
    onFileChanged: hiddenProbe.running = true
  }
  Timer {
    interval: 1000
    repeat: true
    running: !root.ready
    onTriggered: hiddenProbe.running = true
  }

  SocketServer {
    path: Quickshell.env("OMARCHY_BAR_SOCKET")
    active: path !== ""
    handler: Socket {
      id: connection
      onConnectedChanged: {
        if (!connected && root.owner === connection) {
          root.owner = null
          root.ready = false
          if (root.message === "") root.message = "Shell unavailable"
        }
      }
      property string pending: ""
      function reject() {
        // A live client falls back to its own exclusive zone when rejected.
        // Release its old snapshot first, otherwise the two zones would add.
        if (root.owner === connection) {
          var released = Object.assign({}, root.snapshot)
          released.screens = []
          root.snapshot = released
        }
        connected = false
        return false
      }
      function receive(line) {
        var next = State.parse(line)
        if (!next) return reject()
        // A second shell must not supersede a still-connected owner.
        if (root.owner && root.owner !== connection) return reject()
        root.owner = connection
        if (next.loading) {
          root.ready = false
          root.message = "Shell restarting…"
        } else {
          root.snapshot = next
          root.ready = next.ready
          root.message = next.ready ? "" : "Shell restarting…"
        }
        Qt.callLater(function() {
          if (connection && connection.connected && !next.loading) {
            connection.write("ok\n")
            connection.flush()
          }
        })
        return true
      }
      parser: SplitParser {
        splitMarker: ""
        onRead: function(chunk) {
          var result = State.append(connection.pending, chunk)
          if (!result) { connection.reject(); return }
          connection.pending = result.pending
          for (var i = 0; i < result.lines.length; i++) {
            if (!connection.receive(result.lines[i])) break
          }
        }
      }
    }
  }

  IpcHandler {
    target: "reservation"
    function ping(): string { return "ok" }
    function status(): string {
      return JSON.stringify({ ready: root.ready, message: root.message, snapshot: root.snapshot })
    }
    function restarting(): void { root.ready = false; root.message = "Shell restarting…" }
    function crashed(): void { root.ready = false; root.message = "Shell crashed — restarting…" }
    function failed(): void { root.ready = false; root.message = "Shell stopped — restart required" }
  }

  Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
      id: panel
      required property var modelData
      screen: modelData
      readonly property bool vertical: root.snapshot.position === "left" || root.snapshot.position === "right"
      visible: !(root.flagKnown ? root.flagHidden : root.snapshot.hidden) && root.snapshot.size > 0 && root.snapshot.screens.indexOf(modelData.name) >= 0
      anchors {
        top: root.snapshot.position === "top" || panel.vertical
        bottom: root.snapshot.position === "bottom" || panel.vertical
        left: root.snapshot.position === "left" || !panel.vertical
        right: root.snapshot.position === "right" || !panel.vertical
      }
      implicitWidth: vertical ? root.snapshot.size : 0
      implicitHeight: vertical ? 0 : root.snapshot.size
      exclusiveZone: root.snapshot.size
      color: root.ready ? "transparent" : root.snapshot.background
      // Stay below the interactive bar, accept neither mouse nor keyboard input.
      mask: Region { }
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.namespace: "omarchy-bar-reservation"
      Text {
        anchors.centerIn: parent
        width: Math.max(0, (panel.vertical ? panel.height : panel.width) - 16)
        rotation: panel.vertical ? -90 : 0
        text: root.message
        visible: !root.ready
        color: root.snapshot.foreground
        font.family: "monospace"
        font.pixelSize: Math.min(14, Math.max(8, root.snapshot.size - 8))
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
      }
    }
  }
}
