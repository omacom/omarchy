import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../panels/tailscale" as Tailscale

// The models that run on hardware you own, and the memory they run in: one
// bar across the top that splits this machine's RAM between apps, each running
// model and what's free, then a line per model.
Panel {
  id: root
  moduleName: "omarchy.local-models"
  ipcTarget: "omarchy.local-models"
  manageIpc: false
  visible: engine.relevant

  // Items inside the panel's lazily built content, null until it first
  // opens. Code inside the content reaches its own ids directly.
  readonly property Item panelFlick: panel.loadedContent ? panel.loadedContent.panelFlick : null
  readonly property Item column: panel.loadedContent ? panel.loadedContent.column : null

  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color urgent: bar ? bar.urgent : Commons.Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property color surface: Commons.Color.popups.background
  readonly property color track: Style.selectedFillFor(foreground, Commons.Color.accent)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property var lines: engine.lines

  // A model on another machine of the tailnet carries its host. Away, it
  // offers nothing; unpaired, only pairing, which is what fetches its key.
  // Paired, it can be used or disconnected from while its host runs it, and
  // offers nothing while it doesn't: it's never started or stopped from here.
  // This machine's own models offer sharing only while running: where
  // Tailscale can serve them, or where one is shared already, so it can
  // always be stopped. A stopped model stays shared and is served again when
  // it starts, but says nothing about it until then. One the catalog has
  // moved on from offers its update, running or stopped, but not while it
  // loads, stops or is being updated already.
  function localActions(model, canShare) {
    var actions = []
    if (model.unit === "removing" || model.unit === "installing") return actions
    if (model.host) {
      if (model.offline) return actions
      if (!model.paired) return ["pair"]
      return model.unit === "active" ? ["disconnect", "launch"] : []
    } else {
      if (model.update && model.updating !== true && ["active", "inactive", "failed"].indexOf(model.unit) >= 0) actions.push("update")
      if (model.unit === "active" && (canShare || model.shared === true)) actions.push("share")
    }
    if (model.unit !== "deactivating") actions.push("toggle")
    if (model.unit === "active") actions.push("launch")
    return actions
  }

  readonly property var actionKinds: ({ toggle: "modelToggle", launch: "modelLaunch", pair: "modelPair", disconnect: "modelDisconnect", share: "modelShare", update: "modelUpdate" })

  function modelId(model) {
    return model.host ? model.host + "/" + model.recipe : model.recipe
  }

  // A stopped model with an error to explain, which links to its logs. Only
  // this machine's own: a tailnet model's logs live on its host. A tailnet
  // model can fail to pair instead, which links to what pairing printed.
  function localFailed(model) {
    if (model.host) return pairFailure(model) !== null
    return ["active", "activating", "deactivating", "removing"].indexOf(model.unit) < 0 && String(model.error || "") !== "" && !errorRead(model)
  }

  // Errors whose logs have been opened, by recipe. The line drops one at once
  // rather than waiting for the engine to forget it, which an engine older
  // than its dismiss never does. A model that starts again can fail anew, so
  // its entry goes then, as it does once the engine has forgotten the error.
  property var readErrors: ({})

  function errorRead(model) {
    return !!model && !model.host && readErrors[model.recipe] === String(model.error || "")
  }

  function markErrorRead(model) {
    var read = Object.assign({}, readErrors)
    read[model.recipe] = String(model.error || "")
    readErrors = read
  }

  Connections {
    target: engine
    function onLocalModelChanged() {
      var models = engine.localModel.models || {}
      var read = {}
      var changed = false
      for (var recipe in root.readErrors) {
        var model = models[recipe]
        if (model && ["active", "activating"].indexOf(model.unit) < 0 && String(model.error || "") === root.readErrors[recipe]) read[recipe] = root.readErrors[recipe]
        else changed = true
      }
      if (changed) root.readErrors = read
    }
  }

  // A failed pairing still to explain: not once the model is paired, its host
  // is away (its line says so instead), or it's being paired again.
  function pairFailure(model) {
    if (!model || !model.host || model.paired === true || String(model.offline || "") !== "") return null
    var id = modelId(model)
    return engine.pairingId === id ? null : (engine.pairFailures[id] || null)
  }

  function showLocalLogs(model) {
    var failure = model.panelSetup ? { output: model.output } : pairFailure(model)
    // A pairing's output is all there is of it, and so is that of a setup
    // that failed before its download began, so the terminal shows that
    // again and closes as failed, the way a pairing in a terminal ended.
    // An error that has been read leaves the model's line. The engine forgets
    // a model's failure after its logs have printed it, keeping their status
    // for the terminal's last line; an engine without dismiss changes nothing.
    var recipe = Util.shellQuote(String(model.recipe))
    var command = failure ? "printf %s " + Util.shellQuote(String(failure.output)) + "; false"
      : "omarchy-agent-local logs " + recipe + "; logs=$?; omarchy-agent-local dismiss " + recipe + " >/dev/null 2>&1; (exit $logs)"
    Util.execArgv(["omarchy-launch-floating-terminal-with-presentation", command])
    // A failed pairing lives only here.
    if (failure && !model.panelSetup) engine.dismissPairFailure(modelId(model))
    else if (!failure) markErrorRead(model)
    root.close()
  }

  // What a local model makes, in a word.
  function kindLabel(model) {
    return model.kind === "image" ? Commons.I18n.t("localModels.kindImage")
      : model.kind === "video" ? Commons.I18n.t("localModels.kindVideo")
      : model.kind === "music" ? Commons.I18n.t("localModels.kindMusic")
      : Commons.I18n.t("localModels.kindText")
  }

  // Image, video and music models are made with in Fantasi rather than an agent.
  function makesInFantasi(model) {
    return ["image", "video", "music"].indexOf(model.kind) >= 0
  }

  // Fantasi's launcher icon. The icon set's drawing is redrawn in place on a
  // theme or set switch, so its URL carries the set's revision to reload it,
  // as the app library's icons do; without one, the packaged icon.
  readonly property string fantasiSetIcon: (Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share") + "/icons/hicolor/scalable/apps/fantasi.svg"
  property int iconRevision: 0
  property bool fantasiDrawn: false
  readonly property string fantasiIcon: fantasiDrawn ? Util.fileUrl(fantasiSetIcon) + "?theme=" + iconRevision : Quickshell.iconPath("fantasi", true)

  FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/current/icons.revision"
    watchChanges: true
    printErrors: false
    onFileChanged: {
      root.iconRevision++
      fantasiSetIconFile.reload()
    }
  }

  FileView {
    id: fantasiSetIconFile
    path: root.fantasiSetIcon
    printErrors: false
    onLoaded: root.fantasiDrawn = true
    onLoadFailed: root.fantasiDrawn = false
  }

  function runLocalAction(model, action) {
    if (action === "launch") {
      // An image or video model makes pictures or clips in Fantasi rather than running an agent.
      // An open Fantasi takes the model and comes to the front, so this always opens.
      if (makesInFantasi(model)) Util.execArgv(["uwsm-app", "--", "fantasi", "open", "--model", modelId(model)])
      else Util.execArgv(["omarchy-agent", "--local-model", modelId(model)])
      root.close()
    } else if (action === "toggle") {
      var running = model.unit === "active" || model.unit === "activating"
      // Greyed out means not startable by any route: click, Return or Enter.
      if (!running && localStartBlocked(model)) return
      // The panel has no terminal: a start that fails records its reason,
      // which the model's line shows.
      Util.execArgv(["omarchy-agent-local", running ? "stop" : "start", model.recipe])
    } else if (action === "share") {
      Util.execArgv(["omarchy-agent-local", "share", model.recipe].concat(model.shared ? ["--off"] : []))
    } else if (action === "update") {
      // In the background, like a setup: the model's line says it's updating
      // until its new runtime or weights are in place.
      Util.execArgv(["omarchy-agent-local", "update", "--detach", model.recipe])
    } else if (action === "pair") {
      // Pairs in the background while the panel stays open; a failure shows
      // on the model's line.
      engine.pair(model)
      if (engine.pairingId === modelId(model)) landAfterPair = modelId(model)
    } else if (action === "disconnect") {
      Util.execArgv(["omarchy-agent-local", "forget", modelId(model)])
    }
  }

  // The model being paired from the panel. Once it is, and running there, the
  // keyboard cursor lands on its terminal, so Return opens an agent on it.
  // The survey that shows it paired can trail the pairing itself, and a model
  // still starting on its host has no terminal yet, so this waits for the
  // terminal rather than for the pairing to end, while the panel stays open.
  property string landAfterPair: ""
  function landOnPaired() {
    if (landAfterPair === "" || engine.pairingId !== "") return
    if (!root.opened || engine.pairFailures[landAfterPair]) {
      landAfterPair = ""
      return
    }
    for (var p = 0; p < lines.length; p++) {
      var model = lines[p].model
      if (!model || !model.host || modelId(model) !== landAfterPair || model.paired !== true) continue
      if (localActions(model, engine.canShare).indexOf("launch") < 0) return
      landAfterPair = ""
      pointAt("modelLaunch", p)
      return
    }
  }
  onLinesChanged: Qt.callLater(landOnPaired)
  Connections {
    target: engine
    function onPairingIdChanged() { Qt.callLater(root.landOnPaired) }
  }

  // How long ago an offline host was last seen, in the panel's own words.
  function lastSeenText(model) {
    var seen = Number(model && model.last_seen_ms || 0)
    if (!(seen > 0)) return ""
    var ago = Math.max(0, Date.now() - seen)
    return ago < 60000 ? Commons.I18n.t("localModels.networkJustNow") : Commons.I18n.t("localModels.networkAgo").arg(formatDuration(ago))
  }

  function formatDuration(ms) {
    if (!(ms > 0)) return Commons.I18n.t("localModels.durationNow")
    var minutes = Math.floor(ms / 60000)
    var hours = Math.floor(minutes / 60)
    var days = Math.floor(hours / 24)
    if (days > 0) return Commons.I18n.t("localModels.durationDaysHours").arg(Commons.I18n.formatNumber(days)).arg(Commons.I18n.formatNumber(hours % 24))
    if (hours > 0) return Commons.I18n.t("localModels.durationHoursMinutes").arg(Commons.I18n.formatNumber(hours)).arg(Commons.I18n.formatNumber(minutes % 60))
    return Commons.I18n.t("localModels.durationMinutes").arg(Commons.I18n.formatNumber(Math.max(1, minutes)))
  }

  // Neither the tailnet nor memory has a change signal, so the panel looks at
  // both when it opens and again every 2 seconds while it stays open, never
  // while closed: a model another machine starts or stops sharing shows up or
  // goes at once, and memory an app lets go of shows as free. A survey is one
  // fetch per online peer, half a second, and never overlaps.
  Timer {
    interval: 2000
    running: root.opened
    repeat: true
    onTriggered: {
      engine.refreshNetwork()
      engine.readMemory()
    }
  }

  // The setup runs on in the background and reports to status.json, where it
  // becomes the model's own line, which draws the download as it goes. A
  // first one installs Podman before that, on the same line.
  function downloadLocal(recipe) {
    // A Spark cabled to this one: its setup asks for the other machine's password once, so it
    // runs in a terminal.
    if (recipe.link) {
      Util.execArgv(["omarchy-launch-floating-terminal-with-presentation", "omarchy-agent-local link setup"])
      root.close()
      return
    }
    engine.setUp(recipe)
  }

  function linkTitle(link) {
    return link.host ? Commons.I18n.t("localModels.linkOffer").arg(link.host) : Commons.I18n.t("localModels.linkOfferUnnamed")
  }

  // What a local model needs at its peak, as the catalog measured it on
  // this kind of machine; 0 when it hasn't been measured here.
  function localNeedsGib(model) {
    if (!model) return 0
    var recipes = engine.localRecipes || []
    for (var i = 0; i < recipes.length; i++) {
      if (recipes[i] && recipes[i].id === model.recipe) return Number(recipes[i].memory_gib) || 0
    }
    return 0
  }

  function localStartBlocked(model) {
    return !!model && model.unit !== "active" && model.unit !== "activating" && model.fits === false
  }

  // A start or stop runs steadily to 90% at the time the last one took, then
  // keeps creeping toward 98%, so one that runs long reads as slow, not stuck.
  function phaseProgress(elapsed, expected) {
    if (!(expected > 0)) return 0
    if (elapsed <= expected) return 0.9 * elapsed / expected
    return 0.9 + 0.08 * (1 - Math.exp(-(elapsed - expected) / expected))
  }

  property double loadNowMs: Date.now()
  readonly property bool localLoading: lines.some(function(line) {
    var model = line.model
    return model && (["activating", "deactivating", "removing"].indexOf(model.unit) >= 0 || (model.install && model.install.phase === "dependencies"))
  })
  Timer {
    interval: 250
    running: root.opened && root.localLoading
    repeat: true
    triggeredOnStart: true
    onTriggered: root.loadNowMs = Date.now()
  }

  // ----------------------------------------------------------------- memory
  //
  // This machine's RAM split into what apps hold, what each running model
  // holds, and what's free for the next one to load into.

  // The memory a model on this machine holds once it's loaded, as the engine
  // last measured it.
  function heldGib(model) {
    if (!model || model.host || ["active", "activating", "deactivating"].indexOf(model.unit) < 0) return 0
    return model.observed ? Math.max(0, Number(model.observed.ram_used_gib) || 0) : 0
  }

  readonly property var memory: {
    var total = engine.memoryTotalGib
    var free = Math.min(total, engine.memoryFreeGib)
    var slices = []
    var held = 0
    for (var i = 0; i < lines.length; i++) {
      var gib = heldGib(lines[i].model)
      if (gib <= 0) continue
      slices.push({ index: i, gib: gib })
      held += gib
    }
    return { total: total, free: free, held: held, apps: Math.max(0, total - free - held), slices: slices }
  }

  // The line the bar speaks for: the one under the pointer, else the one the
  // keyboard cursor is in. A running model lights its slice; a stopped one
  // lays what it needs over the free space.
  property int hoveredLine: -1
  readonly property int previewLine: hoveredLine >= 0 ? hoveredLine : lineIndexOfKey()
  readonly property var preview: {
    var line = lines[previewLine]
    var model = line ? line.model : null
    if (!model || model.host || model.unit === "installing" || model.unit === "removing") return null
    if (heldGib(model) > 0) return { held: true, index: previewLine, name: model.name || model.recipe, gib: heldGib(model) }
    var needs = localNeedsGib(model)
    if (!(needs > 0)) return null
    // The engine's verdict decides, as it does for the play button; the bar
    // only shows by how much.
    return { held: false, needs: needs, fits: model.fits !== false }
  }

  function memoryCaption() {
    var p = preview
    var gb = function(value) { return Commons.I18n.formatNumber(Math.round(value)) }
    if (p && p.held) return Commons.I18n.t("localModels.memoryHeldBy").arg(p.name).arg(gb(p.gib))
    if (p && p.fits) return Commons.I18n.t("localModels.memoryFits").arg(gb(Math.max(0, memory.free - p.needs)))
    if (p && p.needs > memory.free) return Commons.I18n.t("localModels.memoryShort").arg(gb(p.needs - memory.free))
    if (p) return Commons.I18n.t("localModels.notEnoughMemory")
    var parts = [Commons.I18n.t("localModels.memoryApps").arg(gb(memory.apps))]
    if (memory.held > 0) parts.push(Commons.I18n.t("localModels.memoryModels").arg(gb(memory.held)))
    return parts.join(" · ")
  }

  // ------------------------------------------------------------------- hide

  property var deleteTarget: null
  function deleteSelected() {
    var target = keyTarget
    if (!target || ["modelToggle", "modelLaunch", "modelPair", "modelDisconnect", "modelShare", "modelUpdate", "modelHeader", "localDownload"].indexOf(target.kind) < 0) return
    var model = lines[target.index].model
    // A setup the panel still owns has nothing on disk to delete, so it asks
    // nothing: a failure is forgotten and one waiting its turn is dropped. The
    // one starting can't be stopped midway through installing packages.
    if (model && model.panelSetup) {
      if (model.install.phase === "failed") engine.dismissSetupFailure()
      else if (model.install.phase === "waiting") engine.unqueueSetup(model.recipe)
      return
    }
    deleteTarget = lines[target.index]
  }

  // A model on this machine is removed, weights and all; anything else (an
  // offer, the cabled Spark, a tailnet model) is only hidden from the panel.
  function confirmDelete() {
    var target = deleteTarget
    deleteTarget = null
    if (!target) return
    if (target.model && !target.model.host) {
      Util.execArgv(["omarchy-agent-local", "remove", target.model.recipe])
    } else if (bar && bar.shell) {
      var next = JSON.parse(JSON.stringify(settings || {}))
      if (!next.providers) next.providers = {}
      next.providers[target.id] = Object.assign({}, next.providers[target.id] || {}, { enabled: false })
      bar.shell.updateEntryInline(moduleName, next)
    }
  }

  function deleteMessage(target) {
    if (!target) return ""
    if (target.model && target.model.host) return Commons.I18n.t("localModels.networkHideConfirm").arg(target.model.name || target.model.recipe).arg(target.model.host)
    if (target.model) return Commons.I18n.t("localModels.removeConfirm").arg(target.model.name || target.model.recipe)
    if (target.offer && target.offer.link) return Commons.I18n.t("localModels.linkHideConfirm").arg(target.name)
    return Commons.I18n.t("localModels.hideOfferConfirm").arg(target.name)
  }

  // -------------------------------------------------------------------- add
  //
  // The + lists what can be added: the catalog's recipes that fit this
  // machine and aren't set up yet, recommended first, then the tailnet's
  // models hidden from the page. Each recipe downloads tens of GB in the
  // background, its line showing how far along it is.
  property bool adding: false

  readonly property var addRecipes: {
    var models = engine.localModel && engine.localModel.models ? engine.localModel.models : {}
    var recipes = (engine.localRecipes || []).filter(function(recipe) {
      return recipe && recipe.available && !models[recipe.id]
    })
    recipes.sort(function(a, b) { return (b.best ? 1 : 0) - (a.best ? 1 : 0) })
    return recipes
  }

  readonly property var addNetwork: {
    var network = engine.networkModels || {}
    var hidden = []
    for (var id in network)
      if (!engine.lineEnabled("net:" + id)) hidden.push(network[id])
    hidden.sort(function(a, b) { return String(a.id).localeCompare(String(b.id)) })
    return hidden
  }

  readonly property var addRows: addRecipes.concat(addNetwork)

  function recipeFacts(recipe) {
    if (recipe.link) return Commons.I18n.t("localModels.linkSetUp")
    var facts = []
    if (recipe.memory_gib != null) facts.push(Commons.I18n.t("localModels.memoryFact").arg(Commons.I18n.formatNumber(recipe.memory_gib, 0)))
    if (recipe.context != null) facts.push(Commons.I18n.t("localModels.contextFact").arg(Commons.I18n.formatNumber(Math.round(recipe.context / 1024), 0)))
    if (recipe.decode_tok_s != null) facts.push(Commons.I18n.t("localModels.speedFact").arg(Commons.I18n.formatNumber(Math.round(recipe.decode_tok_s), 0)))
    return facts.join(" · ")
  }

  // What a running network model is, in place of the memory its host
  // measures: its output speed there, and its context.
  function remoteStats(model) {
    var facts = []
    var decode = Math.round(Number(model.decode_tok_s))
    if (decode > 0) facts.push(Commons.I18n.t("localModels.speedFact").arg(Commons.I18n.formatNumber(decode, 0)))
    if (Number(model.ctx) > 0) facts.push(Commons.I18n.t("localModels.contextFact").arg(Commons.I18n.formatNumber(Math.round(Number(model.ctx) / 1024), 0)))
    return facts.join(" · ")
  }

  function networkFacts(model) {
    var facts = [Commons.I18n.t("localModels.networkOnHost").arg(model.host)]
    if (Number(model.ctx) > 0) facts.push(Commons.I18n.t("localModels.contextFact").arg(Commons.I18n.formatNumber(Math.round(Number(model.ctx) / 1024), 0)))
    facts.push(model.offline ? Commons.I18n.t("localModels.networkOffline")
      : model.unit === "active" ? Commons.I18n.t("localModels.networkRunning") : Commons.I18n.t("localModels.loadingMeter"))
    return facts.join(" · ")
  }

  function showNetworkModel(model) {
    if (!model || !bar || !bar.shell) return
    var next = JSON.parse(JSON.stringify(settings || {}))
    if (!next.providers) next.providers = {}
    next.providers["net:" + model.id] = Object.assign({}, next.providers["net:" + model.id] || {}, { enabled: true })
    bar.shell.updateEntryInline(moduleName, next)
    stopAdding()
  }

  function chooseAddRow(index) {
    if (index < addRecipes.length) {
      engine.setUp(addRecipes[index])
      stopAdding()
    } else {
      showNetworkModel(addNetwork[index - addRecipes.length])
    }
  }

  // A download's speed beside its bar, and how much of it has arrived on the
  // bar's tooltip, in the decimal units downloads are counted in. Nothing
  // while the speed is still zero or the total unknown.
  function downloadRate(rate) {
    return rate > 0 ? Commons.I18n.t("localModels.downloadRate").arg(Commons.I18n.formatNumber(Math.round(rate / 1e6), 0)) : ""
  }

  function downloadAmount(done, total) {
    return total > 0 ? Commons.I18n.t("localModels.downloadValue").arg(Commons.I18n.formatNumber(done / 1e9, 1)).arg(Commons.I18n.formatNumber(total / 1e9, 1)) : ""
  }

  // What pressing update means: how much it downloads, once the engine has
  // sized it, and that the model restarts.
  function updateTip(model) {
    var bytes = Number(model && model.update && model.update.download_bytes) || 0
    if (bytes >= 1e8) return Commons.I18n.t("localModels.updateDownloadGb").arg(Commons.I18n.formatNumber(bytes / 1e9, 1))
    if (bytes > 0) return Commons.I18n.t("localModels.updateDownloadMb").arg(Commons.I18n.formatNumber(Math.max(1, Math.round(bytes / 1e6)), 0))
    return Commons.I18n.t("localModels.update")
  }

  function startAdding() {
    adding = true
    // A package upgrade may have brought new recipes.
    engine.refreshLocal()
  }

  function stopAdding() {
    adding = false
    root.focusKeys()
  }

  // ------------------------------------------------------------------- keys
  //
  // The keyboard walks everything on the page that does something, in
  // reading order, one row at a time: the hero's +, then each line's buttons
  // and its error link, or the rows to add while adding. Up and down change
  // rows, left and right move along one. Hovering moves the same cursor, so
  // only one thing is lit.
  property bool cursorActive: false

  readonly property var keyRows: {
    var rows = [[{ kind: "add", index: 0 }]]
    if (adding) {
      for (var r = 0; r < addRows.length; r++) rows.push([{ kind: "localAdd", index: r }])
      return rows
    }
    for (var p = 0; p < lines.length; p++) {
      if (lines[p].offer) {
        rows.push([{ kind: "localDownload", index: p }])
        continue
      }
      var actions = localActions(lines[p].model, engine.canShare)
      rows.push(actions.length > 0 ? actions.map(function(action) { return { kind: actionKinds[action], index: p } }) : [{ kind: "modelHeader", index: p }])
      if (localFailed(lines[p].model)) rows.push([{ kind: "modelLogs", index: p }])
    }
    return rows
  }
  property int keyRow: 0
  property int keyColumn: 0
  readonly property var keyTarget: {
    if (!cursorActive || keyRow < 0 || keyRow >= keyRows.length) return null
    var row = keyRows[keyRow]
    return row[Math.min(keyColumn, row.length - 1)]
  }

  function hasKey(kind, index) {
    return !!keyTarget && keyTarget.kind === kind && keyTarget.index === (index || 0)
  }

  function pointAt(kind, index) {
    for (var r = 0; r < keyRows.length; r++) {
      for (var c = 0; c < keyRows[r].length; c++) {
        if (keyRows[r][c].kind === kind && keyRows[r][c].index === (index || 0)) {
          keyRow = r
          keyColumn = c
          cursorActive = true
          return
        }
      }
    }
  }

  // The first arrow only shows where the cursor is, as in the other panels.
  // Arriving on a line lands on its rightmost button: terminal, or play.
  function moveKey(dx, dy) {
    if (keyRows.length === 0) return
    if (!cursorActive) {
      keyRow = clamp(keyRow, 0, keyRows.length - 1)
      keyColumn = 0
      cursorActive = true
      return
    }
    if (dy !== 0) {
      keyRow = clamp(keyRow + dy, 0, keyRows.length - 1)
      var row = keyRows[keyRow]
      var line = ["modelToggle", "modelLaunch", "modelPair", "modelDisconnect", "modelShare", "modelUpdate", "modelHeader", "localDownload"].indexOf(row[0].kind) >= 0
      keyColumn = line ? row.length - 1 : Math.min(keyColumn, row.length - 1)
    } else if (dx !== 0) {
      keyRow = clamp(keyRow, 0, keyRows.length - 1)
      keyColumn = clamp(Math.min(keyColumn, keyRows[keyRow].length - 1) + dx, 0, keyRows[keyRow].length - 1)
    }
  }

  // The line the cursor is in, by its position on the page.
  function lineIndexOfKey() {
    var target = keyTarget
    if (!target || adding) return -1
    if (["modelToggle", "modelLaunch", "modelPair", "modelDisconnect", "modelShare", "modelUpdate", "modelHeader", "modelLogs", "localDownload"].indexOf(target.kind) >= 0) return target.index
    return -1
  }

  function activateSelection() {
    var target = keyTarget
    if (!target) refreshNow()
    else if (target.kind === "add") adding ? stopAdding() : startAdding()
    else if (target.kind === "localAdd") chooseAddRow(target.index)
    else if (["modelToggle", "modelLaunch", "modelPair", "modelDisconnect", "modelShare", "modelUpdate"].indexOf(target.kind) >= 0)
      runLocalAction(lines[target.index].model, { modelToggle: "toggle", modelLaunch: "launch", modelPair: "pair", modelDisconnect: "disconnect", modelShare: "share", modelUpdate: "update" }[target.kind])
    else if (target.kind === "localDownload") downloadLocal(lines[target.index].offer)
    else if (target.kind === "modelLogs") showLocalLogs(lines[target.index].model)
  }

  function resetKeys() {
    cursorActive = false
    keyRow = 0
    keyColumn = 0
    Qt.callLater(function() { if (adding) pointAt("localAdd", 0) })
  }
  onAddingChanged: resetKeys()

  // Hands the keyboard back to the panel after an inline edit.
  function focusKeys() {
    if (panel.loadedContent) panel.loadedContent.forceActiveFocus()
  }

  // Keeps whatever the cursor lands on inside the scrolled view.
  function revealItem(item) {
    if (!item || !column || !panelFlick || !panelFlick.interactive) return
    var top = item.mapToItem(column, 0, 0).y
    var margin = Style.space(12)
    if (top - margin < panelFlick.contentY)
      panelFlick.contentY = Math.max(0, top - margin)
    else if (top + item.height + margin > panelFlick.contentY + panelFlick.height)
      panelFlick.contentY = Math.min(panelFlick.contentHeight - panelFlick.height, top + item.height + margin - panelFlick.height)
  }

  function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)) }
  function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

  readonly property bool localBlocked: lines.some(function(line) { return line.model && line.model.fits === false })

  function refreshNow() {
    engine.refreshLocal()
    engine.refreshNetwork()
    engine.readMemory()
  }

  // Vendor marks live with the agents plugin, where the launchers and
  // notifications find them too; a mark it lacks falls back to the bar glyph.
  function colorLuminance(color) {
    var channel = function(value) {
      return value <= 0.03928 ? value / 12.92 : Math.pow((value + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b)
  }

  function markCandidates(vendor, surfaceColor) {
    var id = String(vendor || "local")
    var candidates = []
    if (colorLuminance(surfaceColor || Commons.Color.background) >= 0.5)
      candidates.push(Qt.resolvedUrl("../agents/assets/" + id + "-light.svg"))
    candidates.push(Qt.resolvedUrl("../agents/assets/" + id + ".svg"))
    return candidates
  }

  property bool localListed: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (!opened) {
    // A model paired here that starts after the panel closes doesn't move
    // the cursor the next time it opens.
    landAfterPair = ""
    hoveredLine = -1
  } else {
    deleteTarget = null
    adding = false
    resetKeys()
    if (panelFlick) panelFlick.contentY = 0
    engine.readMemory()
    // "Doesn't fit" was true when a model last started or stopped; memory an
    // app has since let go of only shows after a fresh look, once per open.
    if (localBlocked) Util.execArgv(["omarchy-agent-local", "status", "--write"])
    engine.refreshNetwork()
    // The listing the + and the offer read is refreshed once per shell run;
    // an update restarts the shell.
    if (!localListed) {
      localListed = true
      engine.refreshLocal()
    }
    Qt.callLater(function() { if (panel.loadedContent) panel.loadedContent.forceActiveFocus() })
  }

  Models {
    id: engine
    settings: root.settings
  }

  ShellIpc {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refreshNow(); return "ok" }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰘚"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.MiddleButton) root.refreshNow()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    // Pairing may bring up the SSH agent's prompt to approve a key, such as
    // 1Password's, which has to take focus and clicks while the panel shows
    // how the pairing goes.
    yielding: engine.pairingId !== ""
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(860))

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias panelFlick: panelFlick
      property alias column: column
      ConfirmDialog {
        anchors.fill: parent
        z: 20
        opened: root.deleteTarget !== null
        onOpenedChanged: {
          // Delete then Return removes, as in every other confirmation.
          selectedIndex = 1
          if (opened) forceActiveFocus()
          else root.focusKeys()
        }
        Keys.onPressed: function(event) {
          handleKey(event)
          event.accepted = true
        }
        message: root.deleteMessage(root.deleteTarget)
        foreground: root.foreground
        background: root.surface
        fontFamily: root.fontFamily
        onCanceled: root.deleteTarget = null
        onConfirmed: root.confirmDelete()
      }
      implicitHeight: column.implicitHeight
      anchors.fill: parent

      onMoveRequested: function(dx, dy) { root.moveKey(dx, dy) }
      onDeleteRequested: root.deleteSelected()
      blocked: root.deleteTarget !== null
      onActivateRequested: root.activateSelection()
      onCloseRequested: {
        if (root.adding) root.stopAdding()
        else root.close()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refreshNow()
      }

      Flickable {
        id: panelFlick
        // Reaches a little into the panel's padding on the left, with the
        // content shifted back, so the box around a lit mark isn't clipped
        // where it overhangs the content's edge.
        readonly property real overhang: Style.space(8)
        anchors.fill: parent
        anchors.leftMargin: -overhang
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar {
          id: panelScroll
          policy: ScrollBar.AsNeeded
        }

        Column {
          id: column
          x: LayoutMirroring.enabled ? (panelFlick.interactive ? panelScroll.width + Style.space(6) : 0) : panelFlick.overhang
          width: panelFlick.width - panelFlick.overhang - (panelFlick.interactive ? panelScroll.width + Style.space(6) : 0)
          spacing: Style.space(16)

          // ---------- Hero: local models · memory free · add ----------
          PanelHero {
            id: hero
            width: parent.width
            title: Commons.I18n.t("localModels.title")
            meta: root.adding ? Commons.I18n.t("localModels.addModel")
              : root.memory.total > 0 ? Commons.I18n.t("localModels.memoryFree").arg(Commons.I18n.formatNumber(Math.round(root.memory.free))).arg(Commons.I18n.formatNumber(Math.round(root.memory.total)))
              : ""
            foreground: root.foreground
            fontFamily: root.fontFamily

            iconComponent: Component {
              Text {
                textFormat: Text.PlainText
                text: button.text
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
              }
            }

            trailingControl: Component {
              HeroButton {
                hasCursor: root.hasKey("add")
                onHovered: root.pointAt("add")
                glyph: root.adding ? "󰅖" : "󰐕"
                tooltip: root.adding ? Commons.I18n.t("localModels.backToModels") : Commons.I18n.t("localModels.addModel")
                onClicked: root.adding ? root.stopAdding() : root.startAdding()
              }
            }
          }

          MemoryBar {
            visible: !root.adding && root.memory.total > 0
            width: column.width
          }

          AddList {
            visible: root.adding
            width: column.width
          }

          Repeater {
            model: root.adding ? [] : root.lines

            ModelSection {
              required property var modelData
              required property int index
              width: column.width
              line: modelData
              lineIndex: index
            }
          }
        }
      }
    }
  }

  // The machine's memory as one bar: apps, then each running model, then
  // what's free, to scale. Under it, what the bar adds up to, or what the
  // line under the pointer or cursor means for it.
  component MemoryBar: Column {
    id: memoryBar
    spacing: Style.space(10)
    readonly property real thickness: Math.max(Style.space(8), Math.round(Style.spacing.controlHeight * 0.3))
    readonly property real gap: Style.space(2)
    readonly property var p: root.preview
    // Every slice is drawn at least this wide, so a small one still shows;
    // whatever that takes comes off the free space.
    readonly property real minSlice: thickness

    function share(gib) {
      return root.memory.total > 0 ? gib / root.memory.total : 0
    }

    PanelSeparator { foreground: root.foreground }

    Item {
      id: barTrack
      width: parent.width
      height: memoryBar.thickness

      Row {
        id: slices
        anchors.fill: parent
        spacing: memoryBar.gap
        readonly property real room: Math.max(0, width - spacing * (root.memory.slices.length + 1))

        // What apps hold, in the track's own color.
        Rectangle {
          height: parent.height
          width: Math.max(memoryBar.minSlice, slices.room * memoryBar.share(root.memory.apps))
          radius: Math.min(height / 2, Style.cornerRadius)
          color: root.alpha(root.foreground, 0.28)
        }

        Repeater {
          model: root.memory.slices

          Rectangle {
            required property var modelData
            readonly property bool lit: !!memoryBar.p && memoryBar.p.held && memoryBar.p.index === modelData.index
            height: parent.height
            width: Math.max(memoryBar.minSlice, slices.room * memoryBar.share(modelData.gib))
            radius: Math.min(height / 2, Style.cornerRadius)
            color: lit ? Commons.Color.accent : root.foreground
            Behavior on width { NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: Style.duration(120) } }
          }
        }

        // Free: an outline, with a stopped model's footprint laid into it.
        Rectangle {
          id: freeSlice
          height: parent.height
          width: Math.max(0, slices.width - x)
          radius: Math.min(height / 2, Style.cornerRadius)
          color: "transparent"
          border.width: Math.max(1, Style.hoverBorderWidth)
          border.color: root.track

          Rectangle {
            readonly property bool shown: !!memoryBar.p && !memoryBar.p.held
            visible: shown
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: shown && root.memory.free > 0 ? Math.min(parent.width, parent.width * memoryBar.p.needs / root.memory.free) : 0
            radius: parent.radius
            color: shown && memoryBar.p.fits ? Commons.Color.accent : Commons.Color.warning
            opacity: 0.75
          }
        }
      }

      HoverHandler { id: barHover }
      PanelToolTip {
        visible: barHover.hovered && !memoryBar.p
        text: Commons.I18n.t("localModels.memoryTooltip")
          .arg(Commons.I18n.formatNumber(Math.round(root.memory.apps)))
          .arg(Commons.I18n.formatNumber(Math.round(root.memory.held)))
          .arg(Commons.I18n.formatNumber(Math.round(root.memory.free)))
        fontFamily: root.fontFamily
      }
    }

    Text {
      width: parent.width
      textFormat: Text.PlainText
      text: root.memoryCaption()
      color: memoryBar.p && !memoryBar.p.held && !memoryBar.p.fits ? Commons.Color.warning : root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }
  }

  // What the + offers, one row each: the catalog's recipes that fit, then
  // the tailnet's hidden models under their own heading.
  component AddList: Column {
    spacing: Style.space(14)

    PanelSeparator { foreground: root.foreground }

    Text {
      visible: root.addRows.length === 0
      width: parent.width
      textFormat: Text.PlainText
      text: Commons.I18n.t("localModels.allInstalled")
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WordWrap
    }

    Repeater {
      model: root.adding ? root.addRows : []

      Column {
        id: addRow
        required property var modelData
        required property int index
        readonly property bool network: index >= root.addRecipes.length
        width: parent.width
        spacing: Style.space(14)

        PanelSectionHeader {
          visible: addRow.network && addRow.index === root.addRecipes.length
          text: Commons.I18n.t("localModels.networkModels")
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        Item {
          id: recipeRow
          readonly property bool hasCursor: root.hasKey("localAdd", addRow.index)
          width: parent.width
          implicitHeight: Math.max(recipeMark.height, recipeBody.implicitHeight)
          onHasCursorChanged: if (hasCursor) root.revealItem(recipeRow)

          // The mark sits beside the name and details together, centred on
          // both, and only it is lit, as on a model's line.
          CursorSurface {
            anchors.fill: recipeMark
            anchors.margins: -Style.space(5)
            z: -1
            hasCursor: recipeRow.hasCursor
            foreground: root.foreground
          }

          VendorMark {
            id: recipeMark
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            // As tall as the name and details, so the lit box frames both.
            size: Math.max(Style.font.heading, recipeBody.implicitHeight - Style.space(10))
            vendor: addRow.modelData.vendor
          }

          Column {
            id: recipeBody
            anchors.left: recipeMark.right
            anchors.leftMargin: Style.space(10)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(4)

            Item {
              width: parent.width
              implicitHeight: recipeName.implicitHeight

              Text {
                id: recipeName
                anchors.left: parent.left
                textFormat: Text.PlainText
                text: String(addRow.modelData.name || addRow.modelData.recipe || addRow.modelData.id)
                color: recipeRow.hasCursor ? Commons.Color.accent : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                font.bold: true
              }

              Text {
                anchors.left: recipeName.right
                anchors.leftMargin: Style.space(8)
                anchors.baseline: recipeName.baseline
                visible: !addRow.network && addRow.modelData.best === true
                textFormat: Text.PlainText
                text: Commons.I18n.t("localModels.recommended")
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }

            // Measured on this machine class, so the speed holds here; a
            // fact the catalog doesn't have is left out.
            Text {
              width: parent.width
              textFormat: Text.PlainText
              text: addRow.network ? root.networkFacts(addRow.modelData) : root.recipeFacts(addRow.modelData)
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              wrapMode: Text.WordWrap
            }
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.pointAt("localAdd", addRow.index)
            onClicked: root.chooseAddRow(addRow.index)
          }
        }
      }
    }
  }

  // One model: its mark, name and what it makes, its buttons, then how its
  // setup, start or stop is going, or the memory it holds or needs.
  component ModelSection: Column {
    id: section
    property var line: null
    property int lineIndex: -1
    readonly property var model: line ? (line.model || null) : null
    // On another machine of the tailnet: whose, whether paired, whether away.
    readonly property bool remote: !!model && !!model.host
    readonly property bool offline: remote && String(model.offline || "") !== ""
    readonly property bool paired: remote && model.paired === true
    // The recommended model offered for download, before it has a line of its own.
    readonly property var offer: line ? (line.offer || null) : null
    // A first setup: downloading, or failed with its reason.
    readonly property bool installing: !!model && model.unit === "installing"
    readonly property var install: installing && model.install ? model.install : ({})
    // Before the download, a first setup installs Podman to run it in.
    readonly property bool preparing: installing && install.phase === "dependencies"
    readonly property bool downloadShown: installing && !preparing && install.phase !== "failed"
    readonly property real totalBytes: Number(install.total_bytes) || 0
    readonly property real doneBytes: Number(install.done_bytes) || 0
    readonly property real rateBytes: Number(install.rate_bytes_s) || 0
    readonly property bool loading: !!model && model.unit === "activating"
    readonly property bool running: !!model && model.unit === "active"
    // A local model that's set up and stopped steps back, so the one running
    // stands out; its play button stays bright.
    readonly property bool resting: !!model && !remote && !running && !loading && !installing
    readonly property bool stopping: !!model && model.unit === "deactivating"
    // Removing stops it first, then deletes its weights; one bar covers both.
    readonly property bool removing: !!model && model.unit === "removing"
    // When a start or stop ends, its bar fills to the end before the row
    // changes over to memory (or goes), rather than vanishing near 90%.
    property string finishing: ""
    readonly property bool loadingShown: loading || finishing === "loading"
    readonly property bool stoppingShown: stopping || finishing === "stopping"
    onLoadingChanged: if (!loading && running) { finishing = "loading"; finishTimer.restart() }
    onStoppingChanged: if (!stopping && !loading) { finishing = "stopping"; finishTimer.restart() }
    Timer {
      id: finishTimer
      interval: Style.duration(450)
      onTriggered: section.finishing = ""
    }
    readonly property real loadSeconds: model && Number(model.expected_load_seconds) > 0 ? Number(model.expected_load_seconds) : 60
    readonly property real stopSeconds: model && Number(model.expected_stop_seconds) > 0 ? Number(model.expected_stop_seconds) : 10
    readonly property real removeSeconds: model && Number(model.expected_remove_seconds) > 0 ? Number(model.expected_remove_seconds) : 10
    readonly property real phaseSeconds: removing ? removeSeconds : stopping ? stopSeconds : loadSeconds
    readonly property real elapsed: model ? Math.max(0, (root.loadNowMs - Number(model.since_ms || root.loadNowMs)) / 1000) : 0
    readonly property real memory: model && model.observed ? Number(model.observed.ram_used_gib || 0) : 0
    readonly property real needsGib: root.localNeedsGib(model)
    spacing: Style.space(16)

    // The whole line speaks for the memory bar while the pointer is on it.
    HoverHandler {
      onHoveredChanged: {
        if (hovered) root.hoveredLine = section.lineIndex
        else if (root.hoveredLine === section.lineIndex) root.hoveredLine = -1
      }
    }

    PanelSeparator { foreground: root.foreground }

    Item {
      id: sectionHead
      width: parent.width
      implicitHeight: Math.max(sectionMark.height, sectionName.implicitHeight)
      readonly property bool lit: root.hasKey("modelHeader", section.lineIndex)
      onLitChanged: if (lit) root.revealItem(sectionHead)

      CursorSurface {
        anchors.fill: sectionMark
        anchors.margins: -Style.space(5)
        z: -1
        hasCursor: sectionHead.lit
        foreground: root.foreground
      }

      VendorMark {
        id: sectionMark
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        opacity: section.resting ? 0.45 : 1
        vendor: section.model ? section.model.vendor : section.offer ? section.offer.vendor : ""
      }

      Text {
        id: sectionName
        anchors.left: sectionMark.right
        anchors.leftMargin: Style.space(10)
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        width: Math.max(0, Math.min(implicitWidth, sectionHead.width - sectionMark.width - sectionKind.implicitWidth - (localUpdate.visible ? localUpdate.width : 0) - (localShare.visible ? localShare.width : 0) - (remotePair.visible ? remotePair.width : 0) - (remoteDisconnect.visible ? remoteDisconnect.width : 0) - (localToggle.visible ? localToggle.width : 0) - (sectionLaunch.visible ? sectionLaunch.width : 0) - Style.space(44)))
        elide: Text.ElideRight
        text: section.model ? (section.model.name || section.model.recipe)
          : section.offer ? (section.offer.link ? root.linkTitle(section.offer.link) : (section.offer.name || section.offer.id))
          : ""
        HoverHandler { id: localNameHover }
        PanelToolTip {
          // A setup has no endpoint until its model first starts.
          visible: !!section.model && !section.installing && localNameHover.hovered
          text: section.model ? Commons.I18n.t("localModels.endpoint").arg(section.model.endpoint || "").arg(section.model.recipe) : ""
        }
        color: root.foreground
        opacity: section.resting ? 0.45 : 1
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }

      // What the model makes reads as part of its name, and a network one's
      // host as well.
      Text {
        id: sectionKind
        anchors.left: sectionName.right
        anchors.leftMargin: Style.space(8)
        anchors.baseline: sectionName.baseline
        visible: text !== ""
        textFormat: Text.PlainText
        text: section.offer && section.offer.link ? ""
          : section.model || section.offer ? [root.kindLabel(section.model || section.offer)].concat(section.remote ? [section.model.host] : []).join(" · ")
          : ""
        color: root.dim
        opacity: section.resting ? 0.6 : 1
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      // Shares this machine's running model with the tailnet, or stops
      // sharing it: the Tailscale mark, dim while private and in the icons'
      // color while shared, when its tooltip counts the machines using it.
      // Shown only while the model runs, where Tailscale can serve it or it's
      // shared already; a stopped shared model is shared again on start.
      PanelActionButton {
        id: localShare
        anchors.right: localToggle.visible ? localToggle.left : sectionLaunch.visible ? sectionLaunch.left : parent.right
        anchors.rightMargin: localToggle.visible || sectionLaunch.visible ? Style.space(4) : 0
        anchors.verticalCenter: parent.verticalCenter
        readonly property bool shared: !!section.model && section.model.shared === true
        visible: !!section.model && !section.remote && !section.removing && !section.installing && section.running && (shared || engine.canShare)
        readonly property int users: shared ? (engine.shareClients[section.model.recipe] || 0) : 0
        tooltipText: users > 0 ? Commons.I18n.tn("localModels.networkSharedUsers", users).arg(Commons.I18n.formatNumber(users))
          : shared ? Commons.I18n.t("localModels.networkStopSharing") : Commons.I18n.t("localModels.networkShare")
        foreground: root.foreground
        fontFamily: root.fontFamily
        hasCursor: root.hasKey("modelShare", section.lineIndex)
        onHasCursorChanged: if (hasCursor) root.revealItem(localShare)
        onClicked: root.runLocalAction(section.model, "share")

        Tailscale.TailscaleIcon {
          anchors.centerIn: parent
          // The mark fills its box where a font glyph leaves padding around
          // its ink, so it's drawn smaller to sit no larger than the pause.
          iconSize: Math.round(Style.font.icon * 0.7)
          color: localShare.shared || localShare._hot ? root.foreground : root.dim
        }
      }

      // The catalog has a newer runtime, weights or settings for this model
      // than it was set up with. Updating restarts it, so it's offered, never
      // done on its own; while it runs the button stays, dimmed, to say so.
      PanelActionButton {
        id: localUpdate
        anchors.right: localShare.visible ? localShare.left : localToggle.visible ? localToggle.left : sectionLaunch.visible ? sectionLaunch.left : parent.right
        anchors.rightMargin: localShare.visible || localToggle.visible || sectionLaunch.visible ? Style.space(4) : 0
        anchors.verticalCenter: parent.verticalCenter
        readonly property bool updating: !!section.model && section.model.updating === true
        visible: !!section.model && !section.remote && !section.removing && !section.installing && (updating || (!!section.model.update && !section.loading && !section.stopping))
        // The arrows the bar's system update shows, drawn to the play's size:
        // this glyph fills more of its box than the play and pause do.
        iconText: ""
        fontSize: Math.round(Style.font.icon * 0.8)
        tooltipText: updating ? Commons.I18n.t("localModels.updating") : root.updateTip(section.model)
        foreground: updating ? root.dim : root.foreground
        opacity: updating ? 0.5 : 1
        fontFamily: root.fontFamily
        hasCursor: root.hasKey("modelUpdate", section.lineIndex)
        onHasCursorChanged: if (hasCursor) root.revealItem(localUpdate)
        onClicked: if (!updating) root.runLocalAction(section.model, "update")
      }

      // A network model this machine isn't paired with yet: the play a local
      // model starts with, which pairs over SSH. Greyed out while a pairing
      // runs, as only one runs at a time.
      PanelActionButton {
        id: remotePair
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: section.remote && !section.offline && !section.paired
        iconText: "󰐊"
        tooltipText: section.remote ? Commons.I18n.t("localModels.networkPair").arg(section.model.host) : ""
        foreground: engine.pairingId !== "" ? root.dim : root.foreground
        opacity: engine.pairingId !== "" ? 0.5 : 1
        fontFamily: root.fontFamily
        hasCursor: root.hasKey("modelPair", section.lineIndex)
        onHasCursorChanged: if (hasCursor) root.revealItem(remotePair)
        onClicked: root.runLocalAction(section.model, "pair")
      }

      // Once paired and running there: the pause a local model stops with,
      // which stops using just this model here.
      PanelActionButton {
        id: remoteDisconnect
        anchors.right: sectionLaunch.visible ? sectionLaunch.left : parent.right
        anchors.rightMargin: sectionLaunch.visible ? Style.space(4) : 0
        anchors.verticalCenter: parent.verticalCenter
        visible: section.remote && !section.offline && section.paired && section.model.unit === "active"
        iconText: "󰏤"
        tooltipText: section.remote ? Commons.I18n.t("localModels.networkDisconnect").arg(section.model.host) : ""
        foreground: root.foreground
        fontFamily: root.fontFamily
        hasCursor: root.hasKey("modelDisconnect", section.lineIndex)
        onHasCursorChanged: if (hasCursor) root.revealItem(remoteDisconnect)
        onClicked: root.runLocalAction(section.model, "disconnect")
      }

      PanelActionButton {
        id: localToggle
        anchors.right: sectionLaunch.visible ? sectionLaunch.left : parent.right
        anchors.rightMargin: sectionLaunch.visible ? Style.space(4) : 0
        anchors.verticalCenter: parent.verticalCenter
        visible: !!section.model && !section.remote && !section.stopping && !section.removing && !section.installing
        // Greyed out, not disabled, so the reason still shows on hover.
        readonly property bool blocked: root.localStartBlocked(section.model)
        iconText: section.running || section.loading ? "󰏤" : "󰐊"
        tooltipText: blocked ? Commons.I18n.t("localModels.notEnoughMemory")
          : section.running || section.loading ? Commons.I18n.t("localModels.stop") : Commons.I18n.t("localModels.start")
        foreground: blocked ? root.dim : root.foreground
        opacity: blocked ? 0.5 : 1
        fontFamily: root.fontFamily
        hasCursor: root.hasKey("modelToggle", section.lineIndex)
        onClicked: root.runLocalAction(section.model, "toggle")

        // The button's own tooltip follows the pointer; the keyboard cursor
        // landing on a greyed-out play says why too.
        PanelToolTip {
          visible: localToggle.blocked && localToggle.hasCursor
          text: Commons.I18n.t("localModels.notEnoughMemory")
          fontFamily: root.fontFamily
        }
      }

      // Opens an agent on a running text model, or Fantasi on an image,
      // video or music one. On an offered model, the same place downloads it.
      PanelActionButton {
        id: sectionLaunch
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        readonly property bool download: !!section.offer
        readonly property bool image: !!section.model && root.makesInFantasi(section.model)
        visible: download || (!!section.model && section.running && (!section.remote || (section.paired && !section.offline)))
        iconText: download ? (section.offer.link ? "󰌘" : "󰇚") : image ? "󰋩" : "󰞷"
        // Fantasi's own launcher icon, as the icon set draws it, on a model made with in it.
        iconSource: !download && image ? root.fantasiIcon : ""
        tooltipText: download ? (section.offer.link ? Commons.I18n.t("localModels.linkSetUp") : Commons.I18n.t("localModels.download"))
          : image ? Commons.I18n.t("localModels.openFantasi") : Commons.I18n.t("localModels.launch")
        foreground: root.foreground
        fontFamily: root.fontFamily
        hasCursor: root.hasKey(download ? "localDownload" : "modelLaunch", section.lineIndex)
        onClicked: download ? root.downloadLocal(section.offer) : root.runLocalAction(section.model, "launch")
      }
    }

    // Under an offered model: what it needs and how fast it runs here.
    Text {
      visible: !!section.offer && text !== ""
      width: parent.width
      textFormat: Text.PlainText
      text: section.offer ? root.recipeFacts(section.offer) : ""
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }

    // Under a local model: its download while it's set up, or progress while
    // it loads or stops (against how long that took last time). A network
    // model shows its stats while it runs instead: its memory is its host's
    // business.
    Item {
      visible: section.preparing || section.downloadShown || section.loadingShown || section.stoppingShown || section.removing
      width: parent.width
      implicitHeight: Math.max(localMeterTitle.implicitHeight, localMeterValue.implicitHeight)

      Text {
        id: localMeterTitle
        width: parent.width * 0.3
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: section.preparing ? Commons.I18n.t("localModels.installingMeter")
          : section.downloadShown ? Commons.I18n.t("localModels.downloadingMeter")
          : section.removing ? Commons.I18n.t("localModels.removingMeter")
          : section.loadingShown ? Commons.I18n.t("localModels.loadingMeter")
          : Commons.I18n.t("localModels.stoppingMeter")
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }
      Meter {
        id: localMeterBar
        anchors.left: localMeterTitle.right
        anchors.right: localMeterValue.left
        anchors.rightMargin: Style.space(20)
        anchors.verticalCenter: parent.verticalCenter
        value: section.preparing ? root.phaseProgress(section.elapsed, 30)
          : section.downloadShown ? (section.totalBytes > 0 ? section.doneBytes / section.totalBytes : 0)
          : section.finishing !== "" ? 1 : root.phaseProgress(section.elapsed, section.phaseSeconds)
      }
      // How much of a download has arrived, over its bar. The bar is a few
      // pixels tall, so the whole height of its row answers the pointer.
      Item {
        anchors.left: localMeterBar.left
        anchors.right: localMeterBar.right
        height: parent.height
        visible: section.downloadShown
        HoverHandler { id: downloadBarHover }
        PanelToolTip {
          visible: downloadBarHover.hovered && text !== ""
          text: root.downloadAmount(section.doneBytes, section.totalBytes)
          fontFamily: root.fontFamily
        }
      }
      Text {
        id: localMeterValue
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignRight
        text: section.downloadShown ? root.downloadRate(section.rateBytes) : ""
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }
    }

    // Under a local model, running or at rest: the memory it takes, which
    // is what says whether there's room for it. Amber when there isn't now.
    // It reads as part of the name above, so it sits closer to it than the
    // section's rows sit to each other.
    Item {
      // Never the whole line: a spacing scale that outgrows the text would
      // leave a zero-height row, which the column drops from its layout.
      readonly property real pull: Math.max(0, Math.min(Style.space(10), localRam.implicitHeight - 1))
      visible: !!section.model && !section.remote && !section.installing && !section.loadingShown && !section.stoppingShown && !section.removing && localRam.text !== ""
      width: parent.width
      implicitHeight: localRam.implicitHeight - pull

      Text {
        id: localRam
        y: -parent.pull
        width: parent.width
        textFormat: Text.PlainText
        text: section.running ? Commons.I18n.t("localModels.usingRam").arg(Commons.I18n.formatNumber(Math.round(section.memory)))
          : section.needsGib > 0 ? Commons.I18n.t("localModels.needsRam").arg(Commons.I18n.formatNumber(Math.round(section.needsGib))) : ""
        color: !section.running && root.localStartBlocked(section.model) ? Commons.Color.warning : root.dim
        // Steps back with the name, except as a warning that it won't fit.
        opacity: section.resting && !root.localStartBlocked(section.model) ? 0.45 : 1
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        elide: Text.ElideRight
      }
    }

    Text {
      visible: section.remote && section.running && !section.loadingShown && !section.stoppingShown && text !== ""
      width: parent.width
      textFormat: Text.PlainText
      text: section.remote ? root.remoteStats(section.model) : ""
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }

    // A network model whose host is away keeps its line, saying so.
    Text {
      visible: section.offline
      width: parent.width
      textFormat: Text.PlainText
      text: !section.offline ? ""
        : (section.model.offline === "offline" ? Commons.I18n.t("localModels.networkHostOffline") : Commons.I18n.t("localModels.networkHostUnreachable")).arg(section.model.host)
          + (root.lastSeenText(section.model) !== "" ? " · " + Commons.I18n.t("localModels.networkLastSeen").arg(root.lastSeenText(section.model)) : "")
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.Wrap
    }

    // A network model being paired, until it is or fails to be.
    Text {
      visible: section.remote && engine.pairingId === root.modelId(section.model)
      width: parent.width
      textFormat: Text.PlainText
      text: section.remote ? Commons.I18n.t("localModels.networkPairing").arg(section.model.host) : ""
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.Wrap
    }

    // Why pairing with a network model failed, which links to all that
    // pairing printed.
    TextLink {
      readonly property var failure: section.remote ? root.pairFailure(section.model) : null
      visible: failure !== null
      width: Math.min(implicitWidth, parent.width)
      text: !failure ? "" : failure.message !== "" ? failure.message : Commons.I18n.t("localModels.networkPairFailed").arg(section.model.host)
      idleColor: root.urgent
      hotColor: root.urgent
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.Wrap
      picked: root.hasKey("modelLogs", section.lineIndex)
      tooltip: Commons.I18n.t("localModels.networkPairOutputTip")
      onClicked: root.showLocalLogs(section.model)
    }

    // Sharing that Tailscale refused, with the way to fix it.
    Text {
      visible: !!section.model && !section.remote && section.model.shared === true && String(engine.localModel.share_error || "") !== ""
      width: parent.width
      textFormat: Text.PlainText
      text: String(engine.localModel.share_error || "")
      color: root.urgent
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.Wrap
    }

    // Why a model on this machine stopped, which links to its logs.
    TextLink {
      visible: !!section.model && !section.remote && !section.running && !section.loadingShown && !section.stoppingShown && !section.removing && String(section.model.error || "") !== "" && !root.errorRead(section.model)
      width: Math.min(implicitWidth, parent.width)
      text: section.model ? String(section.model.error || "") : ""
      idleColor: root.urgent
      hotColor: root.urgent
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.Wrap
      picked: root.hasKey("modelLogs", section.lineIndex)
      tooltip: Commons.I18n.t("localModels.showLogsTip")
      onClicked: root.showLocalLogs(section.model)
    }
  }

  // A model maker's mark, falling back to the bar glyph when there is none.
  component VendorMark: Item {
    id: mark
    property string vendor: ""
    property var candidates: root.markCandidates(vendor, root.surface)
    property string candidatesKey: candidates.join("\n")
    property int candidateIndex: 0
    onCandidatesKeyChanged: candidateIndex = 0
    property real size: Style.font.heading

    width: size
    height: size

    Image {
      id: markImage
      anchors.fill: parent
      source: mark.candidateIndex < mark.candidates.length ? mark.candidates[mark.candidateIndex] : ""
      sourceSize.width: mark.size * 2
      sourceSize.height: mark.size * 2
      fillMode: Image.PreserveAspectFit
      // Advancing source from inside its own status change trips the
      // binding-loop detector; defer the step one tick.
      onStatusChanged: if (status === Image.Error && mark.candidateIndex < mark.candidates.length)
        Qt.callLater(function() { mark.candidateIndex++ })
    }

    Text {
      anchors.centerIn: parent
      visible: markImage.status !== Image.Ready
      textFormat: Text.PlainText
      text: button.text
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: mark.size
    }
  }

  // The tinted square in the hero's corner.
  component HeroButton: Rectangle {
    id: heroButton
    signal clicked()
    signal hovered()
    property string glyph: ""
    property string tooltip: ""
    property bool hasCursor: false
    implicitWidth: Style.space(34)
    implicitHeight: implicitWidth
    radius: Style.cornerRadius
    // The cursor needs more than a shade deeper to read on a tinted square.
    color: root.alpha(Commons.Color.accent, hasCursor ? 0.3 : 0.12)
    border.width: hasCursor ? Math.max(1, Style.hoverBorderWidth) : 0
    border.color: Commons.Color.accent
    onHasCursorChanged: if (hasCursor) root.revealItem(heroButton)

    Text {
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: heroButton.glyph
      color: Commons.Color.accent
      font.family: root.fontFamily
      font.pixelSize: Style.font.heading
    }

    MouseArea {
      id: heroMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: heroButton.hovered()
      onClicked: heroButton.clicked()
    }

    PanelToolTip {
      visible: heroMouse.containsMouse
      text: heroButton.tooltip
    }
  }

  // A plain-text control: dim until hovered or picked.
  component TextLink: Text {
    id: link
    signal clicked()
    property bool picked: false
    property string tooltip: ""
    property color idleColor: root.dim
    property color hotColor: root.foreground
    readonly property bool hot: linkMouse.containsMouse || picked
    onPickedChanged: if (picked) root.revealItem(link)
    textFormat: Text.PlainText
    color: hot ? hotColor : idleColor
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.underline: hot

    MouseArea {
      id: linkMouse
      anchors.fill: parent
      anchors.margins: -Style.space(4)
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: link.clicked()
    }

    PanelToolTip {
      visible: link.tooltip !== "" && linkMouse.containsMouse
      text: link.tooltip
    }
  }

  // A rounded track that fills as a download, start or stop goes along.
  component Meter: Item {
    id: meter
    property real value: -1
    property real thickness: Math.max(Style.space(4), Math.round(Style.spacing.controlHeight * 0.14))
    implicitHeight: thickness

    Rectangle {
      id: meterTrack
      anchors.fill: parent
      radius: height / 2
      color: root.track
    }

    Rectangle {
      anchors.left: meterTrack.left
      anchors.verticalCenter: meterTrack.verticalCenter
      height: meterTrack.height
      radius: meterTrack.radius
      width: meterTrack.width * root.clamp(meter.value, 0, 1)
      color: root.foreground

      Behavior on width {
        NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic }
      }
    }
  }
}
