import QtQuick
import Quickshell
import Quickshell.Io
import "VpnTailscaleModel.js" as Model

// Tailscale, which runs its own daemon, as one of NetworkVpn's providers.
//
// Tailscale already has its own bar widget, which signs in, grants the
// operator, picks exit nodes and switches accounts. That stays the one place
// Tailscale is driven: this only reads its state, so the network panel can
// list it and the bar can lock its icon while an exit node carries the
// traffic. The row is listed only while the Tailscale widget is on the bar
// (its panel is what the row opens) and tailscaled is running.
//
// tailscaled's tun device showing up in NetworkManager is the cue to start
// watching; NetworkManager signals nothing when Tailscale goes up or down, so
// from then on tailscale's own IPN bus triggers one status read per change.
Scope {
  id: root

  readonly property string provider: Model.provider
  readonly property string widget: Model.widget

  // Whether the Tailscale widget is on a bar: its panel answers IPC while it
  // is. `revision` is there to re-check as handlers come and go.
  readonly property bool widgetLive: IpcRegistry.revision >= 0 && IpcRegistry.handlerFor(Model.widget) !== null

  // The entry for the row, or null while tailscaled isn't answering. Always
  // read, since the bar's lock doesn't depend on the widget; `listed` says
  // whether the panel shows it.
  property var status: null
  readonly property var connections: status ? [Object.assign({}, status, { listed: widgetLive })] : []

  property bool readAgain: false
  property real watchedAt: 0
  property int quickExits: 0

  // Called on each NetworkManager read with whether tailscaled's device is
  // there. Watching starts once it is, and again when it comes back after a
  // restart; a watch that keeps ending at once is left alone.
  function deviceSeen(present) {
    if (present && !events.running && quickExits < 3) events.running = true
  }

  function refresh() {
    if (reader.running) {
      readAgain = true
      return
    }
    reader.running = true
  }

  // Signing in is the one thing the row does beyond opening the widget, since
  // that is what a click on "Sign-in required" asks for: the widget opens the
  // sign-in page in the browser and follows it through.
  function toggle(id) {
    if (status && status.state === "login") IpcRegistry.call(Model.widget, "up", [])
  }

  Process {
    id: reader
    command: ["tailscale", "status", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.status = Model.parseStatus(text)
    }
    onExited: {
      if (!root.readAgain) return
      root.readAgain = false
      root.refresh()
    }
  }

  Timer {
    id: settle
    interval: 150
    onTriggered: root.refresh()
  }

  // Tailscale connecting, stopping, or switching exit node. The first message
  // carries the current state, which takes the first reading. When tailscaled
  // goes away the watch ends and its entry goes with it.
  Process {
    id: events
    command: ["tailscale", "debug", "watch-ipn", "--initial", "--peer-changes=false", "--peer-patches=false"]
    onRunningChanged: if (running) root.watchedAt = Date.now()
    onExited: {
      root.quickExits = Date.now() - root.watchedAt < 1000 ? root.quickExits + 1 : 0
      root.status = null
    }
    stdout: SplitParser {
      onRead: function(line) {
        if (Model.isEvent(line)) settle.restart()
      }
    }
  }
}
