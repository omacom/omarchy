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

  property alias usageService: usage
  readonly property var providers: usage.enabledProviders
  // The selection follows the provider, not the slot it happens to sit in: a
  // provider whose first scan lands while the panel is open would otherwise
  // shift the list underneath you and swap out what you were reading.
  property string selectedProviderId: ""
  readonly property int providerIndex: {
    for (var i = 0; i < providers.length; i++)
      if (providers[i].providerId === selectedProviderId) return i
    return 0
  }
  readonly property var provider: providers.length > 0 ? providers[providerIndex] : null

  property bool cursorActive: false
  property bool machinesOpen: false
  property int focusSection: 0
  property int usageCursor: 0
  property bool detailsOpen: false
  readonly property int machineIndex: {
    for (var i = 0; i < usage.machineChoices.length; i++)
      if (usage.machineChoices[i].id === usage.selectedMachineId) return i
    return 0
  }
  function selectMachine(delta) {
    var count = usage.machineChoices.length
    usage.selectedMachineId = usage.machineChoices[(machineIndex + delta + count) % count].id
  }
  function showMachines() {
    detailsOpen = false
    machinesOpen = true
    Qt.callLater(function() {
      keyCatcher.forceActiveFocus()
      machineSettings.revealSelected()
    })
  }
  function leaveMachines() {
    machinesOpen = false
    focusSection = 2
    ensureTopControlsVisible()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }
  function ensureUsageCursorVisible() {
    Qt.callLater(function() {
      var page = root.activeProviderPage()
      var row = page ? page.detailItemAt(root.usageCursor) : null
      root.ensureContentItemVisible(row)
    })
  }

  function ensureContentItemVisible(item) {
    if (!item || panelFlick.height <= 0) return
    var itemY = item.mapToItem(contentStack, 0, 0).y
    var maximumY = Math.max(0, panelFlick.contentHeight - panelFlick.height)
    if (itemY < panelFlick.contentY)
      panelFlick.contentY = Math.max(0, itemY)
    else if (itemY + item.height > panelFlick.contentY + panelFlick.height)
      panelFlick.contentY = Math.min(maximumY, itemY + item.height - panelFlick.height)
  }

  function ensureTopControlsVisible() {
    Qt.callLater(function() { panelFlick.contentY = 0 })
  }

  function activeProviderPage() {
    for (var i = 0; i < providerPages.count; i++) {
      var page = providerPages.itemAt(i)
      if (page && page.selectedPage) return page
    }
    return null
  }

  // Countdowns and "updated" read this instead of Date.now() so the
  // panel keeps telling the truth while it sits open.
  property double nowMs: Date.now()

  readonly property var limits: limitWindows(provider)
  readonly property var headline: bindingWindow(provider)
  readonly property var balance: provider ? (provider.balance || null) : null
  // A prepaid account runs low the way a subscription window fills up: the
  // last 10% of the funded credits lights the same alarm.
  readonly property bool balanceAlarming: !!balance && balance.funded > 0
    && balance.remaining / balance.funded <= 0.1
  readonly property bool alarming: (!!headline && headline.percent >= 0.9) || balanceAlarming

  function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)) }
  function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
  function providerSupportsPricing(value) {
    return !!value && (value.providerId === "codex" || value.providerId === "claude" || value.providerId === "kimi")
  }

  function selectProvider(index) {
    if (providers.length === 0) return
    var wrapped = ((index % providers.length) + providers.length) % providers.length
    selectedProviderId = providers[wrapped].providerId
    usageCursor = 0
    detailsOpen = false
  }

  function refreshNow() {
    usage.refreshAll(true)
    usage.refreshMachines()
  }

  function launchAgent() {
    if (root.bar) root.bar.run("omarchy-agent --pick")
    root.close()
  }

  // ---------------------------------------------------------------- limits
  //
  // Both providers report the same two shapes: a short rolling session window
  // and a long weekly one. Everything below normalizes them into one record so
  // the meters and the hero speak a single language.

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

  // ---------------------------------------------------------------- content

  // The plan you pay for, under the name of the tool it pays for. Limits live
  // in their own section; the hero just says what this is.
  function heroMeta(p) {
    if (!p) return ""
    if (String(p.usageStatusText || "") !== "") return p.usageStatusText
    var tier = String(p.tierLabel || "")
    if (tier === "") return "Subscription"
    return tier.charAt(0).toUpperCase() + tier.slice(1)
  }

  // Local calendar date, recomputed from nowMs so a panel left open across
  // midnight moves the "Today" row with the clock.
  function todayDate() {
    var now = new Date(root.nowMs)
    return now.getFullYear()
      + "-" + String(now.getMonth() + 1).padStart(2, "0")
      + "-" + String(now.getDate()).padStart(2, "0")
  }

  function dayName(date) {
    var parsed = new Date(String(date || "") + "T00:00:00")
    if (isNaN(parsed.getTime())) return String(date || "")
    return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][parsed.getDay()]
  }

  function dayLabel(date, today) {
    if (today) return "Today"
    return dayName(date)
  }

  function dayTooltip(day, today) {
    if (!day) return ""
    var parsed = new Date(String(day.date) + "T00:00:00")
    var label = isNaN(parsed.getTime())
      ? String(day.date)
      : dayName(day.date) + " " + (parsed.getMonth() + 1) + "/" + parsed.getDate()
    var text = label + " · " + usage.formatTokenCount(Number(day.messageCount || 0)) + " tokens"
    // Prompt and session counts only exist for today, so they ride along here
    // instead of taking a section of their own. Billing-API agents never
    // count prompts, and "0 prompts" would read as a quiet day, not a gap.
    if (today && provider && provider.hasPromptStats !== false)
      text += " · " + Number(provider.todayPrompts || 0) + " prompts · "
        + Number(provider.todaySessions || 0) + " sessions"
    if (day.pricingEnabled === true)
      text += "\n" + usage.pricing.dailyTooltipDetails(day)
    return text
  }

  function weekPeak(days) {
    var peak = 0
    for (var i = 0; i < days.length; i++) peak = Math.max(peak, Number(days[i].messageCount || days[i].tokens || 0))
    return peak
  }

  function modelRows(p) {
    var usageByModel = p ? (p.modelUsage || {}) : {}
    var rows = []
    for (var id in usageByModel) {
      var bucket = usageByModel[id] || {}
      var input = Number(bucket.inputTokens || 0)
      var output = Number(bucket.outputTokens || 0)
      var cacheRead = Number(bucket.cacheReadInputTokens || 0)
      var cacheWrite = Number(bucket.cacheCreationInputTokens || 0)
      rows.push({
        name: usage.friendlyModelName(id),
        total: input + output + cacheRead + cacheWrite,
        input: input,
        output: output,
        cacheRead: cacheRead,
        cacheWrite: cacheWrite
      })
    }
    rows.sort(function(a, b) { return b.total - a.total })
    return rows.slice(0, 4)
  }

  function pricedModelRows(rows) {
    var result = []
    var values = rows || []
    for (var i = 0; i < values.length; i++) {
      var row = values[i]
      result.push({
        id: row.id,
        name: row.id === "(unknown model)" ? row.id : usage.friendlyModelName(row.id),
        total: row.tokens,
        value: row.value,
        tooltip: row.tooltip,
        pricingPresentation: true
      })
    }
    return result
  }

  function pricedSummaryRows(rows) {
    var result = []
    var values = rows || []
    for (var i = 0; i < values.length; i++) {
      var row = values[i]
      result.push({
        name: row.label,
        total: row.tokens,
        value: row.value,
        tooltip: row.tooltip,
        pricingPresentation: true
      })
    }
    return result
  }

  function pricingLimitationText(provider, dailyRows, modelPresentation) {
    if (!providerSupportsPricing(provider)) return ""
    var incomplete = false
    var days = dailyRows || []
    for (var i = 0; i < days.length; i++) {
      if (Number(days[i].tokens || 0) > 0 && days[i].cost && days[i].cost.status !== "complete") {
        incomplete = true
        break
      }
    }
    var rows = (modelPresentation.models || []).concat(modelPresentation.summaries || [])
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      if (Number(rows[rowIndex].tokens || 0) > 0
          && rows[rowIndex].cost && rows[rowIndex].cost.status !== "complete")
        incomplete = true
    }
    if (!incomplete) return ""
    var text = "Costs exclude usage with missing prices or token details."
    var missing = modelPresentation.missingPriceModels || []
    if (missing.length > 0) {
      var names = []
      for (var missingIndex = 0; missingIndex < missing.length; missingIndex++)
        names.push(missing[missingIndex] === "(unknown model)"
          ? missing[missingIndex] : usage.friendlyModelName(missing[missingIndex]))
      text += " Missing prices: " + names.join(", ") + "."
    }
    return text
  }

  function modelTooltip(row) {
    if (!row) return ""
    if (row.pricingPresentation === true) return String(row.tooltip || "")
    return "In " + usage.formatTokenCount(row.input)
      + " · out " + usage.formatTokenCount(row.output)
      + " · cache read " + usage.formatTokenCount(row.cacheRead)
      + " · cache write " + usage.formatTokenCount(row.cacheWrite)
  }

  // Only speaks up when the numbers cover more than this machine.
  function footerText(provider) {
    var remoteStatus = usage.machineStatus(root.nowMs, provider ? provider.providerId : "")
    if (remoteStatus !== "") return remoteStatus
    if (usage.syncStatusText !== "") return usage.syncStatusText
    if (provider && provider.syncEnabled && provider.syncDeviceCount > 0)
      return "Merged from " + provider.syncDeviceCount + " device" + (provider.syncDeviceCount === 1 ? "" : "s")
    return ""
  }

  function coverageText(provider) {
    if (!provider || provider.usageIncomplete !== true) return ""
    if (provider.knownUsage === false)
      return "Remote usage is unavailable. No zero usage is assumed."
    return "Known usage subtotal shown. Remote coverage is incomplete."
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

  // Nothing to report, nothing in the bar: Bar.qml collapses a slot whose item
  // is invisible, so the icon appears the moment the first scan finds usage and
  // stays away entirely on a machine that has never run either CLI.
  visible: providers.length > 0 || usage.remoteMachines.length > 0
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onProviderIndexChanged: if (panelFlick) panelFlick.contentY = 0
  onOpenedChanged: if (opened) {
    cursorActive = false
    machinesOpen = false
    focusSection = 0
    nowMs = Date.now()
    if (panelFlick) panelFlick.contentY = 0
    usage.refreshLimits()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  Main {
    id: usage
    settings: root.settings
    pricingActive: root.opened
  }

  // Cheap enough to keep running: it only re-evaluates text bindings, and a
  // stale "resets in 2h" on a panel that is open is worse than a timer.
  Timer {
    interval: 30000
    running: root.opened
    repeat: true
    onTriggered: root.nowMs = Date.now()
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refreshNow(); return "ok" }
    function next(): string { root.selectProvider(root.providerIndex + 1); return "ok" }
    function machines(): string { root.open(); root.showMachines(); return "ok" }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󱚣"
    active: root.alarming
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.launchAgent()
      else if (buttonCode === Qt.MiddleButton) root.selectProvider(root.providerIndex + 1)
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
    // Every provider shares the height of the largest fully laid-out page.
    // Only the actual screen edge limits the panel, not an arbitrary fixed cap.
    contentHeight: panel.fittedContentHeight(contentStack.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent

      blocked: root.machinesOpen && machineSettings.editing
      onMoveRequested: function(dx, dy) {
        root.cursorActive = true
        if (root.machinesOpen) { machineSettings.move(dy || dx); return }
        if (dx !== 0) {
          if (root.focusSection === 1) root.selectMachine(dx)
          else if (root.focusSection === 0) root.selectProvider(root.providerIndex + dx)
        }
        if (dy !== 0) {
          var page = root.activeProviderPage()
          var count = page ? page.detailCount : 0
          if (root.focusSection === 3) {
            var nextCursor = root.usageCursor + dy
            if (nextCursor < 0) {
              root.focusSection = 2
              root.detailsOpen = false
              root.ensureTopControlsVisible()
            } else if (nextCursor >= count) {
              root.focusSection = 0
              root.usageCursor = 0
              root.detailsOpen = false
              root.ensureTopControlsVisible()
            } else {
              root.usageCursor = nextCursor
              root.ensureUsageCursorVisible()
            }
          } else if (dy > 0 && root.focusSection === 2) {
            root.focusSection = count > 0 ? 3 : 0
            root.usageCursor = 0
            root.detailsOpen = false
            if (count > 0) root.ensureUsageCursorVisible()
          } else if (dy < 0 && root.focusSection === 0) {
            root.focusSection = count > 0 ? 3 : 2
            root.usageCursor = Math.max(0, count - 1)
            root.detailsOpen = false
            if (count > 0) root.ensureUsageCursorVisible()
          } else {
            root.focusSection = (root.focusSection + dy + 4) % 4
            root.detailsOpen = false
          }
        }
      }
      onActivateRequested: {
        if (root.machinesOpen) {
          if (machineSettings.mode === "remove") machineSettings.submit()
          else machineSettings.edit("rename")
        } else if (root.focusSection === 3) root.detailsOpen = !root.detailsOpen
        else if (root.focusSection === 2) root.showMachines()
        else root.refreshNow()
      }
      onCloseRequested: {
        if (root.machinesOpen) machineSettings.back()
        else if (root.detailsOpen) root.detailsOpen = false
        else root.close()
      }
      onTabRequested: function(direction) {
        root.switchPanel(direction)
      }
      onDeleteRequested: if (root.machinesOpen) machineSettings.removeSelected()
      onTextKey: function(t) {
        if (root.machinesOpen) {
          if (t === "n") machineSettings.edit("add")
          if (t === "e") machineSettings.edit("rename")
        } else {
          if (t === "r" || t === "R") root.refreshNow()
          if (t === ",") root.showMachines()
        }
      }

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentStack.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Item {
          id: contentStack
          width: panelFlick.width
          implicitHeight: {
            var maximum = Math.max(machineSettings.implicitHeight, emptyState.visible ? emptyState.implicitHeight : 0)
            for (var i = 0; i < providerPages.count; i++) {
              var page = providerPages.itemAt(i)
              if (page) maximum = Math.max(maximum, page.implicitHeight)
            }
            return maximum + computerBar.height + Style.space(12)
          }

          Row {
            id: computerBar
            width: parent.width
            height: Style.space(36)
            spacing: Style.space(8)
            ListView {
              id: computerList
              width: parent.width - settingsButton.width - parent.spacing
              height: parent.height
              orientation: ListView.Horizontal
              spacing: Style.space(6)
              clip: true
              model: usage.machineChoices.length
              currentIndex: root.machineIndex
              onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
              delegate: Button {
                required property int index
                width: Math.min(Style.space(160), implicitWidth)
                height: computerList.height
                text: usage.machineChoices[index].label
                selected: index === root.machineIndex
                hasCursor: !root.machinesOpen && root.focusSection === 1 && selected
                foreground: root.foreground
                fontFamily: root.fontFamily
                fontSize: Style.font.bodySmall
                onClicked: { root.focusSection = 1; usage.selectedMachineId = usage.machineChoices[index].id }
              }
            }
            Button {
              id: settingsButton
              text: "⚙"
              tooltipText: "Computers (,)"
              height: parent.height
              hasCursor: root.focusSection === 2 || root.machinesOpen
              foreground: root.foreground
              onClicked: root.showMachines()
            }
          }

          MachineSettings {
            id: machineSettings
            y: computerBar.height + Style.space(12)
            width: parent.width
            visible: root.machinesOpen
            usage: root.usageService
            foreground: root.foreground
            fontFamily: root.fontFamily
            onBackRequested: root.leaveMachines()
            onFocusRequested: keyCatcher.forceActiveFocus()
            onRevealRequested: function(item) {
              if (root.machinesOpen) root.ensureContentItemVisible(item)
            }
          }

          Text {
            id: emptyState
            textFormat: Text.PlainText
            visible: root.providers.length === 0 && !root.machinesOpen
            y: computerBar.height + Style.space(12)
            width: parent.width
            topPadding: Style.space(24)
            text: usage.remoteMachines.length ? "No usage available for this view yet.\n" + usage.machineStatus(root.nowMs)
              : "No AI coding subscriptions found.\nAgents show up here once you've used them."
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
          }

          Repeater {
            id: providerPages
            // Scope selection only changes which prepared page is active. The
            // pages themselves persist until the usage snapshot changes.
            model: usage.preparedProviderViews.length

            ProviderPage {
              required property int index
              readonly property var preparedView: usage.preparedProviderViews[index]
              width: contentStack.width
              y: computerBar.height + Style.space(12)
              scopeId: preparedView.scopeId
              provider: preparedView.provider
              providerChoices: preparedView.providers
              providerChoiceIndex: preparedView.providerIndex
              selectedPage: !root.machinesOpen && scopeId === usage.selectedMachineId
                && providerChoiceIndex === root.providerIndex
              // Hidden pages still lay out to determine the current global maximum.
              opacity: selectedPage ? 1 : 0
              enabled: selectedPage
              z: selectedPage ? 1 : 0
            }
          }
        }
      }
    }
  }

  component ProviderPage: Column {
    id: page
    property string scopeId: ""
    property var provider: null
    property var providerChoices: root.providers
    property int providerChoiceIndex: root.providerIndex
    property bool selectedPage: false
    readonly property int renderedDayCount: usageSection.visible ? dailyRowRepeater.count : 0
    readonly property int renderedModelCount: modelSection.visible ? modelRowRepeater.count : 0
    readonly property int renderedSummaryCount: modelSection.visible ? summaryRowRepeater.count : 0
    readonly property int detailCount: renderedDayCount + renderedModelCount + renderedSummaryCount
    readonly property var limits: root.limitWindows(provider)
    readonly property var balance: provider ? (provider.balance || null) : null
    readonly property bool balanceAlarming: !!balance && balance.funded > 0
      && balance.remaining / balance.funded <= 0.1
    readonly property var modelPresentation: usage.pricing.modelWindowPresentation(provider, root.nowMs)
    readonly property var models: root.providerSupportsPricing(provider) && modelPresentation.available === true
      ? root.pricedModelRows(modelPresentation.models) : root.modelRows(provider)
    readonly property var modelSummaries: root.providerSupportsPricing(provider) && modelPresentation.available === true
      ? root.pricedSummaryRows(modelPresentation.summaries) : []
    readonly property var pricedDailyRows: usage.pricing.dailyRows(provider, root.nowMs)
    readonly property string limitationText: root.pricingLimitationText(provider, pricedDailyRows, modelPresentation)
    function detailItemAt(index) {
      if (index < renderedDayCount) return dailyRowRepeater.itemAt(index)
      index -= renderedDayCount
      if (index < renderedModelCount) return modelRowRepeater.itemAt(index)
      index -= renderedModelCount
      return index < renderedSummaryCount ? summaryRowRepeater.itemAt(index) : null
    }
    spacing: Style.space(12)

    // ---------- Hero: provider mark · name · plan ----------
    PanelHero {
      id: hero
      visible: !!page.provider
      width: parent.width
      title: page.provider ? page.provider.providerName : ""
      meta: root.heroMeta(page.provider)
      foreground: root.foreground
      fontFamily: root.fontFamily

      iconComponent: Component {
        Item {
          id: heroMark
          property var candidates: root.iconCandidatesForProvider(page.provider, root.surface)
          // Provider objects are rebuilt on every refresh, which churns the
          // array's identity without changing its content. Restart the fallback
          // walk only when the URLs change: re-pointing source at a URL whose
          // load already failed emits no statusChanged, so an identity-only
          // reset would strand the walker on a missing -light twin.
          property string candidatesKey: candidates.join("\n")
          property int candidateIndex: 0
          onCandidatesKeyChanged: candidateIndex = 0

          width: Style.font.display
          height: Style.font.display

          Image {
            id: heroMarkImage
            anchors.fill: parent
            source: heroMark.candidateIndex < heroMark.candidates.length ? heroMark.candidates[heroMark.candidateIndex] : ""
            sourceSize.width: Style.font.display * 2
            sourceSize.height: Style.font.display * 2
            fillMode: Image.PreserveAspectFit
            // Advancing source from inside its own status change trips the
            // binding-loop detector; defer the step one tick.
            onStatusChanged: if (status === Image.Error && heroMark.candidateIndex < heroMark.candidates.length)
              Qt.callLater(function() { heroMark.candidateIndex++ })
          }

          Text {
            textFormat: Text.PlainText
            anchors.centerIn: parent
            visible: heroMarkImage.status !== Image.Ready
            text: button.text
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.display
          }
        }
      }
    }

    // ---------- Provider switch ----------
    Row {
      id: providerSwitch
      visible: page.providerChoices.length > 1
      width: parent.width
      spacing: Style.spacing.md

      readonly property real cellWidth: page.providerChoices.length > 0
        ? (width - spacing * (page.providerChoices.length - 1)) / page.providerChoices.length
        : 0

      Repeater {
        // Tab labels need only an index, never the complete usage records.
        model: page.providerChoices.length

        Button {
          required property int index

          width: providerSwitch.cellWidth
          text: page.providerChoices[index].providerName
          selected: index === page.providerChoiceIndex
          hasCursor: page.selectedPage && root.cursorActive && root.focusSection === 0 && selected
          bordered: true
          foreground: root.foreground
          fontFamily: root.fontFamily
          fontSize: Style.font.bodySmall
          verticalPadding: Style.spacing.controlPaddingY
          onClicked: {
            root.cursorActive = true
            root.selectProvider(index)
          }
          onHovered: function(isHovered) { if (isHovered) root.cursorActive = true }
        }
      }
    }

    // ---------- Status ----------
    BorderSurface {
      visible: !!page.provider && String(page.provider.usageStatusText || "") !== ""
      width: parent.width
      implicitHeight: statusText.implicitHeight + Style.spacing.xl * 2
      color: root.alpha(root.urgent, 0.10)
      borderSpec: Border.flat(root.alpha(root.urgent, 0.35), 1)
      radius: Style.cornerRadius

      Text {
        id: statusText
        textFormat: Text.PlainText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Style.space(12)
        anchors.rightMargin: Style.space(12)
        text: page.provider ? String(page.provider.authHelpText || "") : ""
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }
    }

    // ---------- Balance / limits ----------
    PanelSeparator {
      visible: balanceSection.visible || limitsSection.visible
      foreground: root.foreground
    }

    Column {
      id: balanceSection
      visible: !!page.balance
      width: parent.width
      spacing: Style.space(10)

      // The meter shows what is left, not what is used: a prepaid
      // account drains toward empty rather than filling toward a cap.
      readonly property real ratio: page.balance && page.balance.funded > 0
        ? root.clamp(page.balance.remaining / page.balance.funded, 0, 1)
        : -1

      PanelSectionHeader {
        width: parent.width
        text: "BALANCE"
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      Item {
        width: parent.width
        implicitHeight: Math.max(balanceLabel.implicitHeight, balanceValue.implicitHeight)

        Text {
          id: balanceLabel
          text: "Prepaid credits"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          id: balanceValue
          textFormat: Text.PlainText
          text: page.balance ? root.formatMoney(page.balance.remaining, page.balance.currency) : ""
          color: page.balanceAlarming ? root.urgent : root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      Meter {
        visible: balanceSection.ratio >= 0
        width: parent.width
        value: balanceSection.ratio
        alarming: page.balanceAlarming
      }

      Text {
        textFormat: Text.PlainText
        visible: text !== ""
        width: parent.width
        text: root.balanceDetailText(page.balance)
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    Column {
      id: limitsSection
      visible: page.limits.length > 0
      width: parent.width
      spacing: Style.space(10)

      PanelSectionHeader {
        text: "LIMITS · LOCAL ACCOUNT"
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      Repeater {
        model: page.limits

        LimitRow {
          required property var modelData
          width: limitsSection.width
          window: modelData
        }
      }
    }

    Text {
      visible: text !== ""
      width: parent.width
      text: root.coverageText(page.provider)
      textFormat: Text.PlainText
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WordWrap
    }

    // ---------- Usage ----------
    PanelSeparator {
      visible: usageSection.visible
      foreground: root.foreground
    }

    Column {
      id: usageSection
      visible: !!page.provider && page.provider.knownUsage !== false
        && !!page.provider.recentDays && page.provider.recentDays.length > 0
      width: parent.width
      spacing: Style.spacing.md

      readonly property var days: root.providerSupportsPricing(page.provider)
        ? page.pricedDailyRows
        : (page.provider ? (page.provider.recentDays || []) : [])
      readonly property real peak: Math.max(1, root.weekPeak(days))

      PanelSectionHeader {
        width: parent.width
        text: usage.pricing.dailyHeading(page.provider, usageSection.days)
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      Repeater {
        id: dailyRowRepeater
        model: usageSection.days

        DayRow {
          required property var modelData
          required property int index

          width: usageSection.width
          tooltipAllowed: page.selectedPage
          cursorIndex: index
          day: modelData
          ratio: Number(modelData.messageCount || modelData.tokens || 0) / usageSection.peak
          // By date, not by position: the Claude stats-cache fallback can
          // hand us a window that stops short of today.
          today: String(modelData.date || "") === root.todayDate()
        }
      }

      Text {
        visible: page.limitationText !== ""
        width: parent.width
        text: page.limitationText
        textFormat: Text.PlainText
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }
    }

    // ---------- Models ----------
    PanelSeparator {
      visible: modelSection.visible
      foreground: root.foreground
    }

    Column {
      id: modelSection
      visible: !!page.provider && page.provider.knownUsage !== false && page.models.length > 0
      width: parent.width
      spacing: Style.spacing.md

      PanelSectionHeader {
        width: parent.width
        text: root.providerSupportsPricing(page.provider)
          && page.modelPresentation.available === true
          ? "TOKENS / KNOWN API COST EST. BY MODEL (30 DAYS)" : "TOKENS BY MODEL"
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      Repeater {
        id: modelRowRepeater
        model: page.models

        ModelRow {
          required property var modelData
          required property int index
          tooltipAllowed: page.selectedPage
          cursorIndex: page.renderedDayCount + index
          width: modelSection.width
          row: modelData
          // Scaled to the heaviest model, so the top row is always full —
          // the same scale-to-peak the weekly chart uses for its busiest day.
          share: modelData.total / Math.max(1, page.models[0].total)
        }
      }

      Repeater {
        id: summaryRowRepeater
        model: page.modelSummaries

        ModelRow {
          required property var modelData
          required property int index
          tooltipAllowed: page.selectedPage
          cursorIndex: page.renderedDayCount + page.renderedModelCount + index
          width: modelSection.width
          row: modelData
          share: 0
          summary: true
        }
      }

    }

    Text {
      textFormat: Text.PlainText
      visible: text !== ""
      width: parent.width
      topPadding: Style.space(2)
      text: root.footerText(page.provider)
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
    }
  }

  // A limit window: label and percentage, meter, and reset countdown.
  component LimitRow: Column {
    id: limitRow
    property var window: null

    readonly property bool alarming: window && window.percent >= 0.9

    spacing: Style.space(6)

    Item {
      width: parent.width
      implicitHeight: Math.max(limitLabel.implicitHeight, limitValue.implicitHeight)

      Text {
        id: limitLabel
        textFormat: Text.PlainText
        // A model-scoped window is titled after its model, and those names run
        // long enough to reach the percentage, so the title gives way first.
        text: limitRow.window ? limitRow.window.title : ""
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
        anchors.left: parent.left
        anchors.right: limitValue.left
        anchors.rightMargin: Style.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        id: limitValue
        textFormat: Text.PlainText
        text: limitRow.window && limitRow.window.percent >= 0
          ? Math.round(limitRow.window.percent * 100) + "%"
          : "—"
        color: limitRow.alarming ? root.urgent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    Meter {
      width: parent.width
      value: limitRow.window ? limitRow.window.percent : -1
      alarming: limitRow.alarming
    }

    Text {
      id: resetText
      textFormat: Text.PlainText
      width: parent.width
      text: {
        var remainingMs = root.resetMsFor(limitRow.window)
        return remainingMs > 0 ? "Resets in " + root.formatDuration(remainingMs) : ""
      }
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }
  }

  // Rounded track showing the percentage of the allowance used.
  component Meter: Item {
    id: meter
    property real value: -1
    property bool alarming: false
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
      color: meter.alarming ? root.urgent : root.foreground

      Behavior on width {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
      }
    }

  }

  // Reserve independent columns so digit changes never move tokens or costs.
  // Font metrics keep the same capacity when the configured monospace font scales.
  component UsageValue: Item {
    id: valueColumns
    property string text: ""
    property color color: root.dim
    readonly property var parts: text.split("/")
    readonly property bool priced: parts.length > 1

    implicitWidth: tokenMeasure.advanceWidth + (priced
      ? separator.implicitWidth + Style.space(8) + moneyMeasure.advanceWidth : 0)
    implicitHeight: tokens.implicitHeight

    TextMetrics {
      id: tokenMeasure
      font: tokens.font
      text: "99999.9M"
    }
    TextMetrics {
      id: moneyMeasure
      font: tokens.font
      text: "$99999.9999"
    }

    Text {
      id: tokens
      text: valueColumns.parts[0]
      textFormat: Text.PlainText
      color: valueColumns.color
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      font.bold: true
      width: tokenMeasure.advanceWidth
      horizontalAlignment: Text.AlignRight
      anchors.verticalCenter: parent.verticalCenter
    }
    Text {
      id: separator
      visible: valueColumns.priced
      text: "/"
      color: valueColumns.color
      font: tokens.font
      anchors.left: tokens.right
      anchors.leftMargin: Style.space(4)
      anchors.verticalCenter: parent.verticalCenter
    }
    Text {
      id: money
      visible: valueColumns.priced
      text: valueColumns.priced ? valueColumns.parts[1] : ""
      textFormat: Text.PlainText
      color: valueColumns.color
      font: tokens.font
      width: moneyMeasure.advanceWidth
      horizontalAlignment: Text.AlignRight
      anchors.left: separator.right
      anchors.leftMargin: Style.space(4)
      anchors.verticalCenter: parent.verticalCenter
    }

  }

  // One row per day: label, bar, tokens. Today is picked out in full
  // foreground so the week reads as a run-up to right now.
  component DayRow: Item {
    id: dayRow
    property bool tooltipAllowed: true
    property int cursorIndex: -1
    property var day: null
    property real ratio: 0
    property bool today: false

    Rectangle {
      anchors.fill: parent
      color: "transparent"
      border.color: root.foreground
      border.width: 1
      visible: dayRow.tooltipAllowed && root.focusSection === 3 && root.usageCursor === dayRow.cursorIndex
    }

    implicitHeight: Math.max(dayLabel.implicitHeight, dayValue.implicitHeight) + Style.spacing.sm

    Text {
      id: dayLabel
      textFormat: Text.PlainText
      text: root.dayLabel(dayRow.day ? dayRow.day.date : "", dayRow.today)
      color: dayRow.today ? root.foreground : root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: dayRow.today
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(52)
    }

    Rectangle {
      id: dayTrack
      anchors.left: dayLabel.right
      anchors.right: dayValue.left
      anchors.leftMargin: Style.space(8)
      anchors.rightMargin: Style.space(10)
      anchors.verticalCenter: parent.verticalCenter
      height: Math.max(Style.space(4), Math.round(Style.spacing.controlHeight * 0.14))
      radius: height / 2
      color: root.track

      Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        radius: parent.radius
        width: parent.width * root.clamp(dayRow.ratio, 0, 1)
        color: dayRow.today ? root.foreground : root.alpha(root.foreground, 0.55)

        Behavior on width {
          NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
      }
    }

    UsageValue {
      id: dayValue
      text: dayRow.day && dayRow.day.value
        ? dayRow.day.value
        : usage.formatTokenCount(dayRow.day ? Number(dayRow.day.messageCount || 0) : 0)
      color: dayRow.today ? root.foreground : root.dim
      anchors.right: parent.right
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      width: implicitWidth
    }

    MouseArea {
      id: dayHover
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
    }

    PanelToolTip {
      visible: root.opened && !root.machinesOpen && dayRow.tooltipAllowed
        && (dayHover.containsMouse || root.focusSection === 3 && root.detailsOpen && root.usageCursor === dayRow.cursorIndex)
      text: root.dayTooltip(dayRow.day, dayRow.today)
      fontFamily: root.fontFamily
    }
  }

  // Model rows read as a table: the share bar fills the row behind the label
  // instead of stacking under it, which keeps the whole dashboard on one screen.
  component ModelRow: Item {
    id: modelRow
    property bool tooltipAllowed: true
    property int cursorIndex: -1
    property var row: null
    property real share: 0
    property bool summary: false

    Rectangle {
      anchors.fill: parent
      color: "transparent"
      border.color: root.foreground
      border.width: 1
      visible: modelRow.tooltipAllowed && root.focusSection === 3 && root.usageCursor === modelRow.cursorIndex
    }

    implicitHeight: modelName.implicitHeight + Style.spacing.lg

    Rectangle {
      anchors.fill: parent
      radius: Style.cornerRadius
      color: root.alpha(root.foreground, modelRow.summary ? 0.09 : 0.05)
    }

    Rectangle {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: parent.width * root.clamp(modelRow.share, 0, 1)
      radius: Style.cornerRadius
      color: root.alpha(root.foreground, 0.14)

      Behavior on width {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
      }
    }

    Text {
      id: modelName
      textFormat: Text.PlainText
      text: modelRow.row ? modelRow.row.name : ""
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
      anchors.left: parent.left
      anchors.leftMargin: Style.space(8)
      anchors.right: modelTokens.left
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
    }

    UsageValue {
      id: modelTokens
      text: modelRow.row
        ? (modelRow.row.pricingPresentation === true ? modelRow.row.value
          : usage.formatTokenCount(modelRow.row.total))
        : ""
      color: root.dim
      anchors.right: parent.right
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      width: implicitWidth
    }

    MouseArea {
      id: modelHover
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
    }

    PanelToolTip {
      visible: root.opened && !root.machinesOpen && modelRow.tooltipAllowed
        && (modelHover.containsMouse || root.focusSection === 3 && root.detailsOpen && root.usageCursor === modelRow.cursorIndex)
      text: root.modelTooltip(modelRow.row)
      fontFamily: root.fontFamily
    }
  }
}
