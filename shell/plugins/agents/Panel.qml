import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../panels/elsewhen/Model.js" as Reorder
import "../panels/tailscale" as Tailscale

Panel {
  id: root
  moduleName: "omarchy.agents"
  ipcTarget: "omarchy.agents"
  manageIpc: false

  // Items inside the panel's lazily built content, null until it first
  // opens. Code inside the content reaches its own ids directly.
  readonly property Item panelFlick: panel.loadedContent ? panel.loadedContent.panelFlick : null
  readonly property Item hero: panel.loadedContent ? panel.loadedContent.hero : null
  readonly property Item column: panel.loadedContent ? panel.loadedContent.column : null
  readonly property Item providerSections: panel.loadedContent ? panel.loadedContent.providerSections : null

  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color urgent: bar ? bar.urgent : Commons.Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property color surface: Commons.Color.popups.background
  readonly property color track: Style.selectedFillFor(foreground, Commons.Color.accent)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  // Every subscription on one page, limits first: the question this panel
  // answers is how much room is left, and where.
  readonly property var providers: dragProviders !== null ? dragProviders : usage.panelProviders

  property var deleteTarget: null
  function deleteSelected() {
    var i = providerIndexOfKey()
    if (i >= 0 && removable(providers[i])) deleteTarget = providers[i]
  }

  // What omarchy agent account remove takes to sign a line out: the
  // provider, and for an agent with accounts, the line's own or, where it has
  // only the one, the login this machine started with. Empty for a line with
  // no sign-in of its own.
  readonly property var signOutProviders: ["agy", "claude", "codex", "copilot", "cursor", "deepseek", "fireworks", "grok", "minimax", "muse", "opencode", "openrouter", "synthetic", "zai"]
  function signOutArgs(line) {
    if (!line || line.localModel || signOutProviders.indexOf(line.providerId) < 0) return []
    if (line.account) return [line.providerId, String(line.account.id)]
    return ["claude", "codex", "grok"].indexOf(line.providerId) >= 0 ? [line.providerId, "primary"] : [line.providerId]
  }

  function forgets(line) {
    return signOutArgs(line).length > 0
  }

  // A local model's line goes back to the add screen; the default's hands
  // the default on, since the default always has its line, and stays when
  // no other line could take it. A setup can't be stopped while it installs
  // what it runs in.
  function removable(line) {
    if (!line) return false
    if (line.localModel) {
      var model = localModelState(line.localModel)
      if (model && model.panelSetup && ["failed", "waiting"].indexOf(model.install.phase) < 0) return false
      return !opensByDefault(line) || !!defaultSuccessor(line)
    }
    return true
  }

  function opensByDefault(line) {
    return !!line && !!line.localModel && usage.defaultAgent === "local" && line.localModel.target === localDefaultTarget
  }

  // The highest line but this one that can be the default.
  function defaultSuccessor(line) {
    return usage.panelProviders.find(function(other) {
      return usage.lineId(other) !== usage.lineId(line) && defaultIdFor(other) !== ""
    }) || null
  }

  // Signs the line out through omarchy agent account remove, which hides
  // the agent once its last sign-in is gone; a line with no sign-in of its
  // own is only hidden. A model on this machine is removed from it,
  // download and all, and a paired machine's is unlinked, still running
  // there; the add screen offers either again.
  function confirmDelete() {
    var target = deleteTarget
    deleteTarget = null
    if (!target) return
    if (target.localModel) {
      // The default's line hands the default to the highest line left that
      // can take it, as if its star were pressed.
      if (opensByDefault(target)) {
        var next = defaultSuccessor(target)
        if (!next) return
        makeDefault(next, next.account || null)
      }
      var model = localModelState(target.localModel)
      // One on this machine keeps its line, removing, until it's gone, and
      // the listing written again then says it's no longer installed, which
      // takes it off the panel. A setup the service still owns has nothing
      // on disk: a failure is forgotten, and one waiting its turn dropped.
      if (model && !model.panelSetup) {
        Util.execArgv(["bash", "-c", 'omarchy-models remove "$1"; omarchy-models refresh --quiet', "remove", model.recipe])
        return
      }
      if (model && model.install.phase === "failed") localModelsService.dismissSetupFailure()
      else if (model) localModelsService.unqueueSetup(model.recipe)
      usage.removeLocalModels([target.localModel.target])
      return
    }
    var args = signOutArgs(target)
    // Copilot signs out only inside a session of its own, in a terminal.
    if (target.providerId === "copilot") {
      Util.execArgv(["omarchy-launch-floating-terminal-with-presentation", "omarchy-agent-account-remove --yes --agent copilot"])
      root.close()
      return
    }
    if (args.length > 0) {
      Util.execArgv(["bash", "-c", 'out=$(omarchy-agent-account-remove --yes --agent "${@:2}" </dev/null 2>&1) || omarchy-notification-send -u critical "$1" "$out"',
                     "remove-account", Commons.I18n.t("agents.removeFailed").arg(lineName(target))].concat(args))
      return
    }
    setProviderShown(target.providerId, false)
  }

  // Hides an agent from the panel, or shows a hidden one again, as signing in
  // to it does. The sign-in commands ask for this through showAgent, so the
  // change is made here, one at a time, on the settings as they are now.
  function setProviderShown(id, shown) {
    if (!bar || !bar.shell || id === "") return
    var current = settings && settings.providers && settings.providers[id]
    if (shown && (!current || current.enabled !== false)) return
    var next = JSON.parse(JSON.stringify(settings || {}))
    if (!next.providers) next.providers = {}
    next.providers[id] = Object.assign({}, next.providers[id] || {}, { enabled: shown })
    bar.shell.updateEntryInline(moduleName, next)
  }

  property bool cursorActive: false

  // Countdowns and "last updated" ages read this instead of Date.now() so the
  // panel keeps telling the truth while it sits open.
  property double nowMs: Date.now()


  // The keyboard walks everything on the page that does something, in
  // reading order, one row at a time: the hero's button, then each line's
  // buttons, its Sign-in required link, and the starter tiles; or, while
  // adding, the choices by provider id. Up and down change rows, left and
  // right move along one. Hovering moves the same cursor, so only one thing
  // is lit.
  readonly property var keyRows: {
    var rows = []
    var hero = []
    if (instructionsShown) hero.push({ kind: "instructions", index: 0 })
    if (addButtonShown) hero.push({ kind: "add", index: 0 })
    if (hero.length > 0) rows.push(hero)
    if (picking) {
      var blocks = [addGroup("subscription"), addGroup("provider")]
      // A block wraps at addColumns, and so do its rows.
      for (var b = 0; b < blocks.length; b++)
        for (var c = 0; c < blocks[b].length; c += addColumns)
          rows.push(blocks[b].slice(c, c + addColumns).map(function(choice) { return { kind: "choice", index: choice.providerId } }))
      for (var o = 0; o < ownModelOffers.length; o++) rows.push([{ kind: "ownModel", index: o }])
    } else if (addStage === "more") {
      var more = moreChoices
      for (var r = 0; r < more.length; r++) rows.push([{ kind: "choice", index: more[r].providerId }])
    } else if (addStage === "running") {
      if (pasteLinkShown) rows.push([{ kind: "pasteCode", index: 0 }])
      if (addUrl !== "" && !addCheckingCode) rows.push([{ kind: "reopenSignIn", index: 0 }])
    } else if (addStage === "") {
      for (var p = 0; p < providers.length; p++) {
        // Every line is a stop, so Ctrl+Up/Down can move it: its terminal
        // button when it has a harness of its own, else its mark. One that
        // doesn't hold the star offers it, and a lapsed sign-in follows.
        var line = []
        if (defaultIdFor(providers[p]) !== "" && !starred(providers[p], providers[p].account || null))
          line.push({ kind: "providerStar", index: p })
        var stop = lineStop(p)
        var actions = localLineActions(providers[p])
        for (var a = 0; a < actions.length; a++)
          if (localActionKinds[actions[a]] !== stop) line.push({ kind: localActionKinds[actions[a]], index: p })
        if (makesOpenIndex === p)
          for (var m = 0; m < starterPrompts.length; m++) line.push({ kind: "make:" + starterPrompts[m].kind, index: p })
        else if (launches(providers[p]))
          line.push({ kind: "makeToggle", index: p })
        if (desktopFor(providers[p])) line.push({ kind: "providerDesktop", index: p })
        line.push({ kind: stop, index: p })
        rows.push(line)
        if (needsSignIn(providers[p])) rows.push([{ kind: "providerSignin", index: p }])
        if (localLogsShown(providers[p])) rows.push([{ kind: "localLogs", index: p }])
      }
      if (starterShown) {
        for (var j = 0; j < starterPrompts.length; j += starterColumns) {
          var tiles = []
          for (var k = j; k < Math.min(j + starterColumns, starterPrompts.length); k++) tiles.push({ kind: "starter", index: k })
          rows.push(tiles)
        }
      }
    }
    return rows
  }
  property int keyRow: 0
  property int keyColumn: 0
  // What the keys act on: the cursor, shown or, while the mouse leads,
  // following it unseen, so Enter and Delete still work on what it's over.
  readonly property var keyTarget: {
    if (!(cursorActive || pointerActive) || keyRow < 0 || keyRow >= keyRows.length) return null
    var row = keyRows[keyRow]
    return row[Math.min(keyColumn, row.length - 1)]
  }

  function hasKey(kind, index) {
    return cursorActive && !!keyTarget && keyTarget.kind === kind && keyTarget.index === (index || 0)
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

  // A line's rightmost button, where the cursor lands on it: its terminal,
  // or the mark for a line with no button.
  // A line's last stop, where Up and Down land: its terminal button, or for
  // a local model that isn't running yet, its play button, else its mark.
  function lineStop(p) {
    if (launches(providers[p])) return "providerLaunch"
    return localLineActions(providers[p]).indexOf("toggle") >= 0 ? "localToggle" : "provider"
  }

  // The first arrow only shows where the cursor is, as in the other panels.
  function moveKey(dx, dy) {
    pointerActive = false
    if (keyRows.length === 0) return
    if (!cursorActive) {
      keyRow = clamp(keyRow, 0, keyRows.length - 1)
      keyColumn = 0
      cursorActive = true
      return
    }
    if (dy !== 0) {
      keyRow = clamp(keyRow + dy, 0, keyRows.length - 1)
      // Arriving on an agent or account lands on its terminal button, so
      // Down then Enter starts the next one; a line without one lands on its
      // rightmost stop.
      var row = keyRows[keyRow]
      var last = row[row.length - 1].kind
      keyColumn = ["providerLaunch", "localToggle", "provider"].indexOf(last) >= 0 ? row.length - 1 : Math.min(keyColumn, row.length - 1)
    } else if (dx !== 0) {
      // A row can go while the cursor is on it, like the starters when the
      // last agent stops.
      keyRow = clamp(keyRow, 0, keyRows.length - 1)
      keyColumn = clamp(Math.min(keyColumn, keyRows[keyRow].length - 1) + dx, 0, keyRows[keyRow].length - 1)
    }
  }

  // The agent the cursor is in, by its position on the page.
  function providerIndexOfKey() {
    return lineOf(keyTarget)
  }

  // The agent a cursor stop belongs to, or -1.
  function lineOf(target) {
    if (!target) return -1
    if (["provider", "providerSignin", "providerLaunch", "providerStar", "makeToggle", "providerDesktop",
         "localUpdate", "localShare", "localToggle", "localLogs"].indexOf(target.kind) >= 0 || target.kind.indexOf("make:") === 0) return target.index
    return -1
  }

  // Ctrl+Up/Down carries the agent the cursor is in up or down the page, and
  // the cursor along with it.
  function reorderProvider(dy) {
    if (dragIndex >= 0) return
    var from = providerIndexOfKey()
    if (from < 0) return
    var to = clamp(from + dy, 0, providers.length - 1)
    if (to === from) return
    usage.moveProvider(usage.lineId(providers[from]), to)
    Qt.callLater(function() { pointAtProvider(to) })
  }

  // As in Elsewhen, keep the layout fixed until the lifted section settles.
  property var dragProviders: null
  property string dragProviderId: ""
  property int dragIndex: -1
  property int dragTarget: -1
  property real dragOffset: 0
  property real dragPressY: 0
  property var rowPitches: []
  property bool settling: false
  property bool renaming: false

  function beginProviderDrag(index, y) {
    if (dragIndex >= 0 || !providerSections) return
    var pitches = []
    for (var i = 0; i < providerSections.count; i++)
      pitches.push(providerSections.itemAt(i).height + column.spacing)
    rowPitches = pitches
    // Keep the same model object so grabbing does not rebuild the delegates.
    dragProviders = providers
    dragProviderId = usage.lineId(providers[index])
    dragPressY = y
    dragOffset = 0
    dragTarget = index
    dragIndex = index
  }

  function dragProviderOver(y) {
    if (dragIndex < 0 || settling) return
    dragOffset = y - dragPressY
    dragTarget = Reorder.dragTargetFor(dragIndex, dragOffset, rowPitches[dragIndex],
                                      dragTarget, providers.length, rowPitches)
  }

  function resetProviderDrag() {
    dropAnimation.stop()
    dragIndex = -1
    dragTarget = -1
    dragProviderId = ""
    dragOffset = 0
    settling = false
    dragProviders = null
  }

  function finishProviderDrag() {
    var id = dragProviderId
    var to = dragTarget
    var moved = dragIndex >= 0 && to !== dragIndex
    // Disable slot motion before replacing the model: it already matches the preview.
    dragIndex = -1
    if (moved) usage.moveProvider(id, to)
    resetProviderDrag()
    if (moved) Qt.callLater(function() { pointAtProvider(to) })
  }

  function settleProviderDrag(cancel) {
    if (dragIndex < 0) return
    dropAnimation.stop()
    settling = true
    if (cancel) dragTarget = dragIndex
    var offset = Reorder.dropOffset(dragIndex, dragTarget, rowPitches[dragIndex], rowPitches)
    if (Style.duration(150) === 0) {
      dragOffset = offset
      finishProviderDrag()
    } else {
      dropAnimation.to = offset
      dropAnimation.restart()
    }
  }

  function dropProvider() {
    if (!settling) settleProviderDrag(false)
  }

  NumberAnimation {
    id: dropAnimation
    target: root
    property: "dragOffset"
    duration: Style.duration(150)
    easing.type: Easing.Bezier
    easing.bezierCurve: Style.easeOut
    onFinished: root.finishProviderDrag()
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

  // The bar icon lights up when any account new sessions use is nearly out,
  // a prepaid balance is down to its last 10%, or monthly spend is near its cap.
  readonly property bool alarming: {
    for (var i = 0; i < providers.length; i++) {
      // An account not in use limits nothing until it's switched to.
      if (providers[i].account && providers[i].account.active !== true) continue
      var window = bindingWindow(providers[i])
      if (window && window.percent >= 0.9) return true
      if (balanceAlarming(providers[i].balance)) return true
      if (spendAlarming(providers[i].spend)) return true
    }
    return false
  }

  function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)) }
  function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

  // A provider's accounts, when it has any. The list arrives as a sequence
  // rather than a JS array once it has passed through a model, so it's
  // judged by its length.

  function refreshNow() {
    usage.refreshAll(true)
  }

  // ------------------------------------------------------------ adding
  //
  // Adding a subscription happens right here: pick a provider, name it if
  // it's a second account, then sign in through the browser while the panel
  // follows omarchy-agent-account-add --events. The browser taking focus may
  // close the panel; the login carries on, and its result arrives as a
  // notification too.

  // Every agent the panel can sign in to, and so offer to sign in to again.
  // The add picker shows those with a group, in its blocks: the four
  // subscriptions, then the model providers whose key or plan runs in
  // OpenCode. Copilot, Cursor, and Muse are added with `omarchy agent account
  // add`. Muse and OpenCode print their sign-in page rather than opening it,
  // so the panel opens it for them. Copilot's limits are asked with gh's
  // sign-in, which its own login doesn't renew, so trouble there keeps its
  // help text instead of a Sign-in required link.
  readonly property var signInProviders: [
    { providerId: "claude", providerName: "Claude", group: "subscription" },
    { providerId: "codex", providerName: "Codex", group: "subscription" },
    { providerId: "grok", providerName: "Grok", group: "subscription" },
    { providerId: "agy", providerName: "Gemini", group: "subscription" },
    { providerId: "muse", providerName: "Muse", group: "subscription", printsPage: true },
    { providerId: "cursor", providerName: "Cursor", group: "subscription" },
    { providerId: "copilot", providerName: "Copilot", group: "subscription", limitsElsewhere: true },
    { providerId: "more-subscriptions", providerName: Commons.I18n.t("agents.more"), group: "subscription", more: "moreSubscriptions" },
    { providerId: "fireworks", providerName: "Fireworks", group: "provider" },
    { providerId: "opencode", providerName: "OpenCode", group: "provider", printsPage: true },
    { providerId: "openrouter", providerName: "OpenRouter", group: "provider" },
    { providerId: "more-providers", providerName: Commons.I18n.t("agents.more"), group: "provider", more: "moreProviders" },
    // Behind More: providers whose usage Omarchy reads, so their keys can be
    // checked before they're saved in OpenCode.
    // Monthly coding plans: OpenCode Go, on the same OpenCode sign-in as the
    // pay-as-you-go tile, and those that sign in with a key; then DeepSeek,
    // which charges per use.
    { providerId: "opencode-go", providerName: "OpenCode Go", group: "moreSubscriptions", iconId: "opencode", signsInAs: "opencode" },
    { providerId: "minimax", providerName: "MiniMax", group: "moreSubscriptions" },
    { providerId: "synthetic", providerName: "Synthetic", group: "moreSubscriptions" },
    { providerId: "zai", providerName: "Z.ai", group: "moreSubscriptions" },
    { providerId: "deepseek", providerName: "DeepSeek", group: "moreProviders" },
    { providerId: "kimi", providerName: "Kimi", group: "", terminalLogin: true, limitsElsewhere: true }
  ]
  readonly property int addColumns: 4
  // The More list's last row, which hands any other provider to OpenCode.
  readonly property string otherInOpenCode: "opencode-other"

  // China installs only offer providers reachable in mainland China in the
  // add picker; signInProviders keeps the full set so existing sign-ins and
  // re-authentication continue to work.
  property string region: "global"
  readonly property bool isChinaRegion: region === "cn"

  FileView {
    id: regionFile
    path: Quickshell.env("OMARCHY_REGION_FILE") || "/etc/omarchy/region"
    watchChanges: true
    printErrors: false
    onLoaded: root.region = String(text() || "").trim() || "global"
    onLoadFailed: root.region = "global"
    onFileChanged: reload()
  }

  readonly property var cnGroupIds: ({
    subscription: ["minimax", "zai", "kimi"],
    provider: ["deepseek"],
    moreSubscriptions: [],
    moreProviders: []
  })

  // The More list a More tile opened: its group's providers, and for pay as
  // you go, OpenCode's own sign-in for the rest.
  property string addMore: ""
  readonly property var moreChoices: addGroup(addMore).concat(addMore === "moreProviders"
    ? [{ providerId: otherInOpenCode, providerName: Commons.I18n.t("agents.moreInOpenCode"), opencode: true }] : [])

  function addGroup(group) {
    if (isChinaRegion) {
      var ids = cnGroupIds[group] || []
      var out = []
      for (var i = 0; i < ids.length; i++) {
        var match = signInProviders.find(function(p) { return p.providerId === ids[i] })
        if (match) out.push(match)
      }
      return out
    }
    return signInProviders.filter(function(p) { return p.group === group })
  }

  // ---------------------------------------------------------- local models
  //
  // The coding models that run on hardware you own: this machine's, which
  // their lines start, stop, share, update and remove, and those a paired
  // machine runs. The local models service follows omarchy-models and runs
  // the setups started from the add screen.
  readonly property var localModelsService: bar && bar.shell ? bar.shell.firstPartyServiceFor("omarchy.local-models") : null
  readonly property var localModels: localModelsService && localModelsService.localModel ? localModelsService.localModel.models || {} : {}

  // A line for each coding model set up on this machine, in whatever state,
  // and for each one a paired machine that's online is running. Its target
  // is what opens it: the recipe, or host/recipe for a paired machine's. The
  // lines carry only what names a model, so the status omarchy-models
  // rewrites twice a second while one downloads or loads doesn't rebuild
  // them: a line reads its model's state through localModelState.
  readonly property string localModelLinesKey: JSON.stringify(buildLocalModelLines(localModels,
    localModelsService ? localModelsService.setupRows() : [],
    localModelsService ? localModelsService.networkModels || {} : {},
    localModelsService ? localModelsService.localRecipes || [] : []))
  readonly property var localModelLines: JSON.parse(localModelLinesKey)

  function buildLocalModelLines(models, setups, network, list) {
    var recipes = {}
    for (var r = 0; r < list.length; r++) recipes[list[r].id] = list[r]
    var out = []
    var add = function(model, host) {
      var target = host ? host + "/" + model.recipe : model.recipe
      var recipe = host ? {} : (recipes[model.recipe] || {})
      out.push({
        providerId: "local",
        providerName: model.name || model.recipe,
        lineId: "local/" + target,
        iconId: model.vendor || "local",
        localModel: {
          target: target,
          host: host || "",
          decode_tok_s: model.decode_tok_s != null ? model.decode_tok_s : recipe.decode_tok_s,
          context: model.ctx != null ? model.ctx : recipe.context,
          memory_gib: recipe.memory_gib,
          best: recipe.best === true
        }
      })
    }
    for (var id in models)
      if (models[id].kind === "text") add(models[id], "")
    // A setup started from here, before status.json lists it.
    for (var s = 0; s < setups.length; s++)
      if (!models[setups[s].recipe] && setups[s].kind === "text") add(setups[s], "")
    for (var nid in network) {
      var shared = network[nid]
      if (shared.kind === "text" && shared.unit === "active" && shared.paired === true && String(shared.offline || "") === "") add(shared, shared.host)
    }
    return out
  }

  // A line's model on this machine as it is now: as status.json has it, or,
  // before that lists it, the setup starting, waiting its turn, or failed.
  // Null for a paired machine's, which has a line only while it runs.
  function localModelState(local) {
    if (!local || local.host !== "" || !localModelsService) return null
    return localModels[local.target] || localModelsService.setupRows().find(function(row) { return row.recipe === local.target }) || null
  }

  function localRunning(local) {
    if (!local) return false
    if (local.host !== "") return true
    var model = localModelState(local)
    return !!model && model.unit === "active" && model.sub_state === "running"
  }

  // What the network and local blocks of the add screen offer: each coding
  // model without a line, a paired machine's first, then one shared on the
  // tailnet by a machine not paired yet, which choosing pairs with. This
  // machine's are those set up here and every recipe that fits and isn't,
  // recommended first, then another DGX Spark cabled to this one. Those
  // being set up or paired with, and the one being started from here, stay,
  // showing how that goes.
  readonly property var ownModelOffers: {
    var offers = []
    var lines = localModelLines.filter(function(line) {
      return !usage.localModelAdded(line) || line.localModel.target === settingUpLocal || localSettingUp(localModelState(line.localModel))
    })
    var offerLine = function(targetList, line) {
      var model = localModelState(line.localModel)
      if (model && model.unit === "removing") return
      targetList.push({ target: line.localModel.target, name: line.providerName, vendor: line.iconId,
                        host: line.localModel.host, facts: line.localModel,
                        best: line.localModel.host === "" && line.localModel.best === true,
                        shortfall: memoryShort(line.localModel.target, line.localModel.memory_gib, model) })
    }
    lines.filter(function(line) { return line.localModel.host !== "" }).forEach(function(line) { offerLine(offers, line) })
    var network = localModelsService ? localModelsService.networkModels || {} : {}
    for (var nid in network) {
      var shared = network[nid]
      if (shared.paired === true || String(shared.offline || "") !== "" || shared.kind !== "text" || shared.unit !== "active") continue
      offers.push({ target: nid, name: shared.name || shared.recipe, vendor: shared.vendor || "local", host: shared.host,
                    facts: { decode_tok_s: shared.decode_tok_s, context: shared.ctx }, pair: shared })
    }
    var localOffers = []
    lines.filter(function(line) { return line.localModel.host === "" }).forEach(function(line) { offerLine(localOffers, line) })
    var recipes = (localModelsService ? localModelsService.localRecipes || [] : []).filter(function(recipe) {
      return recipe.kind === "text" && recipe.available === true
        && !localModelLines.some(function(line) { return line.localModel.target === String(recipe.id) })
    })
    for (var r = 0; r < recipes.length; r++)
      localOffers.push({ target: String(recipes[r].id), name: recipes[r].name || String(recipes[r].id), vendor: recipes[r].vendor || "local",
                         host: "", facts: recipes[r], recipe: recipes[r], best: recipes[r].best === true,
                         shortfall: memoryShort(String(recipes[r].id), recipes[r].memory_gib, null) })
    offers = offers.concat(sortLocalOffers(localOffers))
    var link = localModelsService && localModelsService.localModel ? localModelsService.localModel.link : null
    if (link && link.state === "available")
      offers.push({ target: "", name: link.host ? Commons.I18n.t("localModels.linkOffer").arg(link.host) : Commons.I18n.t("localModels.linkOfferUnnamed"),
                    vendor: "nvidia", host: "", facts: {}, link: link })
    return offers
  }

  function sortLocalOffers(offers) {
    return offers.slice().sort(function(a, b) { return (b.best ? 1 : 0) - (a.best ? 1 : 0) })
  }

  // A model on this machine that the memory free now can't start: one set up
  // that the engine judged too big, or a recipe needing more than is free,
  // which isn't set up then, as it couldn't run. What it needs and what's
  // free, either -1 where unknown; null when it fits, or when it's already
  // being set up or started from here.
  function memoryShort(target, needsGib, model) {
    if (target === settingUpLocal || localSettingUp(model)) return null
    var free = localModelsService ? localModelsService.memoryFreeGib : -1
    var needs = needsGib != null ? Number(needsGib) : -1
    var stopped = !!model && (model.unit === "inactive" || model.unit === "failed")
    if (stopped ? model.fits !== false : (!!model || needs < 0 || free < 0 || needs <= free)) return null
    return { needs: needs, free: free }
  }

  function memoryShortText(shortfall) {
    if (shortfall.needs < 0 || shortfall.free < 0 || shortfall.needs <= shortfall.free) return Commons.I18n.t("localModels.notEnoughMemory")
    return Commons.I18n.t("agents.memoryShort").arg(Commons.I18n.formatNumber(shortfall.needs, 0))
      .arg(Commons.I18n.formatNumber(shortfall.free, shortfall.free < 10 ? 1 : 0))
  }

  // The network block's share of the offers, which come first.
  readonly property int networkOfferCount: ownModelOffers.filter(function(offer) { return offer.host !== "" }).length
  // Local models offered for this machine, excluding a cabled-Spark link offer.
  readonly property int localModelOfferCount: ownModelOffers.filter(function(offer) { return offer.host === "" && !offer.link }).length

  function offerRecommended(offer, localCount) {
    return !!offer && offer.host === "" && !offer.link && offer.best === true && localCount > 1
  }

  // A model removed from this machine is no longer added, so set up again
  // it's offered on the add screen first. One still being set up, handing off
  // to the background unit, or downloading isn't installed yet either, and stays.
  function findRemovedLocalModels(added, models, setups, recipes, settingUp, handingOff) {
    var pending = handingOff || []
    return (added || []).filter(function(target) {
      return target.indexOf("/") < 0
        && target !== settingUp
        && pending.indexOf(target) < 0
        && !(models && models[target])
        && !(setups || []).some(function(row) { return row.recipe === target })
        && (recipes || []).some(function(recipe) { return String(recipe.id) === target && recipe.installed === false })
    })
  }

  readonly property var removedLocalModels: {
    if (!localModelsService) return []
    return findRemovedLocalModels(usage.addedLocalModels, localModels, localModelsService.setupRows(),
      localModelsService.localRecipes || [], settingUpLocal, localModelsService.handingOff || [])
  }
  onRemovedLocalModelsChanged: if (removedLocalModels.length > 0) Qt.callLater(function() {
    var dropped = removedLocalModels
    if (dropped.length > 0) usage.removeLocalModels(dropped)
  })

  // A model set up or started from the add screen keeps its row there,
  // showing how that goes, until it runs. Then it becomes the default if
  // nothing else was finished first, and the add screen steps back to the
  // panel, where it has its line.
  property string settingUpLocal: ""
  readonly property var localSetup: settingUpLocal === "" ? null : localModelState({ target: settingUpLocal, host: "" })

  // A tailnet model being paired with keeps its row too, its metadata line
  // saying how the pairing goes; once paired, it has its line in the panel and
  // becomes the default if nothing else was finished first.
  property string pairingLocal: ""
  onLocalModelLinesChanged: {
    if (pairingLocal === "" || !localModelLines.some(function(line) { return line.localModel.target === pairingLocal })) return
    if (usage.defaultAgent === "") selectLocalDefault(pairingLocal)
    pairingLocal = ""
    if (settingUpLocal === "" && addStage === "pick") cancelAdd()
  }

  // How the pairing is going: under way, or why it failed.
  readonly property var pairingStatus: {
    if (pairingLocal === "" || !localModelsService) return null
    var host = pairingLocal.split("/")[0]
    if (localModelsService.pairingId === pairingLocal)
      return { text: Commons.I18n.t("localModels.networkPairing").arg(host), failed: false }
    var failure = localModelsService.pairFailures[pairingLocal]
    if (failure)
      return { text: failure.message || Commons.I18n.t("localModels.networkPairFailed").arg(host), failed: true }
    return null
  }

  function localSettingUp(model) {
    return !!model && (model.panelSetup === true || model.unit === "installing")
  }

  // An offer's setup, or its start from here, as its row shows it.
  function offerMeter(offer) {
    if (!offer || offer.host !== "" || offer.target === "") return null
    var model = localModelState(offer)
    var starting = offer.target === settingUpLocal
    return starting || localSettingUp(model) ? localMeter(model, starting) : null
  }
  onLocalSetupChanged: {
    if (!localSetup || localSetup.unit !== "active" || localSetup.sub_state !== "running") return
    var target = settingUpLocal
    Qt.callLater(function() {
      if (settingUpLocal !== target) return
      settingUpLocal = ""
      if (usage.defaultAgent === "") selectLocalDefault(target)
      if (pairingLocal === "" && addStage === "pick") cancelAdd()
    })
  }

  // What a model on this machine is doing, as a meter: its title, how far
  // along (by the download's bytes, or by time against what that took last
  // time), and the download's speed. Failed, the title says why, and the
  // logs say more when there are any. Null for a model running or at rest,
  // but one just asked to start, `starting`, is already loading.
  function localMeter(model, starting) {
    if (!model) return null
    var install = model.install || {}
    var elapsed = Math.max(0, (nowMs - Number(model.since_ms || nowMs)) / 1000)
    var timed = function(title, expected) { return { title: title, value: phaseProgress(elapsed, expected), rate: "" } }
    if (model.unit === "removing") return timed(Commons.I18n.t("localModels.removingMeter"), Number(model.expected_remove_seconds) || 10)
    if ((model.unit === "installing" && install.phase === "failed") || (["active", "activating", "deactivating"].indexOf(model.unit) < 0 && String(model.error || "") !== ""))
      return { title: String(model.error || "") || Commons.I18n.t("localModels.setupFailed"), value: -1, rate: "", failed: true, logs: true }
    // Stopped, and too big for the memory free now.
    if ((model.unit === "inactive" || model.unit === "failed") && model.fits === false)
      return { title: Commons.I18n.t("localModels.notEnoughMemory"), value: -1, rate: "", failed: true }
    if (model.unit === "installing" && install.phase === "dependencies") return timed(Commons.I18n.t("localModels.installingMeter"), 30)
    if (model.unit === "installing") {
      var total = Number(install.total_bytes) || 0
      return { title: "", value: total > 0 ? (Number(install.done_bytes) || 0) / total : 0,
               rate: downloadRate(Number(install.rate_bytes_s) || 0), downloading: true }
    }
    if (model.unit === "activating") return timed(Commons.I18n.t("localModels.loadingMeter"), expectedLoadSeconds(model))
    if (model.unit === "deactivating") return timed(Commons.I18n.t("localModels.stoppingMeter"), expectedStopSeconds(model))
    // Between the press and the engine saying it's loading.
    if (starting && model.unit !== "active") return { title: Commons.I18n.t("localModels.loadingMeter"), value: 0, rate: "" }
    return null
  }

  // A start or stop runs steadily to 90% at the time the last one took, then
  // keeps creeping toward 98%, so one that runs long reads as slow, not stuck.
  function phaseProgress(elapsed, expected) {
    if (!(expected > 0)) return 0
    if (elapsed <= expected) return 0.9 * elapsed / expected
    return 0.9 + 0.08 * (1 - Math.exp(-(elapsed - expected) / expected))
  }

  // How far an update is, as one bar from the press until the model is
  // updated: waiting its turn, its download (the engine's bytes, or time where
  // an engine reports none), then, when it ran, the old one stopping and the
  // new one loading. A model that was stopped is stopped again at the end.
  function updateProgress(model, startedMs, nowMs) {
    var seconds = function(fromMs) { return Math.max(0, (nowMs - (fromMs || nowMs)) / 1000) }
    var share = function(elapsed, expected) { return phaseProgress(elapsed, expected) / 0.98 }
    if (model.updating === true && model.unit === "deactivating")
      return 0.7 + 0.05 * share(seconds(Number(model.since_ms)), expectedStopSeconds(model))
    if (model.updating === true && model.unit === "activating")
      return 0.75 + 0.23 * share(seconds(Number(model.since_ms)), expectedLoadSeconds(model))
    var progress = model.update_progress
    if (!progress) return 0.7 * share(seconds(startedMs), 120)
    if (progress.phase === "downloading" && Number(progress.total_bytes) > 0)
      return 0.05 + 0.65 * Math.min(1, Number(progress.done_bytes) / Number(progress.total_bytes))
    return 0.05 * share(seconds(startedMs), 10)
  }

  // How far a CLI package install is, as one monotonic bar from connecting
  // through downloading, verifying, and extracting/hooks. Creeps gently while
  // waiting for the first event, so the bar never sits empty.
  function cliInstallProgress(stage, done, total, startedMs, nowMs) {
    var fraction = total > 0 ? clamp(done / total, 0, 1) : 0
    if (stage === "downloading") return 0.05 + 0.70 * fraction
    if (stage === "verifying") return 0.75 + 0.07 * fraction
    if (stage === "installing") return 0.82 + 0.16 * fraction
    if (total > 0) return clamp(fraction, 0, 0.98)
    var elapsed = Math.max(0, (nowMs - (startedMs || nowMs)) / 1000)
    return 0.03 + 0.09 * phaseProgress(elapsed, 10) / 0.98
  }

  function cliInstallTitle(stage) {
    if (stage === "downloading") return Commons.I18n.t("agents.downloadingMeter")
    if (stage === "verifying") return Commons.I18n.t("agents.verifyingMeter")
    return Commons.I18n.t("agents.installingMeter")
  }

  // How long a start or stop took last time, or a guess where none has run.
  function expectedLoadSeconds(model) {
    return Number(model && model.expected_load_seconds) || 60
  }

  function expectedStopSeconds(model) {
    return Number(model && model.expected_stop_seconds) || 10
  }

  // A line's meters move by the second, so the clock ticks while one shows.
  readonly property bool localBusy: settingUpLocal !== "" || localModelLines.some(function(line) {
    var model = localModelState(line.localModel)
    return !!model && (["installing", "activating", "deactivating", "removing"].indexOf(model.unit) >= 0 || model.updating === true)
  })
  readonly property bool cliInstalling: addStage === "running" && addPhase === "get" && !addFetched
  Timer {
    interval: 250
    running: root.opened && (root.localBusy || (root.cliInstalling && root.addInstallStage === ""))
    repeat: true
    onTriggered: {
      root.nowMs = Date.now()
      if (root.cliInstalling && root.addInstallStage === "")
        root.addInstallFill = Math.max(root.addInstallFill, root.cliInstallProgress("", 0, 0, root.addInstallStartedMs, root.nowMs))
    }
  }

  // What a model on this machine offers on its line. One the catalog has
  // moved on from offers its update, running or stopped, but not while it
  // loads, stops or is updated already. Sharing shows only while it runs:
  // where Tailscale can serve it, or where it's shared already, so it can
  // always be stopped. A stopped model stays shared and is served again when
  // it starts.
  function localActions(model, canShare) {
    if (!model || model.unit === "removing" || model.unit === "installing") return []
    var actions = []
    if (model.update && model.updating !== true && ["active", "inactive", "failed"].indexOf(model.unit) >= 0) actions.push("update")
    if (model.unit === "active" && (canShare || model.shared === true)) actions.push("share")
    if (model.unit !== "deactivating") actions.push("toggle")
    return actions
  }

  readonly property var localActionKinds: ({ update: "localUpdate", share: "localShare", toggle: "localToggle" })

  // A line's own buttons, in the order they show: none but on a model on
  // this machine.
  function localLineActions(line) {
    if (!line || !line.localModel) return []
    return localActions(localModelState(line.localModel), !!localModelsService && localModelsService.canShare)
  }

  // A failure with logs to read, which the line links to.
  function localLogsShown(line) {
    var meter = line && line.localModel ? localMeter(localModelState(line.localModel), false) : null
    return !!meter && meter.logs === true
  }

  function localStartBlocked(model) {
    return !!model && model.unit !== "active" && model.unit !== "activating" && model.fits === false
  }

  // Starting, stopping, sharing and updating run in the background, and the
  // line follows what omarchy-models writes. The panel has no terminal: a
  // start that fails records its reason, which the line shows.
  function runLocalAction(local, action) {
    var model = localModelState(local)
    if (!model) return
    if (action === "toggle") {
      var running = model.unit === "active" || model.unit === "activating"
      // Greyed out means not startable by any route: click, Return or Enter.
      if (!running && localStartBlocked(model)) return
      Util.execArgv(["omarchy-models", running ? "stop" : "start", model.recipe])
    } else if (action === "share") {
      Util.execArgv(["omarchy-models", "share", model.recipe].concat(model.shared ? ["--off"] : []))
    } else if (action === "update") {
      // Its bar starts at the press, before the engine has said a word, and
      // runs until the model is updated.
      for (var i = 0; providerSections && i < providerSections.count; i++) {
        var section = providerSections.itemAt(i)
        if (section && section.local && section.local.target === local.target) section.askUpdate()
      }
      Util.execArgv(["omarchy-models", "update", "--detach", model.recipe])
    }
  }

  // What pressing update means: how much it downloads, once the engine has
  // sized it, and that the model restarts.
  function updateTip(model) {
    var bytes = Number(model && model.update && model.update.download_bytes) || 0
    if (bytes >= 1e8) return Commons.I18n.t("localModels.updateDownloadGb").arg(Commons.I18n.formatNumber(bytes / 1e9, 1))
    if (bytes > 0) return Commons.I18n.t("localModels.updateDownloadMb").arg(Commons.I18n.formatNumber(Math.max(1, Math.round(bytes / 1e6)), 0))
    return Commons.I18n.t("localModels.update")
  }

  // The logs of a model that failed. A setup that failed before its
  // download began has only what it printed, so the terminal shows that and
  // closes as failed. The engine forgets a model's failure once its logs
  // have printed it, keeping their status for the terminal's last line.
  function showLocalLogs(model) {
    var recipe = Util.shellQuote(String(model.recipe))
    var command = model.panelSetup ? "printf %s " + Util.shellQuote(String(model.output)) + "; false"
      : "omarchy-models logs " + recipe + "; logs=$?; omarchy-models dismiss " + recipe + " >/dev/null 2>&1; (exit $logs)"
    Util.execArgv(["omarchy-launch-floating-terminal-with-presentation", command])
    root.close()
  }

  function selectLocalDefault(target) {
    usage.defaultAgent = "local"
    usage.localPin = target
    selectDefault.command = ["omarchy-default-agent", "--select", "local", target]
    selectDefault.running = true
  }

  function ownModelFacts(recipe) {
    var facts = []
    if (recipe.memory_gib != null) facts.push(Commons.I18n.t("localModels.memoryFact").arg(Commons.I18n.formatNumber(recipe.memory_gib, 0)))
    if (recipe.decode_tok_s != null) facts.push(Commons.I18n.t("localModels.speedFact").arg(Commons.I18n.formatNumber(Math.round(recipe.decode_tok_s), 0)))
    if (recipe.context != null) facts.push(Commons.I18n.t("localModels.contextFact").arg(Commons.I18n.formatNumber(Math.round(Number(recipe.context) / 1024), 0)))
    return facts.join(" · ")
  }

  // The local model the default opens: the pinned one, else the one started
  // last.
  readonly property string localDefaultTarget: {
    var local = localModelsService && localModelsService.localModel ? localModelsService.localModel : {}
    var pin = usage.localPin
    if (pin !== "" && (pin.indexOf("/") >= 0 || localModels[pin])) return pin
    return String(local.last || "")
  }

  // Choosing a model adds it. One already running steps straight back to the
  // panel, where it has its line; one set up here and stopped starts, and one
  // not set up is set up, its row following that until it runs. A cabled Spark
  // is set up in a terminal, which asks for the other machine's password once.
  function chooseOwnModel(index) {
    var offer = ownModelOffers[index]
    // One the memory free can't start is neither started nor set up.
    if (!offer || offer.shortfall) return
    if (offer.link) {
      root.close()
      Util.execArgv(["omarchy-launch-floating-terminal-with-presentation", "omarchy-models link setup"])
      return
    }
    // A tailnet model not paired yet is paired with in the background, its
    // row saying how that goes; once paired, it has its line in the panel.
    if (offer.pair) {
      if (localModelsService.pairingId !== "") return
      usage.addLocalModel(offer.target)
      pairingLocal = offer.target
      localModelsService.pair(offer.pair)
      return
    }
    // A setup or start underway from here goes on; one that failed, or
    // whose password prompt was dismissed, is tried again. One downloading
    // from a terminal is added and followed.
    var meter = offerMeter(offer)
    if (meter && !meter.failed && usage.addedLocalModels.indexOf(offer.target) >= 0) return
    var local = { target: offer.target, host: offer.host }
    var model = localModelState(local)
    usage.addLocalModel(offer.target)
    if (localRunning(local)) {
      // Ready now, so it's the first one finished when nothing else is.
      if (usage.defaultAgent === "") selectLocalDefault(offer.target)
      if (settingUpLocal === "" && pairingLocal === "") {
        if (addStage === "pick") cancelAdd()
        else root.focusKeys()
      }
      return
    }
    settingUpLocal = offer.target
    if (!model || model.panelSetup || (model.unit === "installing" && (model.install || {}).phase === "failed")) {
      var recipe = offer.recipe || (localModelsService.localRecipes || []).find(function(r) { return String(r.id) === offer.target })
      if (recipe) localModelsService.setUp(recipe)
    } else if ((model.unit === "inactive" || model.unit === "failed") && !localStartBlocked(model)) {
      Util.execArgv(["omarchy-models", "start", model.recipe])
    }
  }

  // The CLI's download while a first sign-in installs it: its speed beside
  // its bar, in the decimal units downloads are counted in.
  function downloadRate(rate) {
    return rate > 0 ? Commons.I18n.t("agents.downloadRate").arg(Commons.I18n.formatNumber(Math.round(rate / 1e6), 0)) : ""
  }

  property string addStage: ""
  property string addProvider: ""
  property var addChecks: ({})
  property string addStatus: ""
  property string addCode: ""
  property string addUrl: ""
  property bool addNeedsPaste: false
  // What to paste, when the sign-in says: Gemini's code, an API key.
  property string addPasteHint: ""
  // An API key is the whole sign-in, with no browser login to speak of.
  property bool addKeyEntry: false
  property bool addCheckingCode: false
  property string addResult: ""
  // The CLI's own download, when it isn't installed yet: the first sign-in
  // installs it before the browser opens.
  property bool addDownloading: false
  property real addRateBytes: 0
  property string addInstallStage: ""
  property double addInstallStartedMs: 0
  property real addInstallFill: 0
  // Where a sign-in is, as a setup flow: getting the CLI, then signing in.
  property string addPhase: ""
  // When the download ends its bar fills to the end before the sign-in takes
  // its place, so one that took a second still reads as done, not skipped.
  property bool addFetched: false
  property string addHeldStatus: ""
  Timer {
    id: addFetchTimer
    interval: Style.duration(450)
    onTriggered: root.beginSignIn(root.addHeldStatus)
  }

  function beginSignIn(status) {
    addFetchTimer.stop()
    addFetched = false
    addStatus = status
    addDownloading = false
    addRateBytes = 0
    addInstallStage = ""
    addInstallFill = 0
    addPhase = "signin"
  }
  property bool addReauth: false
  // Signing in takes over the hero: the provider's mark and name, with what's
  // being set up below, from naming through sign-in or failure.
  readonly property bool setupShown: (addStage === "name" || addStage === "running" || addStage === "error") && addProviderEntry !== null
  readonly property var addProviderEntry: {
    for (var i = 0; i < signInProviders.length; i++)
      if (signInProviders[i].providerId === addProvider) return signInProviders[i]
    return null
  }
  // Claude only needs a code pasted back when its page shows one, so the
  // field waits behind a link until then.
  readonly property bool pasteLinkShown: addProvider === "claude" && !addNeedsPaste && !addDownloading && !addCheckingCode
  // Whether the sign-in in progress opened a private window, so reopening its
  // page does too.
  property bool addPrivate: false

  function addAccount() {
    if (addStage === "running") return
    addProvider = ""
    addReauth = false
    addStage = "pick"
    addChecks = ({})
    if (!checkProcess.running) checkProcess.running = true
    // A package upgrade may have brought new models to set up.
    if (localModelsService) localModelsService.refreshLocal()
  }

  function chooseAddProvider(id) {
    var tile = signInProviders.find(function(p) { return p.providerId === id })
    if (tile && tile.more) {
      addMore = tile.more
      addStage = "more"
      return
    }
    if (id === otherInOpenCode) {
      openOpenCodeLogin()
      return
    }
    if (tile && tile.terminalLogin) {
      openTerminalLogin(tile.providerId)
      return
    }
    if (tile && tile.signsInAs) id = tile.signsInAs
    var state = addChecks[id] || ""
    if (state === "") return
    addProvider = id
    if (state === "additional") addStage = "name"
    else startAdd("")
  }

  function beginAdd(providerId, isPrivate, isReauth, command) {
    addProvider = providerId
    addPrivate = isPrivate
    addStatus = Commons.I18n.t("agents.starting")
    addCode = ""
    addUrl = ""
    // Claude's login usually finishes on its own once the browser hands back
    // to it. When its page shows a code instead, its prompt for it has no
    // newline to read it by, so the field stays a link away the whole time.
    addNeedsPaste = false
    addPasteHint = ""
    addKeyEntry = false
    addCheckingCode = false
    addDownloading = false
    addRateBytes = 0
    addInstallStage = ""
    addInstallStartedMs = 0
    addInstallFill = 0
    addPhase = ""
    addFetched = false
    addFetchTimer.stop()
    addReauth = isReauth
    addResult = ""
    addStage = "running"
    addProcess.command = command
    addProcess.running = true
    root.focusKeys()
  }

  function startAdd(label) {
    beginAdd(addProvider, (addChecks[addProvider] || "") === "additional", false,
      ["omarchy-agent-account-add", "--events", addProvider].concat(label !== "" ? [label] : []))
  }

  function cancelAdd() {
    // The More list steps back to the add screen it came from.
    if (addStage === "more") {
      addStage = "pick"
      return
    }
    if (addProcess.running) addProcess.signal(15)
    addFetchTimer.stop()
    addCheckingCode = false
    addProvider = ""
    addReauth = false
    addStage = ""
    root.focusKeys()
  }

  // Every other provider OpenCode signs in to, in its own picker.
  function openOpenCodeLogin() {
    root.close()
    Util.execArgv(["omarchy-launch-floating-terminal-with-presentation",
                   'omarchy-install-ai-cli opencode && opencode auth login && { [[ -n $(omarchy-default-agent) ]] || omarchy-default-agent --select opencode; }'])
  }

  function openTerminalLogin(id) {
    root.close()
    if (id === "kimi") {
      Util.execArgv(["omarchy-launch-floating-terminal-with-presentation",
                     'omarchy-install-ai-cli kimi && kimi login && { omarchy-shell omarchy.agents showAgent kimi true >/dev/null 2>&1 || true; } && { omarchy-agent-launcher kimi || true; } && { omarchy-agent-usage-update --force kimi || true; } && { [[ -n $(omarchy-default-agent) ]] || omarchy-default-agent --select kimi; }'])
    }
  }

  function submitPaste(code) {
    if (!addProcess.running || code.trim() === "") return
    addProcess.write(code.trim() + "\n")
    addNeedsPaste = false
    if (!addKeyEntry) addCheckingCode = true
    root.focusKeys()
  }

  // The add command's own lines are tagged; everything else is the CLI
  // talking, and only two things in it matter here: a code to confirm in the
  // browser (Grok, Muse, OpenCode), and an invitation to paste one back (Claude).
  function handleAddLine(line) {
    var text = String(line).replace(/\u001b\[[0-9;]*m/g, "")
    var tagged = text.match(/^@@omarchy (status|progress|paste|key|done|error) (.*)$/)
    if (tagged) {
      if (tagged[1] === "paste" || tagged[1] === "key") {
        addPasteHint = tagged[2]
        addNeedsPaste = true
        addKeyEntry = tagged[1] === "key"
        addCheckingCode = false
      } else if (tagged[1] === "progress") {
        var parts = tagged[2].split(" ")
        var done = Number(parts[0]) || 0
        var total = Number(parts[1]) || 0
        var stage = parts[3] || ""
        var now = Date.now()
        if (addPhase !== "get") {
          addInstallStartedMs = now
          addInstallFill = 0
          nowMs = now
        }
        addInstallStage = stage
        addRateBytes = Number(parts[2]) || 0
        addDownloading = true
        addPhase = "get"
        addInstallFill = Math.max(addInstallFill, cliInstallProgress(stage, done, total, addInstallStartedMs, now))
      } else if (tagged[1] === "status") {
        // A download's progress follows its status at once; any other
        // status is the sign-in's, held while a finished download's bar fills.
        if (addPhase === "get" && !addFetched) {
          addFetched = true
          addHeldStatus = tagged[2]
          addFetchTimer.restart()
        } else if (addFetched) {
          addHeldStatus = tagged[2]
        } else {
          beginSignIn(tagged[2])
        }
      } else {
        addFetchTimer.stop()
        addFetched = false
        addDownloading = false
        addCheckingCode = false
        addResult = tagged[2]
        // A sign-in that finishes goes straight back to the page, where the
        // account shows once its limits arrive.
        addStage = tagged[1] === "done" ? "" : tagged[1]
        if (tagged[1] === "done") {
          setProviderShown(addProvider, true)
          addProvider = ""
          addReauth = false
          usage.refreshLimits()
          // Nothing to show yet means the sign-in is what counts as set up.
          if (usage.enabledProviders.length === 0 && !checkProcess.running) {
            addChecks = ({})
            checkProcess.running = true
          }
        }
        root.focusKeys()
      }
      return
    }
    // On a line of its own, or after OpenCode's "Enter code:".
    var code = text.match(/(?:^|code:)\s*([A-Z0-9]{4}-[A-Z0-9]{4})\s*$/)
    if (code) addCode = code[1]
    if (/paste code/i.test(text)) {
      addCheckingCode = false
      addNeedsPaste = true
    }
    var url = text.match(/(https:\/\/\S+)/)
    if (url && addUrl === "") {
      addUrl = url[1]
      if (addProviderEntry && addProviderEntry.printsPage) reopenSignIn()
    }
  }

  // The field takes the keys from here, so the cursor lets go of the links.
  function openPasteField() {
    addCheckingCode = false
    addNeedsPaste = true
    cursorActive = false
  }

  function reopenSignIn() {
    if (addUrl === "") return
    Util.execArgv(addPrivate ? ["omarchy-launch-browser", "--private", addUrl] : ["omarchy-launch-browser", addUrl])
  }

  // A few ways into making Omarchy your own, handed to the default agent. The
  // prompts live in omarchy-agent-make.
  readonly property var starterPrompts: [
    { glyph: "󰏘", label: Commons.I18n.t("agents.theme"), kind: "theme" },
    { glyph: "󰐱", label: Commons.I18n.t("agents.plugin"), kind: "plugin" },
    { glyph: "󰣆", label: Commons.I18n.t("agents.app"), kind: "app" },
    { glyph: "󰊴", label: Commons.I18n.t("agents.game"), kind: "game" }
  ]
  // Two across, so a label in a long language still fits its tile.
  readonly property int starterColumns: 2

  // A local model that's running, and a coding model that's set up but
  // stopped, which takes a task too: opening the agent on it starts it first.
  readonly property bool localModelRunning: Object.keys(localModels).some(function(id) {
    return localModels[id] && localModels[id].kind === "text" && localModels[id].unit === "active" && localModels[id].sub_state === "running"
  })
  readonly property bool localModelStopped: Object.keys(localModels).some(function(id) {
    return localModels[id] && localModels[id].kind === "text" && localModels[id].unit === "inactive"
  })

  // The starters only show once something can take the task: a local model
  // that's running or stopped, or a signed-in subscription with a coding agent
  // of its own. A model still downloading or loading doesn't count yet.
  readonly property bool starterAgentReady: localModelRunning || localModelStopped || providers.some(function(p) {
    return harnessFor(p) !== "" && !signedOut(p)
  })
  readonly property bool starterShown: indexShown && starterAgentReady

  function startPrompt(kind) {
    root.close()
    Util.execArgv(["omarchy-agent-make", kind])
  }

  function renameAccount(p, account, label) {
    if (!p || !account) return
    Util.execArgv(["omarchy-agent-account-rename", p.providerId, String(account.id), label])
  }

  // A line's name: the agent's, and its account's when it's one of several.
  function lineName(line) {
    if (!line) return ""
    if (line.localModel) return line.localModel.host ? line.providerName + " " + line.localModel.host : line.providerName
    return line.account ? line.providerName + " " + String(line.account.label || line.account.id || "") : line.providerName
  }

  // The line whose sparkles were opened into its four make icons; folded
  // again when the line is left or the panel closes.
  property int makesOpenIndex: -1

  function openMakes(index) {
    makesOpenIndex = index
    Qt.callLater(function() { pointAt("make:" + starterPrompts[0].kind, index) })
  }

  // The desktop app a subscription has, when it's installed: the terminal
  // button starts the coding agent, this opens the app, which keeps its own
  // sign-in.
  readonly property var desktopApps: ({
    agy: "antigravity",
    claude: "com.anthropic.Claude",
    codex: "chatgpt",
    cursor: "cursor",
    grok: "grok-bot",
    grokbot: "grok-bot",
    hermes: "hermes-desktop",
    opencode: "ai.opencode.desktop"
  })

  function desktopFor(provider) {
    var id = provider && desktopApps[provider.providerId]
    if (typeof id !== "string" || !DesktopEntries.applications.values.length) return null
    return DesktopEntries.byId(id)
  }

  // Focuses the app's window when it's open, else launches it.
  function launchDesktop(provider) {
    var entry = desktopFor(provider)
    if (!entry) return
    root.close()
    var id = entry.id.toLowerCase()
    var startupClass = entry.startupClass.toLowerCase()
    for (var win of ToplevelManager.toplevels.values) {
      var appId = win.appId.toLowerCase()
      // ChatGPT also uses the Codex app id. The harness lives in a terminal
      // with its own id (org.omarchy.codex), which must never claim this.
      if (!win.parent && appId && (appId === id || appId === startupClass || (id === "chatgpt" && appId === "codex"))) {
        win.activate()
        return
      }
    }
    Util.execArgv(["uwsm-app", "--", "gtk-launch", entry.id + ".desktop"])
  }

  // Starts a line's agent, or has it make `kind` when one is given, first
  // switching to the line's account when it isn't the one in use.
  function runLine(line, kind) {
    if (!launches(line)) return
    var command = [kind ? "omarchy-agent-make" : "omarchy-agent"]
    if (line.localModel) command.push("--local-model", line.localModel.target)
    else if (opensInAgent(line)) command.push("--provider", line.providerId)
    else command.push("--agent", harnessFor(line))
    if (kind) command.push(kind)
    if (command[1] === "--agent" && line.account && !line.account.active)
      command = ["bash", "-c", 'omarchy-agent-account-use "$1" "$2" >/dev/null && exec "${@:3}"',
                 "run-line", line.providerId, String(line.account.id)].concat(command)
    Util.execArgv(command)
    root.close()
  }

  function useAccount(p, account) {
    if (!p || !account || account.active) return
    Util.execArgv(["omarchy-agent-account-use", p.providerId, String(account.id)])
  }

  function activateSelection() {
    var target = keyTarget
    if (!target) refreshNow()
    else if (target.kind === "add") addStage !== "" ? cancelAdd() : addAccount()
    else if (target.kind === "instructions") editInstructions()
    else if (target.kind === "choice") chooseAddProvider(target.index)
    else if (target.kind === "ownModel") chooseOwnModel(target.index)
    else if (target.kind === "pasteCode") openPasteField()
    else if (target.kind === "reopenSignIn") reopenSignIn()
    else if (target.kind === "providerLaunch") runLine(providers[target.index])
    else if (target.kind === "providerStar") makeDefault(providers[target.index], providers[target.index].account || null)
    else if (target.kind === "makeToggle") openMakes(target.index)
    else if (target.kind === "providerDesktop") launchDesktop(providers[target.index])
    else if (target.kind.indexOf("make:") === 0) runLine(providers[target.index], target.kind.slice(5))
    else if (target.kind === "starter") startPrompt(starterPrompts[target.index].kind)
    else if (target.kind === "providerSignin") signInAgain(providers[target.index], providers[target.index].account || null)
    else if (target.kind === "localUpdate") runLocalAction(providers[target.index].localModel, "update")
    else if (target.kind === "localShare") runLocalAction(providers[target.index].localModel, "share")
    else if (target.kind === "localToggle") runLocalAction(providers[target.index].localModel, "toggle")
    else if (target.kind === "localLogs") showLocalLogs(localModelState(providers[target.index].localModel))
  }

  // The cursor's place on a line: its terminal button, or its mark.
  function pointAtProvider(i) {
    pointAt(lineStop(i), i)
  }

  // Whichever moved last, the mouse or the keys, engages a line, never
  // both. Only the pointer really moving counts: the keys reflow the panel
  // under a parked one, which reads as hovering whatever lands beneath it.
  property bool pointerActive: false
  property point pointerSpot: Qt.point(-1, -1)
  function pointerMoved(spot) {
    if (spot.x === pointerSpot.x && spot.y === pointerSpot.y) return
    pointerSpot = spot
    if (pointerActive) return
    pointerActive = true
    cursorActive = false
  }

  // The keyboard's cursor follows the mouse unseen, so the next arrow
  // starts from there.
  function pointerOnLine(i) {
    if (!pointerActive) return
    var row = keyRows[keyRow]
    if (!row || lineOf(row[Math.min(keyColumn, row.length - 1)]) !== i) pointAtProvider(i)
    cursorActive = false
  }

  // A control under the mouse draws its own hover.
  function hoverAt(kind, index) {
    if (!pointerActive) return
    pointAt(kind, index)
    cursorActive = false
  }

  // Hands the keyboard back to the panel after an inline edit.
  function focusKeys() {
    if (panel.loadedContent) panel.loadedContent.forceActiveFocus()
  }

  // Only the agents `omarchy-agent-account-add` signs in get the link; any
  // other agent's sign-in trouble stays text, with its own help to follow.
  function supportsSignIn(p) {
    for (var i = 0; i < signInProviders.length; i++)
      if (p && signInProviders[i].providerId === p.providerId) return !signInProviders[i].limitsElsewhere
    return false
  }

  // A lapsed or missing sign-in is something you can fix from here; any other
  // trouble is only reported.
  function needsSignIn(item) {
    if (item && item.providerId && !supportsSignIn(item)) return false
    return signedOut(item)
  }

  // Whether its sign-in has lapsed, whether or not it can be fixed from here.
  function signedOut(item) {
    var status = String(item && item.usageStatusText || "")
    return status === "Sign-in expired" || status === "Waiting for auth"
  }

  // Whatever keeps the numbers from being current, said beside the last ones
  // known: they stay on show until a check succeeds again. A failed refresh
  // with numbers kept may leave the status empty and say why only in its help.
  function usageNote(item) {
    if (!item || needsSignIn(item)) return ""
    var status = String(item.usageStatusText || "")
    var stale = item.limitsStale === true || item.stale === true
    if (status === "" && !(stale && String(item.authHelpText || "") !== "")) return ""
    return helpDisplayText(item.authHelpText) || statusDisplayText(status)
  }

  // Sign an account that's already here in again, following along in the
  // add view just like adding one.
  function signInAgain(p, account) {
    if (!supportsSignIn(p) || addStage === "running") return
    beginAdd(p.providerId, !!account && account.primary !== true, true,
      ["omarchy-agent-account-add", "--events", "--reauth",
        account && account.primary !== true ? String(account.id) : ":primary", p.providerId])
  }

  function resetCreditsText(credits) {
    if (!credits || !(Number(credits.available) > 0)) return ""
    var count = Number(credits.available)
    var expires = new Date(String(credits.nextExpiresAt || "")).getTime()
    if (isFinite(expires) && expires > nowMs) {
      return Commons.I18n.tn("agents.freeResetsExpires", count)
        .arg(Commons.I18n.formatNumber(count)).arg(formatDuration(expires - nowMs))
    }
    return freeResetsText(count)
  }

  function freeResetsText(count) {
    return Commons.I18n.tn("agents.freeResets", count).arg(Commons.I18n.formatNumber(count))
  }

  function planLabel(p) {
    var tier = String(p && p.tierLabel || "")
    if (tier === "Prepaid") return Commons.I18n.t("agents.tierPrepaid")
    return tier === "" ? "" : tier.charAt(0).toUpperCase() + tier.slice(1)
  }

  function launchAgent() {
    if (root.bar) root.bar.run("omarchy-agent --pick")
    root.close()
  }

  // The coding agent made for each subscription, by usage provider id. A
  // provider with none of its own (Z.ai, DeepSeek…) gets no terminal button:
  // which harness to point at it is the user's choice.
  readonly property var harnesses: ({
    agy: "agy",
    claude: "claude",
    codex: "codex",
    copilot: "copilot",
    cursor: "cursor-agent",
    deepseek: "dsh",
    devin: "devin",
    grok: "grok",
    hermes: "hermes",
    kimi: "kimi",
    muse: "muse",
    opencode: "opencode",
    qwen: "qwen"
  })

  function harnessFor(provider) {
    return provider && harnesses[provider.providerId] ? harnesses[provider.providerId] : ""
  }

  // The providers whose key or plan the panel saves in OpenCode open there,
  // on the model they've used most.
  readonly property var keyProviders: ["fireworks", "openrouter", "deepseek", "minimax", "synthetic", "zai"]

  function opensInAgent(provider) {
    return !!provider && keyProviders.indexOf(provider.providerId) >= 0
  }

  // A local model opens once it's set up, starting first when it's stopped.
  function launches(provider) {
    // A local model opens an agent only while it runs; until then its line
    // has the play button alone.
    if (provider && provider.localModel) return localRunning(provider.localModel)
    return harnessFor(provider) !== "" || opensInAgent(provider)
  }

  // What choosing this agent as the default writes: its harness, OpenCode for
  // a provider that runs there, or "local" for models on hardware you own.
  // Empty for one that can't be the default.
  function defaultIdFor(provider) {
    if (!provider) return ""
    if (provider.providerId === "local") return "local"
    if (opensInAgent(provider)) return "opencode"
    return harnessFor(provider)
  }

  function isDefault(provider) {
    var id = defaultIdFor(provider)
    return id !== "" && usage.defaultAgent === id
  }

  // The star: the agent becomes the default without opening, and with several
  // accounts the one starred becomes the one sessions use.
  function makeDefault(provider, account) {
    var id = defaultIdFor(provider)
    if (id === "") return
    // A local model's star pins it as the one the default opens.
    if (provider.localModel) {
      if (starred(provider, null)) return
      selectLocalDefault(provider.localModel.target)
      return
    }
    if (account && !account.active) useAccount(provider, account)
    if (usage.defaultAgent === id) return
    usage.defaultAgent = id
    selectDefault.command = ["omarchy-default-agent", "--select", id]
    selectDefault.running = true
  }

  // Filled on the default agent, and with several accounts on the one in use.
  function starred(provider, account) {
    if (provider && provider.localModel) return isDefault(provider) && provider.localModel.target === localDefaultTarget
    return isDefault(provider) && (!account || account.active === true)
  }


  // ---------------------------------------------------------------- limits
  //
  // Both providers report the same two shapes: a short rolling session window
  // and a long weekly one. Everything below normalizes them into one record so
  // the meters speak a single language.

  // Claude spells its windows out ("Session (5-hour)"), Codex abbreviates
  // them ("5h window", "30m window"). Both have to land on the same record.
  function windowIsLong(text) {
    return text.indexOf("week") >= 0 || text.indexOf("7-day") >= 0 || text.indexOf("seven") >= 0
      || text.indexOf("month") >= 0 || text.indexOf("30-day") >= 0
  }

  function windowSpanMs(label) {
    var text = String(label || "").toLowerCase()
    if (text.indexOf("month") >= 0 || text.indexOf("30-day") >= 0) return 30 * 24 * 3600 * 1000
    if (windowIsLong(text)) return 7 * 24 * 3600 * 1000
    var hours = text.match(/(\d+)\s*-?\s*h(?:our)?\b/)
    if (hours) return Number(hours[1]) * 3600 * 1000
    var minutes = text.match(/(\d+)\s*-?\s*m(?:in(?:ute)?s?)?\b/)
    if (minutes) return Number(minutes[1]) * 60 * 1000
    return 0
  }

  function windowTitle(label) {
    var text = String(label || "").toLowerCase()
    if (text.indexOf("month") >= 0) return "Monthly"
    if (windowIsLong(text)) return "Weekly"
    if (text.indexOf("session") >= 0 || windowSpanMs(label) > 0) return "Session"
    var plain = String(label || "").replace(/\s*\(.*\)\s*/, "").trim()
    return plain === "" ? "Limit" : plain
  }

  // A collector that already knows which window a limit belongs to says so,
  // and that beats reading it back out of the label: a model-scoped limit is
  // titled after its model, and a name like "Opus 5 (1M context)" would parse
  // as a one-minute window.
  function limitWindow(label, percent, resetAt, title) {
    var reset = new Date(String(resetAt || "")).getTime()
    var expired = isFinite(reset) && reset <= root.nowMs
    return {
      title: String(title || "") !== "" ? String(title) : windowTitle(label),
      percent: expired ? 0 : Number(percent),
      resetAt: expired ? "" : String(resetAt || "")
    }
  }

  function limitWindows(p) {
    if (!p) return []
    var out = []
    var list = p.limits || []
    for (var i = 0; i < list.length; i++) {
      var entry = list[i] || {}
      var percent = Number(entry.percent)
      if (percent >= 0) out.push(limitWindow(entry.label, percent, entry.resetsAt, entry.title))
    }
    return out
  }

  // A model-scoped window ("Fable Weekly") is its own allowance, but it runs
  // on the same clock as the window it's named for, so it's shown attached to
  // that row rather than as a row of its own. One with nothing to attach to
  // still gets its own row.
  function scopedPart(title) {
    var match = String(title || "").match(/^(.+) (Session|Weekly|Monthly)$/)
    return match ? { model: match[1], window: match[2] } : null
  }

  function displayWindows(p) {
    var windows = limitWindows(p)
    var out = []
    var byTitle = {}
    for (var i = 0; i < windows.length; i++) {
      if (scopedPart(windows[i].title)) continue
      windows[i].scoped = []
      out.push(windows[i])
      byTitle[windows[i].title] = windows[i]
    }
    for (var j = 0; j < windows.length; j++) {
      var part = scopedPart(windows[j].title)
      if (!part) continue
      var base = byTitle[part.window]
      if (base) {
        base.scoped.push({ title: part.model, percent: windows[j].percent, resetAt: windows[j].resetAt })
      } else {
        windows[j].scoped = []
        out.push(windows[j])
      }
    }
    return out
  }

  // The window that decides how much room is left — the fullest one, since
  // that is what stops the next prompt.
  function bindingWindow(p) {
    var windows = limitWindows(p)
    var best = null
    for (var i = 0; i < windows.length; i++) {
      if (!best || windows[i].percent > best.percent) best = windows[i]
    }
    return best
  }

  function resetMsFor(w) {
    if (!w || w.resetAt === "") return -1
    var ms = new Date(w.resetAt).getTime()
    return isFinite(ms) ? ms - root.nowMs : -1
  }

  function formatDuration(ms) {
    if (!(ms > 0)) return Commons.I18n.t("agents.durationNow")
    var minutes = Math.floor(ms / 60000)
    var hours = Math.floor(minutes / 60)
    var days = Math.floor(hours / 24)
    if (days > 0) return Commons.I18n.t("agents.durationDaysHours").arg(Commons.I18n.formatNumber(days)).arg(Commons.I18n.formatNumber(hours % 24))
    if (hours > 0) return Commons.I18n.t("agents.durationHoursMinutes").arg(Commons.I18n.formatNumber(hours)).arg(Commons.I18n.formatNumber(minutes % 60))
    return Commons.I18n.t("agents.durationMinutes").arg(Commons.I18n.formatNumber(Math.max(1, minutes)))
  }

  // Window titles stay English in the records, where scopedPart() and the
  // collectors match on them; only what reaches the screen is translated.
  function windowDisplayTitle(title) {
    var value = String(title || "")
    if (value === "Session") return Commons.I18n.t("agents.windowSession")
    if (value === "Weekly") return Commons.I18n.t("agents.windowWeekly")
    if (value === "Monthly") return Commons.I18n.t("agents.windowMonthly")
    if (value === "Spend limit") return Commons.I18n.t("agents.windowSpendLimit")
    if (value === "Limit") return Commons.I18n.t("agents.windowLimit")
    var part = scopedPart(value)
    if (part && part.window === "Session") return Commons.I18n.t("agents.modelSession").arg(part.model)
    if (part && part.window === "Weekly") return Commons.I18n.t("agents.modelWeekly").arg(part.model)
    if (part && part.window === "Monthly") return Commons.I18n.t("agents.modelMonthly").arg(part.model)
    return value
  }

  function scopedAllowanceText(scoped, windowTitle) {
    var percent = Commons.I18n.formatNumber(Math.round(scoped.percent * 100))
    var value = String(windowTitle || "")
    if (value === "Session") return Commons.I18n.t("agents.scopedSession").arg(scoped.title).arg(percent)
    if (value === "Weekly") return Commons.I18n.t("agents.scopedWeekly").arg(scoped.title).arg(percent)
    if (value === "Monthly") return Commons.I18n.t("agents.scopedMonthly").arg(scoped.title).arg(percent)
    return Commons.I18n.t("agents.scopedOther").arg(scoped.title).arg(percent).arg(windowDisplayTitle(value))
  }

  // The collectors write a fixed English status; the ones that reach the
  // screen are shown in the current language.
  function statusDisplayText(status) {
    var value = String(status || "")
    if (value === "Balance unavailable") return Commons.I18n.t("agents.balanceUnavailable")
    if (value === "Out of credits") return Commons.I18n.t("agents.outOfCredits")
    var limits = value.match(/^(.+) limits unavailable$/)
    if (limits) return Commons.I18n.t("agents.providerLimitsUnavailable").arg(limits[1])
    var provider = value.match(/^(.+) unavailable$/)
    if (provider) return Commons.I18n.t("agents.providerUnavailable").arg(provider[1])
    if (value === "Sign-in expired") return Commons.I18n.t("agents.signInExpired")
    if (value === "Waiting for auth") return Commons.I18n.t("agents.waitingForAuth")
    if (value === "Limits paused") return Commons.I18n.t("agents.limitsPaused")
    return value
  }

  // The usage collectors cache their help lines in English, so the fixed
  // ones are translated here; commands stay verbatim as arguments, and raw
  // error text from a provider passes through as it came.
  function helpDisplayText(text) {
    var value = String(text || "")
    switch (value) {
    case "Run `claude auth login` to restore authoritative usage.":
      return Commons.I18n.t("agents.helpRunToRestoreUsage").arg("`claude auth login`")
    case "Run `codex login` to authenticate.":
      return Commons.I18n.t("agents.helpRunToAuthenticate").arg("`codex login`")
    case "Start Grok, or run `grok login`, to sign in.":
      return Commons.I18n.t("agents.helpStartOrRunToSignIn").arg("Grok").arg("`grok login`")
    case "Start Grok to see its limits; signing in again is not needed.":
      return Commons.I18n.t("agents.helpStartToSeeLimits").arg("Grok")
    case "Grok's saved sign-in expired. Start Grok to refresh it.":
      return Commons.I18n.t("agents.helpSignInExpired").arg("Grok")
    case "Set FIREWORKS_API_KEY, run `firectl set-api-key`, or sign in to Fireworks in pi or opencode.":
      return Commons.I18n.t("agents.helpFireworksSignIn").arg("FIREWORKS_API_KEY").arg("`firectl set-api-key`")
    case "codex not found in PATH":
      return Commons.I18n.t("agents.helpNotInPath").arg("codex")
    case "Fireworks usage scan failed":
      return Commons.I18n.t("agents.helpScanFailed").arg("Fireworks")
    }
    return value
  }

  // ---------------------------------------------------------------- balance
  //
  // Prepaid agents report a credit ledger instead of rate-limit windows: the
  // record's balance object carries remaining, funded, and spent amounts.

  // A prepaid account runs low the way a subscription window fills up: the
  // last 10% of the funded credits lights the same alarm.
  function balanceAlarming(b) {
    return !!b && b.funded > 0 && b.remaining / b.funded <= 0.1
  }

  function currencyPrefix(currency) {
    var code = String(currency || "USD").toUpperCase()
    if (code === "USD") return "$"
    if (code === "EUR") return "€"
    if (code === "GBP") return "£"
    return code + " "
  }

  function formatMoney(value, currency) {
    var amount = Number(value)
    if (!isFinite(amount)) amount = 0
    return currencyPrefix(currency) + Commons.I18n.formatNumber(amount, 2)
  }

  // A balance or spend row's amount is as wide as a limit row's time left
  // ("19h 40m"), so every line ends where the limit meters do.
  TextMetrics {
    id: valueColumnMetrics
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
    text: "00h 00m"
  }
  // The share of a meter row its title takes: wide enough for the longest
  // window name ("Claude/GPT Weekly") without eliding it.
  readonly property real labelColumnRatio: 0.34
  readonly property real valueColumnWidth: Math.ceil(valueColumnMetrics.advanceWidth)

  // ------------------------------------------------------------------ spend
  //
  // Pay-as-you-go agents report what the account spent over the last 30
  // days, or this month against the cap when its tier sets one, which fills
  // like a limit window.

  function spendAlarming(s) {
    return !!s && s.cap > 0 && s.amount / s.cap >= 0.9
  }

  function spendValueText(s) {
    if (!s) return ""
    var amount = formatMoney(s.amount, s.currency)
    // Added up from this machine's sessions, so only about what was billed.
    if (s.estimated) return Commons.I18n.t("agents.spendEstimated").arg(amount)
    return s.cap > 0 ? Commons.I18n.t("agents.spendOfCap").arg(amount).arg(formatMoney(s.cap, s.currency)) : amount
  }

  // What one of the spend's days cost, for its bar's tooltip, with the tokens
  // it took when the record still has them (the last week's). The days end
  // on the collector's today, the last of the record's recent days.
  function spendDayText(s, recentDays, index) {
    if (!s || !(index >= 0 && index < s.days.length)) return ""
    // Tokens are counted in local days, so a record dated in UTC days has
    // none to pair with its bars.
    var recent = s.utc ? [] : (recentDays || [])
    var last = s.through !== "" ? s.through : recent.length > 0 ? String(recent[recent.length - 1].date) : ""
    var day = new Date(last !== "" ? last + "T12:00:00" : nowMs)
    if (isNaN(day.getTime())) day = new Date(nowMs)
    day.setDate(day.getDate() - (s.days.length - 1 - index))
    var date = Qt.formatDate(day, "yyyy-MM-dd")
    var label = day.toLocaleDateString(Qt.locale(Commons.I18n.formatLocale), "d MMM")
    var cost = formatMoney(s.days[index], s.currency)
    if (s.estimated) cost = Commons.I18n.t("agents.spendEstimated").arg(cost)
    var tokens = 0
    for (var i = 0; i < recent.length; i++)
      if (recent[i].date === date) tokens = Number(recent[i].messageCount) || 0
    return tokens > 0
      ? Commons.I18n.tn("agents.spendDayTokens", tokens).arg(label).arg(cost).arg(usage.formatTokenCount(tokens))
      : Commons.I18n.t("agents.spendDay").arg(label).arg(cost)
  }

  // ---------------------------------------------------------------- summary
  //
  // The hero's line rotates through what the token counts add up to across
  // every agent, now that they no longer get charts of their own.

  readonly property var summaryPhrases: {
    var rev = usage.dataRevision
    var week = 0
    var today = 0
    var prompts = 0
    var sessions = 0
    var byDay = {}
    var byModel = {}
    var providers = usage.enabledProviders
    for (var i = 0; i < providers.length; i++) {
      var p = providers[i]
      var days = p.recentDays || []
      for (var d = 0; d < days.length; d++) {
        var tokens = Number(days[d].messageCount || 0)
        week += tokens
        byDay[days[d].date] = (byDay[days[d].date] || 0) + tokens
      }
      today += Number(p.todayTotalTokens || 0)
      if (p.hasPromptStats !== false) {
        prompts += Number(p.todayPrompts || 0)
        sessions += Number(p.todaySessions || 0)
      }
      var models = p.modelUsage || {}
      for (var id in models) {
        var bucket = models[id] || {}
        var total = Number(bucket.inputTokens || 0) + Number(bucket.outputTokens || 0)
          + Number(bucket.cacheReadInputTokens || 0) + Number(bucket.cacheCreationInputTokens || 0)
        var name = usage.friendlyModelName(id)
        byModel[name] = (byModel[name] || 0) + total
      }
    }

    var phrases = []
    if (week > 0) phrases.push(Commons.I18n.tn("agents.tokensThisWeek", week).arg(usage.formatTokenCount(week)))
    if (today > 0) phrases.push(Commons.I18n.tn("agents.tokensToday", today).arg(usage.formatTokenCount(today)))
    var topModel = ""
    for (var model in byModel) if (topModel === "" || byModel[model] > byModel[topModel]) topModel = model
    if (topModel !== "" && byModel[topModel] > 0) phrases.push(Commons.I18n.t("agents.mostlyModel").arg(topModel))
    var busiest = ""
    for (var date in byDay) if (busiest === "" || byDay[date] > byDay[busiest]) busiest = date
    if (busiest !== "" && byDay[busiest] > 0) phrases.push(Commons.I18n.t("agents.busiestDay").arg(dayName(busiest)))
    if (prompts > 0) phrases.push(Commons.I18n.tn("agents.promptsToday", prompts).arg(Commons.I18n.formatNumber(prompts)))
    if (sessions > 0) phrases.push(Commons.I18n.tn("agents.sessionsToday", sessions).arg(Commons.I18n.formatNumber(sessions)))
    return phrases
  }
  property int phraseIndex: 0
  // Every record that lands rebuilds the phrases, and opening the panel
  // refreshes each agent in turn. Indexing the live list would swap the line
  // on each of those, so the hero holds what it shows until the next fade.
  property string shownPhrase: ""
  readonly property string heroPhrase: !indexShown
    ? addHeading
    : (shownPhrase !== "" ? shownPhrase : Commons.I18n.t("agents.letsMakeSomethingCool"))

  function showPhrase() {
    var n = summaryPhrases.length
    shownPhrase = n > 0 ? summaryPhrases[phraseIndex % n] : ""
  }

  onSummaryPhrasesChanged: if (shownPhrase === "" || summaryPhrases.length <= 1) showPhrase()

  // The held line was written in the language it was shown in; once a new
  // language's strings arrive and the phrases rebuild, show it again.
  Connections {
    target: Commons.I18n
    function onStringsChanged() { Qt.callLater(root.showPhrase) }
  }

  function dayName(date) {
    var parsed = new Date(String(date || "") + "T00:00:00")
    if (isNaN(parsed.getTime())) return String(date || "")
    return Qt.locale(Commons.I18n.formatLocale).dayName([7, 1, 2, 3, 4, 5, 6][parsed.getDay()])
  }

  // Only speaks up when the numbers cover more than this machine.
  function footerText() {
    if (usage.syncStatusText !== "") return usage.syncStatusText
    var providers = usage.enabledProviders
    for (var i = 0; i < providers.length; i++) {
      var count = Number(providers[i].syncDeviceCount || 0)
      if (providers[i].syncEnabled && count > 0)
        return Commons.I18n.tn("agents.merged", count).arg(Commons.I18n.formatNumber(count))
    }
    return ""
  }

  // Marks resolve by convention, so a new agent's data file needs nothing
  // from this panel: assets/<id>.svg if it ships one, the module's bar glyph
  // if it doesn't. Agents that ship a white mark carry an `assets/<id>-light.svg`
  // twin for light surfaces.
  function iconCandidatesForProvider(p, surfaceColor) {
    if (!p) return []
    var id = p.iconId || p.providerId
    var candidates = []
    if (Util.luminance(surfaceColor || Commons.Color.background) >= 0.5)
      candidates.push(Qt.resolvedUrl("assets/" + id + "-light.svg"))
    candidates.push(Qt.resolvedUrl("assets/" + id + ".svg"))
    return candidates
  }

  // Always in the bar: on a machine with no agent yet, the panel is where you
  // set one up.
  readonly property bool anySignedIn: {
    for (var id in addChecks)
      if (addChecks[id] !== "first") return true
    return false
  }
  // Local history counts as set up, so a machine with no subscription still
  // gets its summary rather than the picker.
  // So does any local or paired coding model on the index (running, stopped,
  // loading, stopping, failed, or removing), while a model still being set up
  // or started from the picker stays on the blank-slate picker.
  readonly property bool hasIndexLocalModel: localModelLines.some(function(line) {
    return usage.localModelAdded(line)
      && line.localModel.target !== settingUpLocal
      && !localSettingUp(localModelState(line.localModel))
  })
  readonly property bool blankSlate: usage.enabledProviders.length === 0 && !anySignedIn && !hasIndexLocalModel
  readonly property bool indexShown: addStage === "" && !blankSlate
  // Choosing a provider: asked for with the +, or simply what the panel is
  // while nothing is set up. It's derived rather than switched into, so
  // records that load a moment after the panel opens take its place.
  readonly property bool picking: addStage === "pick" || (blankSlate && addStage === "")
  // The + in the hero turns into the X that leaves adding. A first setup has
  // nothing to go back to until an agent is chosen.
  readonly property bool addButtonShown: !blankSlate || !picking
  // Beside the + on the main list: the instructions every agent follows.
  readonly property bool instructionsShown: addButtonShown && addStage === ""

  function editInstructions() {
    root.close()
    Util.execArgv(["omarchy-agent-instructions", "--edit"])
  }

  // Adding takes over the hero's line, and the cursor starts over.
  readonly property string addHeading: setupShown
    ? (addReauth ? Commons.I18n.t("agents.signingInAgain") : Commons.I18n.t("agents.settingUp"))
    : (blankSlate ? Commons.I18n.t("agents.firstBecomesDefault") : Commons.I18n.t("agents.addKinds"))
  onAddStageChanged: {
    phraseSwap.stop()
    if (hero) hero.metaOpacity = 1.0
    resetKeys()
  }

  // A first setup ends when the records land, which swaps the rows under the
  // cursor without any stage change. Free memory is read again each time the
  // add screen offers models.
  onPickingChanged: {
    resetKeys()
    if (picking && localModelsService) localModelsService.readFreeMemory()
  }

  // Picking an agent to add starts on the first one, ready for Enter. The
  // rows follow the same stage change, so the cursor waits a tick for them.
  function resetKeys() {
    cursorActive = false
    pointerActive = false
    keyRow = 0
    keyColumn = 0
    Qt.callLater(function() {
      if (!picking) return
      var first = addGroup("subscription")[0] || addGroup("provider")[0]
      if (first) pointAt("choice", first.providerId)
    })
  }
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // The code field while it shows, set by the field itself since it lives
  // in the panel's content. A sign-in waiting on a code or key gives it the
  // keyboard whenever the panel opens, so opening it and pasting is all it
  // needs.
  property Item pasteFieldItem: null
  readonly property Item openFocusItem: addStage === "running" && addNeedsPaste && pasteFieldItem ? pasteFieldItem : panel.loadedContent
  onOpenedChanged: if (!opened) {
    openRefresh.stop()
    resetProviderDrag()
    makesOpenIndex = -1
  } else {
    deleteTarget = null
    if (addStage !== "running") {
      addStage = ""
      addProvider = ""
      addReauth = false
    }
    resetKeys()
    if (usage.enabledProviders.length === 0 && !checkProcess.running) checkProcess.running = true
    nowMs = Date.now()
    if (panelFlick) panelFlick.contentY = 0
    usage.reloadDefaults()
    // Defer the external usage/network refresh past the open animation so
    // spawning omarchy-agent-usage-update doesn't compete with rendering it.
    openRefresh.restart()
    // Whether a stopped model fits is as the engine last judged it; memory
    // freed since lets it start, so it's judged again.
    if (Object.keys(localModels).some(function(id) { return localModels[id].fits === false }))
      Util.execArgv(["omarchy-models", "status", "--write"])
    Qt.callLater(function() { if (root.openFocusItem) root.openFocusItem.forceActiveFocus() })
  }

  Timer {
    id: openRefresh
    interval: Math.max(16, Style.duration(220))
    onTriggered: {
      if (!root.opened) return
      usage.refreshLimits()
      if (localModelsService) localModelsService.refreshNetwork()
    }
  }

  // The tailnet has no change signal, so while the panel is open the paired
  // machines' models are surveyed again every 2 seconds, as the local models
  // panel does; never while it's closed. A survey never overlaps the last.
  Timer {
    interval: 2000
    running: root.opened && !!root.localModelsService
    repeat: true
    onTriggered: root.localModelsService.refreshNetwork()
  }

  // Choosing a default from a star. The star fills at once, and once the
  // choice is saved the default is read back, so one the command refused
  // (an agent whose CLI isn't installed here) doesn't stay starred.
  Process {
    id: selectDefault
    onExited: {
      usage.reloadDefaults()
    }
  }

  Main {
    id: usage
    settings: root.settings
    localModelLines: root.localModelLines
    localDefaultTarget: root.localDefaultTarget
  }

  Process {
    id: checkProcess
    running: false
    command: ["omarchy-agent-account-add", "--check"]
    stdout: SplitParser {
      onRead: function(line) {
        var parts = String(line).trim().split(" ")
        if (parts.length !== 2) return
        var checks = Object.assign({}, root.addChecks)
        checks[parts[0]] = parts[1]
        root.addChecks = checks
      }
    }
  }

  Process {
    id: addProcess
    running: false
    stdinEnabled: true
    stdout: SplitParser { onRead: function(line) { root.handleAddLine(line) } }
    onExited: {
      if (root.addStage === "running") {
        root.addCheckingCode = false
        root.addResult = Commons.I18n.t("agents.signInUnfinished")
        root.addStage = "error"
        root.focusKeys()
      }
    }
  }

  // Cheap enough to keep running: it only re-evaluates text bindings, and a
  // stale "resets in 2h" on a panel that is open is worse than a timer.
  Timer {
    interval: 30000
    running: root.opened
    repeat: true
    onTriggered: root.nowMs = Date.now()
  }

  Timer {
    interval: 2800
    running: root.opened && root.summaryPhrases.length > 1 && root.indexShown
    repeat: true
    onTriggered: phraseSwap.restart()
  }

  SequentialAnimation {
    id: phraseSwap
    PropertyAnimation {
      target: hero; property: "metaOpacity"
      to: 0.0; duration: Style.duration(150); easing.type: Easing.OutCubic
    }
    ScriptAction {
      script: {
        root.phraseIndex = (root.phraseIndex + 1) % Math.max(1, root.summaryPhrases.length)
        root.showPhrase()
      }
    }
    PropertyAnimation {
      target: hero; property: "metaOpacity"
      to: 1.0; duration: Style.duration(200); easing.type: Easing.OutCubic
    }
  }

  ShellIpc {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refreshNow(); return "ok" }
    // Shown as "true" or "false": omarchy-shell hands every argument over as
    // text, and a bool parameter takes the text "false" as true.
    function showAgent(id: string, shown: string): string { root.setProviderShown(id, shown === "true"); return "ok" }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󱚣"
    active: root.alarming
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.launchAgent()
      else if (buttonCode === Qt.MiddleButton) root.refreshNow()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: root.openFocusItem
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(860))

    content: PanelKeyCatcher {
      id: keyCatcher
      HoverHandler { onPointChanged: if (hovered) root.pointerMoved(point.scenePosition) }
      property alias panelFlick: panelFlick
      property alias hero: hero
      property alias column: column
      property alias providerSections: providerSections
      ConfirmDialog {
        id: deleteConfirm
        anchors.fill: parent
        z: 20
        opened: root.deleteTarget !== null
        onOpenedChanged: {
          // Delete then Return removes, as in every other confirmation;
          // starting on Cancel made that Return quietly do nothing.
          selectedIndex = 1
          if (opened) forceActiveFocus()
          else root.focusKeys()
        }
        Keys.onPressed: function(event) {
          handleKey(event)
          event.accepted = true
        }
        // A paired machine's model is unlinked, and this machine's removed.
        readonly property bool unlinks: !!root.deleteTarget && !!root.deleteTarget.localModel && root.deleteTarget.localModel.host !== ""
        confirmText: unlinks ? Commons.I18n.t("agents.unlink")
          : !!root.deleteTarget && !!root.deleteTarget.localModel ? Commons.I18n.t("common.delete")
          : Commons.I18n.t("common.confirm")
        message: !root.deleteTarget ? ""
          : unlinks ? Commons.I18n.t("agents.unlinkModelConfirm").arg(root.deleteTarget.providerName)
          : root.opensByDefault(root.deleteTarget) ? Commons.I18n.t("agents.removeDefaultLocalModelConfirm").arg(root.deleteTarget.providerName)
          : root.deleteTarget.localModel ? Commons.I18n.t("agents.removeLocalModelConfirm").arg(root.deleteTarget.providerName)
          : root.forgets(root.deleteTarget) ? Commons.I18n.t("agents.forgetAccountConfirm").arg(root.lineName(root.deleteTarget))
          : Commons.I18n.t("agents.hideProviderConfirm").arg(root.deleteTarget.providerName)
        foreground: root.foreground
        background: root.surface
        fontFamily: root.fontFamily
        onCanceled: root.deleteTarget = null
        onConfirmed: root.confirmDelete()
      }
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      reorderable: root.indexShown && !root.renaming
      onReorderRequested: function(dy) { root.reorderProvider(dy) }

      onMoveRequested: function(dx, dy) {
        // Naming has its own field; there the arrows scroll. Signing in walks
        // its links, and a code field takes its own keys once it's open.
        if (root.addStage === "" || root.addStage === "running" || root.addStage === "more" || root.picking) root.moveKey(dx, dy)
        else if (dy !== 0)
          panelFlick.contentY = root.clamp(panelFlick.contentY + dy * Style.space(56), 0,
                                           Math.max(0, panelFlick.contentHeight - panelFlick.height))
      }
      onDeleteRequested: root.deleteSelected()
      // A text field keeps its own keys: Qt passes Return on after accepting
      // it, and here that would press the Cancel under the cursor too, or
      // steal letters like j/k/x from an account name.
      blocked: root.renaming || root.deleteTarget !== null || (!!addViewLoader.item && addViewLoader.item.inputFocused)
      onActivateRequested: root.activateSelection()
      onCloseRequested: {
        if (root.dragIndex >= 0) root.settleProviderDrag(true)
        else if (root.addStage !== "") root.cancelAdd()
        else root.close()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refreshNow()
        else if (root.indexShown && t >= "1" && t <= "9" && Number(t) <= root.providers.length) { root.pointerActive = false; root.pointAtProvider(Number(t) - 1) }
      }

      Flickable {
        id: panelFlick
        // Reaches a little into the panel's padding on the left, with the
        // content shifted back, so the box around a lit agent mark isn't
        // clipped where it overhangs the content's edge.
        readonly property real overhang: Style.space(8)
        // Reaches into the padding on the right too, where the scroll bar
        // sits just inside the frame, so the content keeps its full width
        // whether the page scrolls or fits.
        readonly property real reach: panel.padding - Style.space(4)
        anchors.fill: parent
        anchors.leftMargin: -overhang
        anchors.rightMargin: -reach
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
          // The overhang sits on the start side, which is the right when
          // mirrored; there the scroll bar takes the left instead.
          x: LayoutMirroring.enabled ? panelFlick.reach : panelFlick.overhang
          width: panelFlick.width - panelFlick.overhang - panelFlick.reach
          spacing: Style.space(16)

          // ---------- Hero: agents · rotating summary · add ----------
          PanelHero {
            id: hero
            width: parent.width
            title: root.setupShown ? root.addProviderEntry.providerName
              : root.picking || root.addStage === "more" ? (root.blankSlate ? Commons.I18n.t("agents.setUpTitle") : Commons.I18n.t("agents.addTitle"))
              : Commons.I18n.t("agents.title")
            meta: root.heroPhrase
            foreground: root.foreground
            fontFamily: root.fontFamily

            iconComponent: Component {
              Item {
                implicitWidth: root.setupShown ? setupMark.width : agentsGlyph.implicitWidth
                implicitHeight: root.setupShown ? setupMark.height : agentsGlyph.implicitHeight

                Text {
                  id: agentsGlyph
                  visible: !root.setupShown
                  textFormat: Text.PlainText
                  text: button.text
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.display
                }

                ProviderIcon {
                  id: setupMark
                  visible: root.setupShown
                  provider: root.addProviderEntry
                  size: Style.font.display * 1.2
                }
              }
            }

            trailingControl: Component {
              Row {
                spacing: Style.space(6)
                visible: root.addButtonShown

                HeroButton {
                  id: instructionsButton
                  visible: root.instructionsShown
                  hasCursor: root.hasKey("instructions")
                  onHasCursorChanged: if (hasCursor) root.revealItem(instructionsButton)
                  fontFamily: root.fontFamily
                  onHovered: root.hoverAt("instructions")
                  glyph: "󰈙"
                  tooltip: Commons.I18n.t("agents.editInstructions")
                  onClicked: root.editInstructions()
                }

                HeroButton {
                  id: addButton
                  visible: root.addButtonShown
                  hasCursor: root.hasKey("add")
                  onHasCursorChanged: if (hasCursor) root.revealItem(addButton)
                  fontFamily: root.fontFamily
                  onHovered: root.hoverAt("add")
                  readonly property bool adding: root.addStage !== ""
                  glyph: adding ? "󰅖" : "󰐕"
                  tooltip: adding ? Commons.I18n.t("agents.backToLimits") : Commons.I18n.t("agents.addTitle")
                  onClicked: adding ? root.cancelAdd() : root.addAccount()
                }
              }
            }
          }

          Loader {
            id: addViewLoader
            active: !root.indexShown
            visible: active
            width: column.width
            sourceComponent: Component {
              AddView {
                visible: !root.indexShown
              }
            }
          }

          Repeater {
            id: providerSections
            model: root.indexShown ? root.providers : []

            ProviderSection {
              required property var modelData
              required property int index
              width: column.width
              provider: modelData
              providerIndex: index
            }
          }

          // ---------- Make something ----------
          PanelSeparator {
            visible: root.starterShown
            foreground: root.foreground
          }

          Column {
            visible: root.starterShown
            width: parent.width
            spacing: Style.space(12)

            PanelSectionHeader {
              text: Commons.I18n.t("agents.makeSomethingCool")
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Grid {
              id: tileGrid
              width: parent.width
              columns: root.starterColumns
              spacing: Style.space(10)

              Repeater {
                model: root.starterPrompts

                StarterTile {
                  required property var modelData
                  required property int index
                  hasCursor: root.hasKey("starter", index)
                  onHovered: root.hoverAt("starter", index)
                  width: (tileGrid.width - tileGrid.spacing * (tileGrid.columns - 1)) / tileGrid.columns
                  glyph: modelData.glyph
                  title: modelData.label
                  onClicked: root.startPrompt(modelData.kind)
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: text !== ""
            width: parent.width
            topPadding: Style.space(2)
            text: root.footerText()
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
          }
        }
      }
    }
  }

  // Adding a subscription, in place of the list: pick, name, sign in.
  // One agent to add: a large mark over its name.
  component AddChoice: Item {
    id: choice
    property var entry: ({})
    readonly property string state: root.addChecks[entry.signsInAs || entry.providerId] || ""
    readonly property bool available: !!entry.more || !!entry.terminalLogin || state === "first" || state === "additional"
    readonly property bool hasCursor: root.hasKey("choice", entry.providerId)
    implicitHeight: choiceBody.implicitHeight + Style.space(16)
    onHasCursorChanged: if (hasCursor) root.revealItem(choice)

    Column {
      id: choiceBody
      anchors.centerIn: parent
      spacing: Style.space(10)

      // The same square a mark fills, so More's name lines up with theirs.
      Item {
        visible: !!choice.entry.more
        anchors.horizontalCenter: parent.horizontalCenter
        width: Style.font.display * 1.6
        height: width
        scale: choice.hasCursor ? 1.08 : 1.0
        Behavior on scale { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutQuad } }

        Text {
          anchors.centerIn: parent
          text: "󰇘"
          textFormat: Text.PlainText
          color: choice.hasCursor ? Commons.Color.accent : root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.display * 1.6
        }
      }

      ProviderIcon {
        visible: !choice.entry.more
        anchors.horizontalCenter: parent.horizontalCenter
        provider: choice.entry
        size: Style.font.display * 1.6
        scale: choice.hasCursor ? 1.08 : 1.0
        Behavior on scale { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutQuad } }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.PlainText
        text: choice.entry.providerName || ""
        color: choice.hasCursor ? Commons.Color.accent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: choice.available ? Qt.PointingHandCursor : Qt.ArrowCursor
      onEntered: root.pointAt("choice", choice.entry.providerId)
      onClicked: root.chooseAddProvider(choice.entry.providerId)
    }
  }

  component AddView: Column {
    id: add
    spacing: Style.space(14)
    // The panel's key catcher can't see inside this component, so it asks here.
    readonly property bool inputFocused: pasteField.activeFocus || addNameField.activeFocus

    PanelSeparator { foreground: root.foreground }

    // Pick, in three blocks: a subscription, a model provider, or a model of
    // your own. Each agent is a large mark over its name, four across.
    Column {
      visible: root.picking
      width: parent.width
      spacing: Style.space(14)

      Repeater {
        model: root.picking ? [
          { group: "subscription", label: Commons.I18n.t("agents.blockSubscriptions") },
          { group: "provider", label: Commons.I18n.t("agents.blockProviders") }
        ].filter(function(b) { return root.addGroup(b.group).length > 0 }) : []

        Column {
          id: block
          required property var modelData
          required property int index
          width: parent.width
          spacing: Style.space(10)

          // A line between blocks; the first sits under the hero's own.
          PanelSeparator {
            visible: block.index > 0
            foreground: root.foreground
          }

          PanelSectionHeader {
            text: block.modelData.label
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Grid {
            id: choiceRow
            width: parent.width
            columns: root.addColumns
            spacing: Style.space(10)

            Repeater {
              model: root.addGroup(block.modelData.group)

              AddChoice {
                required property var modelData
                entry: modelData
                width: (choiceRow.width - choiceRow.spacing * (root.addColumns - 1)) / root.addColumns
              }
            }
          }
        }
      }

      // A model from a paired machine, or shared by one to pair with, in a
      // block of its own above this machine's.
      Column {
        visible: root.networkOfferCount > 0
        width: parent.width
        spacing: Style.space(10)

        PanelSeparator { foreground: root.foreground }

        PanelSectionHeader {
          text: Commons.I18n.t("agents.blockNetworkModel")
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        Repeater {
          model: root.ownModelOffers.slice(0, root.networkOfferCount)
          delegate: ownModelRow
        }
      }

      Column {
        visible: root.ownModelOffers.length > root.networkOfferCount
        width: parent.width
        spacing: Style.space(10)

        PanelSeparator { foreground: root.foreground }

        PanelSectionHeader {
          text: Commons.I18n.t("agents.blockOwnModel")
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        Repeater {
          model: root.ownModelOffers.slice(root.networkOfferCount)
          delegate: ownModelRow
        }
      }

      // One offered model; its place among all the offers, network ones
      // first, is what the keys and choosing go by.
      Component {
        id: ownModelRow

        Item {
          id: ownModel
          required property var modelData
          required property int index
          readonly property int offerIndex: index + (modelData.host !== "" ? 0 : root.networkOfferCount)
          readonly property bool hasCursor: root.hasKey("ownModel", offerIndex)
          // Too big for the memory free now: dimmed, saying so, and not chosen.
          readonly property var shortfall: modelData.shortfall || null
          readonly property bool recommended: root.offerRecommended(modelData, root.localModelOfferCount)
          readonly property var pairingState: modelData.pair && modelData.target === root.pairingLocal ? root.pairingStatus : null
          readonly property var offerMeterState: modelData.pair ? null : root.offerMeter(modelData)
          readonly property bool downloading: !!offerMeterState && offerMeterState.downloading === true
          width: parent.width
          implicitHeight: ownModelText.implicitHeight + Style.space(16)
          onHasCursorChanged: if (hasCursor) root.revealItem(ownModel)

          CursorSurface {
            anchors.fill: parent
            hasCursor: ownModel.hasCursor || ownModelMouse.containsMouse
            foreground: root.foreground
          }

          // The maker's mark.
          ProviderIcon {
            opacity: ownModel.shortfall ? 0.5 : 1
            id: ownModelMark
            anchors.left: parent.left
            anchors.leftMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            provider: ({ providerId: String(ownModel.modelData.vendor || "local") })
            size: Style.font.display
          }

          Column {
            id: ownModelText
            anchors.left: ownModelMark.right
            anchors.leftMargin: Style.space(12)
            anchors.right: parent.right
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(4)

            Item {
              id: ownModelHeader
              width: parent.width
              implicitHeight: Math.max(ownModelName.implicitHeight, ownModelRecommended.visible ? ownModelRecommended.implicitHeight : 0)

              Text {
                id: ownModelName
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: ownModelRecommended.visible
                  ? Math.max(0, Math.min(implicitWidth, parent.width - ownModelRecommended.implicitWidth - Style.space(8)))
                  : parent.width
                text: ownModel.modelData.name
                textFormat: Text.PlainText
                color: ownModel.shortfall ? root.dim : ownModel.hasCursor ? Commons.Color.accent : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                font.bold: true
                elide: Text.ElideRight
              }

              Rectangle {
                id: ownModelRecommended
                visible: ownModel.recommended
                opacity: ownModel.shortfall ? 0.5 : 1
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: ownModelRecommendedLabel.implicitWidth + Style.space(12)
                implicitHeight: ownModelRecommendedLabel.implicitHeight + Style.space(4)
                radius: Style.cornerRadius
                color: root.alpha(Commons.Color.accent, 0.14)
                border.width: Style.spacing.hairline
                border.color: root.alpha(Commons.Color.accent, 0.35)

                Text {
                  id: ownModelRecommendedLabel
                  anchors.centerIn: parent
                  text: Commons.I18n.t("localModels.recommended")
                  textFormat: Text.PlainText
                  color: Commons.Color.accent
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }
              }
            }

            // A paired machine's model says whose it is before its facts; a
            // cabled Spark, what setting it up does; one too big for the
            // memory free now, in red, why it can't start; one being paired
            // with, that it's pairing or why pairing failed. While downloading,
            // the progress bar takes this line's place.
            Text {
              visible: !ownModel.downloading
              width: parent.width
              text: ownModel.pairingState ? ownModel.pairingState.text
                : ownModel.shortfall ? root.memoryShortText(ownModel.shortfall)
                : ownModel.modelData.link ? Commons.I18n.t("localModels.linkSetUp")
                : [ownModel.modelData.host, root.ownModelFacts(ownModel.modelData.facts)].filter(function(part) { return part !== "" }).join(" · ")
              textFormat: Text.PlainText
              color: ownModel.pairingState ? (ownModel.pairingState.failed ? root.urgent : root.foreground)
                : ownModel.shortfall ? root.urgent : root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              wrapMode: ownModel.pairingState && ownModel.pairingState.failed ? Text.Wrap : Text.NoWrap
              elide: ownModel.pairingState && ownModel.pairingState.failed ? Text.ElideNone : Text.ElideRight
            }

            // The setup or start begun here: installing, downloading, then
            // loading, as its line will show it.
            LocalMeterRow {
              meter: ownModel.offerMeterState
              visible: !!meter
              width: parent.width
              topPadding: ownModel.downloading ? Style.space(2) : Style.space(6)
            }
          }

          MouseArea {
            id: ownModelMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: ownModel.shortfall ? Qt.ArrowCursor : Qt.PointingHandCursor
            onEntered: root.pointAt("ownModel", ownModel.offerIndex)
            onClicked: root.chooseOwnModel(ownModel.offerIndex)
          }
        }
      }
    }

    // More: the providers behind the More tile, each to the key step, then
    // OpenCode's own sign-in for the rest.
    Column {
      visible: root.addStage === "more"
      width: parent.width
      spacing: Style.space(4)

      PanelSectionHeader {
        text: root.addMore === "moreSubscriptions" ? Commons.I18n.t("agents.blockSubscriptions") : Commons.I18n.t("agents.blockProviders")
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      Repeater {
        model: root.addStage === "more" ? root.moreChoices : []

        Item {
          id: moreRow
          required property var modelData
          readonly property bool hasCursor: root.hasKey("choice", modelData.providerId)
          width: parent.width
          implicitHeight: Style.space(36)
          onHasCursorChanged: if (hasCursor) root.revealItem(moreRow)

          CursorSurface {
            anchors.fill: parent
            hasCursor: moreRow.hasCursor || moreMouse.containsMouse
            foreground: root.foreground
          }

          ProviderIcon {
            id: moreMark
            visible: !moreRow.modelData.opencode
            anchors.left: parent.left
            anchors.leftMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            provider: moreRow.modelData
          }

          Text {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(8) + moreMark.width + Style.space(10)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: moreRow.modelData.providerName
            textFormat: Text.PlainText
            color: moreRow.hasCursor ? Commons.Color.accent : root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            font.bold: !moreRow.modelData.opencode
            elide: Text.ElideRight
          }

          MouseArea {
            id: moreMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.pointAt("choice", moreRow.modelData.providerId)
            onClicked: root.chooseAddProvider(moreRow.modelData.providerId)
          }
        }
      }
    }

    // Name: a second account needs telling apart from the first.
    Column {
      visible: root.addStage === "name"
      width: parent.width
      spacing: Style.space(10)

      Text {
        width: parent.width
        text: Commons.I18n.t("agents.nameAccount")
        textFormat: Text.PlainText
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }

      TextField {
        id: addNameField
        width: parent.width
        rightPadding: addNameSubmit.width + addNameSubmit.inset * 2
        placeholderText: Commons.I18n.t("agents.placeholderWork")
        foreground: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        function claimFocus() { if (visible) { text = ""; forceActiveFocus() } }
        function submit() { root.startAdd(text.trim()) }
        onVisibleChanged: claimFocus()
        Component.onCompleted: claimFocus()
        // Enter stops here, or the panel would press its cursor too.
        Keys.onReturnPressed: function(event) { submit(); event.accepted = true }
        Keys.onEnterPressed: function(event) { submit(); event.accepted = true }
        Keys.onEscapePressed: function(event) { root.cancelAdd(); event.accepted = true }

        FieldConfirm {
          id: addNameSubmit
          onClicked: addNameField.submit()
        }
      }
    }

    // Setting up a subscription: the CLI installing, in the same row a model
    // downloads in, then logging in through the browser.
    Column {
      visible: root.addStage === "running"
      width: parent.width
      spacing: Style.space(12)

      Text {
        visible: root.addStage === "running" && root.addPhase === ""
        width: parent.width
        textFormat: Text.PlainText
        text: root.addStatus
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        wrapMode: Text.WordWrap
      }

      Item {
        visible: root.addStage === "running" && root.addPhase === "get"
        width: parent.width
        implicitHeight: Math.max(installTitle.implicitHeight, installRate.implicitHeight)

        Text {
          id: installTitle
          width: parent.width * root.labelColumnRatio
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: root.cliInstallTitle(root.addInstallStage)
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          elide: Text.ElideRight
        }

        Meter {
          anchors.left: installTitle.right
          anchors.right: installRate.text !== "" ? installRate.left : parent.right
          anchors.rightMargin: installRate.text !== "" ? Style.space(20) : 0
          anchors.verticalCenter: parent.verticalCenter
          value: root.addFetched ? 1 : root.addInstallFill
        }

        Text {
          id: installRate
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          horizontalAlignment: Text.AlignRight
          text: root.addFetched ? "" : root.downloadRate(root.addRateBytes)
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
        }
      }

      Column {
        visible: root.addStage === "running" && root.addPhase === "signin"
        width: parent.width
        spacing: Style.space(10)

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: root.addKeyEntry
            ? (root.addNeedsPaste ? Commons.I18n.t("agents.enterApiKey") : Commons.I18n.t("agents.checkingKey"))
            : (root.addCheckingCode ? Commons.I18n.t("agents.checkingCode") : Commons.I18n.t("agents.loginBrowser"))
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          font.bold: true
          wrapMode: Text.WordWrap
        }

        // Only what the plain line doesn't say: which window to use when it's
        // a private one.
        Text {
          visible: root.addPrivate && !root.addCheckingCode
          width: parent.width
          textFormat: Text.PlainText
          text: root.addStatus
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
        }

        Column {
          visible: root.addCode !== ""
          width: parent.width
          spacing: Style.space(4)

          Text {
            text: Commons.I18n.t("agents.confirmCode")
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          Text {
            textFormat: Text.PlainText
            text: root.addCode
            color: Commons.Color.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.display
            font.bold: true
            font.letterSpacing: 2
          }
        }

        Column {
          visible: root.addNeedsPaste
          width: parent.width
          spacing: Style.space(6)

          Text {
            width: parent.width
            text: root.addPasteHint || Commons.I18n.t("agents.pasteCode")
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          TextField {
            id: pasteField
            width: parent.width
            rightPadding: pasteSubmit.width + pasteSubmit.inset * 2
            placeholderText: root.addKeyEntry ? Commons.I18n.t("agents.placeholderApiKey") : Commons.I18n.t("agents.placeholderCode")
            password: true
            foreground: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            // Enter stops here, or the panel would press its cursor too.
            function submit() { root.submitPaste(text); text = "" }
            Keys.onReturnPressed: function(event) { submit(); event.accepted = true }
            Keys.onEnterPressed: function(event) { submit(); event.accepted = true }
            function syncPasteFocus() {
              root.pasteFieldItem = visible ? pasteField : null
              if (visible) forceActiveFocus()
            }
            onVisibleChanged: syncPasteFocus()
            Component.onCompleted: if (visible) syncPasteFocus()
            Connections {
              target: root
              function onAddStageChanged() { if (root.addStage !== "running") pasteField.text = "" }
              function onAddNeedsPasteChanged() { if (!root.addNeedsPaste) pasteField.text = "" }
            }
            Component.onDestruction: if (root.pasteFieldItem === pasteField) root.pasteFieldItem = null
            Keys.onEscapePressed: function(event) { root.cancelAdd(); event.accepted = true }

            FieldConfirm {
              id: pasteSubmit
              enabled: pasteField.text.trim() !== ""
              onClicked: pasteField.submit()
            }
          }
        }

        TextLink {
          visible: root.pasteLinkShown
          picked: root.hasKey("pasteCode")
          onHovered: root.hoverAt("pasteCode")
          text: Commons.I18n.t("agents.pasteCodeLink")
          onClicked: root.openPasteField()
        }

        TextLink {
          visible: root.addUrl !== "" && !root.addCheckingCode
          picked: root.hasKey("reopenSignIn")
          onHovered: root.hoverAt("reopenSignIn")
          text: Commons.I18n.t("agents.reopenSignIn")
          onClicked: root.reopenSignIn()
        }
      }
    }

    // Failed.
    Text {
      visible: root.addStage === "error"
      width: parent.width
      textFormat: Text.PlainText
      text: root.addResult
      color: root.addStage === "error" ? root.urgent : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WordWrap
    }
  }

  // One line: a subscription account, a pay-as-you-go provider, or a running
  // local model. Its mark, name, and plan, its buttons, then its limits; a
  // prepaid provider shows its balance instead.
  component ProviderSection: Column {
    id: section
    property var provider: null
    property int providerIndex: -1
    // An account's line: its account, renamed in place by clicking its name.
    readonly property var account: provider ? (provider.account || null) : null
    // A local model's line: where it runs and what it is, and, on this
    // machine, how it is now and what it's doing.
    readonly property var local: provider ? (provider.localModel || null) : null
    readonly property var localState: local ? root.localModelState(local) : null
    readonly property var localActions: root.localLineActions(provider)
    // Stopped, it steps back, so the one running stands out.
    readonly property bool resting: !!localState && ["active", "activating", "installing"].indexOf(localState.unit) < 0
    // An update has one bar of its own from the press to the end, through
    // the reload of a model that ran, and never runs back. The press counts
    // until the engine says it's updating, which takes a moment; one that
    // never does (the command failed) lets the bar go after 20 seconds.
    property bool updateAsked: false
    readonly property bool updating: !!localState && ["installing", "removing"].indexOf(localState.unit) < 0 && (localState.updating === true || updateAsked)
    property double updateStartedMs: 0
    property real updateFill: 0
    readonly property real updateTarget: updating ? root.updateProgress(localState, updateStartedMs, root.nowMs) : 0
    onUpdateTargetChanged: updateFill = Math.max(updateFill, updateTarget)
    function askUpdate() {
      updateAsked = true
      askTimer.restart()
    }
    Timer {
      id: askTimer
      interval: 20000
      onTriggered: section.updateAsked = false
    }
    onLocalStateChanged: if (updateAsked && !!localState && localState.updating === true) {
      updateAsked = false
      askTimer.stop()
    }
    onUpdatingChanged: if (updating) {
      updateStartedMs = Date.now()
      updateFill = 0
    }
    Component.onCompleted: if (updating) updateStartedMs = Date.now()
    readonly property var localMeter: {
      if (!updating) return root.localMeter(localState, false)
      var progress = localState.update_progress
      return { title: Commons.I18n.t("localModels.updating"), value: updateFill,
               rate: progress && progress.phase === "downloading" ? root.downloadRate(Number(progress.rate_bytes_s) || 0) : "" }
    }
    property bool editingName: false
    property string renamedTo: ""
    readonly property string accountLabel: renamedTo !== "" ? renamedTo : account ? String(account.label || account.id || "") : ""
    readonly property string accountName: provider ? String((provider.account && provider.account.email) || provider.accountName || "") : ""
    onAccountChanged: renamedTo = ""
    onEditingNameChanged: root.renaming = editingName

    function startRename() {
      root.focusKeys()
      editingName = true
      nameField.text = accountLabel
      nameField.forceActiveFocus()
      nameField.selectAll()
    }

    function finishRename(save) {
      if (!editingName) return
      var value = nameField.text.trim()
      editingName = false
      if (nameField.activeFocus) root.focusKeys()
      if (save && value !== "" && value !== accountLabel) {
        renamedTo = value
        root.renameAccount(provider, account, value)
      }
    }
    readonly property var windows: root.displayWindows(provider)
    // A note on numbers that aren't current sits where the first limit's time
    // left would, when that limit has none to show; else beside the name.
    readonly property bool noteInRow: windows.length > 0 && root.resetMsFor(windows[0]) <= 0
    readonly property var balance: provider ? (provider.balance || null) : null
    readonly property var spend: provider ? (provider.spend || null) : null
    spacing: Style.space(16)
    readonly property bool dragged: root.dragIndex === providerIndex
    // The pointer or the keyboard, whichever moved last, is on this agent.
    readonly property bool engaged: root.pointerActive ? sectionHover.hovered : root.providerIndexOfKey() === providerIndex
    readonly property bool makesOpen: root.makesOpenIndex === providerIndex
    onEngagedChanged: {
      if (!engaged && makesOpen) root.makesOpenIndex = -1
      // Once the change settles: moving the cursor while keyTarget is being
      // worked out is a binding loop, which can leave Delete with no line.
      if (engaged) Qt.callLater(root.pointerOnLine, providerIndex)
    }
    HoverHandler { id: sectionHover }
    z: dragged ? 2 : 0
    opacity: dragged ? 0.9 : 1
    transform: Translate {
      y: Reorder.rowShift(section.providerIndex, root.dragIndex, root.dragTarget,
                          root.dragOffset, root.rowPitches[root.dragIndex] || 0)
      Behavior on y {
        enabled: root.dragIndex >= 0 && !section.dragged
        NumberAnimation {
          duration: Style.duration(150)
          easing.type: Easing.Bezier
          easing.bezierCurve: Style.easeOut
        }
      }
    }

    PanelSeparator { foreground: root.foreground }

    Item {
      id: sectionHead
      width: parent.width
      // Where the line's text has to stop: before its buttons.
      readonly property real textEnd: sectionActions.x - Style.space(8)
      implicitHeight: Math.max(sectionMark.height, sectionName.implicitHeight)
      // Lit for the keyboard, and as the drop spot while an agent is dragged.
      readonly property bool lit: root.dragProviderId !== "" ? root.dragTarget === section.providerIndex : root.hasKey("provider", section.providerIndex)
      onLitChanged: if (lit && root.dragProviderId === "") root.revealItem(sectionHead)

      // Only the mark is lit: it's the handle the agent moves by.
      CursorSurface {
        anchors.fill: sectionMark
        anchors.margins: -Style.space(5)
        z: -1
        hasCursor: sectionHead.lit
        foreground: root.foreground
      }

      ProviderIcon {
        id: sectionMark
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        provider: section.provider
        opacity: section.resting ? 0.45 : 1

        // The mark is the handle for dragging the agent up or down the page.
        MouseArea {
          anchors.fill: parent
          anchors.margins: -Style.space(4)
          hoverEnabled: true
          preventStealing: true
          cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
          onPressed: function(mouse) {
            root.beginProviderDrag(section.providerIndex, mapToItem(root.column, mouse.x, mouse.y).y)
          }
          onPositionChanged: function(mouse) {
            if (pressed) root.dragProviderOver(mapToItem(root.column, mouse.x, mouse.y).y)
          }
          onReleased: root.dropProvider()
          onCanceled: root.settleProviderDrag(true)
        }
      }

      Text {
        id: sectionName
        anchors.left: sectionMark.right
        anchors.leftMargin: Style.space(10)
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: section.provider ? section.provider.providerName : ""
        width: Math.max(0, Math.min(implicitWidth, sectionHead.textEnd - x))
        elide: Text.ElideRight
        color: root.foreground
        opacity: section.resting ? 0.45 : 1
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }

      // An account's name reads like its plan, before it: Claude Work · Max 20x.
      Text {
        id: sectionAccount
        anchors.left: sectionName.right
        anchors.leftMargin: Style.space(8)
        anchors.baseline: sectionName.baseline
        visible: !!section.account && !section.editingName
        width: Math.max(0, Math.min(implicitWidth, sectionHead.textEnd - x))
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: section.accountLabel
        color: sectionHead.lit ? Commons.Color.accent : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.underline: accountNameMouse.containsMouse

        MouseArea {
          id: accountNameMouse
          anchors.fill: parent
          enabled: !!section.account
          hoverEnabled: true
          cursorShape: Qt.IBeamCursor
          onClicked: section.startRename()
        }

        PanelToolTip {
          visible: accountNameMouse.containsMouse && !!section.account && section.accountName !== ""
          text: section.accountName
        }
      }

      TextField {
        id: nameField
        visible: section.editingName
        anchors.left: sectionName.right
        anchors.leftMargin: Style.space(8)
        anchors.right: sectionActions.left
        anchors.rightMargin: Style.space(8)
        anchors.verticalCenter: sectionName.verticalCenter
        rightPadding: renameSave.width + renameSave.inset * 2
        foreground: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        horizontalPadding: Style.space(4)
        verticalPadding: Style.space(1)
        // Enter stops here, or the panel would press its cursor too.
        Keys.onReturnPressed: function(event) { section.finishRename(true); event.accepted = true }
        Keys.onEnterPressed: function(event) { section.finishRename(true); event.accepted = true }
        onActiveFocusChanged: if (!activeFocus) section.finishRename(false)
        Keys.onEscapePressed: function(event) {
          section.finishRename(false)
          event.accepted = true
        }

        FieldConfirm {
          id: renameSave
          inset: Style.space(2)
          size: Math.max(1, Math.round(nameField.height - Style.space(4)))
          fontSize: Style.font.iconSmall
          enabled: nameField.text.trim() !== ""
          onClicked: section.finishRename(true)
        }
      }

      // The plan reads as part of the name: Claude Max 20x.
      Text {
        id: sectionPlan
        anchors.left: sectionAccount.visible ? sectionAccount.right : sectionName.right
        anchors.leftMargin: Style.space(8)
        anchors.baseline: sectionName.baseline
        visible: !section.editingName && text !== ""
        width: Math.max(0, Math.min(implicitWidth, sectionHead.textEnd - x))
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: {
          var plan = root.planLabel(section.provider)
          return plan !== "" && section.account ? "· " + plan : plan
        }
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption

        HoverHandler { id: planHover }

        PanelToolTip {
          visible: planHover.hovered && sectionPlan.visible && section.accountName !== ""
          text: section.accountName
        }
      }

      UsageNote {
        anchors.left: sectionPlan.visible ? sectionPlan.right : sectionName.right
        anchors.leftMargin: Style.space(8)
        anchors.verticalCenter: sectionName.verticalCenter
        visible: !section.editingName && !section.noteInRow && message !== ""
        record: section.provider
      }

      // The line's buttons, from the right: its terminal, its desktop app,
      // its makes, its star, and remove. Hidden ones take no room, but an unlit
      // star keeps its place so the others don't move.
      Row {
        id: sectionActions
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        layoutDirection: Qt.RightToLeft
        spacing: Style.space(6)

        // Opens the coding agent made for this subscription: Codex for OpenAI,
        // Claude Code for Anthropic. The default's line shows its star here
        // instead until it's engaged.
        PanelActionButton {
          outlined: true
          id: sectionLaunch
          anchors.verticalCenter: parent.verticalCenter
          visible: root.launches(section.provider) && (section.engaged || !sectionStar.on)
          iconText: "󰞷"
          tooltipText: Commons.I18n.t("agents.launchHarness").arg(root.lineName(section.provider))
          foreground: root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.hasKey("providerLaunch", section.providerIndex)
          onHovered: function(isHovered) { if (isHovered) root.hoverAt("providerLaunch", section.providerIndex) }
          onClicked: root.runLine(section.provider)
        }

          // The subscription's desktop app, when it's installed.
        PanelActionButton {
          outlined: true
          id: sectionDesktop
          readonly property var entry: root.desktopFor(section.provider)
          anchors.verticalCenter: parent.verticalCenter
          visible: !!entry && section.engaged
          iconText: "󰍹"
          tooltipText: entry ? Commons.I18n.t("agents.openDesktopApp").arg(entry.name) : ""
          foreground: root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.hasKey("providerDesktop", section.providerIndex)
          onHovered: function(isHovered) { if (isHovered) root.hoverAt("providerDesktop", section.providerIndex) }
          onClicked: root.launchDesktop(section.provider)
        }

          // Making something with this line's agent, as the starter tiles do
          // with the default: one sparkles icon on the line in use, which opens
          // into the four.
        PanelActionButton {
          outlined: true
          id: sectionSparkles
          anchors.verticalCenter: parent.verticalCenter
          visible: root.launches(section.provider) && section.engaged && !section.makesOpen
          iconText: "󰙴"
          tooltipText: Commons.I18n.t("agents.makeSomethingWith").arg(root.lineName(section.provider))
          foreground: root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.hasKey("makeToggle", section.providerIndex)
          onHovered: function(isHovered) { if (isHovered) root.hoverAt("makeToggle", section.providerIndex) }
          onClicked: root.openMakes(section.providerIndex)
        }

        Row {
          id: sectionMakes
          anchors.verticalCenter: parent.verticalCenter
          visible: section.makesOpen
          spacing: Style.space(2)

          Repeater {
            model: root.starterPrompts

            PanelActionButton {

              outlined: true
              required property var modelData
              iconText: modelData.glyph
              tooltipText: Commons.I18n.t("agents.makeWith").arg(modelData.label.toLowerCase()).arg(root.lineName(section.provider))
              foreground: root.foreground
              fontFamily: root.fontFamily
              hasCursor: root.hasKey("make:" + modelData.kind, section.providerIndex)
              onHovered: function(isHovered) { if (isHovered) root.hoverAt("make:" + modelData.kind, section.providerIndex) }
              onClicked: root.runLine(section.provider, modelData.kind)
            }
          }
        }

        // A model on this machine starts and stops here: play, or pause.
        // Greyed out, not disabled, where it won't fit, so the reason still
        // shows on hover.
        PanelActionButton {
          outlined: true
          id: localToggle
          anchors.verticalCenter: parent.verticalCenter
          visible: section.localActions.indexOf("toggle") >= 0
          readonly property bool stops: !!section.localState && ["active", "activating"].indexOf(section.localState.unit) >= 0
          readonly property bool blocked: root.localStartBlocked(section.localState)
          iconText: stops ? "󰏤" : "󰐊"
          tooltipText: blocked ? Commons.I18n.t("localModels.notEnoughMemory")
            : stops ? Commons.I18n.t("localModels.stop") : Commons.I18n.t("localModels.start")
          foreground: blocked ? root.dim : root.foreground
          opacity: blocked ? 0.5 : 1
          fontFamily: root.fontFamily
          hasCursor: root.hasKey("localToggle", section.providerIndex)
          onHovered: function(isHovered) { if (isHovered) root.hoverAt("localToggle", section.providerIndex) }
          onClicked: root.runLocalAction(section.local, "toggle")
        }

        // Shares the running model with the tailnet, or stops sharing it: the
        // Tailscale mark, dim while private, and in the icons' color while
        // shared, when its tooltip counts the machines using it.
        PanelActionButton {
          outlined: true
          id: localShare
          anchors.verticalCenter: parent.verticalCenter
          visible: section.localActions.indexOf("share") >= 0
          readonly property bool shared: !!section.localState && section.localState.shared === true
          readonly property int users: shared && root.localModelsService ? (root.localModelsService.shareClients[section.localState.recipe] || 0) : 0
          tooltipText: users > 0 ? Commons.I18n.tn("localModels.networkSharedUsers", users).arg(Commons.I18n.formatNumber(users))
            : shared ? Commons.I18n.t("localModels.networkStopSharing") : Commons.I18n.t("localModels.networkShare")
          foreground: root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.hasKey("localShare", section.providerIndex)
          onHovered: function(isHovered) { if (isHovered) root.hoverAt("localShare", section.providerIndex) }
          onClicked: root.runLocalAction(section.local, "share")

          Tailscale.TailscaleIcon {
            anchors.centerIn: parent
            // The mark fills its box where a font glyph leaves padding around
            // its ink, so it's drawn smaller to sit no larger than the pause.
            iconSize: Math.round(Style.font.icon * 0.7)
            color: localShare.shared || localShare._hot ? root.foreground : root.dim
          }
        }

        // The catalog has a newer runtime, weights or settings for this model
        // than it was set up with. Updating restarts it, so it's offered,
        // never done on its own; while it runs the button stays, dimmed.
        PanelActionButton {
          outlined: true
          id: localUpdate
          anchors.verticalCenter: parent.verticalCenter
          visible: section.updating || section.localActions.indexOf("update") >= 0
          // The arrows the bar's system update shows, drawn to the play's
          // size: this glyph fills more of its box than the play and pause do.
          iconText: ""
          fontSize: Math.round(Style.font.icon * 0.8)
          tooltipText: section.updating ? Commons.I18n.t("localModels.updating") : root.updateTip(section.localState)
          foreground: section.updating ? root.dim : root.foreground
          opacity: section.updating ? 0.5 : 1
          fontFamily: root.fontFamily
          hasCursor: root.hasKey("localUpdate", section.providerIndex)
          onHovered: function(isHovered) { if (isHovered) root.hoverAt("localUpdate", section.providerIndex) }
          onClicked: if (!section.updating) root.runLocalAction(section.local, "update")
        }

        // The default's star is filled: the default agent, and with several
        // accounts the one in use. Another line's makes it the default.
        PanelActionButton {
          outlined: true
          id: sectionStar
          anchors.verticalCenter: parent.verticalCenter
          visible: root.defaultIdFor(section.provider) !== "" && !(on && section.engaged)
          readonly property bool on: root.starred(section.provider, section.account)
          // The default's star shows only at rest, in place of its buttons;
          // another shows when it's engaged, and keeps its place either way so
          // the terminal button doesn't move.
          readonly property bool shown: on || section.engaged
          opacity: shown ? 1 : 0
          enabled: shown
          iconText: on ? "󰓎" : "󰓒"
          tooltipText: on
            ? Commons.I18n.t("agents.isDefault")
            : Commons.I18n.t("agents.makeDefault").arg(root.lineName(section.provider))
          foreground: on ? Commons.Color.accent : root.foreground
          fontFamily: root.fontFamily
          hasCursor: root.hasKey("providerStar", section.providerIndex)
          onHovered: function(isHovered) { if (isHovered) root.hoverAt("providerStar", section.providerIndex) }
          onClicked: root.makeDefault(section.provider, section.account)
        }

        // Mouse-only: opens the same confirmation as Delete / x.
        PanelActionButton {
          id: sectionRemove
          outlined: true
          anchors.verticalCenter: parent.verticalCenter
          visible: section.engaged && !section.makesOpen && root.removable(section.provider)
          iconText: "󰅙"
          tooltipText: section.local && section.local.host !== ""
            ? Commons.I18n.t("agents.unlink")
            : Commons.I18n.t("common.delete")
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: root.deleteTarget = section.provider
        }
      }
    }

    // The machine a local model runs on when that isn't this one, then its
    // memory, speed, and context. While downloading, the progress bar takes
    // this line's place.
    Text {
      visible: !!section.local && text !== "" && !(section.localMeter && section.localMeter.downloading === true)
      width: parent.width
      textFormat: Text.PlainText
      text: section.local ? [section.local.host, root.ownModelFacts(section.local)].filter(function(part) { return part !== "" }).join(" · ") : ""
      color: root.dim
      opacity: section.resting ? 0.6 : 1
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      elide: Text.ElideRight
    }

    // A model on this machine at work: its download, load, stop, update or
    // removal, against how long that took last time.
    LocalMeterRow {
      visible: !!section.localMeter && !section.localMeter.failed
      width: parent.width
      meter: section.localMeter
    }

    // Why a model on this machine stopped or its setup failed, which opens
    // its logs.
    TextLink {
      visible: !!section.localMeter && section.localMeter.logs === true
      width: Math.min(implicitWidth, parent.width)
      text: visible ? section.localMeter.title : ""
      idleColor: root.urgent
      hotColor: root.urgent
      wrapMode: Text.Wrap
      picked: root.hasKey("localLogs", section.providerIndex)
      onHovered: root.hoverAt("localLogs", section.providerIndex)
      tooltip: Commons.I18n.t("localModels.showLogsTip")
      onClicked: root.showLocalLogs(section.localState)
    }

    // A stopped model too big for the memory free now.
    Text {
      visible: !!section.localMeter && section.localMeter.failed === true && section.localMeter.logs !== true
      width: parent.width
      textFormat: Text.PlainText
      text: visible ? section.localMeter.title : ""
      color: Commons.Color.warning
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.Wrap
    }

    // Sharing that Tailscale refused, with the way to fix it.
    Text {
      readonly property string error: section.localState && section.localState.shared === true && root.localModelsService
        ? String(root.localModelsService.localModel.share_error || "") : ""
      visible: error !== ""
      width: parent.width
      textFormat: Text.PlainText
      text: error
      color: root.urgent
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.Wrap
    }

    // A sign-in to redo, for the line's account when it's one of several.
    TextLink {
      visible: root.needsSignIn(section.provider)
      picked: root.hasKey("providerSignin", section.providerIndex)
      onHovered: root.hoverAt("providerSignin", section.providerIndex)
      text: Commons.I18n.t("agents.signInRequired")
      idleColor: root.urgent
      tooltip: section.account
        ? Commons.I18n.t("agents.signInAgainAccount")
        : Commons.I18n.t("agents.signInAgainProvider").arg(section.provider ? section.provider.providerName : "")
      onClicked: root.signInAgain(section.provider, section.account)
    }


    Column {
      visible: section.windows.length > 0
      width: parent.width
      spacing: Style.space(12)

      Repeater {
        model: section.windows

        CompactLimit {
          required property var modelData
          required property int index
          width: section.width
          window: modelData
          note: index === 0 && section.noteInRow ? section.provider : null
          stale: !!section.provider && section.provider.limitsStale === true
          fetchedAt: section.provider ? Number(section.provider.limitsFetchedAt || 0) : 0
        }
      }

      Text {
        textFormat: Text.PlainText
        visible: text !== ""
        width: parent.width
        text: root.resetCreditsText(section.provider ? section.provider.resetCredits : null)
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    // The meter fills with what has been spent, the way a limit window fills
    // toward its cap.
    Item {
      visible: !!section.balance
      width: parent.width
      implicitHeight: balanceTitle.implicitHeight

      Text {
        id: balanceTitle
        textFormat: Text.PlainText
        width: parent.width * root.labelColumnRatio
        anchors.verticalCenter: parent.verticalCenter
        text: Commons.I18n.t("agents.balance")
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      // Without a funded figure there is nothing to fill toward, so no meter.
      Meter {
        visible: !!section.balance && section.balance.funded > 0
        anchors.left: balanceTitle.right
        anchors.right: balanceValue.left
        anchors.rightMargin: Style.space(20)
        anchors.verticalCenter: parent.verticalCenter
        value: visible ? 1 - section.balance.remaining / section.balance.funded : -1
        alarming: root.balanceAlarming(section.balance)
      }

      Text {
        id: balanceValue
        textFormat: Text.PlainText
        width: Math.max(root.valueColumnWidth, implicitWidth)
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        text: section.balance ? root.formatMoney(section.balance.remaining, section.balance.currency) : ""
        color: root.balanceAlarming(section.balance) ? root.urgent : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }
    }

    // Against a real monthly cap the spend is this month's meter; without
    // one, a bar for each of the last 30 days, scaled to the busiest, shows
    // where it went. A section with a balance shows that alone.
    Item {
      visible: !!section.spend && !section.balance
      width: parent.width
      implicitHeight: spendTitle.implicitHeight

      Text {
        id: spendTitle
        textFormat: Text.PlainText
        width: parent.width * root.labelColumnRatio
        anchors.verticalCenter: parent.verticalCenter
        text: section.spend && section.spend.cap > 0 ? Commons.I18n.t("agents.spendThisMonth") : Commons.I18n.t("agents.spendLast30Days")
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        elide: Text.ElideRight
      }

      Meter {
        visible: !!section.spend && section.spend.cap > 0
        anchors.left: spendTitle.right
        anchors.right: spendValue.left
        anchors.rightMargin: Style.space(20)
        anchors.verticalCenter: parent.verticalCenter
        value: visible ? section.spend.amount / section.spend.cap : -1
        alarming: root.spendAlarming(section.spend)
      }

      Item {
        id: spendDays
        visible: !!section.spend && section.spend.cap <= 0 && section.spend.days.length > 0
        anchors.left: spendTitle.right
        anchors.right: spendValue.left
        anchors.rightMargin: Style.space(20)
        // The bars stand on the title's baseline, as tall as its letters rise.
        anchors.bottom: spendTitle.baseline
        height: spendTitle.baselineOffset
        readonly property var days: section.spend ? section.spend.days : []
        readonly property real busiest: Math.max.apply(null, days.concat([0]))
        readonly property real gap: Style.space(2)
        readonly property real stub: Math.max(Style.space(2), Math.round(Style.spacing.controlHeight * 0.07))
        // The day under the pointer: its bar lights up, and the tooltip says
        // what it cost. A mirrored row counts from the other end.
        readonly property real hoverX: LayoutMirroring.enabled ? width - dayHover.point.position.x : dayHover.point.position.x
        readonly property int hoveredDay: dayHover.hovered && days.length > 0
          ? root.clamp(Math.floor(hoverX / width * days.length), 0, days.length - 1) : -1

        HoverHandler { id: dayHover }

        PanelToolTip {
          visible: spendDays.hoveredDay >= 0
          text: root.spendDayText(section.spend, section.provider ? section.provider.recentDays : [], spendDays.hoveredDay)
        }

        Row {
          anchors.fill: parent
          spacing: spendDays.gap

          Repeater {
            model: spendDays.days.length

            Rectangle {
              readonly property real cost: spendDays.days[index]
              width: (spendDays.width - spendDays.gap * (spendDays.days.length - 1)) / spendDays.days.length
              height: cost > 0 && spendDays.busiest > 0 ? Math.max(spendDays.stub, spendDays.height * cost / spendDays.busiest) : spendDays.stub
              anchors.bottom: parent ? parent.bottom : undefined
              radius: Math.min(width, height) / 2
              color: index === spendDays.hoveredDay ? Commons.Color.accent : cost > 0 ? root.foreground : root.track
            }
          }
        }
      }

      Text {
        id: spendValue
        textFormat: Text.PlainText
        width: Math.max(root.valueColumnWidth, implicitWidth)
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        text: root.spendValueText(section.spend)
        color: root.spendAlarming(section.spend) ? root.urgent : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }
    }

  }

  // A provider's mark, falling back to the bar glyph when it ships none.
  component ProviderIcon: Item {
    id: mark
    property var provider: null
    property var candidates: root.iconCandidatesForProvider(provider, root.surface)
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

  // A starter: its glyph and what it makes, on a soft tile that warms to the
  // accent on hover.
  component StarterTile: Rectangle {
    id: tile
    signal clicked()
    signal hovered()
    property string glyph: ""
    property string title: ""
    property bool hasCursor: false
    readonly property bool hot: hasCursor || tileMouse.containsMouse
    implicitHeight: tileBody.implicitHeight + Style.space(20)
    radius: Style.cornerRadius
    color: hot ? root.alpha(Commons.Color.accent, 0.14) : root.alpha(root.foreground, 0.05)
    onHasCursorChanged: if (hasCursor) root.revealItem(tile)

    Row {
      id: tileBody
      anchors.centerIn: parent
      spacing: Style.space(8)

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: tile.glyph
        color: Commons.Color.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: tile.title
        color: tile.hot ? Commons.Color.accent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }
    }

    MouseArea {
      id: tileMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: tile.hovered()
      onClicked: tile.clicked()
    }

    PanelToolTip {
      visible: tileMouse.containsMouse
      text: Commons.I18n.t("agents.startOnNew").arg(tile.title.toLowerCase())
    }
  }

  // A plain-text control: dim until hovered or picked, accent when it's the
  // current choice. Stands in for bordered buttons, which pile up here.
  // How a model's setup, start, stop, update or removal goes: what it's
  // doing, a meter, and a download's speed; or, failed, why.
  component LocalMeterRow: Item {
    id: meterRow
    property var meter: null
    property real topPadding: 0
    readonly property bool failed: !!meter && meter.failed === true
    // A failed step has no measure of its own, only its reason.
    readonly property bool barless: !meter || failed || meter.value < 0
    readonly property bool titled: !!meter && String(meter.title || "") !== ""
    readonly property bool hasRate: meterRate.text !== ""
    implicitHeight: Math.max(titled ? meterTitle.implicitHeight : 0, meterRate.implicitHeight, meterBar.implicitHeight) + topPadding

    Text {
      id: meterTitle
      visible: meterRow.titled
      width: meterRow.barless ? parent.width : parent.width * root.labelColumnRatio
      anchors.bottom: parent.bottom
      textFormat: Text.PlainText
      text: meterRow.meter ? meterRow.meter.title : ""
      color: meterRow.failed ? root.urgent : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: meterRow.failed ? Text.Wrap : Text.NoWrap
      elide: meterRow.failed ? Text.ElideNone : Text.ElideRight
    }

    Meter {
      id: meterBar
      visible: !meterRow.barless
      anchors.left: meterRow.titled ? meterTitle.right : parent.left
      anchors.right: meterRow.hasRate ? meterRate.left : parent.right
      anchors.rightMargin: meterRow.hasRate ? (meterRow.titled ? Style.space(20) : Style.space(10)) : 0
      anchors.verticalCenter: meterRow.titled ? meterTitle.verticalCenter : meterRate.verticalCenter
      value: meterRow.meter ? meterRow.meter.value : 0
    }

    Text {
      id: meterRate
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      textFormat: Text.PlainText
      horizontalAlignment: Text.AlignRight
      text: meterRow.meter && !meterRow.failed ? meterRow.meter.rate : ""
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: meterRow.titled ? Style.font.bodySmall : Style.font.caption
    }
  }

  component TextLink: Text {
    id: link
    signal clicked()
    signal hovered()
    property bool current: false
    property bool picked: false
    property string tooltip: ""
    property color idleColor: root.dim
    property color hotColor: root.foreground
    readonly property bool hot: linkMouse.containsMouse || picked
    onPickedChanged: if (picked) root.revealItem(link)
    textFormat: Text.PlainText
    color: current ? Commons.Color.accent : (hot ? hotColor : idleColor)
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.bold: current
    font.underline: hot && !current

    MouseArea {
      id: linkMouse
      anchors.fill: parent
      anchors.margins: -Style.space(4)
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: link.hovered()
      onClicked: link.clicked()
    }

    PanelToolTip {
      visible: link.tooltip !== "" && linkMouse.containsMouse
      text: link.tooltip
    }
  }

  // An account's name, email and plan, with ACTIVE or a Use link on the
  // right. Clicking the name edits it in place: Enter renames, Esc or
  // clicking away leaves it as it was.
  // A mark beside the name when the numbers aren't current, with why and
  // what to do on hover.
  component UsageNote: Text {
    id: noteMark
    property var record: null
    readonly property string message: root.usageNote(record)
    visible: message !== ""
    text: "󰋽"
    textFormat: Text.PlainText
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption

    HoverHandler { id: noteHover }

    PanelToolTip {
      visible: noteHover.hovered && noteMark.visible
      // Capped through implicitWidth, which the tooltip centers itself by.
      implicitWidth: Math.min(implicitContentWidth + leftPadding + rightPadding, Style.space(320))
      text: noteMark.message
    }
  }

  // One line per limit window: title, meter, percentage, and reset. A
  // model-scoped allowance on the same clock ("Fable" on Weekly) is a marker
  // on this row's meter, named in the row's tooltip.
  component CompactLimit: Item {
    id: compact
    property var window: null
    // The agent's note, shown in the time-left slot when there's none.
    property var note: null
    // The age of numbers kept past a failed check is shown only on hover.
    property bool stale: false
    property real fetchedAt: 0
    readonly property var scoped: window && window.scoped ? window.scoped : []
    readonly property bool alarming: window && window.percent >= 0.9
    readonly property real resetMs: root.resetMsFor(window)
    implicitHeight: Math.max(compactTitle.implicitHeight, compactValue.implicitHeight)

    HoverHandler { id: compactHover }

    PanelToolTip {
      visible: compactHover.hovered && !!compact.window
      text: {
        var lines = []
        if (compact.window) {
          var windowName = root.windowDisplayTitle(compact.window.title)
          var used = Commons.I18n.formatNumber(Math.round(compact.window.percent * 100))
          lines.push(compact.resetMs > 0
            ? Commons.I18n.t("agents.windowUsedResets").arg(windowName).arg(used).arg(root.formatDuration(compact.resetMs))
            : Commons.I18n.t("agents.windowUsed").arg(windowName).arg(used))
        }
        if (compact.stale)
          lines.push(compact.fetchedAt > 0 && root.nowMs - compact.fetchedAt > 60000
            ? Commons.I18n.t("agents.lastUpdatedAgo").arg(root.formatDuration(root.nowMs - compact.fetchedAt))
            : compact.fetchedAt > 0 ? Commons.I18n.t("agents.lastUpdatedJustNow") : Commons.I18n.t("agents.lastUpdatedUnknown"))
        for (var i = 0; i < compact.scoped.length; i++)
          lines.push(root.scopedAllowanceText(compact.scoped[i], compact.window ? compact.window.title : ""))
        return lines.join("\n")
      }
    }

    Text {
      id: compactTitle
      textFormat: Text.PlainText
      width: parent.width * root.labelColumnRatio
      anchors.verticalCenter: parent.verticalCenter
      text: compact.window ? root.windowDisplayTitle(compact.window.title) : ""
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }

    Meter {
      anchors.left: compactTitle.right
      anchors.right: compactValue.left
      anchors.rightMargin: Style.space(20)
      anchors.verticalCenter: parent.verticalCenter
      value: compact.window ? compact.window.percent : -1
      alarming: compact.alarming
      markers: compact.scoped
    }

    // Sized to the widest time left ("19h 40m"), so every meter ends in the
    // same place.
    TextMetrics {
      id: compactValueMetrics
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      text: "00h 00m"
    }

    // How long until the window resets. The meter says how full it is; the
    // exact percentage is in the row's tooltip.
    Text {
      id: compactValue
      width: Math.ceil(compactValueMetrics.advanceWidth)
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      horizontalAlignment: Text.AlignRight
      text: compact.resetMs > 0 ? root.formatDuration(compact.resetMs) : ""
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }

    UsageNote {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      visible: !!compact.note && compact.resetMs <= 0 && message !== ""
      record: compact.note
    }
  }

  // Rounded track showing the percentage of the allowance used.
  component Meter: Item {
    id: meter
    property real value: -1
    property bool alarming: false
    property real thickness: Math.max(Style.space(4), Math.round(Style.spacing.controlHeight * 0.14))

    // Other allowances on the same clock, drawn as ticks across the track.
    property var markers: []

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
      color: meter.alarming ? root.urgent : root.foreground

      Behavior on width {
        NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic }
      }
    }

    Repeater {
      model: meter.markers

      Rectangle {
        required property var modelData
        width: Math.max(2, Math.round(meter.thickness * 0.5))
        height: meter.thickness * 2.5
        radius: width / 2
        anchors.verticalCenter: meterTrack.verticalCenter
        // Explicit x doesn't mirror, so the tick measures from the end the
        // fill grows from.
        readonly property real along: root.clamp(meterTrack.width * root.clamp(Number(modelData.percent), 0, 1) - width / 2, 0, meterTrack.width - width)
        x: LayoutMirroring.enabled ? meterTrack.width - width - along : along
        color: meter.alarming ? root.urgent : root.foreground
      }
    }
  }

  // Confirm button seated inside the right edge of an inline TextField.
  component FieldConfirm: PanelActionButton {
    property real inset: Style.space(4)
    anchors.right: parent ? parent.right : undefined
    anchors.rightMargin: inset
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    iconText: "󰄬"
    tooltipText: Commons.I18n.t("common.confirm")
    foreground: root.foreground
    fontFamily: root.fontFamily
  }
}
