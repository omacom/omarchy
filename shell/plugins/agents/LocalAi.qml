import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "LocalAi.js" as Ui
// Native Agents content; the optional Local AI controller owns deployment and telemetry.
Item {
  id: root
  property var bar: null
  required property string cli
  property bool editingFolder: false
  function editFolder() { folderInput.text = (snap.agents || {}).directory || Quickshell.env("HOME"); editingFolder = true; Qt.callLater(function() { folderInput.forceActiveFocus(); folderInput.selectAll(); revealItem(folderInput) }) }
  function saveFolder() { var path = folderInput.text; if (path === "~" || path.indexOf("~/") === 0) path = Quickshell.env("HOME") + path.slice(1); act(["agent-dir", path]) }
  property bool active: false
  property alias contentFocus: keys
  required property Item overlayHost
  property string copyUrl: ""
  property string copyError: ""
  signal dismissRequested()
  signal switchRequested(int direction)
  signal revealRequested(real y, real rowHeight)
  readonly property real viewportHeight: overlayHost.height
  onViewportHeightChanged: scrollBy(0)
  property bool browseWhileWorking: false
  readonly property bool panelActive: active
  implicitHeight: content.implicitHeight
  function dismiss() { dismissRequested() }
  function focusContent() { if (linkOverlay.visible) urlText.forceActiveFocus(); else keys.forceActiveFocus() }
  onActiveChanged: {
    if (active) { refresh(); Qt.callLater(focusContent) }
    else linkOverlay.close()
  }

  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/omarchy/local-ai"

  // ---------------------------------------------------------------- native theme, fills and sharp corners
  readonly property color popupBg: Color.popups.background
  readonly property color ink: bar ? bar.foreground : Color.foreground
  readonly property color fg: Qt.darker(ink, 1.15)
  readonly property color dim: Qt.darker(ink, 1.55)
  readonly property color faint: Qt.darker(ink, 1.8)
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color accent: Color.accent
  readonly property color recessed: Qt.rgba(0, 0, 0, 0.24)
  readonly property color restFill: Util.alpha(ink, 0.04)
  readonly property color selectedFill: Style.selectedFillFor(ink, Color.accent)
  readonly property color hairline: Util.alpha(ink, 0.12)
  readonly property string mono: bar ? bar.fontFamily : Style.font.family

  // ---------------------------------------------------------------- snapshot and navigation
  property var snap: ({ state: "uninitialized", operation: {}, models: [], cards: [], recipes: [], gpus: [], share: {}, agents: {}, reason: "", error: "" })
  property var path: ["home"]           // home › card › model
  readonly property string view: path[path.length - 1]
  property string hw: ""                // the card type open
  property int count: 1                 // how many of it
  property string pick: ""              // the recipe picked
  property string slotSel: ""           // the running model open
  property bool launcherOpen: false
  property string launchPick: ""
  property bool launchModelOpen: false
  property string agentPick: ""
  property bool agentOpen: false
  property bool copied: false
  property string toast: ""
  property string localError: ""
  property bool pending: false          // a verb was issued and no snapshot has confirmed it yet
  property string lastVerb: ""
  property var queue: []                // verbs to run after the current one exits
  property int elapsed: 0
  property int cursor: 0
  readonly property var ui: Ui.build({ snap: snap, view: view, browseWhileWorking: browseWhileWorking, hw: hw, count: count, pick: pick, slotSel: slotSel, launcherOpen: launcherOpen, launchPick: launchPick, launchModelOpen: launchModelOpen, agentPick: agentPick, agentOpen: agentOpen, copied: copied, pending: pending, lastVerb: lastVerb, elapsed: elapsed, localError: localError })
  readonly property string tone: ui.tone
  readonly property bool working: Ui.isWorking({snap: snap, pending: pending, lastVerb: lastVerb})
  onWorkingChanged: { if (!working) browseWhileWorking = false; else if (!browseWhileWorking && lastVerb !== "share") Qt.callLater(home) }
  readonly property var all: ui.rows.concat(ui.foot)
  readonly property var actionable: all.map(function(r, i) { return r.action && !r.disabled ? i : -1 }).filter(function(i) { return i >= 0 })
  readonly property int cursorAt: actionable.length ? actionable[Math.min(cursor, actionable.length - 1)] : -1

  function take(json) {
    try { var s = JSON.parse(json), busyNow = ["download", "starting", "unload", "share"].indexOf(s.state) >= 0, newError = !!s.error && s.error !== snap.error; freed(snap, s); snap = s; localError = ""; if (busyNow || newError || (actionDone && ["run", "load", "unload", "share"].indexOf(lastVerb) < 0)) pending = false; tick() }   // the snapshot, not our own pending flag, decides when pending ends
    catch (e) { if (json.trim() === "") { localError = "no answer"; pending = false } }
  }
  function freed(before, after) { // a model that left while we were stopping: say which card came free
    var gone = (before.models || []).filter(function(m) { return m.state !== "stopped" && !(after.models || []).some(function(n) { return n.recipeId === m.recipeId && n.state !== "stopped" }) })
    if (gone.length && (lastVerb === "unload" || before.state === "unload")) { var c = Ui.cardOfKeys(before, gone[0].keys); say((c ? c.name : "card") + " " + gone[0].keys.map(function(k) { return "#" + k.split(":")[1] }).join(" ") + " · freed") }
  }
  function tick() { var t = Date.parse((snap.operation || {}).startedAt || ""); elapsed = working && !isNaN(t) ? Math.max(0, Math.round((Date.now() - t) / 1000)) : 0 }
  function say(t) { toast = t; toastTimer.restart() }
  function refresh() { if (!poll.running) poll.running = true }
  function go(v) { var p = path.slice(); p.push(v); path = p; cursor = 0; agentOpen = false }
  function back() { if (path.length > 1) { var p = path.slice(); p.pop(); path = p } cursor = 0; agentOpen = false }
  function home() { path = ["home"]; cursor = 0; agentOpen = false; Qt.callLater(function() { scrollBy(-1e9) }) }
  // verbs hand off to the controller one at a time; run, load, unload and share are done when a snapshot
  // shows their worker, the rest when the process exits
  property bool actionDone: false
  function act(args) { if (action.running) { queue = queue.concat([args]); return } lastVerb = args[0]; actionDone = false; pending = true; pendingTimeout.restart(); action.command = [cli].concat(args); action.running = true }
  function scrollBy(amount) {
    var top = -mapToItem(overlayHost, 0, 0).y
    revealRequested(top + amount + (amount >= 0 ? viewportHeight + 0.01 : 0), 0)
  }
  function revealItem(it) { if (it) revealRequested(it.mapToItem(root, 0, 0).y, it.height) }
  function navigateCrumb(action) { activate(action); editingFolder = false; Qt.callLater(function() { scrollBy(-1e9); focusContent() }) }
  function activate(a) {
    if (!a) return
    var s = a.split(":"), v = s[0]
    if (working && Ui.changesDeployment(a)) return
    if (working && ["home", "card", "gpu", "model", "count", "back"].indexOf(v) >= 0) browseWhileWorking = true
    if (v === "work") { browseWhileWorking = false; home(); return }
    if (v === "choose-folder") root.editFolder()
    else if (v === "home") home()
    else if (v === "back") back()
    else if (v === "gpu" || v === "card") { hw = s[1]; count = 1; pick = ""; home(); go("card") }
    else if (v === "count") { count = parseInt(s[1], 10) || 1; pick = "" }
    else if (v === "pick") { pick = pick === s[1] ? "" : s[1]; Qt.callLater(function() { var i = ui.rows.findIndex(function(r) { return r.child && (r.disabled || r.action.indexOf("run:") === 0) }); if (i >= 0) body.reveal(i) }) }
    else if (v === "model") { slotSel = s[1]; var model = Ui.modelById(snap, slotSel), group = model ? Ui.cardOfKeys(snap, model.keys) : null; home(); if (group) { hw = group.hardwareId; go("card") } go("model") }
    else if (v === "run") { var recipe = Ui.recipeById(snap, s[1]), g = recipe ? Ui.cardByHw(snap, recipe.hardwareId) : null; if (!g) return; var plan = Ui.loadPlan(snap, recipe, g); home(); act(["run", s[1], plan.gpu]) }
    else if (v === "run-again") { home(); act(["load"]) }
    else if (v === "refresh") { localError = ""; refresh() }
    else if (v === "stop") { home(); act(["unload", s[1]]) }
    else if (v === "stop-download") { if (action.running) return; lastVerb = "unload"; actionDone = false; action.command = [cli, "unload"]; action.running = true }
    else if (v === "launcher-toggle") { launcherOpen = !launcherOpen; launchModelOpen = false; agentOpen = false; cursor = 0 }
    else if (v === "launch-model-toggle") { launchModelOpen = !launchModelOpen; agentOpen = false }
    else if (v === "launch-model") { launchPick = s.slice(1).join(":"); launchModelOpen = false; cursor = 0 }
    else if (v === "agent-toggle") { agentOpen = !agentOpen; launchModelOpen = false }
    else if (v === "agent") { agentPick = s[1]; agentOpen = false; cursor = root.view === "home" ? 3 : 1 }
    else if (v === "open-agent") { if (agentLaunch.running) return; agentLaunch.command = [cli, "open-agent", s[1], s[2]]; agentLaunch.running = true; say(s[1] + " · " + (Ui.modelById(snap, s[2]) || { name: "" }).name) }
    else if (v === "share") { act(["share"]) }
    else if (v === "update") { act(["update"]) }
    else if (v === "update-check") { act(["update", "--check"]) }
    else if (v === "copy") { var m = Ui.modelById(snap, s[1]); if (copy.running || !m || !m.shareUrl) return; copyUrl = m.shareUrl; copyError = ""; linkOverlay.open() }
    else if (v === "log") { logOpen.running = true; say("log · open") }
  }
  function copyLink() {
    if (copy.running || !copyUrl) return
    copyError = ""
    copy.command = ["bash", "-c", "command -v wl-copy >/dev/null 2>&1 || exit 127; printf %s \"$1\" | wl-copy", "_", copyUrl]
    copy.running = true
  }
  function moveCursor(d) { if (actionable.length) cursor = ((cursor + d) % actionable.length + actionable.length) % actionable.length }
  function cursorRow() { return cursorAt >= 0 ? all[cursorAt] : null }

  // ---------------------------------------------------------------- the controller
  FileView { path: root.stateDir + "/snapshot.json"; watchChanges: true; onFileChanged: reload(); onLoaded: root.take(text()) }
  Process { id: poll; command: [root.cli, "snapshot"]; stdout: StdioCollector { waitForEnd: true; onStreamFinished: { if (text.length <= 262144) root.take(text) } } }
  Process { id: action; onExited: function(code) { if (root.queue.length) { var n = root.queue[0]; root.queue = root.queue.slice(1); root.lastVerb = n[0]; root.pending = true; pendingTimeout.restart(); action.command = [root.cli].concat(n); action.running = true; return } root.actionDone = true; if (root.lastVerb === "agent-dir") { if (code === 0) { root.editingFolder = false; root.focusContent() } else root.say("Folder not found · enter an existing path") } if (["run", "load", "unload", "share"].indexOf(root.lastVerb) < 0) root.pending = false; if (code !== 0 && root.lastVerb === "update") root.say("update failed · log"); root.refresh() } }
  Process { id: agentLaunch; onExited: function(code) { root.refresh(); if (code === 0) root.dismiss() } }
  Process { id: copy; onExited: function(code) { if (code === 0) { root.copied = true; copiedTimer.restart(); linkOverlay.close(); root.say("link copied") } else root.copyError = code === 127 ? "wl-copy is missing. Select the URL to copy it manually." : "Copy failed. Try again or select the URL." } }
  Process { id: logOpen; command: ["omarchy-launch-tui", "--app-id=org.omarchy.local-ai-log", "less", "+G", root.stateDir + "/log"] }
  Timer { interval: root.pending ? 1000 : root.working ? 2000 : root.panelActive ? 10000 : 60000; running: root.active || root.pending || root.working; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
  Timer { id: pendingTimeout; interval: 20000; onTriggered: root.pending = false }
  Timer { interval: 1000; running: root.working; repeat: true; triggeredOnStart: true; onTriggered: root.tick() }
  Timer { id: toastTimer; interval: 3500; onTriggered: root.toast = "" }
  Timer { id: copiedTimer; interval: 1400; onTriggered: root.copied = false }
  // Sharing opens a fixed overlay; copying is an explicit action.
  onSnapChanged: { if (lastVerb === "share" && slotSel !== "" && view === "model" && !working) { var m = Ui.modelById(snap, slotSel); if (m && m.shareUrl) { lastVerb = ""; activate("copy:" + slotSel) } } }
  onToneChanged: cursor = 0
  onViewChanged: { cursor = 0; launchModelOpen = false; editingFolder = false; Qt.callLater(function() { scrollBy(-1e9) }) }

  Controls.Popup {
    id: linkOverlay
    parent: root.overlayHost
    x: 0; y: 0
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    padding: Style.space(16)
    modal: true
    dim: false
    focus: true
    closePolicy: Controls.Popup.CloseOnEscape
    background: Rectangle { color: root.popupBg }
    onOpened: { urlText.forceActiveFocus(); urlText.selectAll() }
    onClosed: { root.copyUrl = ""; root.copyError = ""; root.focusContent() }
    contentItem: Item {
      Column {
        id: linkHeading
        width: parent.width
        spacing: Style.space(8)
        PanelSectionHeader { width: parent.width; text: "Share model"; foreground: root.ink; fontFamily: root.mono }
        Text { textFormat: Text.PlainText; width: parent.width; text: "Copy this URL to use the model on your tailnet."; color: root.dim; font.family: root.mono; font.pixelSize: Style.font.bodySmall; wrapMode: Text.WordWrap }
      }
      Controls.ScrollView {
        anchors { top: linkHeading.bottom; bottom: linkActions.top; left: parent.left; right: parent.right; topMargin: Style.space(16); bottomMargin: Style.space(16) }
        clip: true
        Controls.TextArea {
          id: urlText
          Keys.priority: Keys.BeforeItem
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || (event.key === Qt.Key_C && (event.modifiers & Qt.ControlModifier))) { root.copyLink(); event.accepted = true }
          }
          text: root.copyUrl
          readOnly: true
          selectByMouse: true
          wrapMode: TextEdit.WrapAnywhere
          color: root.ink
          selectionColor: root.selectedFill
          selectedTextColor: root.ink
          font.family: root.mono
          font.pixelSize: Style.font.body
          background: Rectangle { color: root.recessed }
        }
      }
      Column {
        id: linkActions
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        spacing: Style.space(12)
        Text { textFormat: Text.PlainText; visible: root.copyError !== ""; width: parent.width; text: root.copyError; color: root.urgent; font.family: root.mono; font.pixelSize: Style.font.bodySmall; wrapMode: Text.WordWrap }
        Row {
          spacing: Style.space(8)
          Button { text: copy.running ? "Copying…" : "Copy URL"; enabled: !copy.running; bordered: true; foreground: root.ink; fontFamily: root.mono; onClicked: root.copyLink() }
          Button { text: "Close"; bordered: true; foreground: root.ink; fontFamily: root.mono; onClicked: linkOverlay.close() }
        }
      }
    }
  }

  Item {
    id: keys
    anchors.fill: parent
    focus: true
    Keys.priority: Keys.BeforeItem
    Keys.onPressed: function(event) {
      if (root.editingFolder) return
      var k = event.key, r = root.cursorRow()
      if (k === Qt.Key_Escape) { if (root.editingFolder) { root.editingFolder = false; root.focusContent() } else if (root.agentOpen || root.launchModelOpen) { root.agentOpen = false; root.launchModelOpen = false; root.cursor = 0 } else if (root.view === "home" && root.launcherOpen) { root.launcherOpen = false; root.cursor = 0 } else if (root.view !== "home") root.back(); else root.dismiss() }
      else if (k === Qt.Key_Tab || k === Qt.Key_Backtab) { var direction = (event.modifiers & Qt.ShiftModifier) || k === Qt.Key_Backtab ? -1 : 1; root.switchRequested(direction) }
      else if (k === Qt.Key_O && (event.modifiers & Qt.ControlModifier)) root.editFolder()
      else if (k === Qt.Key_PageDown || k === Qt.Key_PageUp) root.scrollBy((k === Qt.Key_PageDown ? 1 : -1) * root.viewportHeight * 0.85)
      else if (k === Qt.Key_Home || k === Qt.Key_End) root.scrollBy(k === Qt.Key_Home ? -1e9 : 1e9)
      else if (k === Qt.Key_Down || event.text === "j") root.moveCursor(1)
      else if (k === Qt.Key_Up || event.text === "k") root.moveCursor(-1)
      else if (k === Qt.Key_Return || k === Qt.Key_Enter) { if (r) root.activate(r.action) }
      else if ((k === Qt.Key_Left || k === Qt.Key_Right) && root.view === "card") { var g = Ui.cardByHw(root.snap, root.hw), n = g ? g.keys.length : 1; root.count = Math.max(1, Math.min(n, root.count + (k === Qt.Key_Right ? 1 : -1))); root.pick = "" }
      else if (k === Qt.Key_Backspace && root.view !== "home") root.back()
      else return
      event.accepted = true
    }
    Column {
      id: content
      anchors.left: parent.left; anchors.right: parent.right
      spacing: Style.space(10)
      Item { // Breadcrumbs wrap on narrow screens; every destination is a link.
        id: crumb
        visible: root.ui.path.length > 1; width: parent.width
        height: visible ? crumbFlow.implicitHeight + Style.space(12) : 0
        Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: root.hairline }
        Flow {
          id: crumbFlow
          x: Style.space(6); y: Style.space(6); width: parent.width - Style.space(12); spacing: Style.space(2)
          Repeater { model: root.ui.path
            Button {
              required property var modelData; required property int index
              objectName: "breadcrumb-" + index
              text: (index ? "› " : "") + modelData.n
              width: Math.min(implicitWidth, crumbFlow.width); clip: true; leftAlign: true
              fontFamily: root.mono; fontSize: Style.font.caption
              foreground: index === root.ui.path.length - 1 ? root.ink : root.dim
              horizontalPadding: Style.space(6); verticalPadding: Style.space(4)
              focusable: true; tooltipText: modelData.n
              onClicked: root.navigateCrumb(modelData.action)
            }
          }
        }
      }
      Column {
        id: folderEditor
        visible: root.editingFolder
        width: parent.width
        spacing: Style.space(6)
        Controls.TextField {
          id: folderInput
          width: parent.width
          color: root.ink
          selectionColor: root.selectedFill
          selectedTextColor: root.ink
          font.family: root.mono
          font.pixelSize: Style.font.bodySmall
          placeholderText: "Project folder path"
          background: Rectangle { color: root.popupBg; border.color: root.dim; border.width: 1 }
          onAccepted: root.saveFolder()
          Keys.onEscapePressed: { root.editingFolder = false; root.focusContent() }
        }
        Row {
          spacing: Style.space(6)
          Button { text: "Save folder"; enabled: !root.pending && folderInput.text !== ""; bordered: true; foreground: root.ink; fontFamily: root.mono; onClicked: root.saveFolder() }
          Button { text: "Cancel"; bordered: true; foreground: root.ink; fontFamily: root.mono; onClicked: { root.editingFolder = false; root.focusContent() } }
        }
      }
      LocalAiRow {
        id: folderRow
        visible: !root.editingFolder && !root.working && (root.view === "model" || (root.view === "home" && root.launcherOpen))
        height: visible ? implicitHeight : 0
        width: parent.width
        p: root
        r: ({ type: "row", compact: true, label: "Project folder", value: (root.snap.agents || {}).directory || Quickshell.env("HOME"), action: "choose-folder" })
      }
      Item { // Rows share the page viewport with headers, editors and bottom actions.
        id: body
        width: parent.width
        readonly property real inset: 0
        height: list.implicitHeight + inset * 2
        Column {
          id: list
          anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: body.inset; spacing: Style.space(10)
          Repeater { id: rowsRep; model: root.ui.rows
            LocalAiRow { required property var modelData; required property int index; objectName: "content-row-" + index; r: modelData; p: root; x: r.child ? Style.space(18) : 0; width: list.width - x; cursor: index === root.cursorAt } }
        }
        function reveal(i) { // keep the cursor row in view
          var it = i < root.ui.rows.length ? rowsRep.itemAt(i) : footRep.itemAt(i - root.ui.rows.length); if (!it) return
          root.revealItem(it)
        }
        Connections { target: root; function onCursorAtChanged() { if (root.cursorAt >= 0) Qt.callLater(function() { body.reveal(root.cursorAt) }) } }
      }
      Column { // Bottom actions remain reachable through the same scroll viewport.
        id: foot
        visible: root.ui.foot.length > 0; width: parent.width; spacing: 0
        Rectangle { width: parent.width; height: 1; color: root.hairline }
        Column { anchors.left: parent.left; anchors.right: parent.right; anchors.margins: body.inset; spacing: Style.space(10); topPadding: Style.space(12); bottomPadding: Style.space(12)
          Repeater { id: footRep; model: root.ui.foot
            LocalAiRow { required property var modelData; required property int index; objectName: "footer-row-" + index; r: modelData; p: root; width: parent.width; cursor: root.ui.rows.length + index === root.cursorAt } } }
      }
      Rectangle { // ---- a word that passes
        id: toastBox
        visible: root.toast !== ""; width: parent.width; height: visible ? Style.space(28) : 0; color: root.recessed
        Text { textFormat: Text.PlainText; anchors.left: parent.left; anchors.leftMargin: Style.space(12); anchors.verticalCenter: parent.verticalCenter; text: root.toast; color: root.dim; font.family: root.mono; font.pixelSize: Style.font.caption }
      }
    }
  }
}
