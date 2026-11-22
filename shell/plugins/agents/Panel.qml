import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../panels/elsewhen/Model.js" as Reorder

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
  readonly property bool shiftHeld: panel.loadedContent ? panel.loadedContent.shiftHeld : false

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
    var target = keyTarget
    if (!target || ["provider", "providerLaunch"].indexOf(target.kind) < 0) return
    deleteTarget = providers[target.index]
  }

  // Hides the agent from the panel; it comes back from settings.
  function confirmDelete() {
    var target = deleteTarget
    deleteTarget = null
    if (!target) return
    if (bar && bar.shell) {
      var next = JSON.parse(JSON.stringify(settings || {}))
      if (!next.providers) next.providers = {}
      next.providers[target.providerId] = Object.assign({}, next.providers[target.providerId] || {}, { enabled: false })
      bar.shell.updateEntryInline(moduleName, next)
    }
  }

  property bool cursorActive: false

  // Countdowns and "last updated" ages read this instead of Date.now() so the
  // panel keeps telling the truth while it sits open.
  property double nowMs: Date.now()

  // Every account of every provider that has more than one, in page order.
  // The keyboard picks one by its position; picking only looks, and Enter on
  // a picked account is what moves new sessions to it.
  readonly property var accountEntries: {
    var out = []
    for (var i = 0; i < providers.length; i++) {
      var list = providerAccounts(providers[i])
      if (list.length < 2) continue
      for (var j = 0; j < list.length; j++) out.push({ provider: providers[i], account: list[j] })
    }
    return out
  }
  readonly property var pickedEntry: keyTarget && ["account", "signin"].indexOf(keyTarget.kind) >= 0
    ? accountEntries[keyTarget.index] || null
    : null

  // The keyboard walks everything on the page that does something, in
  // reading order, one row at a time: the hero's buttons, then each agent's
  // header, its Sign-in required link or switchable accounts, and the starter
  // tiles, or the agents to add while picking one. Up and down change rows, left and right move along one.
  // Hovering moves the same cursor, so only one thing is lit.
  readonly property var keyRows: {
    var rows = []
    var hero = []
    if (addButtonShown) hero.push({ kind: "add", index: 0 })
    if (hero.length > 0) rows.push(hero)
    if (picking) {
      var choices = []
      for (var k = 0; k < addProviders.length; k++) choices.push({ kind: "choice", index: k })
      rows.push(choices)
    } else if (addStage === "running") {
      if (pasteLinkShown) rows.push([{ kind: "pasteCode", index: 0 }])
      if (addUrl !== "") rows.push([{ kind: "reopenSignIn", index: 0 }])
    } else if (addStage === "") {
      // Accounts count in the same order as accountEntries. Only what can be
      // done is a stop: one that isn't active offers Use, a lapsed sign-in
      // comes first, and the active account with nothing to fix is skipped.
      var entry = 0
      for (var p = 0; p < providers.length; p++) {
        // Every agent's line is a stop, so Ctrl+Up/Down can move it: its
        // terminal button when it has a harness of its own, else its mark.
        rows.push([{ kind: lineStop(p), index: p }])
        var accounts = providerAccounts(providers[p])
        if (accounts.length < 2) {
          if (needsSignIn(providers[p])) rows.push([{ kind: "providerSignin", index: p }])
          continue
        }
        for (var a = 0; a < accounts.length; a++, entry++) {
          var row = []
          if (needsSignIn(accounts[a])) row.push({ kind: "signin", index: entry })
          if (!accounts[a].active) row.push({ kind: "account", index: entry })
          if (row.length > 0) rows.push(row)
        }
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
  // A line's rightmost button, where the cursor lands on it: its terminal,
  // or the mark for a line with no button.
  function lineStop(p) {
    var provider = providers[p]
    if (!provider) return "provider"
    return harnessFor(provider) !== "" ? "providerLaunch" : "provider"
  }

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
      // Arriving on an account lands on Use, and on an agent's line on its
      // rightmost button.
      var row = keyRows[keyRow]
      var use = -1
      for (var c = 0; c < row.length; c++) if (row[c].kind === "account") use = c
      var line = ["provider", "providerLaunch"].indexOf(row[0].kind) >= 0
      keyColumn = use >= 0 ? use : line ? row.length - 1 : Math.min(keyColumn, row.length - 1)
    } else if (dx !== 0) {
      // A row can go while the cursor is on it, like the starters when the
      // last agent stops.
      keyRow = clamp(keyRow, 0, keyRows.length - 1)
      keyColumn = clamp(Math.min(keyColumn, keyRows[keyRow].length - 1) + dx, 0, keyRows[keyRow].length - 1)
    }
  }

  // The agent the cursor is in, by its position on the page.
  function providerIndexOfKey() {
    var target = keyTarget
    if (!target) return -1
    if (["provider", "providerSignin", "providerLaunch"].indexOf(target.kind) >= 0) return target.index
    if (["account", "signin"].indexOf(target.kind) < 0) return -1
    var entry = accountEntries[target.index]
    return entry ? providers.indexOf(entry.provider) : -1
  }

  // Ctrl+Up/Down carries the agent the cursor is in up or down the page, and
  // the cursor along with it.
  function reorderProvider(dy) {
    if (dragIndex >= 0) return
    var from = providerIndexOfKey()
    if (from < 0) return
    var to = clamp(from + dy, 0, providers.length - 1)
    if (to === from) return
    usage.moveProvider(providers[from].providerId, to)
    Qt.callLater(function() { pointAt(lineStop(to), to) })
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
    dragProviderId = providers[index].providerId
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
    if (moved) Qt.callLater(function() { pointAt(lineStop(to), to) })
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
  function providerAccounts(p) {
    return p && p.accounts && p.accounts.length > 0 ? p.accounts : []
  }

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

  readonly property var addProviders: [
    { providerId: "claude", providerName: "Claude" },
    { providerId: "codex", providerName: "Codex" },
    { providerId: "grok", providerName: "Grok" }
  ]

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
  property string addResult: ""
  // The CLI's own download, when it isn't installed yet: the first sign-in
  // installs it before the browser opens.
  property bool addDownloading: false
  property real addDoneBytes: 0
  property real addTotalBytes: 0
  property real addRateBytes: 0
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
    addPhase = "signin"
  }
  property bool addReauth: false
  // Signing in takes over the hero: the provider's mark and name, with what's
  // being set up below.
  readonly property bool setupShown: addStage === "running" && addProviderEntry !== null
  readonly property var addProviderEntry: {
    for (var i = 0; i < addProviders.length; i++)
      if (addProviders[i].providerId === addProvider) return addProviders[i]
    return null
  }
  // Claude only needs a code pasted back when its page shows one, so the
  // field waits behind a link until then.
  readonly property bool pasteLinkShown: addProvider === "claude" && !addNeedsPaste && !addDownloading
  // Whether the sign-in in progress opened a private window, so reopening its
  // page does too.
  property bool addPrivate: false

  function addProviderName(id) {
    for (var i = 0; i < addProviders.length; i++)
      if (addProviders[i].providerId === id) return addProviders[i].providerName
    return id
  }

  function addAccount() {
    if (addStage === "running") return
    addStage = "pick"
    addChecks = ({})
    if (!checkProcess.running) checkProcess.running = true
  }

  function chooseAddProvider(id) {
    var state = addChecks[id] || ""
    if (state === "") return
    addProvider = id
    if (state === "additional") addStage = "name"
    else startAdd("")
  }

  function startAdd(label) {
    addPrivate = (addChecks[addProvider] || "") === "additional"
    addStatus = Commons.I18n.t("agents.starting")
    addCode = ""
    addUrl = ""
    // Claude's login usually finishes on its own once the browser hands back
    // to it. When its page shows a code instead, its prompt for it has no
    // newline to read it by, so the field stays a link away the whole time.
    addNeedsPaste = false
    addDownloading = false
    addPhase = ""
    addFetched = false
    addFetchTimer.stop()
    addReauth = false
    addResult = ""
    addStage = "running"
    addProcess.command = ["omarchy-agent-account-add", "--events", addProvider].concat(label !== "" ? [label] : [])
    addProcess.running = true
  }

  function cancelAdd() {
    if (addProcess.running) addProcess.signal(15)
    addFetchTimer.stop()
    addStage = ""
    root.focusKeys()
  }

  function submitPaste(code) {
    if (!addProcess.running || code.trim() === "") return
    addProcess.write(code.trim() + "\n")
    addStatus = Commons.I18n.t("agents.checkingCode")
  }

  // The add command's own lines are tagged; everything else is the CLI
  // talking, and only two things in it matter here: a code to confirm in the
  // browser (Grok), and an invitation to paste one back (Claude).
  function handleAddLine(line) {
    var text = String(line).replace(/\u001b\[[0-9;]*m/g, "")
    var tagged = text.match(/^@@omarchy (status|progress|done|error) (.*)$/)
    if (tagged) {
      if (tagged[1] === "progress") {
        var bytes = tagged[2].split(" ")
        addDoneBytes = Number(bytes[0]) || 0
        addTotalBytes = Number(bytes[1]) || 0
        addRateBytes = Number(bytes[2]) || 0
        addDownloading = true
        addPhase = "get"
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
        addResult = tagged[2]
        // A sign-in that finishes goes straight back to the page, where the
        // account shows once its limits arrive.
        addStage = tagged[1] === "done" ? "" : tagged[1]
        if (tagged[1] === "done") {
          usage.refreshLimits()
          root.focusKeys()
          // Nothing to show yet means the sign-in is what counts as set up.
          if (usage.enabledProviders.length === 0 && !checkProcess.running) {
            addChecks = ({})
            checkProcess.running = true
          }
        }
      }
      return
    }
    var code = text.match(/^\s*([A-Z0-9]{4}-[A-Z0-9]{4})\s*$/)
    if (code) addCode = code[1]
    if (/paste code/i.test(text)) addNeedsPaste = true
    var url = text.match(/(https:\/\/\S+)/)
    if (url && addUrl === "") addUrl = url[1]
  }

  // The field takes the keys from here, so the cursor lets go of the links.
  function openPasteField() {
    addNeedsPaste = true
    cursorActive = false
  }

  function reopenSignIn() {
    if (addUrl === "") return
    Util.execArgv(addPrivate ? ["omarchy-launch-browser", "--private", addUrl] : ["omarchy-launch-browser", addUrl])
  }

  // A few ways into making Omarchy your own, handed to the local model when one
  // is running, and to the default agent otherwise or when Shift is held. The
  // prompts live in omarchy-agent-make, shared with the menu's Agent > Make something.
  readonly property var starterPrompts: [
    { glyph: "󰏘", label: Commons.I18n.t("agents.theme"), kind: "theme" },
    { glyph: "󰐱", label: Commons.I18n.t("agents.plugin"), kind: "plugin" },
    { glyph: "󰣆", label: Commons.I18n.t("agents.app"), kind: "app" },
    { glyph: "󰊴", label: Commons.I18n.t("agents.game"), kind: "game" }
  ]
  // Two across, so a label in a long language still fits its tile.
  readonly property int starterColumns: 2

  // The local model a starter opens on, picked as omarchy-agent --prefer-local
  // picks it: the last one started when it's running, any other running one
  // otherwise.
  readonly property var starterLocalModel: {
    var service = bar && bar.shell ? bar.shell.firstPartyServiceFor("omarchy.local-models") : null
    var local = service ? service.localModel : {}
    var models = local.models || {}
    var up = Object.keys(models).filter(function(id) {
      var m = models[id]
      return m && m.unit === "active" && m.sub_state === "running"
    })
    if (up.length === 0) return null
    return models[up.indexOf(local.last) >= 0 ? local.last : up[0]]
  }

  // The starters only show once something can take the task: a local model
  // that's running, or a signed-in subscription with a coding agent of its own.
  // A model still downloading or loading doesn't count yet.
  readonly property bool starterAgentReady: starterLocalModel !== null || providers.some(function(p) {
    return harnessFor(p) !== "" && !signedOut(p)
  })
  readonly property bool starterShown: addStage === "" && !blankSlate && starterAgentReady

  function startPrompt(kind, modifiers) {
    root.close()
    var useDefault = !!(modifiers & Qt.ShiftModifier)
    Util.execArgv(["omarchy-agent-make"].concat(useDefault ? ["--default"] : [], [kind]))
  }

  function renameAccount(p, account, label) {
    if (!p || !account) return
    Util.execArgv(["omarchy-agent-account-rename", p.providerId, String(account.id), label])
  }

  function useAccount(p, account) {
    if (!p || !account || account.active) return
    Util.execArgv(["omarchy-agent-account-use", p.providerId, String(account.id)])
  }

  function activateSelection(modifiers) {
    var target = keyTarget
    if (!target) refreshNow()
    else if (target.kind === "add") addStage !== "" ? cancelAdd() : addAccount()
    else if (target.kind === "choice") chooseAddProvider(addProviders[target.index].providerId)
    else if (target.kind === "pasteCode") openPasteField()
    else if (target.kind === "reopenSignIn") reopenSignIn()
    else if (target.kind === "providerLaunch") launchHarness(providers[target.index])
    else if (target.kind === "starter") startPrompt(starterPrompts[target.index].kind, modifiers)
    else if (target.kind === "providerSignin") signInAgain(providers[target.index], null)
    else if (target.kind === "signin") signInAgain(pickedEntry.provider, pickedEntry.account)
    else if (pickedEntry && !pickedEntry.account.active) useAccount(pickedEntry.provider, pickedEntry.account)
  }

  function isPicked(p, account) {
    return !!pickedEntry && !!p && !!account
      && pickedEntry.provider.providerId === p.providerId && pickedEntry.account.id === account.id
  }

  // Hands the keyboard back to the panel after an inline edit.
  function focusKeys() {
    if (panel.loadedContent) panel.loadedContent.forceActiveFocus()
  }

  function accountDetail(account) {
    var parts = []
    if (String(account.plan || "") !== "") parts.push(account.plan)
    if (account.resetCredits && Number(account.resetCredits.available) > 0)
      parts.push(freeResetsText(Number(account.resetCredits.available)))
    return parts.join(" · ")
  }

  // Only the agents `omarchy-agent-account-add` signs in get the link; any
  // other agent's sign-in trouble stays text, with its own help to follow.
  function supportsSignIn(p) {
    for (var i = 0; i < addProviders.length; i++)
      if (p && addProviders[i].providerId === p.providerId) return true
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
    addProvider = p.providerId
    addPrivate = !!account && account.primary !== true
    addStatus = Commons.I18n.t("agents.starting")
    addCode = ""
    addUrl = ""
    // Claude's login usually finishes on its own once the browser hands back
    // to it. When its page shows a code instead, its prompt for it has no
    // newline to read it by, so the field stays a link away the whole time.
    addNeedsPaste = false
    addDownloading = false
    addPhase = ""
    addFetched = false
    addFetchTimer.stop()
    addReauth = true
    addResult = ""
    addStage = "running"
    addProcess.command = ["omarchy-agent-account-add", "--events", "--reauth",
      account && account.primary !== true ? String(account.id) : ":primary", p.providerId]
    addProcess.running = true
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
  // provider with none of its own (OpenRouter, Fireworks, Z.ai…) gets no
  // terminal button: which harness to point at it is the user's choice.
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

  function launchHarness(provider) {
    var harness = harnessFor(provider)
    if (harness === "") return
    Util.execArgv(["omarchy-agent", "--agent", harness])
    root.close()
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

  function balanceDetailText(b) {
    if (!b || !(b.funded > 0)) return ""
    var spent = formatMoney(b.spent, b.currency)
    var funded = formatMoney(b.funded, b.currency)
    return b.estimated
      ? Commons.I18n.t("agents.balanceSpentEstimated").arg(spent).arg(funded)
      : Commons.I18n.t("agents.balanceSpent").arg(spent).arg(funded)
  }

  // A balance or spend row's amount is as wide as a limit row's time left
  // ("19h 40m"), so every line ends where the limit meters do.
  TextMetrics {
    id: valueColumnMetrics
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
    text: "00h 00m"
  }
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
  readonly property string heroPhrase: addStage !== "" || blankSlate
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

  // Agents that ship a white mark carry an `assets/<id>-light.svg` twin for
  // light surfaces; marks that work on both (Claude's brand-orange) ship one
  // file. The luminance check decides which candidate to try first.
  function colorChannelLuminance(value) {
    var channel = Number(value)
    if (!isFinite(channel)) return 0
    return channel <= 0.03928 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4)
  }

  function colorLuminance(color) {
    return 0.2126 * colorChannelLuminance(color.r)
      + 0.7152 * colorChannelLuminance(color.g)
      + 0.0722 * colorChannelLuminance(color.b)
  }

  // Marks resolve by convention, so a new agent's data file needs nothing
  // from this panel: assets/<id>.svg if it ships one, the module's bar glyph
  // if it doesn't.
  function iconCandidatesForProvider(p, surfaceColor) {
    if (!p) return []
    var candidates = []
    if (colorLuminance(surfaceColor || Commons.Color.background) >= 0.5)
      candidates.push(Qt.resolvedUrl("assets/" + p.providerId + "-light.svg"))
    candidates.push(Qt.resolvedUrl("assets/" + p.providerId + ".svg"))
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
  // So does a running local model, which the starters can hand their task to.
  readonly property bool blankSlate: usage.enabledProviders.length === 0 && !anySignedIn && starterLocalModel === null
  // Choosing a provider: asked for with the +, or simply what the panel is
  // while nothing is set up. It's derived rather than switched into, so
  // records that load a moment after the panel opens take its place.
  readonly property bool picking: addStage === "pick" || (blankSlate && addStage === "")
  // The + in the hero turns into the X that leaves adding. A first setup has
  // nothing to go back to until an agent is chosen.
  readonly property bool addButtonShown: !blankSlate || !picking

  // Adding takes over the hero's line, and the cursor starts over.
  readonly property string addHeading: setupShown
    ? (addReauth ? Commons.I18n.t("agents.signingInAgain") : Commons.I18n.t("agents.settingUp"))
    : picking || addProvider === ""
    ? (blankSlate ? Commons.I18n.t("agents.letTheTokensFlow") : Commons.I18n.t("agents.addAnother"))
    : Commons.I18n.t("agents.addProviderAccount").arg(addProviderName(addProvider))
  onAddStageChanged: {
    phraseSwap.stop()
    if (hero) hero.metaOpacity = 1.0
    resetKeys()
  }

  // A first setup ends when the records land, which swaps the rows under the
  // cursor without any stage change.
  onPickingChanged: resetKeys()

  // Picking an agent to add starts on the first one, ready for Enter. The
  // rows follow the same stage change, so the cursor waits a tick for them.
  function resetKeys() {
    cursorActive = false
    keyRow = 0
    keyColumn = 0
    Qt.callLater(function() { if (picking) pointAt("choice", 0) })
  }
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (!opened) {
    resetProviderDrag()
  } else {
    deleteTarget = null
    if (addStage !== "running") addStage = ""
    resetKeys()
    if (usage.enabledProviders.length === 0 && !checkProcess.running) checkProcess.running = true
    nowMs = Date.now()
    if (panelFlick) panelFlick.contentY = 0
    usage.refreshLimits()
    Qt.callLater(function() { if (panel.loadedContent) panel.loadedContent.forceActiveFocus() })
  }

  Main {
    id: usage
    settings: root.settings
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
        root.addResult = Commons.I18n.t("agents.signInUnfinished")
        root.addStage = "error"
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
    running: root.opened && root.summaryPhrases.length > 1 && root.addStage === "" && !root.blankSlate
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
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(860))

    content: PanelKeyCatcher {
      id: keyCatcher
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
        message: root.deleteTarget ? Commons.I18n.t("agents.hideProviderConfirm").arg(root.deleteTarget.providerName) : ""
        foreground: root.foreground
        background: root.surface
        fontFamily: root.fontFamily
        onCanceled: root.deleteTarget = null
        onConfirmed: root.confirmDelete()
      }
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      reorderable: root.addStage === "" && !root.renaming
      onReorderRequested: function(dy) { root.reorderProvider(dy) }

      onMoveRequested: function(dx, dy) {
        // Naming has its own field; there the arrows scroll. Signing in walks
        // its links, and a code field takes its own keys once it's open.
        if (root.addStage === "" || root.addStage === "running" || root.picking) root.moveKey(dx, dy)
        else if (dy !== 0)
          panelFlick.contentY = root.clamp(panelFlick.contentY + dy * Style.space(56), 0,
                                           Math.max(0, panelFlick.contentHeight - panelFlick.height))
      }
      onDeleteRequested: root.deleteSelected()
      blocked: root.renaming || root.deleteTarget !== null
      onActivateRequested: function(modifiers) { root.activateSelection(modifiers) }
      onCloseRequested: {
        if (root.dragIndex >= 0) root.settleProviderDrag(true)
        else if (root.addStage !== "") root.cancelAdd()
        else root.close()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refreshNow()
        else if (root.addStage === "" && t >= "1" && t <= "9" && Number(t) <= root.accountEntries.length) root.pointAt("account", Number(t) - 1)
      }

      Flickable {
        id: panelFlick
        // Reaches a little into the panel's padding on the left, with the
        // content shifted back, so the box around a lit agent mark isn't
        // clipped where it overhangs the content's edge.
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
          // The overhang sits on the start side, which is the right when
          // mirrored; there the scroll bar takes the left instead.
          x: LayoutMirroring.enabled ? (panelFlick.interactive ? panelScroll.width + Style.space(6) : 0) : panelFlick.overhang
          // When the panel scrolls, the bar gets its own strip rather than
          // sitting on top of the right-aligned numbers.
          width: panelFlick.width - panelFlick.overhang - (panelFlick.interactive ? panelScroll.width + Style.space(6) : 0)
          spacing: Style.space(16)

          // ---------- Hero: agents · rotating summary · add ----------
          PanelHero {
            id: hero
            width: parent.width
            title: root.setupShown ? root.addProviderEntry.providerName : Commons.I18n.t("agents.title")
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
                  id: addButton
                  visible: root.addButtonShown
                  hasCursor: root.hasKey("add")
                  onHasCursorChanged: if (hasCursor) root.revealItem(addButton)
                  fontFamily: root.fontFamily
                  onHovered: root.pointAt("add")
                  readonly property bool adding: root.addStage !== ""
                  glyph: adding ? "󰅖" : "󰐕"
                  tooltip: adding ? Commons.I18n.t("agents.backToLimits") : Commons.I18n.t("agents.addAnother")
                  onClicked: adding ? root.cancelAdd() : root.addAccount()
                }
              }
            }
          }

          AddView {
            visible: root.addStage !== "" || root.blankSlate
            width: column.width
          }

          Repeater {
            id: providerSections
            model: root.addStage === "" ? root.providers : []

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
                  onHovered: root.pointAt("starter", index)
                  width: (tileGrid.width - tileGrid.spacing * (tileGrid.columns - 1)) / tileGrid.columns
                  glyph: modelData.glyph
                  title: modelData.label
                  onClicked: function(modifiers) { root.startPrompt(modelData.kind, modifiers) }
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
  component AddView: Column {
    id: add
    spacing: Style.space(14)

    PanelSeparator { foreground: root.foreground }

    // Pick: each agent by a large mark over its name, three across.
    Row {
      id: choiceRow
      visible: root.picking
      width: parent.width
      spacing: Style.space(10)

      Repeater {
        model: root.picking ? root.addProviders : []

        Item {
          id: choice
          required property var modelData
          required property int index
          readonly property string state: root.addChecks[modelData.providerId] || ""
          readonly property bool available: state === "first" || state === "additional"
          readonly property bool hasCursor: root.hasKey("choice", index)
          width: (choiceRow.width - choiceRow.spacing * (root.addProviders.length - 1)) / root.addProviders.length
          implicitHeight: choiceBody.implicitHeight + Style.space(16)
          onHasCursorChanged: if (hasCursor) root.revealItem(choice)

          Column {
            id: choiceBody
            anchors.centerIn: parent
            spacing: Style.space(10)

            ProviderIcon {
              anchors.horizontalCenter: parent.horizontalCenter
              provider: choice.modelData
              size: Style.font.display * 1.6
              scale: choice.hasCursor ? 1.08 : 1.0
              Behavior on scale { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutQuad } }
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              textFormat: Text.PlainText
              text: choice.modelData.providerName
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
            onEntered: root.pointAt("choice", choice.index)
            onClicked: root.chooseAddProvider(choice.modelData.providerId)
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
        placeholderText: Commons.I18n.t("agents.placeholderWork")
        foreground: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
        onAccepted: root.startAdd(text.trim())
        Keys.onEscapePressed: function(event) { root.cancelAdd(); event.accepted = true }
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
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: Commons.I18n.t("agents.installingMeter")
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
        }

        Meter {
          anchors.left: installTitle.right
          anchors.right: installRate.left
          anchors.rightMargin: Style.space(20)
          anchors.verticalCenter: parent.verticalCenter
          value: root.addFetched ? 1 : root.addTotalBytes > 0 ? root.addDoneBytes / root.addTotalBytes : 0
        }

        Text {
          id: installRate
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          horizontalAlignment: Text.AlignRight
          text: root.downloadRate(root.addRateBytes)
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
          text: Commons.I18n.t("agents.loginBrowser")
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          font.bold: true
          wrapMode: Text.WordWrap
        }

        // Only what the plain line doesn't say: which window to use when it's
        // a private one, or that a pasted code is being checked.
        Text {
          visible: root.addPrivate || root.addStatus === Commons.I18n.t("agents.checkingCode")
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
            text: Commons.I18n.t("agents.pasteCode")
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          TextField {
            id: pasteField
            width: parent.width
            placeholderText: Commons.I18n.t("agents.placeholderCode")
            foreground: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            onAccepted: { root.submitPaste(text); text = "" }
            onVisibleChanged: if (visible) forceActiveFocus()
            Keys.onEscapePressed: function(event) { root.cancelAdd(); event.accepted = true }
          }
        }

        TextLink {
          visible: root.pasteLinkShown
          picked: root.hasKey("pasteCode")
          text: Commons.I18n.t("agents.pasteCodeLink")
          onClicked: root.openPasteField()
        }

        TextLink {
          visible: root.addUrl !== ""
          picked: root.hasKey("reopenSignIn")
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

  // One provider: its mark, name, and plan, then its limits — or, with
  // several accounts, each account's name, state, and limits in turn. A
  // prepaid provider shows its balance instead.
  component ProviderSection: Column {
    id: section
    property var provider: null
    property int providerIndex: -1
    readonly property var accounts: root.providerAccounts(provider)
    readonly property bool multi: accounts.length > 1
    readonly property var windows: root.displayWindows(provider)
    readonly property var balance: provider ? (provider.balance || null) : null
    readonly property var spend: provider ? (provider.spend || null) : null
    spacing: Style.space(16)
    readonly property bool dragged: root.dragIndex === providerIndex
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
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }

      // The plan reads as part of the name: Claude Max 20x.
      Text {
        id: sectionPlan
        anchors.left: sectionName.right
        anchors.leftMargin: Style.space(8)
        anchors.baseline: sectionName.baseline
        visible: !section.multi && text !== ""
        textFormat: Text.PlainText
        text: root.planLabel(section.provider)
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      UsageNote {
        anchors.left: sectionPlan.visible ? sectionPlan.right : sectionName.right
        anchors.leftMargin: Style.space(8)
        anchors.verticalCenter: sectionName.verticalCenter
        visible: !section.multi && message !== ""
        record: section.provider
      }

      // Opens the coding agent made for this subscription: Codex for OpenAI,
      // Claude Code for Anthropic.
      PanelActionButton {
        id: sectionLaunch
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.harnessFor(section.provider) !== ""
        iconText: "󰞷"
        tooltipText: Commons.I18n.t("agents.launchHarness").arg(section.provider ? section.provider.providerName : "")
        foreground: root.foreground
        fontFamily: root.fontFamily
        hasCursor: root.hasKey("providerLaunch", section.providerIndex)
        onClicked: root.launchHarness(section.provider)
      }
    }

    // A sign-in to redo for a single-account provider; with several, each
    // account says so on its own line.
    TextLink {
      visible: !section.multi && root.needsSignIn(section.provider)
      picked: root.hasKey("providerSignin", section.providerIndex)
      text: Commons.I18n.t("agents.signInRequired")
      idleColor: root.urgent
      tooltip: Commons.I18n.t("agents.signInAgainProvider").arg(section.provider ? section.provider.providerName : "")
      onClicked: root.signInAgain(section.provider, null)
    }


    Column {
      visible: !section.multi && section.windows.length > 0
      width: parent.width
      spacing: Style.space(12)

      Repeater {
        model: section.multi ? [] : section.windows

        CompactLimit {
          required property var modelData
          width: section.width
          window: modelData
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

    // The meter shows what is left, not what is used: a prepaid account
    // drains toward empty rather than filling toward a cap.
    Column {
      visible: !!section.balance
      width: parent.width
      spacing: Style.space(6)

      Item {
        width: parent.width
        implicitHeight: balanceTitle.implicitHeight

        Text {
          id: balanceTitle
          textFormat: Text.PlainText
          width: parent.width * 0.3
          anchors.verticalCenter: parent.verticalCenter
          text: Commons.I18n.t("agents.balance")
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
        }

        // Without a funded figure there is nothing to drain from, so no meter.
        Meter {
          visible: !!section.balance && section.balance.funded > 0
          anchors.left: balanceTitle.right
          anchors.right: balanceValue.left
          anchors.rightMargin: Style.space(20)
          anchors.verticalCenter: parent.verticalCenter
          value: visible ? section.balance.remaining / section.balance.funded : -1
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

      Text {
        textFormat: Text.PlainText
        visible: text !== ""
        width: parent.width
        text: root.balanceDetailText(section.balance)
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    // Against a real monthly cap the spend is this month's meter; without
    // one, a bar for each of the last 30 days, scaled to the busiest, shows
    // where it went.
    Item {
      visible: !!section.spend
      width: parent.width
      implicitHeight: spendTitle.implicitHeight

      Text {
        id: spendTitle
        textFormat: Text.PlainText
        width: parent.width * 0.3
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
        anchors.verticalCenter: parent.verticalCenter
        height: spendTitle.implicitHeight
        readonly property var days: section.spend ? section.spend.days : []
        readonly property real busiest: Math.max.apply(null, days.concat([0]))
        readonly property real gap: Style.space(2)
        readonly property real stub: Math.max(Style.space(2), Math.round(Style.spacing.controlHeight * 0.07))

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
              color: cost > 0 ? root.foreground : root.track
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

    Repeater {
      model: section.multi ? section.accounts : []

      Column {
        id: accountBlock
        required property var modelData
        required property int index
        width: section.width
        topPadding: index > 0 ? Style.space(6) : 0
        spacing: Style.space(14)

        AccountHeader {
          width: parent.width
          account: accountBlock.modelData
          owner: section.provider
          picked: root.isPicked(section.provider, accountBlock.modelData)
        }

        Column {
          width: parent.width
          spacing: Style.space(12)

          Repeater {
            model: root.displayWindows({ limits: accountBlock.modelData.limits || [] })

            CompactLimit {
              required property var modelData
              width: accountBlock.width
              window: modelData
              stale: accountBlock.modelData.stale === true
              fetchedAt: Number(accountBlock.modelData.fetchedAt || 0)
            }
          }
        }
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
    signal clicked(int modifiers)
    signal hovered()
    property string glyph: ""
    property string title: ""
    property bool hasCursor: false
    implicitHeight: tileBody.implicitHeight + Style.space(20)
    radius: Style.cornerRadius
    color: hasCursor ? root.alpha(Commons.Color.accent, 0.14) : root.alpha(root.foreground, 0.05)
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
        color: tile.hasCursor ? Commons.Color.accent : root.foreground
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
      onClicked: function(mouse) { tile.clicked(mouse.modifiers) }
    }

    PanelToolTip {
      visible: tileMouse.containsMouse
      // Shift-click takes the default agent, so holding Shift says so.
      text: root.starterLocalModel && !root.shiftHeld
        ? Commons.I18n.t("agents.startLocalOnNew").arg(tile.title.toLowerCase()).arg(root.starterLocalModel.name || root.starterLocalModel.recipe)
        : Commons.I18n.t("agents.startOnNew").arg(tile.title.toLowerCase())
    }
  }

  // A plain-text control: dim until hovered or picked, accent when it's the
  // current choice. Stands in for bordered buttons, which pile up here.
  component TextLink: Text {
    id: link
    signal clicked()
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
  component AccountHeader: Item {
    id: head
    property var account: ({})
    property var owner: null
    property bool picked: false
    property bool editing: false
    // The new name shows at once; the record catches up a moment later.
    property string renamedTo: ""
    readonly property bool isActive: account.active === true
    // Which of the row's links the keyboard is on, when it's on this row.
    readonly property string pickedKind: picked && root.keyTarget ? root.keyTarget.kind : ""
    readonly property string label: renamedTo !== "" ? renamedTo : String(account.label || account.id || "")

    onAccountChanged: renamedTo = ""
    onEditingChanged: root.renaming = editing
    onPickedChanged: if (picked) root.revealItem(head)

    implicitHeight: Math.max(headText.implicitHeight, headAction.implicitHeight)

    function startRename() {
      editing = true
      nameField.text = label
      nameField.forceActiveFocus()
      nameField.selectAll()
    }

    function finishRename(save) {
      if (!editing) return
      var value = nameField.text.trim()
      editing = false
      root.focusKeys()
      if (save && value !== "" && value !== label) {
        renamedTo = value
        root.renameAccount(owner, account, value)
      }
    }

    // One line: the name, then its plan and any caveats, quieter. The
    // email is the name's tooltip.
    Item {
      id: headText
      anchors.left: parent.left
      anchors.right: headAction.left
      anchors.rightMargin: Style.spacing.sm
      implicitHeight: head.editing ? nameField.implicitHeight : nameText.implicitHeight

      Text {
        id: nameText
        textFormat: Text.PlainText
        visible: !head.editing
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, parent.width * 0.6)
        text: head.label
        color: head.picked ? Commons.Color.accent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: head.isActive
        font.underline: nameMouse.containsMouse
        elide: Text.ElideRight

        MouseArea {
          id: nameMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.IBeamCursor
          onClicked: head.startRename()
        }

        PanelToolTip {
          visible: nameMouse.containsMouse && String(head.account.email || "") !== ""
          text: String(head.account.email || "")
        }
      }

      // Bounded by the actions on the right: the plan shortens first, and the
      // Sign-in required link keeps its whole width.
      Row {
        id: detailRow
        visible: !head.editing
        anchors.left: nameText.right
        anchors.leftMargin: Style.space(8)
        anchors.verticalCenter: nameText.verticalCenter
        width: Math.max(0, parent.width - nameText.width - Style.space(8))
        spacing: Style.space(8)

        Text {
          textFormat: Text.PlainText
          visible: text !== ""
          width: Math.max(0, Math.min(implicitWidth, detailRow.width
            - (accountNote.visible ? accountNote.implicitWidth + detailRow.spacing : 0)
            - (signInDot.visible ? signInDot.implicitWidth + detailRow.spacing : 0)
            - (signInLink.visible ? signInLink.implicitWidth + detailRow.spacing : 0)))
          elide: Text.ElideRight
          text: {
            var detail = root.accountDetail(head.account)
            return detail !== "" ? "· " + detail : ""
          }
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }

        UsageNote {
          id: accountNote
          record: head.account
        }

        // The dot is punctuation, not part of the link.
        Text {
          id: signInDot
          visible: root.needsSignIn(head.account)
          text: "·"
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }

        TextLink {
          id: signInLink
          visible: root.needsSignIn(head.account)
          picked: head.pickedKind === "signin"
          text: Commons.I18n.t("agents.signInRequired")
          idleColor: root.urgent
          tooltip: Commons.I18n.t("agents.signInAgainAccount")
          onClicked: root.signInAgain(head.owner, head.account)
        }
      }

      TextField {
        id: nameField
        visible: head.editing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        foreground: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        horizontalPadding: Style.space(4)
        verticalPadding: Style.space(1)
        onAccepted: head.finishRename(true)
        onActiveFocusChanged: if (!activeFocus) head.finishRename(false)
        Keys.onEscapePressed: function(event) {
          head.finishRename(false)
          event.accepted = true
        }
      }
    }

    Item {
      id: headAction
      anchors.right: parent.right
      anchors.top: parent.top
      implicitWidth: head.isActive ? headActive.implicitWidth : useRow.implicitWidth
      implicitHeight: head.isActive ? headActive.implicitHeight : useRow.implicitHeight

      Text {
        id: headActive
        visible: head.isActive
        anchors.right: parent.right
        text: Commons.I18n.t("agents.active")
        textFormat: Text.PlainText
        color: Commons.Color.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
      }

      Row {
        id: useRow
        visible: !head.isActive
        anchors.right: parent.right
        spacing: Style.space(12)

        TextLink {
          text: Commons.I18n.t("agents.use") + (head.pickedKind === "account" ? " ⏎" : "")
          picked: head.pickedKind === "account"
          onClicked: root.useAccount(head.owner, head.account)
        }
      }
    }
  }

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
      width: parent.width * 0.3
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
}
