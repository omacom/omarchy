pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "NetworkVpnModel.js" as Model

// The machine's VPNs: NetworkManager's VPN and WireGuard profiles, which
// Quickshell.Networking does not model, and Tailscale, which runs its own
// daemon. Kept once for the whole shell rather than per bar widget, and
// driven by events rather than polling: NetworkManager's D-Bus signals and
// tailscale's IPN bus each trigger one read when something changes, so an
// idle shell starts nothing.
Singleton {
  id: root

  // [{ name, uuid, type, state }], state "" when inactive, otherwise
  // "activating" | "activated" | "deactivating", or "login" for a Tailscale
  // that needs signing in. Tailscale's entry has uuid "tailscale" and also
  // carries exitNode, the host name its traffic goes through, if any.
  readonly property var connections: Model.withTailscale(nmConnections, tailscale)
  readonly property var activeNames: Model.activeVpnNames(connections)
  readonly property bool active: activeNames.length > 0

  // The entry an up/down started from the shell is waiting on.
  property string pendingUuid: ""
  property string pendingAction: ""  // "up" | "down"
  // The entry whose last connect failed for a reason other than a missing
  // password or sign-in, cleared by the next action.
  property string failedUuid: ""
  readonly property bool busy: pendingUuid !== "" || operatorProc.running

  // A connect moved to a terminal to ask for a password or a sign-in;
  // whatever holds keyboard focus over it (the network panel) should let go.
  signal secretsRequested(string uuid)

  property var nmConnections: []
  property var tailscale: null

  property bool readAgain: false
  property real subscribedAt: 0
  property int quickExits: 0
  property bool tailscaleReadAgain: false
  property real tailscaleWatchedAt: 0
  property int tailscaleQuickExits: 0
  property bool operatorTried: false

  function refresh() {
    if (reader.running) {
      readAgain = true
      return
    }
    reader.running = true
  }

  function refreshTailscale() {
    if (tailscaleReader.running) {
      tailscaleReadAgain = true
      return
    }
    tailscaleReader.running = true
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

  function connect(uuid) {
    var connection = connectionFor(uuid)
    if (connection && connection.state === "login") connectInTerminal(uuid)
    else run("up", uuid)
  }
  function disconnect(uuid) { run("down", uuid) }

  function run(action, uuid) {
    if (busy) return
    var tailscaleAction = Model.isTailscale(uuid)
    if (!tailscaleAction && !Model.isUuid(uuid)) return
    failedUuid = ""
    pendingUuid = uuid
    pendingAction = action
    actionProc.command = tailscaleAction ? ["tailscale", action] : ["nmcli", "connection", action, "uuid", uuid]
    actionProc.running = true
  }

  // A password kept with a secret agent, or a Tailscale sign-in, needs
  // someone at a prompt. The shell has none of its own, so the connect is
  // handed to a terminal: nmcli asks for the password there, and tailscale
  // prints its sign-in link.
  function connectInTerminal(uuid) {
    var command = Model.isTailscale(uuid) ? "tailscale up"
      : (Model.isUuid(uuid) ? "nmcli --ask connection up uuid " + uuid : "")
    if (command === "") return
    Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", command])
    secretsRequested(uuid)
  }

  Process {
    id: reader
    command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,STATE", "connection", "show"]
    environment: ({ LC_ALL: "C" })
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.nmConnections = Model.parseVpnConnections(text)
        // Watching tailscale starts once its daemon is up, and again when it
        // comes back after a restart; a watch that keeps ending at once is
        // left alone.
        if (Model.hasTailscaleDevice(text) && !tailscaleEvents.running && root.tailscaleQuickExits < 3) tailscaleEvents.running = true
      }
    }
    onExited: {
      if (!root.readAgain) return
      root.readAgain = false
      root.refresh()
    }
  }

  Process {
    id: tailscaleReader
    command: ["tailscale", "status", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.tailscale = Model.parseTailscaleStatus(text)
    }
    onExited: {
      if (!root.tailscaleReadAgain) return
      root.tailscaleReadAgain = false
      root.refreshTailscale()
    }
  }

  Process {
    id: actionProc
    environment: ({ LC_ALL: "C" })
    stderr: StdioCollector { id: actionStderr; waitForEnd: true }
    onExited: function(exitCode) {
      var uuid = root.pendingUuid
      var action = root.pendingAction
      var tailscaleAction = Model.isTailscale(uuid)
      root.pendingUuid = ""
      root.pendingAction = ""
      if (exitCode !== 0 && tailscaleAction && Model.needsOperator(actionStderr.text) && !root.operatorTried) {
        root.authorizeOperator(action)
        return
      }
      if (exitCode !== 0 && !tailscaleAction && action === "up" && Model.needsSecrets(actionStderr.text)) root.connectInTerminal(uuid)
      else if (exitCode !== 0 && action === "up") root.failedUuid = uuid
      if (tailscaleAction) root.refreshTailscale()
      else root.refresh()
    }
  }

  // tailscale only takes up/down from root or its operator. Granting the
  // operator once, as Omarchy's Tailscale panel does, asks for the password
  // a single time; the action that was refused runs again after it.
  property string operatorRetryAction: ""
  function authorizeOperator(action) {
    var user = Quickshell.env("USER") || Quickshell.env("LOGNAME") || ""
    operatorTried = true
    if (user === "") {
      failedUuid = "tailscale"
      return
    }
    operatorRetryAction = action
    operatorProc.command = ["pkexec", "tailscale", "set", "--operator=" + user]
    operatorProc.running = true
  }

  Process {
    id: operatorProc
    onExited: function(exitCode) {
      if (exitCode === 0) root.run(root.operatorRetryAction, "tailscale")
      else if (root.operatorRetryAction === "up") root.failedUuid = "tailscale"
      root.operatorRetryAction = ""
    }
  }

  // Several signals land together for one change; read once they settle.
  Timer {
    id: settle
    interval: 150
    onTriggered: root.refresh()
  }

  Timer {
    id: tailscaleSettle
    interval: 150
    onTriggered: root.refreshTailscale()
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

  // Tailscale connecting, stopping, or switching exit node, from its own
  // message bus: NetworkManager sees none of that, since the tun device stays
  // up throughout. The first message carries the current state, which takes
  // the first reading. When tailscaled goes away the watch ends and its entry
  // goes with it.
  Process {
    id: tailscaleEvents
    command: ["tailscale", "debug", "watch-ipn", "--initial", "--peer-changes=false", "--peer-patches=false"]
    onRunningChanged: if (running) root.tailscaleWatchedAt = Date.now()
    onExited: {
      root.tailscaleQuickExits = Date.now() - root.tailscaleWatchedAt < 1000 ? root.tailscaleQuickExits + 1 : 0
      root.tailscale = null
    }
    stdout: SplitParser {
      onRead: function(line) {
        if (Model.isTailscaleEvent(line)) tailscaleSettle.restart()
      }
    }
  }
}
