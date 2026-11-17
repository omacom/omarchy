import QtQuick
import Quickshell
import Quickshell.Io
import "VpnNetworkManagerModel.js" as Model

// NetworkManager's VPN and WireGuard profiles, which Quickshell.Networking
// does not model. Driven by NetworkManager's D-Bus signals rather than
// polling: each change triggers one nmcli read, so an idle shell starts
// nothing. One of NetworkVpn's providers.
//
// Connecting asks for a user name and password in the panel when the profile
// can't connect without them: none saved, a password that is never kept, or
// nmcli reporting that no secret agent answered. Anything else that needs
// asking (certificate passwords, web sign-ins) moves to a terminal running
// `nmcli --ask`.
Scope {
  id: root

  readonly property string provider: Model.provider
  property var connections: []

  // The profile an up/down started from the shell is waiting on.
  property string pendingId: ""
  property string pendingAction: ""  // "up" | "down"
  // The profile whose last connect failed for a reason other than missing
  // credentials, cleared by the next action.
  property string failedId: ""
  readonly property bool busy: pendingId !== "" || detailsProc.running

  // The profile the panel is asking credentials for, the user name to start
  // from, and whether the plugin keeps a user name at all.
  property string credentialsId: ""
  property string credentialsUser: ""
  property bool credentialsNeedUser: false
  property var credentialsPlan: null

  // Each read of NetworkManager's connections, for providers whose daemon
  // only shows up there as a device.
  signal read(string raw)
  // A connect moved to a terminal; whatever holds keyboard focus over it (the
  // network panel) should let go.
  signal handedToTerminal(string id)

  property bool readAgain: false
  property real subscribedAt: 0
  property int quickExits: 0
  property bool usedCredentials: false
  property bool cancelled: false
  property string connectionsSignature: "[]"

  function start() {
    if (!events.running) events.running = true
  }

  function refresh() {
    if (reader.running) {
      readAgain = true
      return
    }
    reader.running = true
  }

  function connectionFor(id) {
    for (var i = 0; i < connections.length; i++) {
      if (connections[i].id === id) return connections[i]
    }
    return null
  }

  function toggle(id) {
    var connection = connectionFor(id)
    if (!connection) return
    var connecting = pendingId === id && pendingAction === "up"
    if (connecting || connection.state === "activated" || connection.state === "activating") disconnect(id)
    else connect(id)
  }

  // WireGuard keeps its keys in the profile, so it connects straight away.
  // A VPN plugin's profile is looked at first, to see whether it can connect
  // without asking for anything.
  function connect(id) {
    if (busy || !Model.isUuid(id)) return
    var connection = connectionFor(id)
    if (credentialsId !== "" && credentialsId !== id) cancelCredentials()
    failedId = ""
    if (connection && connection.type !== "vpn") {
      run("up", id)
      return
    }
    readDetails(id, false)
  }

  // What a profile signs in with. afterFailure is a connect that went ahead
  // because the profile looked complete and then turned out to need secrets.
  function readDetails(id, afterFailure) {
    detailsProc.targetId = id
    detailsProc.afterFailure = afterFailure
    detailsProc.command = ["nmcli", "-g", "vpn.service-type,vpn.data", "connection", "show", "uuid", id]
    detailsProc.running = true
  }

  // A connect still waiting on its server (nmcli waits up to a minute and a
  // half for one that doesn't answer) can be called off: the down ends it,
  // and the up it cuts short is not reported as a failure.
  function disconnect(id) {
    if (!Model.isUuid(id)) return
    if (pendingId === id && pendingAction === "up") {
      if (cancelProc.running) return
      cancelled = true
      if (credentialsId === id) cancelCredentials()
      cancelProc.command = ["nmcli", "connection", "down", "uuid", id]
      cancelProc.running = true
      return
    }
    if (busy) return
    if (credentialsId === id) cancelCredentials()
    run("down", id)
  }

  function run(action, id) {
    failedId = ""
    pendingId = id
    pendingAction = action
    usedCredentials = false
    actionProc.secret = ""
    actionProc.command = ["nmcli", "connection", action, "uuid", id]
    actionProc.running = true
  }

  function askCredentials(id, plan) {
    credentialsPlan = plan
    credentialsUser = plan ? plan.username : ""
    credentialsNeedUser = !!(plan && plan.userKey)
    credentialsId = id
  }

  function cancelCredentials() {
    credentialsId = ""
    credentialsUser = ""
    credentialsNeedUser = false
    credentialsPlan = null
  }

  function submitCredentials(username, password) {
    var plan = credentialsPlan
    var id = credentialsId
    var user = String(username || "")
    if (busy || id === "" || !plan || String(password || "") === "") return
    if (plan.userKey && user === "") return
    var item = plan.userKey && user !== plan.username ? Model.vpnDataItem(plan.userKey, user) : ""
    failedId = ""
    pendingId = id
    pendingAction = "up"
    usedCredentials = true
    actionProc.secret = String(password)
    actionProc.command = ["bash", "-c", Model.connectScript, "nmcli-vpn", id, plan.secretKey, item]
    actionProc.running = true
  }

  // A secret only someone at a prompt can give, which the panel doesn't know
  // how to ask for. The UUID is validated before it reaches the command.
  function connectInTerminal(id) {
    if (!Model.isUuid(id)) return
    Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation", "nmcli --ask connection up uuid " + id])
    handedToTerminal(id)
  }

  Process {
    id: reader
    command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,STATE", "connection", "show"]
    environment: ({ LC_ALL: "C" })
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        // Most reads find nothing changed (any connection's state change
        // triggers one); republishing then would rebuild the panel's rows,
        // and with them a prompt being typed into.
        var next = Model.parseVpnConnections(text)
        var signature = JSON.stringify(next)
        if (signature !== root.connectionsSignature) {
          root.connectionsSignature = signature
          root.connections = next
        }
        root.read(text)
      }
    }
    onExited: {
      if (!root.readAgain) return
      root.readAgain = false
      root.refresh()
    }
  }

  Process {
    id: detailsProc
    property string targetId: ""
    property bool afterFailure: false
    environment: ({ LC_ALL: "C" })
    stdout: StdioCollector { id: detailsStdout; waitForEnd: true }
    onExited: {
      var id = targetId
      targetId = ""
      var plan = Model.credentialPlan(Model.parseVpnDetails(detailsStdout.text))
      if (afterFailure) {
        if (plan) root.askCredentials(id, plan)
        else root.connectInTerminal(id)
      } else if (plan && plan.askFirst) {
        root.askCredentials(id, plan)
      } else {
        root.run("up", id)
      }
    }
  }

  Process {
    id: actionProc
    property string secret: ""
    environment: ({ LC_ALL: "C" })
    stdinEnabled: true
    stderr: StdioCollector { id: actionStderr; waitForEnd: true }
    onStarted: {
      if (root.usedCredentials) write(secret + "\n")
      secret = ""
    }
    onExited: function(exitCode) {
      var id = root.pendingId
      var action = root.pendingAction
      var withCredentials = root.usedCredentials
      var cancelled = root.cancelled
      root.pendingId = ""
      root.pendingAction = ""
      root.usedCredentials = false
      root.cancelled = false

      if (cancelled) {
        // Called off from the panel; nothing to report.
      } else if (exitCode === 0) {
        if (withCredentials) root.cancelCredentials()
      } else if (action === "up") {
        if (Model.needsSecrets(actionStderr.text)) {
          // No agent answered for this profile's password: ask for it here
          // when the plugin is one whose sign-in is a name and a password,
          // and in a terminal for anything else, or for a second secret the
          // name and password didn't cover.
          if (withCredentials) root.connectInTerminal(id)
          else root.readDetails(id, true)
        } else {
          // Anything else (a server that doesn't answer, a refused login,
          // a profile edit that failed) reads as any failed connect: the row
          // says so, and the next click asks again if it still needs to.
          if (withCredentials) root.cancelCredentials()
          root.failedId = id
        }
      }
      root.refresh()
    }
  }

  Process {
    id: cancelProc
    environment: ({ LC_ALL: "C" })
  }

  // Several signals land together for one change; read once they settle.
  Timer {
    id: settle
    interval: 150
    onTriggered: root.refresh()
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
