pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "NetworkVpnModel.js" as Model

// NetworkManager's VPN and WireGuard profiles, which Quickshell.Networking
// does not model. Kept once for the whole shell rather than per bar widget,
// and driven by NetworkManager's own D-Bus signals: a profile activating,
// deactivating, appearing or going away triggers one nmcli read, so an idle
// shell starts nothing.
Singleton {
  id: root

  // [{ name, uuid, type, state }], state "" when inactive, otherwise
  // NetworkManager's "activating" | "activated" | "deactivating".
  property var connections: []
  readonly property var activeNames: Model.activeVpnNames(connections)
  readonly property bool active: activeNames.length > 0

  // The profile an up/down started from the shell is waiting on.
  property string pendingUuid: ""
  property string pendingAction: ""  // "up" | "down"
  // The profile whose last connect failed for a reason other than a missing
  // password, cleared by the next action.
  property string failedUuid: ""
  readonly property bool busy: pendingUuid !== ""

  // A connect moved to a terminal to ask for the password; whatever holds
  // keyboard focus over it (the network panel) should let go.
  signal secretsRequested(string uuid)

  property bool readAgain: false
  property real subscribedAt: 0
  property int quickExits: 0

  function refresh() {
    if (reader.running) {
      readAgain = true
      return
    }
    reader.running = true
  }

  function connectionFor(uuid) {
    for (var i = 0; i < connections.length; i++) {
      if (connections[i].uuid === uuid) return connections[i]
    }
    return null
  }

  function toggle(uuid) {
    var connection = connectionFor(uuid)
    if (!connection) return
    if (connection.state === "activated" || connection.state === "activating") disconnect(uuid)
    else connect(uuid)
  }

  function connect(uuid) { run("up", uuid) }
  function disconnect(uuid) { run("down", uuid) }

  function run(action, uuid) {
    if (busy || !Model.isUuid(uuid)) return
    failedUuid = ""
    pendingUuid = uuid
    pendingAction = action
    actionProc.command = ["nmcli", "connection", action, "uuid", uuid]
    actionProc.running = true
  }

  // A password kept with a secret agent needs someone to type it. Without an
  // agent of its own the shell cannot ask, so the connect is handed to a
  // terminal where nmcli prompts for it.
  function connectInTerminal(uuid) {
    if (!Model.isUuid(uuid)) return
    Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", "nmcli --ask connection up uuid " + uuid])
    secretsRequested(uuid)
  }

  Process {
    id: reader
    command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,STATE", "connection", "show"]
    environment: ({ LC_ALL: "C" })
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.connections = Model.parseVpnConnections(text)
    }
    onExited: {
      if (!root.readAgain) return
      root.readAgain = false
      root.refresh()
    }
  }

  Process {
    id: actionProc
    environment: ({ LC_ALL: "C" })
    stderr: StdioCollector { id: actionStderr; waitForEnd: true }
    onExited: function(exitCode) {
      var uuid = root.pendingUuid
      var action = root.pendingAction
      root.pendingUuid = ""
      root.pendingAction = ""
      if (exitCode !== 0 && action === "up") {
        if (Model.needsSecrets(actionStderr.text)) root.connectInTerminal(uuid)
        else root.failedUuid = uuid
      }
      root.refresh()
    }
  }

  // Several signals land together for one change; read once they settle.
  Timer {
    id: settle
    interval: 150
    onTriggered: root.refresh()
  }

  // Nothing here is needed while the shell draws its first frames, and every
  // process started then competes with the bar and the lock being built, so
  // listening starts a moment later.
  Timer {
    interval: 1000
    running: true
    onTriggered: events.running = true
  }

  // Active connections changing state (VPN and otherwise), VPN plugin state,
  // and profiles being added, removed or edited. dbus-monitor's first line
  // arrives once it is listening, which also takes the first reading.
  Process {
    id: events
    command: ["dbus-monitor", "--system",
      "type='signal',sender='org.freedesktop.NetworkManager',interface='org.freedesktop.NetworkManager.Connection.Active',member='StateChanged'",
      "type='signal',sender='org.freedesktop.NetworkManager',interface='org.freedesktop.NetworkManager.VPN.Connection',member='VpnStateChanged'",
      "type='signal',sender='org.freedesktop.NetworkManager',interface='org.freedesktop.NetworkManager.Settings'",
      "type='signal',sender='org.freedesktop.NetworkManager',interface='org.freedesktop.NetworkManager.Settings.Connection',member='Updated'"]
    onRunningChanged: if (running) root.subscribedAt = Date.now()
    onExited: {
      // Restarted when the bus drops it, unless it keeps ending at once
      // (no system bus), which would only respawn it forever.
      root.quickExits = Date.now() - root.subscribedAt < 1000 ? root.quickExits + 1 : 0
      if (root.quickExits < 5) resubscribe.start()
    }
    stdout: SplitParser {
      onRead: function(line) {
        if (String(line).indexOf("signal ") === 0) settle.restart()
      }
    }
  }

  Timer {
    id: resubscribe
    interval: 2000
    onTriggered: if (!events.running) events.running = true
  }
}
