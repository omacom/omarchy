import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import "views"
import "components"
import "lib/Flavors.js" as Flavors
import "lib/Parser.js" as Parser
import "lib/Colors.js" as Colors
import "lib/Replace.js" as Replace
import "lib/Explain.js" as Explain
import "lib/Icons.js" as Icons
import "lib/Analyze.js" as Analyze
import "lib/Tests.js" as Tests

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

  property alias engine: engine

  // ---- pages --------------------------------------------------------------

  readonly property var pages: [
    { id: "workbench", icon: Icons.ICONS.workbench, label: "Workbench" },
    { id: "compare", icon: Icons.ICONS.compare, label: "Compare flavors" },
    { id: "debug", icon: Icons.ICONS.debug, label: "Debugger (PCRE2)" },
    { id: "bench", icon: Icons.ICONS.bench, label: "Benchmark" },
    { id: "code", icon: Icons.ICONS.code, label: "Code" },
    { id: "reference", icon: Icons.ICONS.reference, label: "Reference" },
  ]
  property string page: "workbench"
  // Pages are built the first time they are shown and kept after that.
  property var visited: ({ workbench: true })

  function showPage(id) {
    var next = {}
    for (var key in visited) next[key] = visited[key]
    next[id] = true
    visited = next
    page = id
    if (id === "workbench") Qt.callLater(function() { workbench.focusPattern() })
  }

  // ---- the session --------------------------------------------------------

  property string pattern: ""
  property string testText: ""
  property string flavor: Flavors.DEFAULT_FLAVOR
  property var flags: Flavors.byId(Flavors.DEFAULT_FLAVOR).defaultFlags.slice()
  property bool all: true
  // "", "substitute", "list" or "split"
  property string tool: ""
  property string replacement: ""
  property string listTemplate: "$&\n"

  readonly property var flavorInfo: Flavors.byId(flavor)
  // The workbench's flags as PCRE2 understands them, for the debugger.
  readonly property var pcre2Flags: Flavors.validFlags("pcre2", flags.concat(["u"]))
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

  // ---- explanation ----

  readonly property var explainRows: Explain.explain(parsed, flags)
  readonly property var patternTokens: Explain.tokens(parsed)
  // One color per kind of syntax, spread around the wheel like the groups'.
  readonly property var kindColors: {
    function pick(i) { var c = Colors.groupColor(i, accent, background); return Qt.hsla(c.h, c.s, c.l, 1) }
    return {
      literal: foreground, escape: pick(11), class: pick(5), quantifier: accent,
      anchor: pick(8), assertion: pick(13), meta: Qt.darker(foreground, 1.3), comment: Qt.darker(foreground, 1.8),
    }
  }
  readonly property var findings: Analyze.analyze(pattern, flavor, flags)

  // ---- unit tests ----

  property var tests: []
  property var testResults: []
  readonly property int testsPassed: testResults.filter(function(r) { return r && r.pass }).length

  function addTest(test) { tests = tests.concat([Tests.normalize(test)]) }
  function removeTest(index) { tests = tests.filter(function(t, i) { return i !== index }) }

  function runTests() {
    testRunner.run("workbench", pattern, flavor, flags, tests, function(results) { root.testResults = results })
  }

  onTestsChanged: { testResults = tests.map(function() { return null }); testTimer.restart() }
  Timer { id: testTimer; interval: 120; onTriggered: root.runTests() }

  TestRunner {
    id: testRunner
    engine: engine
    channel: "tests"
  }
  // The side panel's tab: "matches", "explain" or "optimize".
  property string sideTab: "matches"
  property var patternHighlight: []
  property int patternCursor: -1

  // ---- substitute, list, split ----

  readonly property string replaceSyntax: flavorInfo.replace
  readonly property var groupIndex: {
    var names = result.names && Object.keys(result.names).length ? result.names : parsed.names
    return names || {}
  }
  readonly property string replaceSyntaxNote: replaceSyntax === ""
    ? flavorInfo.name + " only finds matches; there is no replacement"
    : Replace.SYNTAXES[replaceSyntax]
  readonly property string splitNote: Replace.SPLIT_NOTES[Replace.splitRule(replaceSyntax)]
  readonly property var replaceParsed: Replace.parse(tool === "list" ? listTemplate : replacement, replaceSyntax, groupCount, groupIndex)
  readonly property string replaceProblem: replaceParsed.errors.length ? replaceParsed.errors[0].message : ""
  readonly property bool resultUsable: result.ok !== false && pattern !== ""
  readonly property var substitution: tool === "substitute" && resultUsable && replaceSyntax !== ""
    ? Replace.substitute(replaceParsed, testText, result.matches, result.count, result.stride, groupIndex)
    : { text: tool === "substitute" ? testText : "", spans: [] }
  readonly property string listOutput: tool === "list" && resultUsable && replaceSyntax !== ""
    ? Replace.list(replaceParsed, testText, result.matches, result.count, result.stride, groupIndex)
    : ""
  readonly property var splitPieces: tool === "split" && resultUsable
    ? Replace.split(replaceSyntax, testText, result.matches, result.count, result.stride)
    : []

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
    if (n >= 1000000 || (n >= 100000 && !largeText)) text += "+ (stopped counting)"
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

  onPatternChanged: { runTimer.restart(); testTimer.restart() }
  // The file the test text was read from, or "" for typed text. Workers
  // read an opened file themselves.
  property string textFile: ""
  property string textFileError: ""
  // Above this many characters the text is shown read-only in a view that
  // only lays out what is on screen.
  readonly property int largeThreshold: 65536
  readonly property bool largeText: testText.length > largeThreshold

  function openFile(path) {
    textFileError = ""
    fileReader.path = ""
    fileReader.path = path
  }

  function closeFile() {
    textFile = ""
    testText = ""
  }

  function setTypedText(value) {
    textFile = ""
    testText = value
  }

  FileView {
    id: fileReader
    blockLoading: false
    printErrors: false
    onLoaded: {
      root.testText = text()
      root.textFile = path
    }
    onLoadFailed: function(error) {
      root.textFileError = "Could not read " + path
    }
  }

  // Workers keep the text between requests; a new version is sent again.
  property int textVersion: 0
  onTestTextChanged: {
    textVersion++
    runTimer.restart()
  }
  onFlavorChanged: { runTimer.restart(); testTimer.restart() }
  onFlagsChanged: { runTimer.restart(); testTimer.restart() }
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
      textPath: textFile,
      textVersion: textVersion,
      all: all,
      limit: largeText ? 1000000 : 100000,
      parsed: parsed,
    })
  }

  Engine {
    id: engine
    onDetectedChanged: { root.run(); testTimer.restart() }
    onResult: function(reply) {
      if (reply.id !== root.pendingId) return
      // Slices of one search arrive in order; later ones extend the first.
      var first = root.result.id !== reply.id
      var matches = first ? reply.matches : root.result.matches
      if (!first) for (var i = 0; i < reply.matches.length; i++) matches.push(reply.matches[i])
      var next = {
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
      // Everything bound to the result redraws when it changes, so slices of
      // a long search are shown at most every publishInterval.
      if (first || reply.done || !reply.ok) {
        publishTimer.stop()
        root.result = next
      } else {
        root.pendingResult = next
        if (!publishTimer.running) publishTimer.start()
      }
    }
  }

  property var pendingResult: null

  Timer {
    id: publishTimer
    interval: 100
    onTriggered: {
      if (root.pendingResult && root.pendingResult.id === root.pendingId) root.result = root.pendingResult
      root.pendingResult = null
    }
  }

  // ---- lifecycle ----------------------------------------------------------

  function open(payloadJson) {
    closingFromHost = false
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    if (typeof payload.pattern === "string" && payload.pattern !== "") pattern = payload.pattern
    if (typeof payload.text === "string") setTypedText(payload.text)
    if (typeof payload.file === "string" && payload.file !== "") openFile(payload.file)
    if (typeof payload.flavor === "string") setFlavor(payload.flavor)
    if (Array.isArray(payload.flags)) flags = Flavors.validFlags(flavor, payload.flags)
    if (typeof payload.replacement === "string") replacement = payload.replacement
    if (typeof payload.tool === "string") tool = payload.tool
    if (typeof payload.side === "string") sideTab = payload.side
    if (typeof payload.page === "string") showPage(payload.page)
    if (Array.isArray(payload.tests)) tests = payload.tests.map(Tests.normalize)

    window.visible = true
    Qt.callLater(function() { if (window.visible && root.page === "workbench") workbench.focusPattern() })
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

    RowLayout {
      anchors.fill: parent
      spacing: 0

      NavRail {
        Layout.fillHeight: true
        foreground: root.foreground
        accent: root.accent
        pages: root.pages
        current: root.page
        onPicked: function(page) { root.showPage(page) }
      }

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Workbench {
          id: workbench
          anchors.fill: parent
          visible: root.page === "workbench"
          app: root
        }

        Loader {
          anchors.fill: parent
          active: root.visited.debug === true
          visible: root.page === "debug"
          sourceComponent: DebuggerPage { app: root; visible: root.page === "debug"; focus: true }
        }

        Loader {
          anchors.fill: parent
          active: root.visited.bench === true
          visible: root.page === "bench"
          sourceComponent: BenchmarkPage { app: root }
        }

        Loader {
          anchors.fill: parent
          active: root.visited.code === true
          visible: root.page === "code"
          sourceComponent: CodePage { app: root }
        }

        Loader {
          anchors.fill: parent
          active: root.visited.reference === true
          visible: root.page === "reference"
          sourceComponent: ReferencePage { app: root }
        }

        Loader {
          anchors.fill: parent
          active: root.visited.compare === true
          visible: root.page === "compare"
          sourceComponent: ComparePage { app: root; visible: root.page === "compare" }
        }
      }
    }
  }
}
