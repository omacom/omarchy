// The notification daemon: Quickshell's NotificationServer owns
// org.freedesktop.Notifications. docs/notifications.md describes the system.
//
// The engine began as Omapager, Copyright (c) 2026 Neil Jagdish Patel, under
// the MIT License (https://github.com/omacom/omapager).

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Commons as Commons

import "Store.js" as Store
import "Security.js" as Security
import "Layout.js" as Layout
import "Markup.js" as Markup
import "Delivery.js" as Delivery
import "Settings.js" as Settings
import "Icons.js" as Icons

Item {
  id: service

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  // ------------------------------------------------------------- settings
  //
  // shell.json's `notifications` object; Settings.resolve fills every default.
  readonly property var preferences: Settings.resolve(shell && shell.shellConfig ? shell.shellConfig.notifications : null)

  function setSetting(key, value) {
    var values = {}
    values[key] = value
    setSettings(values)
  }

  function setSettings(values) {
    if (!shell || typeof shell.mutateShellConfig !== "function") return
    shell.mutateShellConfig(function(config) {
      if (!Util.isPlainObject(config.notifications)) config.notifications = {}
      for (var key in values) config.notifications[key] = values[key]
    })
  }

  readonly property string displayMode: preferences.displayMode
  readonly property string displayName: preferences.displayName
  readonly property bool stepsAside: preferences.fullscreenOverlay === "all"
  readonly property bool offerSnoozeWhenSharing: preferences.offerSnoozeWhenSharing
  onStepsAsideChanged: hyprRefresh.restart()

  // How many sources, held notifications per source, and recent ones the panel lists.
  readonly property int sourceLimit: 8
  readonly property int heldPerSource: 10
  readonly property int recentCount: 5

  // A shorter retention applies at once to what is already kept.
  readonly property int historyHours: preferences.historyHours
  onHistoryHoursChanged: currentHistory()

  // ------------------------------------------------------------- displays
  //
  // "active" places a new deck on the focused output and keeps it there;
  // "specific" pins one output; "all" mirrors the deck on every output.
  property string deckDisplayName: ""
  readonly property var displayNames: Quickshell.screens.map(function(screen) { return screen.name })
  readonly property string focusedDisplayName: {
    var name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
    return displayNames.indexOf(name) >= 0 ? name : (displayNames[0] || "")
  }
  readonly property string configuredDisplayName: displayMode === "specific" && displayNames.indexOf(displayName) >= 0
    ? displayName : focusedDisplayName
  readonly property string targetDisplayName: {
    var wanted = focusedDisplayName
    if (displayMode === "specific" && displayNames.indexOf(displayName) >= 0) wanted = configuredDisplayName
    else if (displayNames.indexOf(deckDisplayName) >= 0) wanted = deckDisplayName
    return wanted
  }
  onDisplayNamesChanged: {
    if (deckDisplayName && displayNames.indexOf(deckDisplayName) < 0)
      deckDisplayName = configuredDisplayName
  }
  onDisplayModeChanged: { if (toasts.count > 0) deckDisplayName = configuredDisplayName }
  onDisplayNameChanged: { if (displayMode === "specific" && toasts.count > 0) deckDisplayName = configuredDisplayName }
  function pinDeckDisplay() {
    if (toasts.count === 0) deckDisplayName = configuredDisplayName
  }

  function showsOn(name) {
    return displayMode === "all" || name === targetDisplayName
  }

  // ------------------------------------------------------------- quiet
  //
  // A verification code was asked for a moment ago and expires in minutes, so
  // by default it gets through quiet. The panel's key button closes that hole.
  property bool codesBypassQuiet: true
  function setCodesBypassQuiet(value) {
    if (!!value === codesBypassQuiet) return
    codesBypassQuiet = !!value
    saveQuiet()
  }

  property bool doNotDisturb: false
  property double silencedSince: 0
  function setDoNotDisturb(value) {
    var on = !!value
    if (on === doNotDisturb) return
    if (on) silencedSince = Date.now() / 1000
    doNotDisturb = on
    saveQuiet()
  }

  // Undoes both silencing and snoozing everything.
  function letEverythingThrough() {
    setDoNotDisturb(false)
    unsnooze(globalKey)
  }

  readonly property bool quiet: doNotDisturb || globalSnoozeUntil > 0

  // ---------------------------------------------------- screen sharing
  //
  // Watch the portal's PipeWire stream lifetime rather than frame activity,
  // which screenshots and VNC also produce. Sharing only offers a timed snooze.
  readonly property var sharingCandidates: {
    var nodes = Pipewire.nodes.values, out = []
    for (var i = 0; i < nodes.length && out.length < 64; i++)
      if (nodes[i].type === PwNodeType.VideoSource) out.push(nodes[i])
    return out
  }
  PwObjectTracker { objects: service.sharingCandidates }
  readonly property int sharingStreams: {
    if (!Pipewire.ready) return 0
    var count = 0
    for (var i = 0; i < sharingCandidates.length; i++) {
      var node = sharingCandidates[i]
      if (!node.ready) continue
      var props = node.properties
      if (props["media.class"] === "Video/Source"
          && String(props["media.name"] || "").indexOf("xdph-streaming-") === 0) count++
    }
    return count
  }
  readonly property bool sharingActive: sharingStreams > 0
  readonly property bool sharingDetectionAvailable: Pipewire.ready
  property bool sharingOfferHandled: false
  readonly property bool sharingOfferPending: offerSnoozeWhenSharing && sharingActive
    && !sharingOfferHandled && !doNotDisturb && !globalSnoozeUntil
  onSharingActiveChanged: {
    sharingOfferHandled = sharingActive && (doNotDisturb || globalSnoozeUntil > 0)
  }
  onDoNotDisturbChanged: { if (doNotDisturb && sharingActive) sharingOfferHandled = true }
  onGlobalSnoozeUntilChanged: { if (globalSnoozeUntil > 0 && sharingActive) sharingOfferHandled = true }
  function dismissSharingOffer() { if (sharingActive) sharingOfferHandled = true }
  function snoozeSharingOffer(seconds) {
    if (!sharingOfferPending || [1800, 3600, 14400].indexOf(seconds) < 0) return
    sharingOfferHandled = true
    snoozeSource(globalKey, "", seconds, true)
  }

  readonly property int gap: Style.space(6)

  // ------------------------------------------------------------- the bar
  //
  // The deck hangs from the top-right corner, so it clears the bar only when
  // the bar is on the top or right edge and visible.
  readonly property var barRef: shell && shell.bar ? shell.bar : null
  readonly property string barPosition: barRef ? String(barRef.position || "top") : "top"
  readonly property bool barVertical: barPosition === "left" || barPosition === "right"
  readonly property int defaultBarSize: barVertical ? Style.bar.sizeVertical : Style.bar.sizeHorizontal
  function marginsFor(screenName) {
    return Delivery.deckMargins(barPosition, Delivery.barThickness(barRef, screenName, defaultBarSize), Style.gapsOut)
  }
  readonly property int notificationWidth: Style.space(380)

  // ---------------------------------------------------- fullscreen windows
  //
  // Hyprland refuses direct scanout while any overlay-layer surface exists on
  // a monitor, so an idle canvas makes fullscreen games composite each frame.
  // It steps aside under a fullscreen window until a card arrives.
  // Bumped after Hyprland's window snapshot refreshes, so fullscreenOn() re-evaluates.
  property int hyprRevision: 0

  // Per output, for `probe`: is the canvas mapped, stepping aside, showing cards?
  function surfaceStates() {
    var out = []
    var list = surfaceVariants.instances
    for (var i = 0; i < list.length; i++) {
      var s = list[i]
      out.push({ display: s.modelData ? String(s.modelData.name) : "", mapped: s.visible === true,
                 stepAside: s.stepAside === true, showing: s.showingNotifications === true,
                 lingering: s.lingering === true })
    }
    return out
  }

  function fullscreenOn(name) {
    var revision = hyprRevision
    if (!stepsAside || !name) return false
    var screen = null
    for (var s = 0; s < Quickshell.screens.length; s++)
      if (String(Quickshell.screens[s].name) === name) screen = Quickshell.screens[s]
    var monitor = screen ? Hyprland.monitorFor(screen) : null
    var workspace = monitor ? monitor.activeWorkspace : null
    if (!workspace || !workspace.hasFullscreen) return false
    var windows = workspace.toplevels ? workspace.toplevels.values : []
    for (var i = 0; i < windows.length; i++) {
      var ipc = windows[i].lastIpcObject || {}
      // A workspace also reports maximized windows as fullscreen. Only a real
      // fullscreen (mode bit 2) can be scanned out.
      if ((Number(ipc.fullscreen) & 2) !== 0) return true
    }
    return false
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!service.stepsAside) return
      switch (event.name) {
      case "fullscreen": case "openwindow": case "closewindow": case "movewindowv2":
      case "activewindowv2": case "workspacev2": case "focusedmonv2": case "changefloatingmode":
        hyprRefresh.restart()
      }
    }
  }
  // Debounce a fullscreen burst, then let the IPC answer land before re-reading.
  Timer {
    id: hyprRefresh
    interval: 100
    onTriggered: { Hyprland.refreshToplevels(); hyprSettle.restart() }
  }
  Timer {
    id: hyprSettle
    interval: 250
    onTriggered: service.hyprRevision++
  }

  // ------------------------------------------------------------- lifetime
  readonly property int lowDuration: 5000
  readonly property int normalDuration: 8000
  readonly property int maxDuration: 30000

  // Critical waits for you. Everything else gets at least its urgency's
  // minimum, stretched up to 30s when the sender asks for longer.
  function durationFor(urgency, requested) {
    if (urgency === NotificationUrgency.Critical) return 0
    var base = urgency === NotificationUrgency.Low ? lowDuration : normalDuration
    return Math.min(maxDuration, Math.max(base, requested > 0 ? requested : 0))
  }

  // ------------------------------------------------------------- snooze
  //
  // Keyed by the row's group key: per site for browser notifications
  // ("web:app.slack.com"), per app otherwise. Snoozed notifications are still recorded.
  property var snoozes: ({})        // groupKey -> { until: epoch seconds, label, since }
  property int snoozeRevision: 0

  // Snoozing everything is the same mechanism under a key no source can have.
  readonly property string globalKey: "*"
  readonly property double globalSnoozeUntil: { snoozeRevision; return snoozedUntil(globalKey) }

  function shortWords(minutes) {
    if (minutes < 60) return I18n.t("notifications.minutesShort").arg(I18n.formatNumber(minutes))
    var hours = Math.round(minutes / 6) / 10
    return I18n.t("notifications.hoursShort").arg(I18n.formatNumber(hours, hours % 1 ? 1 : 0))
  }

  // One choice, worked out against the clock as it is now: "tomorrow" is a
  // different number of seconds at every hour of the day.
  function snoozeOption(choice) {
    var value = String(choice || "")
    var seconds = Settings.snoozeSeconds(value, Date.now())
    if (!(seconds > 0)) return null
    if (value === "tomorrow")
      return { short: I18n.t("notifications.tomorrow"), seconds: seconds }
    return { short: shortWords(Number(value)), seconds: seconds }
  }

  readonly property var snoozeOptions: {
    var choices = Settings.SNOOZE_CHOICES, out = []
    for (var i = 0; i < choices.length; i++) {
      var option = snoozeOption(choices[i])
      if (option) out.push(option)
    }
    return out
  }

  function snoozedUntil(groupKey) {
    var entry = snoozes[String(groupKey || "")]
    var until = entry ? Number(entry.until || 0) : 0
    return until > Date.now() / 1000 ? until : 0
  }

  // Soonest to wake first, which is the order the panel lists them in.
  function liveSnoozes() {
    snoozeRevision
    var now = Date.now() / 1000, out = []
    for (var key in snoozes) {
      if (key === globalKey) continue
      var entry = snoozes[key]
      if (!entry || Number(entry.until || 0) <= now) continue
      out.push({ key: key, label: String(entry.label || key), until: Number(entry.until) })
    }
    out.sort(function(a, b) { return a.until - b.until })
    return out
  }

  readonly property int snoozeCount: { snoozeRevision; return liveSnoozes().length }
  readonly property bool anySnooze: snoozeCount > 0 || globalSnoozeUntil > 0

  // Past a year is a mistake, and an infinite snooze would persist as null.
  readonly property int maxSnoozeSeconds: 366 * 86400

  // `fromNow` re-snoozes rather than extending what was already left.
  function snoozeSource(groupKey, label, seconds, fromNow) {
    var key = String(groupKey || "")
    seconds = Number(seconds)
    if (!key || !isFinite(seconds) || seconds <= 0) return 0
    seconds = Math.min(seconds, maxSnoozeSeconds)
    // Snoozing everything supersedes silencing: the same quiet, with an end.
    if (key === globalKey) setDoNotDisturb(false)
    var from = fromNow ? Date.now() / 1000
                       : Math.max(Date.now() / 1000, snoozedUntil(key))
    var next = {}
    for (var k in snoozes) next[k] = snoozes[k]
    // When this quiet period began, so the panel lists only what it held.
    var since = (next[key] && snoozedUntil(key)) ? Number(next[key].since || 0)
                                                 : Date.now() / 1000
    next[key] = { until: from + seconds, label: String(label || key), since: since }
    snoozes = next
    snoozeRevision += 1
    saveQuiet()
    // Anything from that source already on screen goes now.
    var keys = []
    for (var i = 0; i < toasts.count; i++) {
      var row = toasts.get(i)
      if (key === globalKey ? !Delivery.bypassesQuiet(row) : String(row.groupKey || "") === key) keys.push(row.key)
    }
    for (var j = 0; j < keys.length; j++) closeToast(keys[j], "snoozed")
    return next[key].until
  }

  function unsnooze(groupKey) {
    var next = {}
    for (var k in snoozes) if (k !== String(groupKey)) next[k] = snoozes[k]
    snoozes = next
    snoozeRevision += 1
    saveQuiet()
  }

  function unsnoozeAll() {
    snoozes = ({})
    snoozeRevision += 1
    saveQuiet()
  }

  // Persisted: nothing on screen says the desktop is quiet, so a reload must not lift it.
  function saveQuiet() { saveSoon("quiet") }

  // Wakes the bindings so a snooze that has run out stops being counted, and
  // drops it from the map. Only runs while something is actually snoozed.
  Timer {
    interval: 20000
    repeat: true
    running: service.anySnooze
    onTriggered: {
      var now = Date.now() / 1000, next = {}, dropped = false
      for (var k in service.snoozes) {
        if (Number(service.snoozes[k].until || 0) > now) next[k] = service.snoozes[k]
        else dropped = true
      }
      if (dropped) { service.snoozes = next; service.saveQuiet() }
      service.snoozeRevision += 1
    }
  }

  // ------------------------------------------------------------- recent
  //
  // Session-only text snapshots of what reached the screen, never live objects.
  property var recentRows: []
  readonly property int recentLimit: 20

  function rememberRecent(row) {
    var key = String(row.key), rows = []
    if (!doNotDisturb && !globalSnoozeUntil && !snoozedUntil(row.groupKey)) {
      // A digest keeps source matching apart from the redacted display text.
      var sourceKey = Qt.md5(String(row.groupKey || ""))
      row = Store.sanitiseForPersistence(row)
      rows.push({
        key: key, sourceKey: sourceKey,
        source: String(row.source || row.app || "").slice(0, 120),
        summary: String(row.summary || "").slice(0, 240),
        bodyLine: String(row.bodyLine || "").slice(0, 1000),
        ts: Number(row.ts)
      })
    }
    // A replacement may move to a snoozed source: drop its old entry even when
    // the new version belongs only in Held Back.
    for (var i = 0; i < recentRows.length && rows.length < recentLimit; i++) {
      if (recentRows[i].key !== key) rows.push(recentRows[i])
    }
    recentRows = rows
  }

  function recentForPanel(limit) {
    snoozeRevision
    if (doNotDisturb || globalSnoozeUntil) return []
    var excluded = Object.create(null), snoozed = liveSnoozes()
    for (var i = 0; i < snoozed.length; i++) excluded[Qt.md5(snoozed[i].key)] = true
    var rows = []
    for (var j = 0; j < recentRows.length && rows.length < limit; j++) {
      if (!excluded[recentRows[j].sourceKey]) rows.push(recentRows[j])
    }
    return rows
  }

  // ------------------------------------------------------- what was held
  //
  // Drawn from history when the panel opens: what quiet kept off the screen.
  property var heldRows: []
  property int heldRevision: 0
  readonly property int heldLimit: 80

  function refreshHeld() {
    heldRows = Store.displayRows(Store.held(currentHistory(), heldLimit))
    heldRevision += 1
  }

  // ---------------------------------------------------- notification history
  //
  // The redacted log (see store below), newest first, read when the panel opens.
  property var historyRows: []
  property int historyRevision: 0

  function refreshHistory() {
    historyRows = Store.displayRows(currentHistory())
    historyRevision += 1
  }

  // When the quiet holding this source began: the earliest of the reasons
  // currently in force.
  function quietSince(groupKey) {
    var entry = snoozes[String(groupKey || "")]
    var mine = entry && snoozedUntil(groupKey) ? Number(entry.since || 0) : 0
    var global = globalSnoozeUntil ? Number((snoozes[globalKey] || {}).since || 0) : 0
    var silence = doNotDisturb ? silencedSince : 0
    var starts = [mine, global, silence].filter(function(t) { return t > 0 })
    return starts.length ? Math.min.apply(null, starts) : 0
  }

  function heldFor(groupKey, limit) {
    heldRevision
    var since = quietSince(groupKey)
    var out = []
    for (var i = 0; i < heldRows.length && out.length < limit; i++) {
      var row = heldRows[i]
      if (String(row.groupKey || "") !== String(groupKey)) continue
      if (since && Number(row.ts || 0) < since) continue
      out.push(row)
    }
    return out
  }

  // Sources snoozed by name first, then (while everything is quiet) any other
  // source that held something.
  function quietSources(limit) {
    snoozeRevision; heldRevision
    var rows = [], seen = {}
    var snoozed = liveSnoozes()
    var i, key
    for (i = 0; i < snoozed.length && rows.length < limit; i++) {
      seen[snoozed[i].key] = true
      rows.push({ key: snoozed[i].key, label: snoozed[i].label, until: snoozed[i].until,
                  held: heldFor(snoozed[i].key, heldPerSource) })
    }
    if (!doNotDisturb && !globalSnoozeUntil) return rows
    for (i = 0; i < heldRows.length && rows.length < limit; i++) {
      key = String(heldRows[i].groupKey || "")
      if (!key || seen[key]) continue
      var held = heldFor(key, heldPerSource)
      if (!held.length) continue
      seen[key] = true
      rows.push({ key: key, label: String(heldRows[i].source || heldRows[i].app || key),
                  until: 0, held: held })
    }
    return rows
  }

  // ------------------------------------------------------------- state
  //
  // Live Notification objects stay in a JS map, never the model: a QObject in a
  // ListModel role dangles once the server destroys it and crashes the next read.
  property var refs: ({})
  property int refsRevision: 0
  property int keySeed: 0

  ListModel {
    id: toasts
    onCountChanged: { if (count === 0) service.deckDisplayName = "" }
  }

  // ------------------------------------------------------ live capacity
  //
  // One reservation per row across held, deferred and visible states. Callbacks
  // compare reservation identity, so a closed row cannot come back on key reuse.
  readonly property int maxLiveNotifications: 100
  property var liveKeys: Object.create(null)

  function liveCount() { return Object.keys(liveKeys).length }

  function reserveLive(key) {
    if (!key) return false
    if (liveKeys[key]) return true
    if (liveCount() >= maxLiveNotifications) return false
    liveKeys[key] = { originalId: 0, row: null, scheduled: false, held: false }
    return true
  }

  function releaseLive(key) {
    if (!liveKeys[key]) return
    delete liveKeys[key]
    held = held.filter(function(heldKey) { return heldKey !== key })
  }

  // One clock the cards' relative times hang off, rather than a timer per card.
  // It stops with no cards on screen, so it catches up as soon as one shows:
  // replayed history would otherwise read against the hour it last ticked.
  property double nowTick: Date.now()
  Timer {
    interval: 20000
    repeat: true
    triggeredOnStart: true
    running: toasts.count > 0
    onTriggered: service.nowTick = Date.now()
  }

  // ------------------------------------------------------------- the deck
  //
  // Expansion follows the pointer, with a grace period for crossing gaps.
  property bool pointerIn: false
  property bool expanded: false
  property string openDeck: ""
  property string hoverKey: ""     // the card under the pointer, when open
  property real hoverX: -1         // where it is, in the deck's coordinates
  property real hoverY: -1

  property var heights: ({})       // key -> measured card height
  property int layoutRevision: 0
  // Cards that arrived since the deck last opened or closed. They settle into
  // their measured height at once (a late icon, a re-wrap) instead of growing.
  property var fresh: ({})
  onExpandedChanged: fresh = ({})

  Timer {
    id: collapseGrace
    interval: 120
    onTriggered: {
      service.commit(function() { service.expanded = false; service.openDeck = "" })
      service.releaseHeld()
    }
  }

  // New cards wait while the deck is held open, so nothing moves mid-read.
  property var held: []

  function holding() { return pointerIn && expanded }

  function releaseHeld() {
    if (!held.length) return
    var queue = held
    held = []
    for (var i = 0; i < queue.length; i++) {
      var pending = liveKeys[queue[i]]
      if (!pending || !pending.row) continue
      pending.held = false
      service.showRow(pending.row)
    }
  }

  // Nothing waits forever: a pointer parked over the deck must not silence
  // the machine.
  Timer {
    id: heldTooLong
    interval: 30000
    running: service.held.length > 0
    onTriggered: service.releaseHeld()
  }

  function pointerEntered(deckKey) {
    collapseGrace.stop()
    if (expanded && (deckKey === undefined || openDeck === deckKey)) return
    commit(function() {
      service.expanded = true
      if (deckKey !== undefined) service.openDeck = deckKey
    })
  }
  function pointerLeft() { collapseGrace.restart() }

  // Fed target heights, never mid-animation ones, so layout moves on events.
  function noteHeight(key, h) {
    if (Math.abs((heights[key] || 0) - h) < 0.5) return
    if (fresh[key] && !expanded) {
      heights[key] = h
      land()
    } else {
      commit(function() { service.heights[key] = h })
    }
  }

  // ------------------------------------------------------- the scene clock
  //
  // One clock for the whole deck: each card interpolates from `was` to its
  // placement by t. A Behavior per card would restart on every retarget.
  readonly property var sceneCurve: [0.21, 1.02, 0.73, 1.0, 1.0, 1.0]
  readonly property int sceneDuration: Style.duration(320)

  property real t: 1                 // 0..1, eased, shared by every card
  property var was: ({})             // where each card was when the target moved
  property real deckWas: 0

  NumberAnimation {
    id: sceneRun
    target: service; property: "t"; from: 0; to: 1
    duration: Math.max(1, service.sceneDuration)
    easing.type: Easing.Bezier
    easing.bezierCurve: service.sceneCurve
    onFinished: service.settled()
  }

  function at(key, what) {
    var target = placements[key]
    if (!target) return 0
    var to = target[what]
    if (t >= 1) return to
    var from = was[key]
    if (!from || from[what] === undefined) return to
    return from[what] + (to - from[what]) * t
  }

  readonly property real deckHeight: t >= 1 ? layout.height
                                            : deckWas + (layout.height - deckWas) * t

  // Taken *before* a change: afterwards the layout binding already points at
  // the new target, so "was" and "to" would match and nothing would move.
  function snapshot() {
    var snap = {}
    for (var key in placements)
      snap[key] = { y: at(key, "y"), scale: at(key, "scale"),
                    opacity: at(key, "opacity"), height: at(key, "height") }
    return snap
  }

  // Snapshot, change, then one move for everything from the same instant.
  function commit(change) {
    var snap = snapshot(), deckNow = deckHeight
    change()
    retarget(snap, deckNow)
  }

  function retarget(snap, deckNow) {
    if (!snap) { snap = snapshot(); deckNow = deckHeight }
    deckWas = deckNow
    was = snap
    layoutRevision += 1
    t = 0
    sceneRun.restart()
  }

  // Arrivals and departures skip the clock: everything jumps to its place.
  function land() {
    sceneRun.stop()
    layoutRevision += 1
    t = 1
    Qt.callLater(landed)
  }

  // Cards come to rest when the clock finishes or a jump has been drawn.
  signal settled()
  // A move started after the jump settles on its own finish instead.
  function landed() { if (t >= 1) settled() }

  readonly property var layout: {
    layoutRevision
    var rows = []
    for (var i = 0; i < toasts.count; i++) {
      var row = toasts.get(i)
      if (!leaving[row.key]) rows.push(row)   // a card on its way out takes no space
    }
    return Layout.compute(rows, {
      expanded: expanded,
      openDeck: openDeck,
      gap: gap,
      deckGap: Style.space(11),
      heightOf: function(key) { return service.heights[key] || Style.space(58) }
    })
  }

  // A leaving card has no placement, so its Toast is hidden and takes no input.
  readonly property var placements: layout.placements

  // Our own identity: the sender's id is reused by replaces_id.
  function nextKey() {
    var key
    do {
      keySeed += 1
      key = "n" + Date.now().toString(36) + keySeed.toString(36)
    } while (liveKeys[key])
    return key
  }

  function rowIndexFor(key) {
    for (var i = 0; i < toasts.count; i++)
      if (toasts.get(i).key === key) return i
    return -1
  }

  // id 0 means "a new notification", not "replace the one with id 0".
  function keyForOriginal(id) {
    if (!id) return ""
    for (var key in liveKeys)
      if (liveKeys[key].originalId === id && refs[key]) return key
    return ""
  }

  // ------------------------------------------------------------- arrival
  function handleNotification(notification) {
    // Replacements reuse the same slot, including before its first insertion.
    var key = keyForOriginal(notification.id) || nextKey()

    if (!reserveLive(key)) {
      notification.tracked = false
      return
    }
    liveKeys[key].originalId = notification.id || 0
    // Otherwise the object is destroyed when this handler returns.
    notification.tracked = true

    var row = Store.snapshot(notification, key, NotificationUrgency)
    row.duration = durationFor(notification.urgency, row.expireTimeout)
    rememberRecent(row)

    var previous = refs[key]
    refs[key] = notification
    refsRevision += 1
    if (previous !== notification) watchNotification(notification, key)
    if (previous && previous !== notification) {
      try { previous.tracked = false } catch (e) {}
    }

    // Quiet still records it (unless ephemeral), straight to history.
    var muted = Delivery.quietReason(row, {
      doNotDisturb: doNotDisturb,
      globalSnoozed: globalSnoozeUntil > 0,
      sourceSnoozed: snoozedUntil(row.groupKey) > 0,
      codesBypassQuiet: codesBypassQuiet
    })
    if (muted) {
      if (!Delivery.isEphemeral(row)) storeRecord(row, muted)
      release(key)
      // A replacement for a card already on screen leaves that card as it was;
      // one still waiting to be shown is gone, and so is its saved row.
      if (rowIndexFor(key) < 0) {
        releaseLive(key)
        storeDrop(key)
      } else {
        liveKeys[key].row = null
      }
      return
    }

    storePut(row)

    // Only a new card waits while the deck is held; an update changes a card in place.
    if (service.holding() && service.rowIndexFor(key) < 0) {
      var pending = liveKeys[key]
      pending.row = row
      if (!pending.held) {
        pending.held = true
        service.held = service.held.concat([key])
      }
      return
    }

    service.showRow(row)
  }

  function watchNotification(notification, key) {
    var reservation = liveKeys[key]
    notification.closed.connect(function() {
      if (service.refs[key] !== notification) return
      delete service.refs[key]
      service.refsRevision += 1
      // Visible snapshots outlive their sender; pending rows must not appear
      // after the sender withdraws them.
      if (service.rowIndexFor(key) < 0) service.finishClose(key, "closed")
    })
    // NotificationServer emits onNotification only for new objects. A
    // replaces_id update mutates this QObject and emits its property signals,
    // so snapshot once after the whole update rather than once per field.
    var queued = false
    var refresh = function() {
      if (!queued) return
      queued = false
      if (reservation.refresh === refresh) reservation.refresh = null
      if (service.liveKeys[key] !== reservation || service.refs[key] !== notification) return
      service.handleNotification(notification)
    }
    var schedule = function() {
      if (queued || service.liveKeys[key] !== reservation || service.refs[key] !== notification) return
      queued = true
      reservation.refresh = refresh
      Qt.callLater(refresh)
    }
    var signals = [notification.summaryChanged, notification.bodyChanged,
                   notification.appNameChanged, notification.appIconChanged,
                   notification.imageChanged, notification.urgencyChanged,
                   notification.expireTimeoutChanged, notification.hintsChanged,
                   notification.actionsChanged]
    for (var i = 0; i < signals.length; i++) signals[i].connect(schedule)
  }

  // Qt.callLater: mutating the model while a Repeater is mid-incubation
  // crashes in QV4::Object::insertMember.
  function showRow(row) {
    var key = String(row.key || "")
    if (!reserveLive(key)) return
    var pending = liveKeys[key]
    pending.row = row
    pending.originalId = row.originalId || 0
    if (pending.held) {
      pending.held = false
      held = held.filter(function(heldKey) { return heldKey !== key })
    }
    if (pending.scheduled) return
    pending.scheduled = true
    Qt.callLater(function() {
      if (service.liveKeys[key] !== pending) return
      // This insertion may have been queued before a replaces_id update.
      // Consume that update first, including its quiet decision.
      if (pending.refresh) pending.refresh()
      pending.scheduled = false
      if (service.liveKeys[key] !== pending || pending.held || !pending.row) return
      var row = pending.row
      pending.row = null
      var at = service.rowIndexFor(key)
      if (at >= 0) {
        var snap = service.snapshot(), deckNow = service.deckHeight
        Store.applyTo(toasts, at, row)      // an update, in place
        service.retarget(snap, deckNow)
      } else {
        service.pinDeckDisplay()
        // Before the insert: the delegate measures itself while it is built.
        service.fresh[key] = true
        toasts.insert(0, row)
        // Arrivals don't slide in: the card and the deck are simply there.
        service.land()
      }
    })
  }

  // Let go of the sender's object. Untracking tells it the notification
  // closed, which is when Chromium deletes the avatar it handed us.
  function release(key, reason) {
    var ref = refs[key]
    if (!ref) return
    // Clear identity before invoking the QObject: its close signal can run
    // synchronously and must not cancel a row or release a newer sender.
    delete refs[key]
    refsRevision += 1
    try {
      if (reason === "expired") ref.expire()
      else if (reason) ref.dismiss()
      else ref.tracked = false
    } catch (e) {}
  }

  // ------------------------------------------------------------- departure
  //
  // A leaving row loses its layout room and vanishes at once, but keeps its
  // model slot until the next tick: removing it from inside the delegate
  // handler that dismissed it would destroy that delegate mid-call.
  property var leaving: ({})

  function closeToast(key, reason) { closeToasts([key], reason) }

  // One jump for the lot, however many cards leave together.
  function closeToasts(keys, reason) {
    var next = {}, marked = false
    for (var k in leaving) next[k] = leaving[k]
    for (var i = 0; i < keys.length; i++) {
      var key = keys[i]
      if (next[key]) continue
      if (rowIndexFor(key) < 0) {
        finishClose(key, reason || "dismissed")
        continue
      }
      next[key] = reason || "dismissed"
      marked = true
    }
    if (!marked) return
    leaving = next
    land()
    Qt.callLater(finishLeaving)
  }

  function finishLeaving() {
    var keys = Object.keys(leaving)
    for (var i = 0; i < keys.length; i++) finishClose(keys[i], leaving[keys[i]])
  }

  function finishClose(key, reason) {
    var rest = {}
    for (var k in leaving) if (k !== key) rest[k] = leaving[k]
    leaving = rest
    var at = rowIndexFor(key)
    if (!liveKeys[key]) return
    releaseLive(key)
    release(key, reason)
    if (at >= 0) toasts.remove(at)
    delete heights[key]
    delete fresh[key]
    // A placeholder (the empty-history notice) was never recorded.
    if (key.indexOf("placeholder") !== 0) storeClose(key, reason)
    layoutRevision += 1
  }

  // Over a snapshot of the keys, never over the model's count: closeToast marks
  // a row leaving rather than removing it, so a count loop never progresses.
  function clearAll(reason) {
    var keys = Object.keys(liveKeys)
    closeToasts(keys, reason)
    return keys.length
  }

  function dismissNewest() {
    for (var i = 0; i < toasts.count; i++) {
      var key = String(toasts.get(i).key)
      if (leaving[key]) continue
      closeToast(key, "dismissed")
      return true
    }
    return false
  }

  // What the sender said can be done with this notification. A restored row
  // has no live sender, so it has none of these.
  function actionsOf(key, revision) {
    var out = []
    var ref = refs[key]
    if (!ref || !ref.actions) return out
    for (var i = 0; i < Math.min(ref.actions.length, Security.MAX_ACTIONS); i++) {
      var a = ref.actions[i]
      var identifier = String(a.identifier || "")
      if (identifier.length > Security.MAX_ACTION_ID || !identifier) continue
      if (identifier === "default") {
        // The card click already runs it.
        continue
      }
      var label = Security.bounded(String(a.text || identifier), Security.MAX_ACTION_LABEL)
      if (/^settings$/i.test(label) || /^settings$/i.test(identifier))
        continue
      out.push({ id: identifier, text: label })
    }
    return out
  }

  function invokeAction(key, identifier) {
    if (typeof identifier !== "string" || identifier.length > Security.MAX_ACTION_ID) return
    invokeSenderAction(key, identifier)
    closeToast(key, "activated")
  }

  function invokeSenderAction(key, identifier) {
    var ref = refs[key]
    if (!ref || !ref.actions) return false
    for (var i = 0; i < Math.min(ref.actions.length, Security.MAX_ACTIONS); i++) {
      if (String(ref.actions[i].identifier) === identifier) {
        try { ref.actions[i].invoke(); return true } catch (e) { return false }
      }
    }
    return false
  }

  // ------------------------------------------------------- source routing
  //
  // Which open window already shows the source: web apps carry their host in
  // the class (exact); a browser tab only in its title (cautious).

  // Whole words only: "slack" must not match "slackline".
  function wordIn(text, word) {
    var at = text.indexOf(word)
    while (at >= 0) {
      var before = at === 0 ? "" : text.charAt(at - 1)
      var after = text.charAt(at + word.length)
      if (!/[a-z0-9]/.test(before) && !/[a-z0-9]/.test(after)) return true
      at = text.indexOf(word, at + 1)
    }
    return false
  }

  function openWindows() {
    var list = Hyprland.toplevels ? Hyprland.toplevels.values : []
    var out = []
    for (var i = 0; i < list.length; i++) {
      var ipc = list[i].lastIpcObject
      var wmClass = String((ipc && ipc["class"]) || "")
      if (wmClass) out.push({ wmClass: wmClass,
                              title: String((ipc && ipc.title) || ""),
                              address: String((ipc && ipc.address) || ""),
                              pid: Number((ipc && ipc.pid) || 0),
                              // 0 is the window you are in, 1 the one before it.
                              focusOrder: Number(ipc && ipc.focusHistoryID !== undefined
                                                 ? ipc.focusHistoryID : 9999) })
    }
    return out
  }

  readonly property var browserClasses: /^(chrome|chromium|firefox|zen|brave|edge|vivaldi|helium)/

  // Every Chrome window title ends "- Google Chrome"; left on, a google.com
  // notification would match every Chrome window.
  readonly property var browserSuffix:
    /\s*[-–—|]\s*(google chrome|chromium|mozilla firefox|firefox|zen browser|brave origin|brave|microsoft edge|vivaldi|helium)\s*$/

  // Labels that name nobody: common subdomains and public suffixes.
  readonly property var genericLabels: ({ www: 1, app: 1, web: 1, my: 1, m: 1,
                                          mail: 1, com: 1, org: 1, net: 1,
                                          io: 1, co: 1, dev: 1, ai: 1, so: 1,
                                          site: 1, uk: 1 })

  // What to look for in a title, most telling first: "app.slack.com" gives
  // ["slack"], "news.ycombinator.com" gives ["news", "ycombinator"].
  function brandsOf(host) {
    var labels = String(host || "").toLowerCase().split(".")
    var out = []
    for (var i = 0; i < labels.length; i++) {
      if (labels[i].length >= 4 && !genericLabels[labels[i]]) { out.push(labels[i]); break }
    }
    var registered = labels.length >= 2 ? labels[labels.length - 2] : ""
    if (registered.length >= 4 && !genericLabels[registered] && out.indexOf(registered) < 0)
      out.push(registered)
    return out
  }

  // The sender process's own window: the one identity that is never a guess.
  function windowForPid(pid) {
    var want = Number(pid || 0)
    if (!want) return null
    var windows = openWindows()
    for (var i = 0; i < windows.length; i++)
      if (windows[i].pid === want) return windows[i]
    return null
  }

  // Of several windows that all match, the one you were in most recently.
  function mostRecent(candidates) {
    if (!candidates.length) return null
    var best = candidates[0]
    for (var i = 1; i < candidates.length; i++)
      if (candidates[i].focusOrder < best.focusOrder) best = candidates[i]
    return best
  }

  function windowForSource(source) {
    var name = String(source || "").toLowerCase()
    if (!name) return null
    var windows = openWindows()
    var i

    var found = []
    if (name.indexOf(".") > 0) {
      for (i = 0; i < windows.length; i++)
        if (windows[i].wmClass.toLowerCase().indexOf(name) >= 0) found.push(windows[i])
      if (found.length) return mostRecent(found)

      // A browser tab, then. Browsers only: "slack" in an editor's title is a filename.
      var brands = brandsOf(name)
      for (var b = 0; b < brands.length; b++) {
        found = []
        for (i = 0; i < windows.length; i++) {
          if (!browserClasses.test(windows[i].wmClass.toLowerCase())) continue
          var title = windows[i].title.toLowerCase().replace(browserSuffix, "")
          if (wordIn(title, brands[b])) found.push(windows[i])
        }
        if (found.length) return mostRecent(found)
      }
      return null
    }

    // Not a host (an app name, say "Signal"): match whole web-app host
    // labels and native classes, never shorter than four characters.
    var slug = name.replace(/[^a-z0-9]+/g, "")
    if (slug.length < 4) return null
    found = []
    for (i = 0; i < windows.length; i++) {
      var lower = windows[i].wmClass.toLowerCase()
      if (lower === slug) { found.push(windows[i]); continue }
      if (lower.indexOf("chrome-") !== 0) continue
      var labels = lower.substring(7).split("__")[0].split(".")
      for (var l = 0; l < labels.length; l++)
        if (labels[l] === slug) { found.push(windows[i]); break }
    }
    return mostRecent(found)
  }

  // By address, because a class is not an identity.
  function focusWindow(win) {
    if (!win) return
    if (!/^0x[0-9a-f]+$/i.test(String(win.address || ""))) return
    Hyprland.dispatch('hl.dsp.focus({window = hl.get_window("address:' + win.address + '")})')
  }

  // A click: Omarchy's own --exec command first, then the sender's default
  // action, then its window, then its site.
  function activate(key) {
    var at = rowIndexFor(key)
    var row = at >= 0 ? toasts.get(at) : null
    var argv = Security.parseExecArgv(row ? row.execArgv : "")
    if (argv) {
      // Detached through bash positional parameters, never a shell string, and
      // outliving the shell, which installer toasts restart on their first act.
      Util.execArgv(argv)
      closeToast(key, "activated")
      return
    }

    var handled = invokeSenderAction(key, "default")
    if (!handled && row) {
      // Source first, link last: a Slack message quoting a link is still a
      // Slack notification, and that link is clickable in its text.
      var win = windowForPid(row.senderPid) || windowForSource(row.source)
      if (win) focusWindow(win)
      else if (Markup.hostname(row.source))
        Security.openExternalUrl("https://" + Markup.hostname(row.source) + "/")
      else if (String(row.link || "")) Security.openExternalUrl(String(row.link))
      else if (String(row.app || "")) Util.execArgv(["omarchy-hyprland-focus-app", String(row.app)])
    }
    closeToast(key, "activated")
  }

  // -------------------------------------------------------------- codes
  //
  // Copying the code Detect.js found in a card.
  Process { id: clipProc; running: false }

  function runClip(args) {
    clipProc.running = false
    clipProc.command = args
    clipProc.running = true
  }

  // A code is kept out of clipboard history (--sensitive) and cleared after a
  // while, but only if it is still what is on the clipboard.
  property string secretHeld: ""

  function copySecret(text) {
    var value = String(text || "")
    if (!value || value.length > 64) return
    runClip(["wl-copy", "--sensitive", "--", value])
    secretHeld = value
    secretLife.restart()
  }

  Timer {
    id: secretLife
    interval: 60000
    onTriggered: clipReader.running = true
  }

  Process {
    id: clipReader
    running: false
    command: ["wl-paste", "--no-newline"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (String(text) === service.secretHeld && service.secretHeld)
          service.runClip(["wl-copy", "--clear"])
        service.secretHeld = ""
      }
    }
  }

  function copyCode(value, key) {
    var at = rowIndexFor(String(key || ""))
    var codes = at >= 0 ? String(toasts.get(at).codes) : ""
    if (at < 0 || codes.split(" ").indexOf(String(value)) < 0) return
    copySecret(value)
    // A copied code finishes its card unless it carried several, a moment
    // after the press so the button's tick is seen.
    if (codes.indexOf(" ") <= 0) codeTaken.keys = codeTaken.keys.concat([String(key)])
  }

  Timer {
    id: codeTaken
    property var keys: []
    interval: 900
    repeat: true
    running: keys.length > 0
    onTriggered: {
      var pending = keys
      keys = []
      for (var i = 0; i < pending.length; i++) service.closeToast(pending[i], "activated")
    }
  }

  // ------------------------------------------------------------- store
  //
  // State, not cache, in ~/.local/state/omarchy/notifications/: live.json (on
  // screen), history.json and quiet.json, formats in Store.js. Each file is
  // read once at startup and rewritten whole a moment after it changes, so a
  // burst of arrivals writes it once.
  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy/notifications"
  property bool storeReady: false
  property bool liveLoaded: false
  property bool historyLoaded: false
  property bool quietLoaded: false
  // Persisted rows: on screen oldest first, history newest first.
  property var liveEntries: []
  property var historyEntries: []
  property var unsaved: ({})

  function storePut(row) {
    liveEntries = Store.putLive(liveEntries, Store.persistable(row))
    saveSoon("live")
  }

  // A row that closes moves from live to history.
  function storeClose(key, reason) {
    var entry = Store.liveEntry(liveEntries, key)
    if (!entry) return
    storeDrop(key)
    storeRecord(entry, reason)
  }

  function storeDrop(key) {
    if (!Store.liveEntry(liveEntries, key)) return
    liveEntries = Store.dropLive(liveEntries, key)
    saveSoon("live")
  }

  // Straight to history: a row that closed, or one quiet kept off the screen.
  function storeRecord(row, reason) {
    var now = Date.now() / 1000
    historyEntries = Store.addHistory(historyEntries, Store.closedEntry(row, reason, now), historyHours, now)
    saveSoon("history")
  }

  // History as of now: rows past their retention go, from disk too.
  function currentHistory() {
    var kept = Store.retain(historyEntries, historyHours, Date.now() / 1000)
    if (kept.length !== historyEntries.length) {
      historyEntries = kept
      saveSoon("history")
    }
    return kept
  }

  function saveSoon(file) {
    unsaved[file] = true
    if (!saveTimer.running) saveTimer.start()
  }

  // Started, never restarted, so a flood still writes every quarter second.
  Timer {
    id: saveTimer
    interval: 250
    onTriggered: service.flushStore()
  }

  // A file is written only once it has been read, so startup never
  // overwrites what the last session left; its loader saves again.
  function flushStore() {
    if (unsaved.live && liveLoaded) {
      delete unsaved.live
      liveFile.setText(Store.serialise(liveEntries))
    }
    if (unsaved.history && historyLoaded) {
      delete unsaved.history
      historyFile.setText(Store.serialise(historyEntries))
    }
    if (unsaved.quiet && quietLoaded) {
      delete unsaved.quiet
      quietFile.setText(Store.serialiseQuiet({ snoozes: snoozes, dnd: doNotDisturb, silencedSince: silencedSince,
                                               codesBypassQuiet: codesBypassQuiet }))
    }
  }

  function loadLive(text) {
    if (liveLoaded) return
    var stored = Store.parseLive(text)
    liveLoaded = true
    restoreRows(stored, false)
    // A row with no room to come back is not on screen to close later, and
    // anything that arrived while the file was being read is newer.
    liveEntries = Store.mergeLive(stored.filter(function(entry) { return !!service.liveKeys[entry.key] }), liveEntries)
    if (unsaved.live || Store.serialise(liveEntries) !== String(text)) saveSoon("live")
  }

  function loadHistory(text) {
    if (historyLoaded) return
    historyEntries = Store.retain(historyEntries.concat(Store.parseHistory(text)), historyHours, Date.now() / 1000)
    historyLoaded = true
    if (unsaved.history || Store.serialise(historyEntries) !== String(text)) saveSoon("history")
  }

  function loadQuiet(text) {
    if (quietLoaded) return
    applyQuiet(Store.parseQuiet(text))
  }

  function applyQuiet(read) {
    if (quietLoaded) return
    if (read) {
      snoozes = read.snoozes
      doNotDisturb = read.dnd
      silencedSince = read.silencedSince
      if (read.codesBypassQuiet !== null) codesBypassQuiet = read.codesBypassQuiet
    }
    quietLoaded = true
    snoozeRevision += 1
    if (unsaved.quiet) saveSoon("quiet")
  }

  // The files exist before anything writes them, at 0600; an atomic write
  // keeps the mode of the file it replaces.
  FileView {
    id: liveFile
    path: service.storeReady ? service.stateDir + "/live.json" : ""
    atomicWrites: true
    printErrors: false
    onLoaded: service.loadLive(text())
    onLoadFailed: service.loadLive("")
  }

  FileView {
    id: historyFile
    path: service.storeReady ? service.stateDir + "/history.json" : ""
    atomicWrites: true
    printErrors: false
    onLoaded: service.loadHistory(text())
    onLoadFailed: service.loadHistory("")
  }

  FileView {
    id: quietFile
    path: service.storeReady ? service.stateDir + "/quiet.json" : ""
    atomicWrites: true
    printErrors: false
    onLoaded: service.loadQuiet(text())
    onLoadFailed: service.loadQuiet("")
  }

  // Once at startup: the private directory and its files. Older layouts'
  // leftovers are removed by a migration.
  Process {
    id: storePrepare
    command: ["bash", "-c",
      "umask 077\n" +
      "dir=$1\n" +
      "mkdir -p -- \"$dir\" && chmod 700 -- \"$dir\" || exit 1\n" +
      "for name in live.json history.json quiet.json; do\n" +
      "  file=$dir/$name\n" +
      "  if [[ -L $file ]]; then rm -f -- \"$file\"; fi\n" +
      "  if [[ -f $file ]]; then chmod 600 -- \"$file\"; elif [[ ! -e $file ]]; then : >\"$file\"; fi\n" +
      "done\n",
      "omarchy-notifications-state", service.stateDir]
    onExited: function(code) { service.storeReady = code === 0 }
  }

  Component.onCompleted: storePrepare.running = true
  // A reload or a clean exit inside the save delay still writes.
  Component.onDestruction: flushStore()

  function restoreRows(rows, replay) {
    // Restore is oldest first; history is newest first. Both insert at zero.
    for (var i = replay ? rows.length - 1 : 0;
         replay ? i >= 0 : i < rows.length; i += replay ? -1 : 1) {
      var row = Store.restored(rows[i])
      if (!row) continue
      if (liveKeys[row.key]) {
        // Startup must not overwrite a newer live arrival. Replaying the same
        // entry deliberately creates a separate card.
        if (!replay) continue
        row.key = nextKey()
      }
      if (!reserveLive(row.key)) break
      showRow(row)
    }
  }

  // ------------------------------------------------------------- server
  NotificationServer {
    id: server
    keepOnReload: false
    imageSupported: true
    actionsSupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    persistenceSupported: true

    onNotification: function(notification) { service.handleNotification(notification) }
  }

  // ------------------------------------------------------------- history replay
  //
  // The last few come back as restored rows: no live sender, a short grace.
  readonly property int replayCount: 6

  function replayHistory() {
    var rows = currentHistory().slice(0, replayCount)
    // Replaying nothing at all looks like a dead keybinding, so say so.
    if (rows.length === 0) showPlaceholder(I18n.t("notifications.noneRecent"))
    else restoreRows(rows, true)
  }

  function showPlaceholder(summary) {
    var key = "placeholder" + nextKey()
    if (!reserveLive(key)) return
    var row = Store.normalise({ key: key, app: "omarchy-action", summary: summary, glyph: "\u{f009a}",
                                urgency: NotificationUrgency.Low, ts: Date.now() / 1000 })
    row.duration = lowDuration
    row.restored = true
    showRow(row)
  }

  // ------------------------------------------------------------- the panel
  //
  // The panel lives with the bar's indicator (one per monitor); requests go
  // through here and the focused monitor's indicator answers.
  signal panelRequested(string action, string screenName)
  readonly property url panelUrl: Qt.resolvedUrl("NotificationPanel.qml")

  // Tracked here because the indicator moves between separate bar instances
  // as the quiet state changes.
  property var openPanel: null
  function notePanel(panel, opened) {
    if (opened) {
      if (openPanel && openPanel !== panel) openPanel.close()
      openPanel = panel
    } else if (openPanel === panel) {
      openPanel = null
    }
  }

  function requestPanel(action, screenName) {
    var what = String(action || "toggle")
    if (openPanel) {
      if (what === "close" || what === "toggle") openPanel.close()
      return "ok"
    }
    if (what !== "close") panelRequested(what, String(screenName || focusedDisplayName))
    return "ok"
  }

  // ------------------------------------------------------------- IPC
  //
  // Keybindings run these handlers directly as global shortcuts, with no client to spawn.
  function runShortcut(method) {
    if (typeof ipcHandler[method] !== "function") return false
    ipcHandler[method]()
    return true
  }

  ShellIpc {
    id: ipcHandler
    target: "notifications"

    function ping(): string { return "ok" }

    function isDnd(): string { return service.doNotDisturb ? "on" : "off" }

    function toggleDnd(): string {
      service.setDoNotDisturb(!service.doNotDisturb)
      return isDnd()
    }

    function setDnd(value: string): string {
      var v = String(value || "").toLowerCase()
      service.setDoNotDisturb(v === "true" || v === "1" || v === "on" || v === "yes")
      return isDnd()
    }

    // Dismiss the newest card on screen.
    function dismissOne(): string { return service.dismissNewest() ? "ok" : "none" }

    // Every card, every stack.
    function dismissAll(): string { service.clearAll("dismissed"); return "ok" }

    // Click the newest card, as the pointer would.
    function invokeLast(): string {
      if (toasts.count === 0) return "none"
      service.activate(String(toasts.get(0).key))
      return "ok"
    }

    // Put the last few back on screen.
    function showHistory(): string { service.replayHistory(); return "ok" }

    // Take cards off the screen by summary substring, used by the first-run
    // notifications once their action has been clicked.
    function dismiss(summary: string): string {
      var needle = String(summary || "")
      if (!needle) return "none"
      var keys = []
      for (var i = 0; i < toasts.count; i++)
        if (String(toasts.get(i).summary || "").indexOf(needle) !== -1)
          keys.push(String(toasts.get(i).key))
      for (var k = 0; k < keys.length; k++) service.closeToast(keys[k], "dismissed")
      return keys.length ? "ok" : "none"
    }

    function count(): string { return String(toasts.count) }

    // Open the deck as hovering would, or close it again. A headless session
    // has no pointer.
    function expand(): string {
      if (service.expanded) {
        service.commit(function() {
          service.expanded = false; service.openDeck = ""; service.hoverKey = ""
        })
      } else if (toasts.count > 0) {
        var front = toasts.get(0)
        service.pointerEntered(Layout.groupKeyFor(front))
        service.hoverKey = String(front.key)
      } else {
        service.pointerEntered(undefined)
      }
      return service.expanded ? "expanded" : "collapsed"
    }

    function openPanel(): string { return service.requestPanel("open") }
    function closePanel(): string { return service.requestPanel("close") }

    // What the daemon thinks is true, for scripts to check.
    function probe(): string {
      return JSON.stringify({ toasts: toasts.count,
        doNotDisturb: service.doNotDisturb, expanded: service.expanded,
        sharingActive: service.sharingActive, sharingStreams: service.sharingStreams,
        sharingOfferPending: service.sharingOfferPending, offerSnoozeWhenSharing: service.offerSnoozeWhenSharing,
        globalSnoozeUntil: service.globalSnoozeUntil,
        displayMode: service.displayMode, displayName: service.displayName,
        displays: service.displayNames, focusedDisplay: service.focusedDisplayName,
        targetDisplay: service.targetDisplayName,
        notificationDisplays: service.displayNames.filter(function(name) { return service.showsOn(name) }),
        stepsAside: service.stepsAside, surfaces: service.surfaceStates() })
    }
  }

  // ------------------------------------------------------------- surface
  //
  // One fixed-size layer per output, so the compositor never scales a stale
  // buffer; the mask makes everything outside the deck click-through. It stays
  // mapped while idle (remapping re-evaluates focus and drags a scrolling
  // layout's viewport), except where it steps aside for a fullscreen window.
  Variants {
    id: surfaceVariants
    model: Quickshell.screens

    PanelWindow {
      id: surface
      required property var modelData
      screen: modelData
      readonly property bool showingNotifications: service.showsOn(String(modelData.name))
      readonly property var margins: service.marginsFor(String(modelData.name))
      readonly property bool stepAside: service.fullscreenOn(String(modelData.name))
      readonly property bool hasSomethingToShow: showingNotifications && toasts.count > 0
      // Holds the canvas for the last card's exit animation.
      property bool lingering: false
      onHasSomethingToShowChanged: {
        if (hasSomethingToShow) lingering = false
        else { lingering = true; lingerTimer.restart() }
      }
      Timer { id: lingerTimer; interval: 800; onTriggered: surface.lingering = false }
      visible: !stepAside || hasSomethingToShow || lingering
      color: "transparent"

      WlrLayershell.namespace: "omarchy-notifications"
      WlrLayershell.layer: WlrLayer.Overlay
      exclusionMode: ExclusionMode.Ignore

      // Constant width and full height, so the buffer is allocated once.
      anchors { top: true; bottom: true; right: true }
      implicitWidth: clipper.width + Style.space(10)

      mask: Region { item: surface.showingNotifications ? deck : null }

      Item {
        id: clipper
        visible: surface.showingNotifications
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: surface.margins.top
        // Room for the arrival's scale animation, and the gap from the edge.
        readonly property int motionInset: Style.spacing.sm
        width: service.notificationWidth + motionInset + surface.margins.right
        height: deck.y + deck.height + motionInset
        clip: true

        Item {
          id: deck
          x: clipper.motionInset
          width: service.notificationWidth
          height: service.deckHeight

          // One hover region over the whole deck, so crossing between cards does
          // not flicker it shut. It accepts no buttons; clicks reach the cards.
          MouseArea {
            id: hoverArea
            z: 5000
            anchors.fill: parent
            anchors.margins: -Style.space(4)
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true

            // The cards cannot see hover under this region, so they are told.
            function hoverAt(x, y) {
              service.hoverX = x
              service.hoverY = y
              var places = service.placements
              var found = ""
              for (var key in places) {
                var pl = places[key]
                if (pl.hidden) continue
                var h = pl.height || Style.space(58)
                if (y >= pl.y && y <= pl.y + h) { found = key; break }
              }
              service.hoverKey = found
            }

            // Cards move under a still pointer after a dismissal: re-hit-test
            // once settled, or a second click invokes a stale card.
            Connections {
              target: service
              function onSettled() {
                Qt.callLater(function() {
                  if (hoverArea.containsMouse)
                    hoverArea.hoverAt(hoverArea.mouseX, hoverArea.mouseY)
                })
              }
            }

            onContainsMouseChanged: {
              service.pointerIn = containsMouse
              if (containsMouse) {
                service.pointerEntered(undefined)
                hoverAt(mouseX, mouseY)
              } else {
                service.hoverKey = ""
                service.pointerLeft()
              }
            }
            onPositionChanged: function(mouse) {
              hoverAt(mouse.x, mouse.y)

              // Which deck you are over decides which opens.
              var decks = service.layout.decks
              for (var i = 0; i < decks.length; i++) {
                var first = decks[i].rows[0]
                var place = service.layout.placements[first.key]
                if (!place) continue
                var top = place.y
                var bottom = top + (service.heights[first.key] || Style.space(58))
                if (mouse.y >= top - Style.space(6) && mouse.y <= bottom + Style.space(6)) {
                  service.pointerEntered(decks[i].key)
                  return
                }
              }
            }
          }

          Repeater {
            model: toasts

            Toast {
              required property var model
              row: model
              scene: service
              cardWidth: deck.width
              place: service.placements[model.key]
                     || ({ y: 0, scale: 1, opacity: 0, z: 1, front: false, hidden: true })
              hovered: service.hoverKey === model.key
              actions: service.actionsOf(model.key, service.refsRevision)
              hoverX: service.hoverX
              hoverY: service.hoverY
              onActionInvoked: function(identifier) { service.invokeAction(model.key, identifier) }
              onCodeCopied: function(code) { service.copyCode(code, model.key) }
              now: service.nowTick
              expanded: service.expanded
                        && service.openDeck === Layout.groupKeyFor(model)
              // Hover opens the body only when there is nothing else to open.
              sole: toasts.count === 1
              paused: service.expanded

              drawnHeight: service.at(model.key, "height")
              // A hidden output collapses child visibility; its measurements
              // must not overwrite the visible deck's heights.
              onTargetHeightChanged: if (surface.showingNotifications) service.noteHeight(model.key, targetHeight)
              Component.onCompleted: if (surface.showingNotifications) service.noteHeight(model.key, targetHeight)

              onExpired: service.closeToast(model.key, "expired")
              onActivated: service.activate(model.key)
              onDismissed: service.closeToast(model.key, "dismissed")
              snoozeOptions: service.snoozeOptions
              onSnoozeRequested: function(seconds) {
                service.snoozeSource(String(model.groupKey || ""),
                                     String(model.source || model.app || ""), seconds)
              }
            }
          }
        }
      }
    }
  }
}
