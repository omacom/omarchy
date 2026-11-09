import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omarchy.power"
  ipcTarget: "omarchy.power"
  // manageIpc: false so this panel can own the single IpcHandler the target
  // permits — needed for the togglePercentage method below.
  manageIpc: false
  property var batteryInfo: ({})
  property var systemInfo: ({})
  property var profiles: []
  property string activeProfile: ""
  property int profileIndex: 0
  property bool cursorActive: false
  // Which row the keyboard cursor is on: the history window chips above, or
  // the power profiles below.
  property string cursorRow: "profiles"
  property int windowIndex: 0
  readonly property var historyWindowKeys: ["6h", "24h", "3d"]
  readonly property bool showPercentage: setting("showPercentage", false) === true
  // With the percentage shown the button paints a text block wider than an
  // icon, so the open-panel mark takes the painted width instead of the
  // icon-sized fraction of the slot the fallback assumes.
  readonly property real openPanelIndicatorWidth: showPercentage && !button.vertical ? button.glyphPaintedWidth : 0
  // ---------- Battery history ----------
  // UPower's charge and rate history, drawn as a graph with the stretches on
  // AC and asleep marked, plus the last charge, the last run on battery and
  // the average drain. The battery service reads and keeps it, once for every
  // monitor; the panel asks it to refresh on opening and once a minute while
  // open. Without the service (a clone gets none) there is no history section.
  readonly property var batteryService: bar?.shell?.firstPartyServiceFor("omarchy.battery") ?? null

  readonly property string historyWindow: {
    var w = String(setting("historyWindow", "24h"))
    return historyWindowKeys.indexOf(w) >= 0 ? w : "24h"
  }
  // The service's figures for the chosen window: { start, span, points, runs, drain }.
  readonly property var historyView: batteryService && batteryService.historyWindows ? (batteryService.historyWindows[historyWindow] || null) : null
  readonly property var historyTimeline: batteryService && batteryService.historyTimeline ? batteryService.historyTimeline : ({ segments: [], sleeps: [] })
  readonly property real historyNow: batteryService ? batteryService.historyNow : 0
  readonly property bool historyReady: !!historyView && Array.isArray(historyView.points) && historyView.points.length > 0
  readonly property real historySpan: historyReady ? historyView.span : 0
  readonly property real historyStart: historyReady ? historyView.start : 0
  readonly property var historyPoints: historyReady ? historyView.points : []
  readonly property var historyRuns: historyReady && Array.isArray(historyView.runs) ? historyView.runs : []
  readonly property var lastCharge: historyReady && batteryService ? batteryService.historyLastCharge : null
  readonly property var lastBattery: historyReady && batteryService ? batteryService.historyLastBattery : null
  readonly property var drain: historyReady ? historyView.drain : null

  // The charge at time t on the graph: the last point at or before it.
  function chargeAt(t) {
    var pts = historyPoints
    if (!pts.length) return -1
    var v = pts[0].v
    for (var i = 0; i < pts.length && pts[i].t <= t; i++) v = pts[i].v
    return v
  }

  function refreshHistory() {
    if (batteryService) batteryService.refreshHistory()
  }

  function setHistoryWindow(w) {
    if (historyWindowKeys.indexOf(w) < 0 || w === historyWindow) return
    root.settings = Object.assign({}, root.settings, { historyWindow: w })
    if (root.bar && root.bar.shell) root.bar.shell.updateEntryInline(root.moduleName, root.settings)
  }

  function locale() { return Qt.locale(Commons.I18n.formatLocale) }

  // The time alone for today, the short weekday and time before that: it has
  // to fit beside its label in half the panel.
  function whenText(t) {
    if (!(t > 0)) return "—"
    var d = new Date(t * 1000)
    var time = d.toLocaleTimeString(locale(), Locale.ShortFormat)
    var today = new Date(); today.setHours(0, 0, 0, 0)
    if (d >= today) return time
    return d.toLocaleDateString(locale(), "ddd") + " " + time
  }


  function durationText(sec) {
    if (!(sec >= 0)) return "—"
    var minutes = Math.round(sec / 60)
    var h = Math.floor(minutes / 60), m = minutes % 60
    if (h === 0) return Commons.I18n.t("power.historyMinutes").arg(Commons.I18n.formatNumber(m))
    return Commons.I18n.t("power.historyHoursMinutes").arg(Commons.I18n.formatNumber(h)).arg(Commons.I18n.formatNumber(m))
  }

  function pct(v) { return v >= 0 ? Commons.I18n.t("power.historyPercent").arg(Commons.I18n.formatNumber(Math.round(v))) : "—" }

  function rangeText(session) {
    if (!session) return "—"
    return Commons.I18n.t("power.historyRange").arg(pct(session.fromPct)).arg(pct(session.toPct))
  }

  function wattsText(w) { return w > 0 ? Commons.I18n.t("power.historyWatts").arg(Commons.I18n.formatNumber(w, 1)) : "—" }

  // What the machine was doing at time t: "ac", "battery" or "asleep".
  function stateAt(t) {
    var sl = historyTimeline.sleeps
    for (var i = 0; i < sl.length; i++) if (t >= sl[i].start && t <= sl[i].end) return sl[i].charged ? "asleepCharging" : "asleep"
    var segs = historyTimeline.segments
    for (var j = segs.length - 1; j >= 0; j--) if (t >= segs[j].start) return segs[j].source
    return ""
  }

  function stateLabel(state) {
    if (state === "ac") return Commons.I18n.t("power.historyLegendCharging")
    if (state === "battery") return Commons.I18n.t("power.historyLegendBattery")
    if (state === "asleep") return Commons.I18n.t("power.historyLegendAsleep")
    if (state === "asleepCharging") return Commons.I18n.t("power.historyAsleepCharging")
    return ""
  }

  readonly property bool batteryPresent: {
    var device = UPower.displayDevice
    return !!(device && device.isPresent)
  }

  function upowerStates() {
    return {
      Charging: UPowerDeviceState.Charging,
      Discharging: UPowerDeviceState.Discharging,
      FullyCharged: UPowerDeviceState.FullyCharged,
      PendingCharge: UPowerDeviceState.PendingCharge
    }
  }

  function selectProfileByDelta(delta) {
    profileIndex = Model.selectProfileIndex(profileIndex, delta, profiles)
  }

  function activateSelectedProfile() {
    if (profileIndex < 0 || profileIndex >= profiles.length) return
    setProfile(profiles[profileIndex])
  }

  function batteryIcon() {
    var device = UPower.displayDevice
    return Model.batteryIcon(device, root.discharging, upowerStates())
  }

  function modeLabel() {
    var device = UPower.displayDevice
    return Model.modeLabel(device, root.discharging, upowerStates(), Commons.I18n.t)
  }

  function profileIcon(name) {
    return Model.profileIcon(name)
  }

  readonly property bool fullyCharged: {
    var device = UPower.displayDevice
    return device && device.isPresent && device.state === UPowerDeviceState.FullyCharged && !root.chargeThresholdActive
  }
  readonly property bool discharging: {
    var device = UPower.displayDevice
    return !!(device && device.isPresent && UPower.onBattery)
  }
  readonly property bool chargeThresholdActive: {
    var device = UPower.displayDevice
    return Model.chargeThresholdActive(device, root.discharging, upowerStates())
  }
  readonly property bool batteryFull: fullyCharged || (!root.discharging && batteryFraction >= 1)
  readonly property bool batteryFlowIdle: batteryFull || chargeThresholdActive

  // 0..1 charge level, used by the visual progress bar.
  readonly property real batteryFraction: {
    var d = UPower.displayDevice
    return Model.batteryFraction(d)
  }

  readonly property bool charging: {
    var d = UPower.displayDevice
    return d && d.isPresent && !UPower.onBattery && !root.batteryFlowIdle
  }

  readonly property color batteryFillColor: {
    return root.bar ? root.bar.foreground : Commons.Color.foreground
  }

  // Cute agent-flavored phrases shown in the hero status line, rotated on a
  // timer so the panel feels alive when current is flowing (either direction).
  readonly property var chargingPhrases: [
    Commons.I18n.t("power.chargingPhrase1"),
    Commons.I18n.t("power.chargingPhrase2"),
    Commons.I18n.t("power.chargingPhrase3"),
    Commons.I18n.t("power.chargingPhrase4"),
    Commons.I18n.t("power.chargingPhrase5"),
    Commons.I18n.t("power.chargingPhrase6"),
    Commons.I18n.t("power.chargingPhrase7"),
    Commons.I18n.t("power.chargingPhrase8"),
    Commons.I18n.t("power.chargingPhrase9")
  ]
  readonly property var onBatteryPhrases: [
    Commons.I18n.t("power.dischargingPhrase1"),
    Commons.I18n.t("power.dischargingPhrase2"),
    Commons.I18n.t("power.dischargingPhrase3"),
    Commons.I18n.t("power.dischargingPhrase4"),
    Commons.I18n.t("power.dischargingPhrase5"),
    Commons.I18n.t("power.dischargingPhrase6"),
    Commons.I18n.t("power.dischargingPhrase7"),
    Commons.I18n.t("power.dischargingPhrase8"),
    Commons.I18n.t("power.dischargingPhrase9")
  ]
  property int phraseIndex: 0

  // Whichever list is "active" given the current power state.
  readonly property var activePhrases: {
    if (fullyCharged) return []
    if (charging) return chargingPhrases
    if (discharging) return onBatteryPhrases
    return []
  }
  readonly property bool rotatingPhrases: activePhrases.length > 0

  // The battery script's readings in the current language's digits; the
  // time field already comes translated, so it is shown as it arrives.
  function reading(raw) {
    return Model.localizeReading(raw, Commons.I18n.formatNumber)
  }

  readonly property string heroStatusText: {
    if (fullyCharged) return Commons.I18n.t("power.fullyCharged")
    if (rotatingPhrases) return activePhrases[phraseIndex % activePhrases.length]
    return modeLabel()
  }

  function refresh() {
    if (!batteryPresent) return

    if (!batteryProc.running) batteryProc.running = true
    if (!profilesProc.running) profilesProc.running = true
    if (!systemProc.running) systemProc.running = true
  }

  function updateKeyValue(raw, targetName) {
    var next = Model.parseKeyValue(raw)
    // Keep last known good data if a refresh briefly returns nothing — happens
    // around AC plug/unplug events. Avoids the section collapsing mid-transition.
    if (Object.keys(next).length === 0) return
    if (targetName === "battery") batteryInfo = next
    else systemInfo = next
  }

  function updateProfiles(raw) {
    var parsed = Model.parseProfiles(raw, profileIndex)
    // Same guard as battery: preserve the last known profile list across
    // transient empty payloads so the buttons don't blink out.
    if (parsed.profiles.length === 0) return
    profiles = parsed.profiles
    activeProfile = parsed.activeProfile
    profileIndex = parsed.profileIndex
    if (opened && !cursorActive) {
      var idx = profiles.indexOf(activeProfile)
      if (idx >= 0) profileIndex = idx
    }
  }

  function setProfile(profile) {
    if (!profile || actionProc.running) return
    actionProc.command = ["omarchy-powerprofiles-set", root.discharging ? "battery" : "ac", profile]
    actionProc.running = true
  }

  function togglePercentage() {
    root.settings = Object.assign({}, root.settings, { showPercentage: !root.showPercentage })
    if (root.bar && root.bar.shell) root.bar.shell.updateEntryInline(root.moduleName, root.settings)
  }

  ShellIpc {
    target: "omarchy.power"

    function open() { root.open() }
    function close() { root.close() }
    function show() { root.open() }
    function hide() { root.close() }
    function toggle() { root.toggle() }
    function togglePercentage() { root.togglePercentage() }
  }

  onOpenedChanged: {
    if (opened) {
      if (!batteryPresent) {
        // Deferred: closing here writes the very property whose change
        // is being notified, which QML reports as a binding loop for
        // Panel.opened on every open attempt without a battery.
        Qt.callLater(function() { root.close() })
        return
      }

      refresh()
      refreshHistory()
      var idx = profiles.indexOf(activeProfile)
      profileIndex = idx >= 0 ? idx : 0
      cursorActive = false
      cursorRow = "profiles"
    }
  }

  onBatteryPresentChanged: if (!batteryPresent) close()

  visible: batteryPresent
  implicitWidth: batteryPresent ? button.implicitWidth : 0
  implicitHeight: batteryPresent ? button.implicitHeight : 0

  Process {
    id: batteryProc
    command: ["omarchy-battery-status", "--shell"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.updateKeyValue(text, "battery") }
  }

  Process {
    id: profilesProc
    command: ["omarchy-powerprofiles-list", "--active-state"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.updateProfiles(text) }
  }

  Process {
    id: systemProc
    command: ["omarchy-system-stats"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.updateKeyValue(text, "system") }
  }

  Process {
    id: actionProc
    onExited: root.refresh()
  }

  Timer { interval: 5000; running: root.opened; repeat: true; onTriggered: root.refresh() }
  Timer { interval: 60000; running: root.opened; repeat: true; onTriggered: root.refreshHistory() }

  // Rotate the status phrase while the panel is open and we're in a
  // rotating state (charging or on battery). The text swap is wrapped in a
  // fade so the changeover reads as one organism rather than a hard cut.
  Timer {
    id: phraseTimer
    interval: 2800
    running: root.opened && root.rotatingPhrases
    repeat: true
    triggeredOnStart: false
    onTriggered: phraseSwap.restart()
  }

  SequentialAnimation {
    id: phraseSwap
    PropertyAnimation {
      target: panel.loadedContent ? panel.loadedContent.heroStatus : null; property: "opacity"
      to: 0.0; duration: Style.duration(150); easing.type: Easing.OutCubic
    }
    ScriptAction {
      script: {
        var n = root.activePhrases.length
        if (n > 0) root.phraseIndex = (root.phraseIndex + 1) % n
      }
    }
    PropertyAnimation {
      target: panel.loadedContent ? panel.loadedContent.heroStatus : null; property: "opacity"
      to: 1.0; duration: Style.duration(200); easing.type: Easing.OutCubic
    }
  }

  // If we leave a rotating state mid-swap, halt the animation and snap back
  // to full opacity so "FULLY CHARGED" is legible immediately rather than
  // appearing dimmed.
  Connections {
    target: root
    function onRotatingPhrasesChanged() {
      if (!root.rotatingPhrases) {
        phraseSwap.stop()
        if (panel.loadedContent) panel.loadedContent.heroStatus.opacity = 1.0
      }
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.batteryIcon()
    labelText: root.showPercentage && !vertical ? Commons.I18n.formatNumber(Math.round(root.batteryFraction * 100)) + "%" : ""
    slotSize: Style.bar.iconSlot * (root.showPercentage && !vertical ? 2 : 1)
    tooltipText: ""
    onPressed: function(b) {
      if (!root.batteryPresent) return
      if (b === Qt.RightButton) root.togglePercentage()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened && root.batteryPresent
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias heroStatus: heroStatus
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        if (dy !== 0 && root.historyReady) {
          if (dy < 0 && root.cursorRow === "profiles") {
            root.cursorRow = "history"
            root.windowIndex = Math.max(0, root.historyWindowKeys.indexOf(root.historyWindow))
          } else if (dy > 0 && root.cursorRow === "history") {
            root.cursorRow = "profiles"
          }
          return
        }
        var delta = dx !== 0 ? dx : dy
        if (root.cursorRow === "history") root.windowIndex = Math.max(0, Math.min(root.historyWindowKeys.length - 1, root.windowIndex + delta))
        else root.selectProfileByDelta(delta)
      }
      onActivateRequested: {
        if (!root.cursorActive) return
        if (root.cursorRow === "history") root.setHistoryWindow(root.historyWindowKeys[root.windowIndex])
        else root.activateSelectedProfile()
      }
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        // ---------- Hero: battery icon · title/status · percentage ----------
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, heroPercent.implicitHeight)

          Text {
            id: heroIcon
            textFormat: Text.PlainText
            text: root.batteryIcon()
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: Style.duration(200) } }
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: heroPercent.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: Commons.I18n.t("power.battery")
              textFormat: Text.PlainText
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              id: heroStatus
              textFormat: Text.PlainText
              text: root.heroStatusText.toUpperCase()
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight
              width: parent.width
            }
          }

          Text {
            id: heroPercent
            textFormat: Text.PlainText
            text: root.reading(root.batteryInfo.percentage) || "—"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.displayLarge
            font.bold: true
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: Style.duration(200) } }
          }
        }

        // ---------- Battery progress bar ----------
        Item {
          width: parent.width
          implicitHeight: Style.space(8)

          Rectangle {
            id: barTrack
            anchors.fill: parent
            radius: height / 2
            color: Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.12)
          }

          Rectangle {
            id: barFill
            anchors.left: barTrack.left
            anchors.verticalCenter: barTrack.verticalCenter
            height: barTrack.height
            radius: barTrack.radius
            color: root.batteryFillColor
            width: Math.max(barTrack.height, barTrack.width * root.batteryFraction)

            Behavior on width { NumberAnimation { duration: Style.duration(320); easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: Style.duration(220) } }

            // Subtle pulse while charging — visible signal that energy is flowing in.
            SequentialAnimation on opacity {
              running: root.charging && !root.fullyCharged && root.opened && !Style.reduceMotion
              loops: Animation.Infinite
              alwaysRunToEnd: true
              NumberAnimation { from: 1.0; to: 0.55; duration: Style.duration(950); easing.type: Easing.InOutSine }
              NumberAnimation { from: 0.55; to: 1.0; duration: Style.duration(950); easing.type: Easing.InOutSine }
            }
          }
        }

        // ---------- Stats ----------
        // Visibility is intentionally only gated by "we've ever loaded data" so
        // the section never collapses mid-transition. fullyCharged is *not* part
        // of the condition: UPower briefly reports FullyCharged on plug-in when
        // the battery sits above the charge-control start threshold, and we
        // refuse to flicker the whole panel for that ~1s window.
        Row {
          visible: root.batteryInfo.percentage !== undefined
          width: parent.width
          spacing: Style.space(20)

          Column {
            width: (parent.width - parent.spacing) / 2
            spacing: Style.spacing.labelGap
            InfoPair { label: Commons.I18n.t("power.batterySize"); value: root.reading(root.batteryInfo.size) }
            InfoPair { label: Commons.I18n.t("power.chargeCycles"); value: root.reading(root.batteryInfo.cycles) || "—" }
          }

          Column {
            width: (parent.width - parent.spacing) / 2
            spacing: Style.spacing.labelGap
            InfoPair {
              label: root.chargeThresholdActive ? Commons.I18n.t("power.chargeLimit") : (root.discharging ? Commons.I18n.t("power.timeLeft") : Commons.I18n.t("power.timeToFull"))
              value: root.chargeThresholdActive ? (root.reading(root.batteryInfo.threshold) || "-") : (root.batteryFlowIdle ? "-" : (root.batteryInfo.time || "—"))
            }
            InfoPair {
              label: root.chargeThresholdActive ? Commons.I18n.t("power.batteryState") : (root.discharging ? Commons.I18n.t("power.discharging") : Commons.I18n.t("power.charging"))
              value: root.chargeThresholdActive ? Commons.I18n.t("power.holding") : (root.batteryFull ? "-" : root.reading(root.batteryInfo.rate))
            }
          }
        }

        // ---------- Battery history ----------
        PanelSeparator {
          visible: root.historyReady
          foreground: root.bar.foreground
        }

        Column {
          id: historySection
          visible: root.historyReady
          width: parent.width
          spacing: Style.space(10)

          Item {
            width: parent.width
            implicitHeight: Math.max(historyHeader.implicitHeight, windowPicker.implicitHeight)

            PanelSectionHeader {
              id: historyHeader
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              text: Commons.I18n.t("power.historyTitle")
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
            }

            ButtonGroup {
              id: windowPicker
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(4)
              focusable: false
              cursorIndex: root.cursorActive && root.cursorRow === "history" ? root.windowIndex : -1
              onHovered: function(index, isHovered) {
                if (!isHovered) return
                root.cursorActive = true
                root.cursorRow = "history"
                root.windowIndex = index
              }
              // Same order as historyWindowKeys, which the keyboard cursor walks.
              options: [
                { value: "6h", label: Commons.I18n.t("power.historyWindow6h") },
                { value: "24h", label: Commons.I18n.t("power.historyWindow24h") },
                { value: "3d", label: Commons.I18n.t("power.historyWindow3d") }
              ]
              value: root.historyWindow
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              fontSize: Style.font.caption
              onChanged: function(v) { root.setHistoryWindow(v) }
            }
          }

          // Charge over the window: the line and the area under it, with
          // the stretches on AC tinted in the accent and the ones asleep
          // shaded. Hovering reads out the time, level and state.
          Item {
            id: graphBox
            width: parent.width
            height: Style.space(96)
            property real hoverX: -1
            // Time runs with the reading direction: oldest at the start
            // edge, now at the end, as the labels under the graph say.
            readonly property bool mirrored: LayoutMirroring.enabled
            readonly property real hoverT: hoverX < 0 ? -1 : root.historyStart + root.historySpan * (mirrored ? width - hoverX : hoverX) / width

            function rgba(c, a) {
              return "rgba(" + Math.round(c.r * 255) + "," + Math.round(c.g * 255) + "," + Math.round(c.b * 255) + "," + a + ")"
            }

            Canvas {
              id: graph
              anchors.fill: parent
              antialiasing: true

              readonly property var deps: [root.historyPoints, root.historyRuns, root.historyTimeline, root.bar.foreground, Commons.Color.accent, graphBox.hoverX, graphBox.mirrored, width, height]
              onDepsChanged: requestPaint()

              onPaint: {
                var ctx = getContext("2d")
                var w = width, h = height
                ctx.reset()
                ctx.clearRect(0, 0, w, h)
                var pts = root.historyPoints
                if (pts.length < 2 || root.historySpan <= 0) return

                var fg = root.bar.foreground, accent = Commons.Color.accent
                var t0 = root.historyStart, span = root.historySpan
                var pad = 2
                function x(t) {
                  var px = Math.max(0, Math.min(w, (t - t0) / span * w))
                  return graphBox.mirrored ? w - px : px
                }
                function band(a, b) {
                  var l = Math.min(x(a), x(b)), r = Math.max(x(a), x(b))
                  ctx.fillRect(l, 0, Math.max(1, r - l), h)
                }
                function y(v) { return pad + (h - 2 * pad) * (1 - v / 100) }

                // Grid at 0, 50 and 100%.
                ctx.strokeStyle = graphBox.rgba(fg, 0.10)
                ctx.lineWidth = 1
                ;[0, 50, 100].forEach(function(v) {
                  ctx.beginPath(); ctx.moveTo(0, Math.round(y(v)) + 0.5); ctx.lineTo(w, Math.round(y(v)) + 0.5); ctx.stroke()
                })

                // Bands: on AC, asleep.
                var segs = root.historyTimeline.segments
                var acRects = []
                for (var i = 0; i < segs.length; i++) {
                  if (segs[i].source !== "ac") continue
                  var end = i === segs.length - 1 ? root.historyNow : segs[i].end
                  if (end < t0) continue
                  acRects.push([segs[i].start, end])
                }
                ctx.fillStyle = graphBox.rgba(accent, 0.14)
                acRects.forEach(function(r) { band(r[0], r[1]) })
                ctx.fillStyle = graphBox.rgba(fg, 0.06)
                root.historyTimeline.sleeps.forEach(function(sl) {
                  if (sl.end < t0 || sl.charged) return
                  band(sl.start, sl.end)
                })

                // Awake runs are drawn solid; across a sleep, when nothing
                // was recorded, a dashed line joins the level going to sleep
                // to the level on waking.
                var runs = root.historyRuns
                function linePath() {
                  ctx.beginPath()
                  runs.forEach(function(run) {
                    ctx.moveTo(x(run[0].t), y(run[0].v))
                    for (var k = 1; k < run.length; k++) ctx.lineTo(x(run[k].t), y(run[k].v))
                  })
                }
                function sleepPath() {
                  ctx.beginPath()
                  for (var r = 1; r < runs.length; r++) {
                    var a = runs[r - 1][runs[r - 1].length - 1], b = runs[r][0]
                    var x1 = x(a.t), y1 = y(a.v), x2 = x(b.t), y2 = y(b.v)
                    var len = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
                    for (var d = 0; d < len; d += 6) {
                      var e = Math.min(len, d + 3)
                      ctx.moveTo(x1 + (x2 - x1) * d / len, y1 + (y2 - y1) * d / len)
                      ctx.lineTo(x1 + (x2 - x1) * e / len, y1 + (y2 - y1) * e / len)
                    }
                  }
                }

                // Area under the whole line, sleeps included.
                ctx.beginPath()
                ctx.moveTo(x(pts[0].t), h)
                runs.forEach(function(run) {
                  for (var k = 0; k < run.length; k++) ctx.lineTo(x(run[k].t), y(run[k].v))
                })
                ctx.lineTo(x(pts[pts.length - 1].t), h)
                ctx.closePath()
                ctx.fillStyle = graphBox.rgba(fg, 0.12)
                ctx.fill()

                // Line, then the AC stretches again in the accent.
                ctx.lineJoin = "round"
                function strokeAll(color) {
                  ctx.strokeStyle = color
                  ctx.lineWidth = 1.5
                  linePath(); ctx.stroke()
                  ctx.lineWidth = 1
                  sleepPath(); ctx.stroke()
                }
                strokeAll(graphBox.rgba(fg, 0.9))
                acRects.forEach(function(r) {
                  ctx.save()
                  var l = Math.min(x(r[0]), x(r[1])), rr = Math.max(x(r[0]), x(r[1]))
                  ctx.beginPath(); ctx.rect(l, 0, Math.max(1, rr - l), h); ctx.clip()
                  strokeAll(graphBox.rgba(accent, 1))
                  ctx.restore()
                })

                // Hover crosshair and dot.
                if (graphBox.hoverX >= 0) {
                  var hv = root.chargeAt(graphBox.hoverT)
                  ctx.strokeStyle = graphBox.rgba(fg, 0.35)
                  ctx.lineWidth = 1
                  ctx.beginPath(); ctx.moveTo(Math.round(graphBox.hoverX) + 0.5, 0); ctx.lineTo(Math.round(graphBox.hoverX) + 0.5, h); ctx.stroke()
                  if (hv >= 0) {
                    ctx.fillStyle = graphBox.rgba(fg, 1)
                    ctx.beginPath(); ctx.arc(graphBox.hoverX, y(hv), 3, 0, Math.PI * 2); ctx.fill()
                  }
                }
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.NoButton
              onPositionChanged: function(mouse) { graphBox.hoverX = Math.max(0, Math.min(width, mouse.x)) }
              onExited: graphBox.hoverX = -1
            }
          }

          // Under the graph: the window's edges, or the hover readout.
          Item {
            width: parent.width
            implicitHeight: startLabel.implicitHeight

            InfoLabel {
              id: startLabel
              visible: graphBox.hoverX < 0
              anchors.left: parent.left
              font.pixelSize: Style.font.caption
              text: root.whenText(root.historyStart)
            }
            InfoLabel {
              visible: graphBox.hoverX < 0
              anchors.right: parent.right
              font.pixelSize: Style.font.caption
              text: Commons.I18n.t("power.historyNow")
            }
            InfoLabel {
              visible: graphBox.hoverX >= 0
              anchors.horizontalCenter: parent.horizontalCenter
              font.pixelSize: Style.font.caption
              opacity: 0.85
              text: graphBox.hoverX < 0 ? "" : Commons.I18n.t("power.historyHover")
                .arg(root.whenText(graphBox.hoverT))
                .arg(root.pct(root.chargeAt(graphBox.hoverT)))
                .arg(root.stateLabel(root.stateAt(graphBox.hoverT)))
            }
          }

          // Legend.
          Row {
            spacing: Style.space(14)
            LegendSwatch { swatch: Commons.Color.accent; strength: 0.9; label: Commons.I18n.t("power.historyLegendCharging") }
            LegendSwatch { swatch: root.bar.foreground; strength: 0.9; label: Commons.I18n.t("power.historyLegendBattery") }
            LegendSwatch { swatch: root.bar.foreground; strength: 0.15; label: Commons.I18n.t("power.historyLegendAsleep") }
          }

          // Last charge | last (or current) run on battery.
          Row {
            width: parent.width
            spacing: Style.space(20)

            Column {
              width: (parent.width - parent.spacing) / 2
              spacing: Style.spacing.labelGap
              InfoPair {
                label: Commons.I18n.t("power.historyPluggedIn")
                value: root.lastCharge ? root.whenText(root.lastCharge.start) : "—"
              }
              InfoPair { label: Commons.I18n.t("power.historyCharged"); value: root.rangeText(root.lastCharge) }
              InfoPair {
                label: root.lastCharge && root.lastCharge.ongoing ? Commons.I18n.t("power.historySoFar") : Commons.I18n.t("power.historyTook")
                value: root.lastCharge ? root.durationText(root.lastCharge.end - root.lastCharge.start) : "—"
              }
              InfoPair { label: Commons.I18n.t("power.historyCharger"); value: root.lastCharge ? root.wattsText(root.lastCharge.avgWatts) : "—" }
            }

            Column {
              width: (parent.width - parent.spacing) / 2
              spacing: Style.spacing.labelGap
              InfoPair {
                label: Commons.I18n.t("power.historyUnplugged")
                value: root.lastBattery ? root.whenText(root.lastBattery.start) : "—"
              }
              InfoPair { label: Commons.I18n.t("power.historyDrained"); value: root.rangeText(root.lastBattery) }
              InfoPair { label: Commons.I18n.t("power.historyAwake"); value: root.lastBattery ? root.durationText(root.lastBattery.awakeSec) : "—" }
              InfoPair { label: Commons.I18n.t("power.historyDraw"); value: root.lastBattery ? root.wattsText(root.lastBattery.avgWatts) : "—" }
            }
          }

          // Average drain over the window, awake and asleep apart.
          Row {
            width: parent.width
            spacing: Style.space(20)

            Column {
              width: (parent.width - parent.spacing) / 2
              InfoPair {
                label: Commons.I18n.t("power.historyDrainRate")
                value: root.drain ? Commons.I18n.t("power.historyPerHour").arg(Commons.I18n.formatNumber(root.drain.pctPerHour, 1)) : "—"
              }
            }
            Column {
              width: (parent.width - parent.spacing) / 2
              InfoPair {
                label: Commons.I18n.t("power.historyAsleepUse")
                value: root.drain && root.drain.sleepSec > 0
                  ? Commons.I18n.t("power.historyOverTime").arg(root.pct(root.drain.sleepPct)).arg(root.durationText(root.drain.sleepSec))
                  : "—"
              }
            }
          }
        }

        // ---------- Power profile picker ----------
        PanelSeparator {
          foreground: root.bar.foreground
        }

        Column {
          width: parent.width
          spacing: Style.space(10)

          PanelSectionHeader {
            text: Commons.I18n.t("power.powerProfile")
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
          }

          Row {
            id: profileRow
            width: parent.width
            spacing: Style.space(6)

            readonly property real cellWidth: root.profiles.length > 0
              ? (width - spacing * (root.profiles.length - 1)) / root.profiles.length
              : 0

            Repeater {
              model: root.profiles
              Button {
                required property var modelData
                required property int index
                width: profileRow.cellWidth
                iconText: root.profileIcon(String(modelData))
                iconSize: Style.font.title
                text: Model.profileLabel(modelData, Commons.I18n.t)
                fontSize: Style.font.bodySmall
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                horizontalPadding: Style.spacing.controlPaddingX
                verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
                bordered: true
                active: root.activeProfile === modelData
                hasCursor: root.cursorActive && root.cursorRow === "profiles" && root.profileIndex === index
                onClicked: root.setProfile(modelData)
                onHovered: function(h) {
                  if (h) {
                    root.cursorActive = true
                    root.cursorRow = "profiles"
                    root.profileIndex = index
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  component InfoPair: Row {
    property string label: ""
    property string value: ""

    width: parent.width
    spacing: Style.space(8)

    InfoLabel { text: label }
    Item { width: Math.max(0, parent.width - parent.children[0].implicitWidth - parent.children[2].implicitWidth - parent.spacing * 2); height: 1 }
    // A value longer than the room beside its label (a long "Yesterday" in
    // another language) elides rather than running past the panel's edge.
    InfoValue {
      text: value
      width: Math.min(implicitWidth, Math.max(0, parent.width - parent.children[0].implicitWidth - parent.spacing * 2))
      elide: Text.ElideRight
    }
  }

  component LegendSwatch: Row {
    property color swatch
    property real strength: 1
    property string label: ""
    spacing: Style.space(6)
    Rectangle {
      width: Style.space(10); height: Style.space(10); radius: Style.space(2)
      anchors.verticalCenter: parent.verticalCenter
      color: Qt.rgba(swatch.r, swatch.g, swatch.b, strength)
    }
    InfoLabel { text: label; font.pixelSize: Style.font.caption }
  }

  component InfoLabel: Text {
    textFormat: Text.PlainText
    color: root.bar.foreground
    opacity: 0.6
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  component InfoValue: Text {
    textFormat: Text.PlainText
    color: root.bar.foreground
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.bodySmall
  }
}
