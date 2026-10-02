import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "omarchy.agents"
  ipcTarget: "omarchy.agents"
  manageIpc: false

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property color surface: Color.popups.background
  readonly property color track: Style.selectedFillFor(foreground, Color.accent)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  // Every subscription on one page, limits first: the question this panel
  // answers is how much room is left, and where.
  readonly property var providers: usage.enabledProviders

  property bool cursorActive: false

  // Countdowns and "as of" ages read this instead of Date.now() so the
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
  readonly property var pickedEntry: keyTarget && ["account", "autoswitch", "signin"].indexOf(keyTarget.kind) >= 0
    ? accountEntries[keyTarget.index] || null
    : null

  // The keyboard walks everything on the page that does something, in
  // reading order, one row at a time: the hero's buttons, then each agent's
  // Sign-in required link or switchable accounts, and the starter tiles, or
  // the agents to add while picking one. Up and down change rows, left and right move along one.
  // Hovering moves the same cursor, so only one thing is lit.
  readonly property var keyRows: {
    var rows = []
    var hero = []
    if (addButtonShown) hero.push({ kind: "add", index: 0 })
    if (addStage === "") hero.push({ kind: "launch", index: 0 })
    if (hero.length > 0) rows.push(hero)
    if (picking) {
      var choices = []
      for (var k = 0; k < addProviders.length; k++) choices.push({ kind: "choice", index: k })
      rows.push(choices)
    } else if (addStage === "") {
      // Accounts count in the same order as accountEntries. Only what can be
      // done is a stop: one that isn't active offers Autoswitch beside Use, a
      // lapsed sign-in comes first, and the active account with nothing to
      // fix is skipped.
      var entry = 0
      for (var p = 0; p < providers.length; p++) {
        var accounts = providerAccounts(providers[p])
        if (accounts.length < 2) {
          if (needsSignIn(providers[p])) rows.push([{ kind: "providerSignin", index: p }])
          continue
        }
        for (var a = 0; a < accounts.length; a++, entry++) {
          var row = []
          if (needsSignIn(accounts[a])) row.push({ kind: "signin", index: entry })
          if (!accounts[a].active) {
            row.push({ kind: "autoswitch", index: entry })
            row.push({ kind: "account", index: entry })
          }
          if (row.length > 0) rows.push(row)
        }
      }
      if (!blankSlate) {
        var tiles = []
        for (var j = 0; j < starterPrompts.length; j++) tiles.push({ kind: "starter", index: j })
        rows.push(tiles)
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
      // Arriving on an account lands on Use; left reaches Autoswitch.
      var row = keyRows[keyRow]
      var use = -1
      for (var c = 0; c < row.length; c++) if (row[c].kind === "account") use = c
      keyColumn = use >= 0 ? use : Math.min(keyColumn, row.length - 1)
    } else if (dx !== 0) {
      keyColumn = clamp(Math.min(keyColumn, keyRows[keyRow].length - 1) + dx, 0, keyRows[keyRow].length - 1)
    }
  }

  // Keeps whatever the cursor lands on inside the scrolled view.
  function revealItem(item) {
    if (!item || !panelFlick || !panelFlick.interactive) return
    var top = item.mapToItem(column, 0, 0).y
    var margin = Style.space(12)
    if (top - margin < panelFlick.contentY)
      panelFlick.contentY = Math.max(0, top - margin)
    else if (top + item.height + margin > panelFlick.contentY + panelFlick.height)
      panelFlick.contentY = Math.min(panelFlick.contentHeight - panelFlick.height, top + item.height + margin - panelFlick.height)
  }

  // The bar icon lights up when any account new sessions use is nearly out,
  // or a prepaid balance is down to its last 10%.
  readonly property bool alarming: {
    for (var i = 0; i < providers.length; i++) {
      var window = bindingWindow(providers[i])
      if (window && window.percent >= 0.9) return true
      if (balanceAlarming(providers[i].balance)) return true
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
    { providerId: "claude", providerName: "Claude Code" },
    { providerId: "codex", providerName: "Codex" },
    { providerId: "grok", providerName: "Grok" }
  ]
  property string addStage: ""
  property string addProvider: ""
  property var addChecks: ({})
  property string addStatus: ""
  property string addCode: ""
  property string addUrl: ""
  property bool addNeedsPaste: false
  property string addResult: ""
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
    addStatus = "Starting…"
    addCode = ""
    addUrl = ""
    // Claude's login offers pasting a code back whenever its page shows one,
    // and its prompt for it has no newline to read it by, so the field is
    // there from the start.
    addNeedsPaste = addProvider === "claude"
    addResult = ""
    addStage = "running"
    addProcess.command = ["omarchy-agent-account-add", "--events", addProvider].concat(label !== "" ? [label] : [])
    addProcess.running = true
  }

  function cancelAdd() {
    if (addProcess.running) addProcess.signal(15)
    addStage = ""
    root.focusKeys()
  }

  // A first sign-in keeps saying so until its limits arrive, rather than
  // flashing the choices again while the record is written.
  onBlankSlateChanged: if (!blankSlate && addStage === "done") addStage = ""

  function submitPaste(code) {
    if (!addProcess.running || code.trim() === "") return
    addProcess.write(code.trim() + "\n")
    addStatus = "Checking the code…"
  }

  // The add command's own lines are tagged; everything else is the CLI
  // talking, and only two things in it matter here: a code to confirm in the
  // browser (Grok), and an invitation to paste one back (Claude).
  function handleAddLine(line) {
    var text = String(line).replace(/\u001b\[[0-9;]*m/g, "")
    var tagged = text.match(/^@@omarchy (status|done|error) (.*)$/)
    if (tagged) {
      if (tagged[1] === "status") {
        addStatus = tagged[2]
      } else {
        addResult = tagged[2]
        addStage = tagged[1]
        if (tagged[1] === "done") {
          usage.refreshLimits()
          addDoneTimer.restart()
          // Nothing to show yet means the sign-in is what counts as set up.
          if (providers.length === 0 && !checkProcess.running) {
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

  function reopenSignIn() {
    if (addUrl === "") return
    Util.execArgv(addPrivate ? ["omarchy-launch-browser", "--private", addUrl] : ["omarchy-launch-browser", addUrl])
  }

  // A few ways into making Omarchy your own, handed to the default agent.
  readonly property var starterPrompts: [
    { glyph: "󰏘", label: "Theme", prompt: "Make me a new Omarchy theme. Ask me what look or inspiration I have in mind, then build it following the Omarchy skill's theming guide and switch to it." },
    { glyph: "󰐱", label: "Plugin", prompt: "Make me a new Omarchy shell plugin. Ask me what I'd like it to do, then build it following the Omarchy skill's plugin guide and enable it." },
    { glyph: "󰣆", label: "App", prompt: "Make me a new app for my Omarchy desktop. Ask me what it should do, then build it following the omarchy-app skill and install it so it shows up in the app launcher." }
  ]

  function startPrompt(prompt) {
    root.close()
    Util.execArgv(["omarchy-agent-prompt", prompt])
  }

  function renameAccount(p, account, label) {
    if (!p || !account) return
    Util.execArgv(["omarchy-agent-account-rename", p.providerId, String(account.id), label])
  }

  function useAccount(p, account) {
    if (!p || !account || account.active) return
    Util.execArgv(["omarchy-agent-account-use", p.providerId, String(account.id)])
  }

  function autoSwitchFor(p) {
    return !!p && !!p.accountSwitch && p.accountSwitch.mode === "auto"
  }

  function switchThreshold(p) {
    return p && p.accountSwitch ? Number(p.accountSwitch.threshold || 95) : 95
  }

  function setSwitchMode(p, mode) {
    if (!p || providerAccounts(p).length < 2 || mode === (autoSwitchFor(p) ? "auto" : "manual")) return
    Util.execArgv(["bash", "-c", 'omarchy-agent-account-mode "$1" "$2" >/dev/null && omarchy-agent-usage-update --limits-only "$1"',
                   "omarchy-agent-account-mode", p.providerId, mode])
  }

  // `m` flips autoswitch for the picked account's provider, or the first
  // provider with several accounts when nothing is picked.
  function toggleSwitchMode() {
    var p = pickedEntry ? pickedEntry.provider : (accountEntries.length > 0 ? accountEntries[0].provider : null)
    if (p) setSwitchMode(p, autoSwitchFor(p) ? "manual" : "auto")
  }

  function activateSelection() {
    var target = keyTarget
    if (!target) refreshNow()
    else if (target.kind === "add") addStage !== "" ? cancelAdd() : addAccount()
    else if (target.kind === "choice") chooseAddProvider(addProviders[target.index].providerId)
    else if (target.kind === "launch") launchAgent()
    else if (target.kind === "starter") startPrompt(starterPrompts[target.index].prompt)
    else if (target.kind === "providerSignin") signInAgain(providers[target.index], null)
    else if (target.kind === "signin") signInAgain(pickedEntry.provider, pickedEntry.account)
    else if (target.kind === "autoswitch") setSwitchMode(pickedEntry.provider, autoSwitchFor(pickedEntry.provider) ? "manual" : "auto")
    else if (pickedEntry && !pickedEntry.account.active) useAccount(pickedEntry.provider, pickedEntry.account)
  }

  function isPicked(p, account) {
    return !!pickedEntry && !!p && !!account
      && pickedEntry.provider.providerId === p.providerId && pickedEntry.account.id === account.id
  }

  // Hands the keyboard back to the panel after an inline edit.
  function focusKeys() {
    keyCatcher.forceActiveFocus()
  }

  function accountDetail(account) {
    var parts = []
    if (String(account.plan || "") !== "") parts.push(account.plan)
    if (account.resetCredits && Number(account.resetCredits.available) > 0)
      parts.push(account.resetCredits.available + " free reset" + (Number(account.resetCredits.available) === 1 ? "" : "s"))
    return parts.join(" · ")
  }

  // A lapsed or missing sign-in is something you can fix from here; any other
  // trouble is only reported.
  function needsSignIn(item) {
    var status = String(item && item.usageStatusText || "")
    return status === "Sign-in expired" || status === "Waiting for auth"
  }

  function otherTrouble(item) {
    var status = String(item && item.usageStatusText || "")
    return status !== "" && !needsSignIn(item) ? status : ""
  }

  // Sign an account that's already here in again, following along in the
  // add view just like adding one.
  function signInAgain(p, account) {
    if (!p || addStage === "running") return
    addProvider = p.providerId
    addPrivate = !!account && account.primary !== true
    addStatus = "Starting…"
    addCode = ""
    addUrl = ""
    // Claude's login offers pasting a code back whenever its page shows one,
    // and its prompt for it has no newline to read it by, so the field is
    // there from the start.
    addNeedsPaste = addProvider === "claude"
    addResult = ""
    addStage = "running"
    addProcess.command = ["omarchy-agent-account-add", "--events", "--reauth",
      account && account.primary !== true ? String(account.id) : ":primary", p.providerId]
    addProcess.running = true
  }

  function resetCreditsText(credits) {
    if (!credits || !(Number(credits.available) > 0)) return ""
    var count = Number(credits.available)
    var text = count + " free reset" + (count === 1 ? "" : "s")
    var expires = new Date(String(credits.nextExpiresAt || "")).getTime()
    if (isFinite(expires) && expires > nowMs) text += " · next expires in " + formatDuration(expires - nowMs)
    return text
  }

  function planLabel(p) {
    var tier = String(p && p.tierLabel || "")
    return tier === "" ? "" : tier.charAt(0).toUpperCase() + tier.slice(1)
  }

  function launchAgent() {
    if (root.bar) root.bar.run("omarchy-agent --pick")
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
    return {
      title: String(title || "") !== "" ? String(title) : windowTitle(label),
      percent: Number(percent),
      resetAt: String(resetAt || "")
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
    if (!(ms > 0)) return "now"
    var minutes = Math.floor(ms / 60000)
    var hours = Math.floor(minutes / 60)
    var days = Math.floor(hours / 24)
    if (days > 0) return days + "d " + (hours % 24) + "h"
    if (hours > 0) return hours + "h " + (minutes % 60) + "m"
    return Math.max(1, minutes) + "m"
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
    return currencyPrefix(currency) + amount.toFixed(2)
  }

  function balanceDetailText(b) {
    if (!b || !(b.funded > 0)) return ""
    var text = formatMoney(b.spent, b.currency) + " spent of " + formatMoney(b.funded, b.currency) + " funded"
    if (b.estimated) text += " · estimated"
    return text
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
    if (week > 0) phrases.push(usage.formatTokenCount(week) + " tokens this week")
    if (today > 0) phrases.push(usage.formatTokenCount(today) + " tokens today")
    var topModel = ""
    for (var model in byModel) if (topModel === "" || byModel[model] > byModel[topModel]) topModel = model
    if (topModel !== "" && byModel[topModel] > 0) phrases.push("Mostly " + topModel)
    var busiest = ""
    for (var date in byDay) if (busiest === "" || byDay[date] > byDay[busiest]) busiest = date
    if (busiest !== "" && byDay[busiest] > 0) phrases.push("Busiest day: " + dayName(busiest))
    if (prompts > 0) phrases.push(prompts + " prompt" + (prompts === 1 ? "" : "s") + " today")
    if (sessions > 0) phrases.push(sessions + " session" + (sessions === 1 ? "" : "s") + " today")
    return phrases
  }
  property int phraseIndex: 0
  // Every record that lands rebuilds the phrases, and opening the panel
  // refreshes each agent in turn. Indexing the live list would swap the line
  // on each of those, so the hero holds what it shows until the next fade.
  property string shownPhrase: ""
  readonly property string heroPhrase: addStage !== "" || blankSlate
    ? addHeading
    : (shownPhrase !== "" ? shownPhrase : "Subscriptions")

  function showPhrase() {
    var n = summaryPhrases.length
    shownPhrase = n > 0 ? summaryPhrases[phraseIndex % n] : ""
  }

  onSummaryPhrasesChanged: if (shownPhrase === "" || summaryPhrases.length <= 1) showPhrase()

  function dayName(date) {
    var parsed = new Date(String(date || "") + "T00:00:00")
    if (isNaN(parsed.getTime())) return String(date || "")
    return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][parsed.getDay()]
  }

  // Only speaks up when the numbers cover more than this machine.
  function footerText() {
    if (usage.syncStatusText !== "") return usage.syncStatusText
    for (var i = 0; i < providers.length; i++) {
      var count = Number(providers[i].syncDeviceCount || 0)
      if (providers[i].syncEnabled && count > 0)
        return "Merged from " + count + " device" + (count === 1 ? "" : "s")
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
    if (colorLuminance(surfaceColor || Color.background) >= 0.5)
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
  readonly property bool blankSlate: providers.length === 0 && !anySignedIn
  // Choosing a provider: asked for with the +, or simply what the panel is
  // while nothing is set up. It's derived rather than switched into, so
  // records that load a moment after the panel opens take its place.
  readonly property bool picking: addStage === "pick" || (blankSlate && addStage === "")
  // The + in the hero turns into the X that leaves adding. A first setup has
  // nothing to go back to until an agent is chosen.
  readonly property bool addButtonShown: !blankSlate || !picking

  // Adding takes over the hero's line, and the cursor starts over.
  readonly property string addHeading: picking || addProvider === ""
    ? "Add an account"
    : "Add " + (/^[AEIOU]/.test(addProviderName(addProvider)) ? "an " : "a ") + addProviderName(addProvider) + " account"
  onAddStageChanged: {
    phraseSwap.stop()
    hero.metaOpacity = 1.0
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

  onOpenedChanged: if (opened) {
    if (addStage !== "running") addStage = ""
    resetKeys()
    if (providers.length === 0 && !checkProcess.running) checkProcess.running = true
    nowMs = Date.now()
    if (panelFlick) panelFlick.contentY = 0
    usage.refreshLimits()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
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
        root.addResult = "The sign-in didn't finish."
        root.addStage = "error"
      }
    }
  }

  Timer {
    id: addDoneTimer
    interval: 2500
    onTriggered: if (root.addStage === "done" && !root.blankSlate) root.addStage = ""
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
      to: 0.0; duration: Style.duration(180); easing.type: Easing.OutQuad
    }
    ScriptAction {
      script: {
        root.phraseIndex = (root.phraseIndex + 1) % Math.max(1, root.summaryPhrases.length)
        root.showPhrase()
      }
    }
    PropertyAnimation {
      target: hero; property: "metaOpacity"
      to: 1.0; duration: Style.duration(260); easing.type: Easing.InQuad
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
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(860))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent

      onMoveRequested: function(dx, dy) {
        // Naming and signing in have their own fields; there the arrows scroll.
        if (root.addStage === "" || root.picking) root.moveKey(dx, dy)
        else if (dy !== 0)
          panelFlick.contentY = root.clamp(panelFlick.contentY + dy * Style.space(56), 0,
                                           Math.max(0, panelFlick.contentHeight - panelFlick.height))
      }
      onActivateRequested: root.activateSelection()
      onCloseRequested: {
        if (root.addStage !== "") root.cancelAdd()
        else root.close()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refreshNow()
        else if (t === "m" || t === "M") root.toggleSwitchMode()
        else if (root.addStage === "" && t >= "1" && t <= "9" && Number(t) <= root.accountEntries.length) root.pointAt("account", Number(t) - 1)
      }

      Flickable {
        id: panelFlick
        anchors.fill: parent
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
          // When the panel scrolls, the bar gets its own strip rather than
          // sitting on top of the right-aligned numbers.
          width: panelFlick.width - (panelFlick.interactive ? panelScroll.width + Style.space(6) : 0)
          spacing: Style.space(16)

          // ---------- Hero: agents · rotating summary · add ----------
          PanelHero {
            id: hero
            width: parent.width
            title: "Agents"
            meta: root.heroPhrase
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
              Row {
                spacing: Style.space(6)
                visible: root.addStage === "" || root.addButtonShown

                HeroButton {
                  visible: root.addButtonShown
                  hasCursor: root.hasKey("add")
                  onHovered: root.pointAt("add")
                  readonly property bool adding: root.addStage !== ""
                  glyph: adding ? "󰅖" : "󰐕"
                  tooltip: adding ? "Back to the limits" : "Add a subscription"
                  onClicked: adding ? root.cancelAdd() : root.addAccount()
                }

                HeroButton {
                  visible: root.addStage === ""
                  hasCursor: root.hasKey("launch")
                  onHovered: root.pointAt("launch")
                  glyph: "󰞷"
                  tooltip: "Start the default agent"
                  onClicked: root.launchAgent()
                }
              }
            }
          }

          AddView {
            visible: root.addStage !== "" || root.blankSlate
            width: column.width
          }

          Repeater {
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
            visible: root.addStage === "" && !root.blankSlate
            foreground: root.foreground
          }

          Column {
            visible: root.addStage === "" && !root.blankSlate
            width: parent.width
            spacing: Style.space(12)

            PanelSectionHeader {
              text: "MAKE SOMETHING COOL"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Row {
              id: tileRow
              width: parent.width
              spacing: Style.space(10)

              Repeater {
                model: root.starterPrompts

                StarterTile {
                  required property var modelData
                  required property int index
                  hasCursor: root.hasKey("starter", index)
                  onHovered: root.pointAt("starter", index)
                  width: (tileRow.width - tileRow.spacing * 2) / 3
                  glyph: modelData.glyph
                  title: modelData.label
                  onClicked: root.startPrompt(modelData.prompt)
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

    Text {
      visible: root.blankSlate && root.picking
      width: parent.width
      text: "Sign in to an AI coding subscription, and this panel keeps track of how much of it you have left."
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }

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
              color: choice.hasCursor ? Color.accent : root.foreground
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
        text: "Name this account. It signs in through a private window, so your browser's current account isn't picked up."
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }

      TextField {
        id: addNameField
        width: parent.width
        placeholderText: "Work"
        foreground: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
        onAccepted: root.startAdd(text.trim())
        Keys.onEscapePressed: function(event) { root.cancelAdd(); event.accepted = true }
      }
    }

    // Running: what's happening, and whatever the sign-in needs from you.
    Column {
      visible: root.addStage === "running"
      width: parent.width
      spacing: Style.space(12)

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: root.addStatus
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        wrapMode: Text.WordWrap
      }

      Column {
        visible: root.addCode !== ""
        width: parent.width
        spacing: Style.space(4)

        Text {
          text: "Confirm this code in your browser"
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }

        Text {
          textFormat: Text.PlainText
          text: root.addCode
          color: Color.accent
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
          text: "If the page shows a code instead of finishing, paste it here."
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          wrapMode: Text.WordWrap
        }

        TextField {
          id: pasteField
          width: parent.width
          placeholderText: "Code"
          foreground: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          onAccepted: { root.submitPaste(text); text = "" }
          Keys.onEscapePressed: function(event) { root.cancelAdd(); event.accepted = true }
        }
      }

      TextLink {
        visible: root.addUrl !== ""
        text: "Open the sign-in page again"
        onClicked: root.reopenSignIn()
      }
    }

    // Done or failed.
    Text {
      visible: root.addStage === "done" || root.addStage === "error"
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
    spacing: Style.space(16)

    PanelSeparator { foreground: root.foreground }

    Item {
      width: parent.width
      implicitHeight: Math.max(sectionMark.height, sectionName.implicitHeight)

      ProviderIcon {
        id: sectionMark
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        provider: section.provider
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

      Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: !section.multi
        textFormat: Text.PlainText
        text: root.planLabel(section.provider)
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    // Sign-in and endpoint trouble for a single-account provider; with
    // several, each account says so on its own line.
    TextLink {
      visible: !section.multi && root.needsSignIn(section.provider)
      picked: root.hasKey("providerSignin", section.providerIndex)
      text: "Sign-in required"
      idleColor: root.urgent
      tooltip: "Sign in to " + (section.provider ? section.provider.providerName : "") + " again"
      onClicked: root.signInAgain(section.provider, null)
    }

    Text {
      visible: !section.multi && root.otherTrouble(section.provider) !== ""
      width: parent.width
      textFormat: Text.PlainText
      text: section.provider ? String(section.provider.authHelpText || "") : ""
      color: root.urgent
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
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
          text: "Balance"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }

        Meter {
          anchors.left: balanceTitle.right
          anchors.right: balanceValue.left
          anchors.rightMargin: Style.spacing.md
          anchors.verticalCenter: parent.verticalCenter
          value: section.balance && section.balance.funded > 0 ? section.balance.remaining / section.balance.funded : -1
          alarming: root.balanceAlarming(section.balance)
        }

        Text {
          id: balanceValue
          textFormat: Text.PlainText
          width: Style.space(96)
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          horizontalAlignment: Text.AlignRight
          text: section.balance ? root.formatMoney(section.balance.remaining, section.balance.currency) : ""
          color: root.balanceAlarming(section.balance) ? root.urgent : root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
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
    signal clicked()
    signal hovered()
    property string glyph: ""
    property string title: ""
    property bool hasCursor: false
    implicitHeight: tileBody.implicitHeight + Style.space(20)
    radius: Style.cornerRadius
    color: hasCursor ? root.alpha(Color.accent, 0.14) : root.alpha(root.foreground, 0.05)
    onHasCursorChanged: if (hasCursor) root.revealItem(tile)

    Row {
      id: tileBody
      anchors.centerIn: parent
      spacing: Style.space(8)

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: tile.glyph
        color: Color.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: tile.title
        color: tile.hasCursor ? Color.accent : root.foreground
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
      text: "Start your default agent on a new " + tile.title.toLowerCase()
    }
  }

  // The tinted square in the hero's corner: start an agent, add a subscription.
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
    color: root.alpha(Color.accent, hasCursor ? 0.3 : 0.12)
    border.width: hasCursor ? Math.max(1, Style.hoverBorderWidth) : 0
    border.color: Color.accent
    onHasCursorChanged: if (hasCursor) root.revealItem(heroButton)

    Text {
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: heroButton.glyph
      color: Color.accent
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

  // A plain-text control: dim until hovered or picked, accent when it's the
  // current choice. Stands in for bordered buttons, which pile up here.
  component TextLink: Text {
    id: link
    signal clicked()
    property bool current: false
    property bool picked: false
    property string tooltip: ""
    property color idleColor: root.dim
    readonly property bool hot: linkMouse.containsMouse || picked
    onPickedChanged: if (picked) root.revealItem(link)
    textFormat: Text.PlainText
    color: current ? Color.accent : (hot ? root.foreground : idleColor)
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
    readonly property bool autoOn: root.autoSwitchFor(owner)
    // Which of the row's links the keyboard is on, when it's on this row.
    readonly property string pickedKind: picked && root.keyTarget ? root.keyTarget.kind : ""
    readonly property string label: renamedTo !== "" ? renamedTo : String(account.label || account.id || "")

    onAccountChanged: renamedTo = ""
    onPickedChanged: if (picked) root.revealItem(head)

    // Anywhere on the line counts, so Use can show up when it's hidden.
    HoverHandler { id: useHover }
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
        color: head.picked ? Color.accent : root.foreground
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

      // Bounded by the actions on the right: the plan and any trouble shorten
      // first, and the Sign-in required link keeps its whole width.
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
            - (signInDot.visible ? signInDot.implicitWidth + detailRow.spacing : 0)
            - (signInLink.visible ? signInLink.implicitWidth + detailRow.spacing : 0)))
          elide: Text.ElideRight
          text: {
            var parts = []
            var detail = root.accountDetail(head.account)
            if (detail !== "") parts.push(detail)
            var trouble = root.otherTrouble(head.account)
            if (trouble !== "") parts.push(trouble)
            return parts.length > 0 ? "· " + parts.join(" · ") : ""
          }
          color: root.otherTrouble(head.account) !== "" ? root.urgent : root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
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
          text: "Sign-in required"
          idleColor: root.urgent
          tooltip: "Sign in to this account again"
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
        text: "ACTIVE"
        color: Color.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
      }

      // Switching now is Use. Hovering it also offers Autoswitch: move new
      // sessions over by themselves once the active account reaches the
      // threshold. While that's on it stays in view in place of Use, and
      // clicking it again goes back to only being notified.
      Row {
        id: useRow
        visible: !head.isActive
        anchors.right: parent.right
        spacing: Style.space(12)

        TextLink {
          visible: head.autoOn || useHover.hovered || head.picked
          text: head.pickedKind === "autoswitch" ? "Autoswitch ⏎" : "Autoswitch"
          picked: head.pickedKind === "autoswitch"
          current: head.autoOn
          tooltip: head.autoOn
            ? "Stop switching automatically"
            : "Switch here automatically at " + root.switchThreshold(head.owner) + "%"
          onClicked: root.setSwitchMode(head.owner, head.autoOn ? "manual" : "auto")
        }

        // With Autoswitch on, Use waits until the line is hovered or picked.
        TextLink {
          visible: !head.autoOn || useHover.hovered || head.picked
          text: head.pickedKind === "account" ? "Use ⏎" : "Use"
          picked: head.pickedKind === "account"
          onClicked: root.useAccount(head.owner, head.account)
        }
      }
    }
  }

  // One line per limit window: title, meter, percentage, and reset. A
  // model-scoped allowance on the same clock ("Fable" on Weekly) is a marker
  // on this row's meter, named in the row's tooltip.
  component CompactLimit: Item {
    id: compact
    property var window: null
    // Numbers kept past a failed check dim, and say how old they are on hover.
    property bool stale: false
    property real fetchedAt: 0
    opacity: stale ? 0.5 : 1.0
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
          lines.push(compact.window.title + ": " + Math.round(compact.window.percent * 100) + "% used"
            + (compact.resetMs > 0 ? " · resets in " + root.formatDuration(compact.resetMs) : ""))
        }
        if (compact.stale)
          lines.push(compact.fetchedAt > 0 && root.nowMs - compact.fetchedAt > 60000
            ? "As of " + root.formatDuration(root.nowMs - compact.fetchedAt) + " ago"
            : "Last known")
        for (var i = 0; i < compact.scoped.length; i++)
          lines.push(compact.scoped[i].title + ": " + Math.round(compact.scoped[i].percent * 100) + "% of its "
            + String(compact.window ? compact.window.title : "").toLowerCase() + " allowance")
        return lines.join("\n")
      }
    }

    Text {
      id: compactTitle
      textFormat: Text.PlainText
      width: parent.width * 0.3
      anchors.verticalCenter: parent.verticalCenter
      text: compact.window ? compact.window.title : ""
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
        x: root.clamp(meterTrack.width * root.clamp(Number(modelData.percent), 0, 1) - width / 2, 0, meterTrack.width - width)
        color: meter.alarming ? root.urgent : root.foreground
      }
    }
  }
}
