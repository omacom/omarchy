import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Commons as Commons
import "views"
import "lib/Flavors.js" as Flavors
import "lib/Parser.js" as Parser
import "lib/Colors.js" as Colors

// Rex, the offline regular expression workbench. Launched from Apps
// (applications/Rex.desktop) through omarchy-launch-rex, or directly:
//   omarchy-shell shell summon omarchy.rex '{"pattern":"\\d+"}'
//
// The window is an ordinary tiled toplevel. Everything that can take time —
// running a pattern on an engine, reading a large file — happens off the UI
// thread, because this window lives in the same process as the bar.
Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property string pluginId: (manifest && manifest.id) || "omarchy.rex"

  readonly property color foreground: Commons.Color.foreground
  readonly property color background: Commons.Color.background
  readonly property color accent: Commons.Color.accent

  property bool closingFromHost: false

  // ---- the session --------------------------------------------------------

  property string pattern: ""
  property string testText: ""
  property string flavor: "ecmascript"
  property var flags: []
  property bool all: true

  readonly property var flavorInfo: Flavors.byId(flavor)
  readonly property var flavorOptions: Flavors.FLAVORS
    .filter(function(f) { return engine.supports(f.id) })
    .map(function(f) { return { value: f.id, label: f.name } })

  readonly property var parsed: Parser.parse(pattern, flavor, flags)
  readonly property var groupNames: {
    var out = []
    for (var name in parsed.names) out[parsed.names[name]] = name
    return out
  }
  readonly property var groupColors: {
    var out = []
    for (var g = 0; g < Math.max(1, parsed.groupCount); g++) {
      // Hue 0 is the accent, which already marks whole matches.
      var c = Colors.groupColor(g + 1, accent, background)
      out.push(Qt.hsla(c.h, c.s, c.l, 1))
    }
    return out
  }

  property var result: ({ ok: true, done: true, matches: [], stride: 2, count: 0, elapsed: 0 })
  property int pendingId: 0
  property int selectedMatch: -1

  readonly property string statusText: {
    if (pattern === "") return ""
    if (result.ok === false) return "Error"
    var n = result.count
    var text = n === 1 ? "1 match" : n.toLocaleString(Qt.locale(), "f", 0) + " matches"
    if (!result.done) return text + " so far…"
    return text + " · " + result.elapsed + " ms"
  }

  // The engine's own error comes first; Rex's parser explains where.
  readonly property string problemText: {
    if (pattern === "") return ""
    var lines = []
    if (result.ok === false && result.error) lines.push(result.error)
    for (var i = 0; i < parsed.errors.length && i < 3; i++) {
      var e = parsed.errors[i]
      lines.push(e.message + " (at " + e.start + ")")
    }
    return lines.join("\n")
  }

  function setFlavor(id) {
    if (!Flavors.exists(id)) return
    flags = Flavors.validFlags(id, flags.length ? flags : Flavors.byId(id).defaultFlags)
    flavor = id
  }

  function toggleFlag(id) {
    var next = flags.slice()
    var at = next.indexOf(id)
    if (at >= 0) next.splice(at, 1)
    else next.push(id)
    flags = next
  }

  onPatternChanged: runTimer.restart()
  onTestTextChanged: runTimer.restart()
  onFlavorChanged: runTimer.restart()
  onFlagsChanged: runTimer.restart()
  onAllChanged: runTimer.restart()

  Timer {
    id: runTimer
    interval: 60
    onTriggered: root.run()
  }

  function run() {
    selectedMatch = -1
    if (pattern === "") {
      pendingId = 0
      result = { ok: true, done: true, matches: [], stride: 2, count: 0, elapsed: 0 }
      return
    }
    pendingId = engine.match({
      flavor: flavor,
      pattern: pattern,
      flags: flags,
      text: testText,
      all: all,
      limit: 100000,
      parsed: parsed,
    })
  }

  Engine {
    id: engine
    onResult: function(reply) {
      if (reply.id !== root.pendingId) return
      // Slices of one search arrive in order; later ones extend the first.
      var first = root.result.id !== reply.id
      var matches = first ? reply.matches : root.result.matches
      if (!first) for (var i = 0; i < reply.matches.length; i++) matches.push(reply.matches[i])
      root.result = {
        id: reply.id,
        ok: reply.ok,
        done: reply.done,
        error: reply.error || "",
        matches: matches,
        stride: reply.stride,
        count: reply.ok ? matches.length / reply.stride : 0,
        elapsed: reply.elapsed,
      }
    }
  }

  // ---- lifecycle ----------------------------------------------------------

  function open(payloadJson) {
    closingFromHost = false
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    if (typeof payload.pattern === "string" && payload.pattern !== "") pattern = payload.pattern
    if (typeof payload.text === "string") testText = payload.text
    if (typeof payload.flavor === "string" && engine.supports(payload.flavor)) setFlavor(payload.flavor)

    window.visible = true
    Qt.callLater(function() { if (window.visible) workbench.focusPattern() })
  }

  // Host-initiated close (`shell hide`): the host already knows.
  function close() {
    closingFromHost = true
    window.visible = false
    closingFromHost = false
  }

  // ---- window -------------------------------------------------------------

  FloatingWindow {
    id: window
    title: "Rex"
    color: root.background
    implicitWidth: Style.space(1280)
    implicitHeight: Style.space(820)
    minimumSize: Qt.size(Style.space(720), Style.space(480))
    visible: false

    // Closing the window from the compositor ends the session; tell the host
    // so the plugin unloads and `toggle` keeps working.
    onVisibleChanged: {
      if (!visible && !root.closingFromHost && root.shell && typeof root.shell.hide === "function")
        root.shell.hide(root.pluginId)
    }

    Workbench {
      id: workbench
      anchors.fill: parent
      app: root
    }
  }
}
