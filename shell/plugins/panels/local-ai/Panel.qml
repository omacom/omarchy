import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
// One model, one button, one agent picker, one share toggle. Renders purely from the
// snapshot file the controller writes; nothing here knows a model name, a flag, or a color.
Panel {
  id: root
  moduleName: "omarchy.local-ai"
  ipcTarget: "omarchy.local-ai"
  manageIpc: false
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string cli: "omarchy-local-ai"   // first-party: the bin/ router on PATH
  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/omarchy/local-ai"

  property var snap: ({ state: "uninitialized", operation: {}, model: null, reason: "", share: {}, agents: {}, error: "" })
  readonly property string state: snap.state || "uninitialized"
  readonly property var model: snap.model || null
  readonly property var operation: snap.operation || ({})
  readonly property var share: snap.share || ({})
  readonly property var agentList: (snap.agents && snap.agents.launchable) || []
  // pending: a verb was just issued and no snapshot has confirmed the worker yet. The panel treats
  // it as busy so the click has an immediate effect instead of a dead second while the worker starts.
  property bool pending: false
  readonly property bool working: ["download", "starting", "unload", "share"].indexOf(state) >= 0
  readonly property bool busy: working || pending
  property int elapsed: 0
  readonly property int expected: operation.expectedSeconds || 0
  readonly property int progress: operation.percent > 0 ? operation.percent
    : (expected > 0 && elapsed > 0 ? Math.min(95, Math.round(elapsed * 100 / expected)) : 0)
  readonly property bool loaded: state === "ready"
  readonly property bool hasRunning: !!snap.running
  readonly property string defaultAgent: (snap.agents && snap.agents.default) || ""
  readonly property var gpus: snap.gpus || []
  readonly property var gpuSel: gpus.filter(function(g) { return g.chosen })[0] || null
  property bool gpusOpen: false
  function gpuLabel(g) { return g.product.replace(/^(NVIDIA GeForce |NVIDIA |Intel |AMD Radeon |AMD )/, "") + (g.vramGb ? " " + g.vramGb + " GB" : "") }
  function gpuLine() {
    if (!gpuSel) return gpus.length === 0 ? "none detected" : gpus.length + " detected, none chosen"
    return (gpus.length > 1 ? (gpus.indexOf(gpuSel) + 1) + "/" + gpus.length + " · " : "") + gpuLabel(gpuSel)
  }
  readonly property string homeDir: Quickshell.env("HOME") || ""
  function tilde(p) { return homeDir && p.indexOf(homeDir) === 0 ? "~" + p.slice(homeDir.length) : p }
  property string agentPick: ""
  property bool agentsOpen: false
  readonly property string agentSel: agentPick !== "" ? agentPick
    : (agentList.indexOf(defaultAgent) >= 0 ? defaultAgent : (agentList.length > 0 ? agentList[0] : ""))
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Util.alpha(foreground, 0.55)

  function refresh() { if (!poll.running) poll.running = true }
  function act(args) { if (busy || action.running) return; pending = true; pendingTimeout.restart(); action.command = [cli].concat(args); action.running = true }
  function take(json) { try { snap = JSON.parse(json); if (working || snap.error) pending = false; tick() } catch (e) {} }
  function tick() {
    var t = Date.parse(operation.startedAt || "")
    elapsed = working && !isNaN(t) ? Math.max(0, Math.round((Date.now() - t) / 1000)) : 0
  }
  function mmss(s) { return Math.floor(s / 60) + ":" + (s % 60 < 10 ? "0" : "") + (s % 60) }
  function title() {
    if (loaded && model) return model.name
    if (hasRunning && snap.running && !snap.running.current) return "Older model running"
    return model ? model.name : "Local AI"
  }
  function status() {
    if (snap.error && !pending) return snap.error
    if (pending && !working) return spinner() + " starting"
    if (busy) return spinner() + " " + (operation.detail || state)
      + (elapsed > 0 ? " · " + mmss(elapsed) + (expected > 0 ? " of about " + mmss(expected) : "") : "")
      + (progress > 0 ? " · " + progress + "%" : "")
    if (snap.reason) return snap.reason
    if (loaded && model) return model.engine + " · " + Math.round(model.ctxTokens / 1024) + "K context"
    return ""
  }
  property int spin: 0
  function spinner() { return ["|", "/", "-", "\\"][spin] }
  readonly property int lastStart: snap.lastStartSeconds || 0
  function startLabel() {
    if (!model) return "Start"
    var label = !model.downloaded && model.sizeGb > 0 ? "Start · " + model.sizeGb + " GB" : "Start"
    return lastStart > 0 && model.downloaded ? label + " · usually " + mmss(lastStart) : label
  }
  // The launch is its own process: the panel closes only when the terminal actually opened, and a
  // refusal (no model, wedged launcher) stays on screen instead of vanishing with the panel.
  function openAgent() {
    if (!loaded || agentSel === "" || busy || action.running || agentLaunch.running) return
    agentLaunch.command = [cli, "open-agent", agentSel]; agentLaunch.running = true
  }

  // The controller rewrites the snapshot after every step; watching the file is what makes
  // progress live. The timer catches reality changing outside an operation.
  FileView {
    id: snapshotFile
    path: root.stateDir + "/snapshot.json"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.take(text())
  }
  Process {
    id: poll
    command: [root.cli, "snapshot"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: { if (text.length <= 262144) root.take(text) } }
  }
  Process { id: action; onExited: root.refresh() }
  Process { id: agentLaunch; onExited: function(code) { root.refresh(); if (code === 0) root.close() } }
  // Poll fast while something runs, whether or not the panel is open, so the bar icon starts and
  // stops moving with the operation; slow when idle. The file watch above makes this a backstop.
  Timer { interval: root.pending ? 1000 : root.working ? 2000 : root.opened ? 10000 : 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
  Timer { id: pendingTimeout; interval: 20000; onTriggered: root.pending = false }
  Timer { interval: 1000; running: root.working; repeat: true; triggeredOnStart: true; onTriggered: root.tick() }
  Timer { interval: 140; running: root.busy && root.opened; repeat: true; onTriggered: root.spin = (root.spin + 1) % 4 }

  onOpenedChanged: if (opened) refresh()

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
    function load(): string { root.act(["load"]); return "ok" }
    function unload(): string { root.act(["unload"]); return "ok" }
    function agent(): string { root.openAgent(); return "ok" }
    function refresh(): string { root.refresh(); return "ok" }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    iconComponent: Component {
      Item {
        // The ring is the model's place; the dot inside grows with progress and breathes while
        // working, so a glance at the bar says how far along a Start is. Full dot = ready,
        // urgent ring = error, hollow = idle.
        Rectangle {
          id: ring
          anchors.centerIn: parent; width: Style.space(9); height: width; radius: width / 2
          color: "transparent"
          border.width: Math.max(1, Style.space(1))
          border.color: root.state === "error" ? (root.bar ? root.bar.urgent : root.foreground) : root.foreground
          opacity: root.loaded ? 0 : 1
          Behavior on opacity { NumberAnimation { duration: 400 } }
        }
        Rectangle {
          id: dot
          anchors.centerIn: parent
          readonly property real fill: root.loaded ? 1 : root.busy ? Math.max(0.3, root.progress / 100) : 0
          width: ring.width * fill; height: width; radius: width / 2
          color: root.foreground
          Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
          SequentialAnimation on opacity {
            running: root.busy; loops: Animation.Infinite; alwaysRunToEnd: true
            NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutSine } NumberAnimation { to: 1; duration: 600; easing.type: Easing.InOutSine }
          }
        }
      }
    }
    tooltipText: "Local AI · " + root.title()
    onPressed: function(code) { if (code === Qt.RightButton && root.loaded) root.openAgent(); else root.toggle() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keys
    contentWidth: panel.fittedContentWidth(Style.space(220))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)
    PanelKeyCatcher {
      id: keys
      anchors.fill: parent
      onActivateRequested: { if (root.loaded) root.openAgent(); else if (root.model && !root.snap.reason) root.act(["load"]) }
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Style.space(10)
        // The top of the card is a field of pixels, edge to edge, with a circle lit inside it: the
        // bar icon at card size. Idle, the circle is a faint disc in a fainter grid. Working, it
        // pulses fast and fills row by row as the download lands. Ready, it breathes slowly.
        // One Canvas, repainted only while the card is open and something is moving.
        Canvas {
          id: orb
          width: parent.width; height: Math.round(cell * rows)
          readonly property int cols: 28
          readonly property int rows: 9                                              // odd: a centre row
          readonly property real cell: width / cols
          readonly property real fill: root.loaded ? 1 : root.progress / 100
          readonly property bool pulsing: root.opened && (root.busy || root.loaded)
          readonly property bool working: root.busy
          readonly property color ink: root.state === "error" && root.bar ? root.bar.urgent : root.foreground
          property real phase: 0
          NumberAnimation on phase { running: orb.pulsing; loops: Animation.Infinite; from: 0; to: 1; duration: root.busy ? 1100 : 3000 }
          onPhaseChanged: requestPaint()
          onFillChanged: requestPaint()
          onPulsingChanged: requestPaint()
          onWorkingChanged: requestPaint()
          onInkChanged: requestPaint()
          onWidthChanged: requestPaint()
          onPaint: {
            var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height)
            var px = cell, gap = Math.max(1, px * 0.28), side = px - gap, corner = side * 0.28
            var cx = cols / 2, cy = rows / 2
            var breath = pulsing ? 0.5 - 0.5 * Math.cos(phase * 2 * Math.PI) : 0        // 0..1, eased both ways
            var radius = (rows / 2) * (pulsing ? 0.72 + 0.28 * breath : 0.86)         // in cells
            var peak = root.loaded ? 0.7 + 0.3 * breath : (root.busy ? 0.55 + 0.25 * breath : 0.34)
            function dot(col, row, a) {
              var x = col * px + gap / 2, y = row * px + gap / 2
              ctx.fillStyle = Qt.rgba(ink.r, ink.g, ink.b, a)
              ctx.beginPath(); ctx.roundedRect(x, y, side, side, corner, corner); ctx.fill()
            }
            for (var row = 0; row < rows; row++) {
              var lit = (rows - row) / rows <= fill
              for (var col = 0; col < cols; col++) {
                var dx = col + 0.5 - cx, dy = row + 0.5 - cy, d = Math.sqrt(dx * dx + dy * dy)
                if (d > radius + 0.5) { dot(col, row, 0.07); continue }                  // the field
                var glow = 1 - Math.pow(d / (radius + 0.5), 2) * 0.55                    // brightest at the centre
                var a = peak * glow * (lit ? 1 : 0.4)
                if (d > radius - 0.5) a *= 0.5 + 0.5 * (radius + 0.5 - d)              // soft rim
                dot(col, row, Math.max(a, 0.07))
              }
            }
          }
        }
        Text { width: parent.width; textFormat: Text.PlainText; text: root.title(); color: root.foreground; font.family: root.bar.fontFamily; font.pixelSize: Style.font.heading; font.weight: Font.Medium; elide: Text.ElideRight }
        Text { width: parent.width; textFormat: Text.PlainText; visible: root.status() !== ""; text: root.status(); color: root.snap.error ? (root.bar ? root.bar.urgent : root.foreground) : root.dim; font.family: root.bar.fontFamily; font.pixelSize: Style.font.bodySmall; wrapMode: Text.WordWrap; maximumLineCount: 3 }
        // What was detected, and which card the recipe is for. One card is a plain line; more than
        // one is a picker, since the person may want the smaller card left free or a different one tried.
        Text { visible: root.gpus.length <= 1; width: parent.width; textFormat: Text.PlainText; text: "GPU · " + root.gpuLine(); color: root.dim; font.family: root.bar.fontFamily; font.pixelSize: Style.font.bodySmall; elide: Text.ElideRight }
        Link { visible: root.gpus.length > 1; enabled: !root.busy; text: "GPU · " + root.gpuLine() + (root.gpusOpen ? "  ^" : "  v"); onTriggered: root.gpusOpen = !root.gpusOpen }
        Column {
          visible: root.gpusOpen && root.gpus.length > 1; width: parent.width; spacing: Style.space(6)
          Repeater {
            model: root.gpus
            Link { required property var modelData; width: content.width; text: "  " + root.gpuLabel(modelData) + (modelData.hardwareId ? "" : " · no validated recipe"); opacity: modelData.chosen ? 1 : 0.7; onTriggered: { root.gpusOpen = false; root.act(["gpu", modelData.key]) } }
          }
          Link { visible: !!root.snap.gpuPinned; width: content.width; text: "  auto (largest card with a recipe)"; onTriggered: { root.gpusOpen = false; root.act(["gpu", "auto"]) } }
        }
        Link { visible: !root.loaded || (!!root.snap.error && !root.busy); enabled: !root.busy && !!root.model && root.snap.reason === ""; text: root.loaded ? "Restart" : root.startLabel(); onTriggered: root.act(["load"]) }
        Link { visible: root.loaded && root.agentList.length > 0; text: "Open agent · " + root.agentSel + (root.agentsOpen ? "  ^" : "  v"); onTriggered: root.agentsOpen = !root.agentsOpen }
        Text { visible: root.loaded && root.agentList.length === 0; width: parent.width; textFormat: Text.PlainText; text: "No installed agent can use this model"; color: root.dim; font.family: root.bar.fontFamily; font.pixelSize: Style.font.bodySmall }
        Column {
          visible: root.agentsOpen && root.loaded; width: parent.width; spacing: Style.space(6)
          Repeater {
            model: root.agentList
            Link { required property var modelData; width: content.width; text: "  " + modelData; onTriggered: { root.agentPick = modelData; root.agentsOpen = false; root.openAgent() } }
          }
        }
        Link { visible: root.loaded && !!root.share.available; enabled: !root.busy; text: root.share.active ? "Stop sharing" : "Share on Tailscale"; onTriggered: root.act(["share"]) }
        Text { visible: root.loaded && !!root.share.error; width: parent.width; textFormat: Text.PlainText; text: root.share.error || ""; color: root.bar ? root.bar.urgent : root.foreground; font.family: root.bar.fontFamily; font.pixelSize: Style.font.bodySmall; wrapMode: Text.WordWrap; maximumLineCount: 3 }
        Text { visible: root.loaded && !!root.share.active; width: parent.width; textFormat: Text.PlainText; text: (root.share.url || "") + "\nkey in " + root.tilde(root.share.keyFile || ""); color: root.dim; font.family: root.bar.fontFamily; font.pixelSize: Style.font.bodySmall; wrapMode: Text.WrapAnywhere }
        Link { visible: root.loaded || root.hasRunning || root.state === "starting"; enabled: !root.busy; text: "Stop"; onTriggered: root.act(["unload"]) }
      }
    }
  }
  component Link: Item {
    signal triggered()
    property alias text: label.text
    property alias enabled: mouse.enabled
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    Rectangle { // rows are the only chrome the panel has; a hover wash says they are buttons
      anchors.fill: parent; radius: Style.space(2)
      color: mouse.containsMouse && mouse.enabled ? Util.alpha(root.foreground, 0.1) : "transparent"
    }
    Text {
      id: label
      width: parent.width; textFormat: Text.PlainText
      color: root.foreground; opacity: mouse.enabled ? 1 : 0.32
      font.family: root.bar.fontFamily; font.pixelSize: Style.font.bodySmall; elide: Text.ElideRight
    }
    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: parent.triggered() }
  }
}
