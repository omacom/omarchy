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
  property string flavor: Flavors.DEFAULT_FLAVOR
  property var flags: Flavors.byId(Flavors.DEFAULT_FLAVOR).defaultFlags.slice()
  property bool all: true

  readonly property var flavorInfo: Flavors.byId(flavor)
  readonly property var flavorOptions: Flavors.FLAVORS
    .filter(function(f) { return engine.supports(f.id) })
    .map(function(f) { return { value: f.id, label: f.name } })

  readonly property var parsed: Parser.parse(pattern, flavor, flags)
  // The engine's own account of group names wins over Rex's parser.
  readonly property var groupNames: {
    var names = result.names && Object.keys(result.names).length ? result.names : parsed.names
    var out = []
    for (var name in names) out[names[name]] = name
    return out
  }
  readonly property int groupCount: Math.max(parsed.groupCount, result.stride / 2 - 1)
  readonly property var groupColors: {
    var out = []
    for (var g = 0; g < Math.max(1, groupCount); g++) {
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
    if (result.building) return "Building the " + result.building + " engine (first use only)…"
    if (result.kind === "timeout") return "Timed out"
    if (result.ok === false) return "Error"
    var n = result.count
    var text = n === 1 ? "1 match" : n.toLocaleString(Qt.locale(), "f", 0) + " matches"
    if (!result.done) return text + " so far…"
    return text + " · " + formatMs(result.elapsed)
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

  function formatMs(ms) {
    if (ms === undefined || ms === null) return ""
    if (ms < 1) return ms.toFixed(2) + " ms"
    if (ms < 10) return ms.toFixed(1) + " ms"
    if (ms < 10000) return Math.round(ms) + " ms"
    return (ms / 1000).toFixed(1) + " s"
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
  // Workers keep the text between requests; a new version is sent again.
  property int textVersion: 0
  onTestTextChanged: {
    textVersion++
    runTimer.restart()
  }
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
      textVersion: textVersion,
      all: all,
      limit: 100000,
      parsed: parsed,
    })
  }

  Engine {
    id: engine
    onDetectedChanged: root.run()
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
        kind: reply.kind || "",
        building: reply.building || "",
        names: reply.names || (first ? null : root.result.names),
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
    if (typeof payload.flavor === "string") setFlavor(payload.flavor)

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
