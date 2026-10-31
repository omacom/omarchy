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
import qs.Commons
import qs.Commons as Commons

import "Store.js" as Store
import "Security.js" as Security
import "Layout.js" as Layout
import "Markup.js" as Markup
import "Delivery.js" as Delivery
import "Icons.js" as Icons

Item {
  id: service

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  // ------------------------------------------------------------- displays
  //
  // A new deck lands on the focused output and stays there until it empties.
  property string deckDisplayName: ""
  readonly property var displayNames: Quickshell.screens.map(function(screen) { return screen.name })
  readonly property string focusedDisplayName: {
    var name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
    return displayNames.indexOf(name) >= 0 ? name : (displayNames[0] || "")
  }
  readonly property string targetDisplayName: displayNames.indexOf(deckDisplayName) >= 0 ? deckDisplayName : focusedDisplayName
  onDisplayNamesChanged: {
    if (deckDisplayName && displayNames.indexOf(deckDisplayName) < 0)
      deckDisplayName = focusedDisplayName
  }
  function pinDeckDisplay() {
    if (toasts.count === 0) deckDisplayName = focusedDisplayName
  }

  function showsOn(name) {
    return name === targetDisplayName
  }

  // ------------------------------------------------------------- quiet
  //
  property bool doNotDisturb: false
  function setDoNotDisturb(value) {
    var on = !!value
    if (on === doNotDisturb) return
    doNotDisturb = on
    saveQuiet()
  }

  // Persisted: nothing on screen says the desktop is quiet, so a reload must not lift it.
  function saveQuiet() { saveSoon("quiet") }

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
                 stepAside: s.stepAside === true, showing: s.showingNotifications === true })
    }
    return out
  }

  function fullscreenOn(name) {
    var revision = hyprRevision
    if (!name) return false
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

  // ------------------------------------------------------------- state
  //
  // Live Notification objects stay in a JS map, never the model: a QObject in a
  // ListModel role dangles once the server destroys it and crashes the next read.
  property var refs: ({})
  property int refsRevision: 0
  property int keySeed: 0

  ListModel {
    id: toasts
    onCountChanged: {
      if (count === 0) service.deckDisplayName = ""
      if (service.keyboardMode) Qt.callLater(function() { service.keepSelection(0) })
    }
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
  // Cards that arrived since the deck last opened or closed. Once still, they
  // settle into their measured height at once (a late icon, a re-wrap) instead
  // of growing; while they are still dropping in, the move takes it up.
  property var fresh: ({})
  onExpandedChanged: fresh = ({})
  property string arriving: ""

  Timer {
    id: collapseGrace
    interval: 120
    onTriggered: {
      // The keyboard holds the deck open while the pointer passes through.
      if (service.keyboardMode) return
      service.commit(function() { service.expanded = false; service.openDeck = "" })
      service.releaseHeld()
    }
  }

  // New cards wait while the deck is held open, so nothing moves mid-read.
  property var held: []

  function holding() { return (pointerIn || keyboardMode) && expanded }

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

  // ------------------------------------------------------------- keyboard
  //
  // Notifications never take the keyboard on their own: a card grabbing focus
  // as it arrived would swallow whatever you were typing. A keybinding starts
  // this instead. The newest card is selected and its deck opened; arrows move
  // between cards, number keys press a button, Enter clicks the card, Delete
  // dismisses it, and Escape, any choice, or a few idle seconds give the
  // keyboard back.
  property bool keyboardMode: false
  property string keyboardKey: ""
  // Cards that fit only until selection showed their buttons, skipped for the
  // rest of this session so Down does not keep landing on them.
  property var keyboardRejected: ({})

  Timer { id: keyboardIdle; interval: 10000; onTriggered: service.stopKeyboard() }

  // Cards in the order they stand: deck by deck, front to back.
  function keyboardOrder() {
    var out = [], decks = layout.decks
    for (var i = 0; i < decks.length; i++)
      for (var j = 0; j < decks[i].rows.length; j++) out.push(String(decks[i].rows[j].key))
    return out
  }

  function selectCard(key) {
    var at = rowIndexFor(key)
    if (at < 0) return false
    keyboardKey = key
    hoverKey = key
    pointerEntered(Layout.groupKeyFor(toasts.get(at)))
    return true
  }

  function startKeyboard(key) {
    var order = keyboardOrder()
    if (!order.length) return false
    keyboardMode = true
    keyboardRejected = ({})
    selectCard(order.indexOf(key) >= 0 ? key : order[0])
    keyboardIdle.restart()
    return true
  }

  function stopKeyboard() {
    if (!keyboardMode) return
    keyboardIdle.stop()
    keyboardMode = false
    keyboardKey = ""
    // With the pointer over the deck, hover stays where the pointer put it.
    if (!pointerIn) {
      hoverKey = ""
      collapseGrace.restart()
    }
  }

  // The selected card went away: select the one that took its place, or the
  // nearest one above it on screen, or stop.
  function keepSelection(fromIndex) {
    if (!keyboardMode || rowIndexFor(keyboardKey) >= 0 && !leaving[keyboardKey]) return
    var order = keyboardOrder()
    for (var i = Math.min(Math.max(0, fromIndex), order.length - 1); i >= 0; i--) {
      if (!keyboardRejected[order[i]] && reachable(order[i])) { selectCard(order[i]); return }
    }
    stopKeyboard()
  }

  // The deck does not scroll, so a card that would open below the bottom of
  // the screen is out of reach, for the keyboard as for the pointer.
  function reachable(key) {
    var at = rowIndexFor(key)
    if (at < 0) return false
    var place = layoutWith(true, Layout.groupKeyFor(toasts.get(at))).placements[key]
    if (!place || place.hidden) return false
    var screen = null
    for (var s = 0; s < Quickshell.screens.length; s++)
      if (String(Quickshell.screens[s].name) === targetDisplayName) screen = Quickshell.screens[s]
    if (!screen) return true
    var room = screen.height - marginsFor(targetDisplayName).top - gap
    return place.y + (place.height || Style.space(58)) <= room
  }

  // Past cards that do not fit: the rest of a long deck can be out of reach
  // while the next deck, opened in its place, is not.
  function moveSelection(step) {
    var order = keyboardOrder()
    for (var next = order.indexOf(keyboardKey) + step; next >= 0 && next < order.length; next += step) {
      if (!keyboardRejected[order[next]] && reachable(order[next])) { selectCard(order[next]); return }
    }
  }

  // Selecting a card shows its buttons and opening its deck can open its body,
  // so it grows after reachable() said yes. Once it has, step back if it no
  // longer fits.
  function keepSelectionInReach() {
    if (!keyboardMode || reachable(keyboardKey)) return
    keyboardRejected[keyboardKey] = true
    var order = keyboardOrder()
    for (var i = order.indexOf(keyboardKey) - 1; i >= 0; i--) {
      if (!keyboardRejected[order[i]] && reachable(order[i])) { selectCard(order[i]); return }
    }
  }

  // The card's buttons in Delivery.deeds' order, which the card draws and
  // numbers in the same order.
  function deedsFor(key) {
    var at = rowIndexFor(key)
    return at < 0 ? [] : Delivery.deeds(toasts.get(at), actionsOf(key, refsRevision))
  }

  function runDeed(key, index) {
    var deed = deedsFor(key)[index]
    if (!deed) return false
    if (deed.kind === "code") copyCode(deed.value, key)
    else if (deed.kind === "exec") runExecAction(key, Number(deed.value))
    else invokeAction(key, String(deed.value))
    return true
  }

  // True when the key was ours.
  function keyboardPressed(key, text) {
    if (!keyboardMode) return false
    keyboardIdle.restart()
    var selected = keyboardKey
    if (key === Qt.Key_Escape) {
      stopKeyboard()
    } else if (key === Qt.Key_Down || key === Qt.Key_J || key === Qt.Key_Tab) {
      moveSelection(1)
    } else if (key === Qt.Key_Up || key === Qt.Key_K || key === Qt.Key_Backtab) {
      moveSelection(-1)
    } else if (key === Qt.Key_Return || key === Qt.Key_Enter) {
      stopKeyboard()
      activate(selected)
    } else if (key === Qt.Key_Delete || key === Qt.Key_Backspace) {
      var at = keyboardOrder().indexOf(selected)
      closeToast(selected, "dismissed")
      keepSelection(at)
    } else if (/^[1-9]$/.test(text)) {
      if (Number(text) <= deedsFor(selected).length) {
        stopKeyboard()
        runDeed(selected, Number(text) - 1)
      }
    } else {
      return false
    }
    return true
  }

  // Fed target heights, never mid-animation ones, so layout moves on events.
  function noteHeight(key, h) {
    if (Math.abs((heights[key] || 0) - h) < 0.5) return
    // Measured while it is being inserted: the arrival's own move follows.
    if (key === arriving) {
      heights[key] = h
      return
    }
    if (fresh[key] && !expanded && !sceneRun.running) {
      heights[key] = h
      land()
    } else {
      commit(function() { service.heights[key] = h })
    }
    if (key === keyboardKey) keepSelectionInReach()
  }

  // ------------------------------------------------------- the scene clock
  //
  // One clock for the whole deck: each card interpolates from `was` to its
  // placement by t. A Behavior per card would restart on every retarget.
  // Style's strong ease-out, with no overshoot: the cards answer at once and settle
  // without a bounce. Whatever leaves (a card, an open deck) goes quicker than
  // it came, since nobody is waiting on it.
  readonly property var sceneCurve: Style.easeOut
  readonly property int arriveDuration: 250
  readonly property int leaveDuration: 200
  property int sceneDuration: arriveDuration
  // How far a card drops in from, and rises by on its way out.
  readonly property real travel: Style.space(24)

  property real t: 1                 // 0..1, eased, shared by every card
  property var was: ({})             // where each card was when the target moved
  property real deckWas: 0
  // Set while a change lands without the clock, so the cards' text jumps too.
  property bool jumping: false

  NumberAnimation {
    id: sceneRun
    target: service; property: "t"; from: 0; to: 1
    duration: Math.max(1, Style.duration(service.sceneDuration))
    easing.type: Easing.Bezier
    easing.bezierCurve: service.sceneCurve
    onFinished: {
      service.finishLeaving()
      service.settled()
    }
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
    retarget(snap, deckNow, expanded ? arriveDuration : leaveDuration)
  }

  function retarget(snap, deckNow, duration) {
    if (!snap) { snap = snapshot(); deckNow = deckHeight }
    deckWas = deckNow
    was = snap
    sceneDuration = duration || arriveDuration
    layoutRevision += 1
    t = 0
    sceneRun.restart()
  }

  // Keyboard dismissals skip the clock: everything jumps to its place.
  function land() {
    sceneRun.stop()
    jumping = true
    layoutRevision += 1
    t = 1
    jumping = false
    Qt.callLater(landed)
  }

  // Cards come to rest when the clock finishes or a jump has been drawn.
  signal settled()
  // A move started after the jump settles on its own finish instead.
  function landed() { if (t >= 1) settled() }

  readonly property var layout: { layoutRevision; return layoutWith(expanded, openDeck) }

  // The deck as it would stand with this deck open; the keyboard asks before
  // it moves.
  function layoutWith(isExpanded, deckKey) {
    var rows = []
    for (var i = 0; i < toasts.count; i++) {
      var row = toasts.get(i)
      if (!leaving[row.key]) rows.push(row)   // a card on its way out takes no space
    }
    return Layout.compute(rows, {
      expanded: isExpanded,
      openDeck: deckKey,
      gap: gap,
      deckGap: Style.space(11),
      heightOf: function(key) { return service.heights[key] || Style.space(58) }
    })
  }

  // A leaving card takes no room in the layout but keeps a placement of its
  // own, rising out of where it was while the others close over it.
  // Copied, not borrowed: writing it into layout.placements would mutate this
  // binding's own input while reading it.
  property var departures: ({})
  readonly property var placements: {
    var out = {}
    var base = layout.placements
    for (var k in base) out[k] = base[k]
    for (var key in leaving) if (departures[key]) out[key] = departures[key]
    return out
  }

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

    var previous = refs[key]
    refs[key] = notification
    refsRevision += 1
    if (previous !== notification) watchNotification(notification, key)
    if (previous && previous !== notification) {
      try { previous.tracked = false } catch (e) {}
    }

    // Quiet still records it (unless ephemeral), straight to history.
    var muted = Delivery.quietReason(row, doNotDisturb)
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
      var snap = service.snapshot(), deckNow = service.deckHeight
      if (at >= 0) {
        // A sender replacing a card on its way out gives it a fresh life:
        // it comes back, rather than leaving with the new words on it.
        if (service.leaving[key]) service.unmarkLeaving(key)
        Store.applyTo(toasts, at, row)      // an update, in place
        service.retarget(snap, deckNow)
      } else {
        service.pinDeckDisplay()
        // Before the insert: the delegate measures itself while it is built.
        service.fresh[key] = true
        service.arriving = key
        toasts.insert(0, row)
        service.arriving = ""
        // It drops in from just above where it lands, from under the bar for
        // the top card, and fades in on the way.
        var landing = service.layout.placements[key]
        snap[key] = { y: (landing ? landing.y : 0) - service.travel,
                      scale: landing ? landing.scale : 1, opacity: 0,
                      height: landing ? landing.height : 0 }
        service.retarget(snap, deckNow, service.arriveDuration)
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
  // A leaving row loses its layout room at once but keeps its model slot until
  // it has risen out of sight. Dismissed from the keyboard, it vanishes and
  // goes on the next tick instead: removing it from inside the delegate
  // handler that dismissed it would destroy that delegate mid-call.
  property var leaving: ({})

  function closeToast(key, reason, instant) { closeToasts([key], reason, instant) }

  // One move, or one jump, for the lot, however many cards leave together.
  function closeToasts(keys, reason, instant) {
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
    if (instant) {
      jumping = true
      leaving = next
      jumping = false
      land()
      Qt.callLater(finishLeaving)
      return
    }
    var snap = snapshot(), deckNow = deckHeight
    var staying = 0
    for (var r = 0; r < toasts.count; r++) if (!next[toasts.get(r).key]) staying++
    var gone = {}
    for (var d in departures) gone[d] = departures[d]
    for (var j = 0; j < keys.length; j++) {
      var from = snap[keys[j]], place = placements[keys[j]]
      if (!next[keys[j]] || gone[keys[j]] || !from) continue
      // Under the cards closing in, so the one taking its place covers it on
      // the way up. Its text goes first, or it would read through them; the
      // last card keeps its words, with nothing to cover it.
      gone[keys[j]] = { y: from.y - travel, scale: from.scale, opacity: 0, height: from.height,
                        z: 0, front: staying === 0, hidden: place ? place.hidden === true : true,
                        leaving: true, until: Date.now() + Style.duration(leaveDuration) }
    }
    departures = gone
    leaving = next
    retarget(snap, deckNow, leaveDuration)
    if (!departureDeadline.running) departureDeadline.start()
  }

  // A departure ends on its own clock, not the scene's: arrivals and updates
  // restart that, and a card updating every tick would otherwise keep every
  // closed card on screen, and counted against the limit, for good.
  Timer {
    id: departureDeadline
    interval: Math.max(1, Style.duration(service.leaveDuration))
    onTriggered: service.finishDeparted(Date.now())
  }

  function finishDeparted(now) {
    var keys = Object.keys(departures), waiting = false
    for (var i = 0; i < keys.length; i++) {
      if (departures[keys[i]].until <= now) finishClose(keys[i], leaving[keys[i]])
      else waiting = true
    }
    if (waiting) departureDeadline.restart()
  }

  function finishLeaving() {
    var keys = Object.keys(leaving)
    for (var i = 0; i < keys.length; i++) finishClose(keys[i], leaving[keys[i]])
  }

  function unmarkLeaving(key) {
    var rest = {}, stay = {}
    for (var k in leaving) if (k !== key) rest[k] = leaving[k]
    for (var g in departures) if (g !== key) stay[g] = departures[g]
    leaving = rest
    departures = stay
  }

  function finishClose(key, reason) {
    unmarkLeaving(key)
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
  function clearAll(reason, instant) {
    var keys = Object.keys(liveKeys)
    closeToasts(keys, reason, instant)
    return keys.length
  }

  // The newest card still on screen, past any on their way out.
  function newestLive() {
    for (var i = 0; i < toasts.count; i++) {
      var key = String(toasts.get(i).key)
      if (!leaving[key]) return key
    }
    return ""
  }

  function dismissNewest(instant) {
    var key = newestLive()
    if (!key) return false
    closeToast(key, "dismissed", instant)
    return true
  }

  // The newest card, by what it offers, its click counting as one: with
  // nothing it is dismissed, with one thing that is done, and with more it
  // takes the keyboard so you can pick.
  function actOnNewest() {
    var key = newestLive()
    if (!key) return false
    var deeds = deedsFor(key).length
    var click = clickable(key)
    if (deeds + (click ? 1 : 0) > 1) startKeyboard(key)
    else if (click) activate(key, true)
    else if (deeds) runDeed(key, 0)
    else closeToast(key, "dismissed", true)
    return true
  }

  // Whether a click does something of the card's own: Omarchy's --exec
  // command, the sender's default action, the sender's own window, or a site
  // to go to. Focusing an app by its name alone does not count.
  function clickable(key) {
    var at = rowIndexFor(key)
    if (at < 0) return false
    var row = toasts.get(at)
    if (Security.parseExecArgv(row.execArgv)) return true
    var ref = refs[key]
    var actions = (ref && ref.actions) || []
    for (var i = 0; i < Math.min(actions.length, Security.MAX_ACTIONS); i++)
      if (String(actions[i].identifier) === "default") return true
    return !!(windowForPid(row.senderPid) || Markup.hostname(row.source) || String(row.link || ""))
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

  // An --action button: its argv runs like the click command does.
  function runExecAction(key, index) {
    var at = rowIndexFor(key)
    var actions = Security.parseExecActions(at >= 0 ? toasts.get(at).execActions : "")
    if (!actions || index < 0 || index >= actions.length) return
    Util.execArgv(actions[index].argv)
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
  function activate(key, instant) {
    var at = rowIndexFor(key)
    var row = at >= 0 ? toasts.get(at) : null
    var argv = Security.parseExecArgv(row ? row.execArgv : "")
    if (argv) {
      // Detached through bash positional parameters, never a shell string, and
      // outliving the shell, which installer toasts restart on their first act.
      Util.execArgv(argv)
      closeToast(key, "activated", instant)
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
    closeToast(key, "activated", instant)
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
    // The transient hint asks to by-pass persistence: such a card is not
    // restored after a restart or kept in history, and its sender sends it
    // again when it still applies. An update that turns a card transient takes
    // its stored row out.
    if (row.transient) {
      storeDrop(row.key)
      return
    }
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
    historyEntries = Store.addHistory(historyEntries, Store.closedEntry(row, reason, now), now)
    saveSoon("history")
  }

  // History as of now: rows past their retention go, from disk too.
  function currentHistory() {
    var kept = Store.retain(historyEntries, Date.now() / 1000)
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
      quietFile.setText(Store.serialiseQuiet({ dnd: doNotDisturb }))
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
    historyEntries = Store.retain(historyEntries.concat(Store.parseHistory(text)), Date.now() / 1000)
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
      doNotDisturb = read.dnd
    }
    quietLoaded = true
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
        row.groupKey = Markup.regroup(row)
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

    // Dismiss, press the one button on, or focus the newest card on screen.
    // These are what the keybindings run, and a keypress is answered at once,
    // without motion.
    function act(): string { return service.actOnNewest() ? "ok" : "none" }

    // Dismiss the newest card on screen.
    function dismissOne(): string { return service.dismissNewest(true) ? "ok" : "none" }

    // Every card, every stack.
    function dismissAll(): string { service.clearAll("dismissed", true); return "ok" }

    // Click the newest card, as the pointer would.
    function invokeLast(): string {
      var key = service.newestLive()
      if (!key) return "none"
      service.activate(key, true)
      return "ok"
    }

    // Press button n (from 1) on the newest card.
    function invokeAction(n: int): string {
      if (toasts.count === 0) return "none"
      return service.runDeed(String(toasts.get(0).key), n - 1) ? "ok" : "none"
    }

    // Hand the keyboard to the notifications until Escape or a choice.
    function keyboard(): string {
      if (service.keyboardMode) { service.stopKeyboard(); return "off" }
      return service.startKeyboard() ? "on" : "none"
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


    // What the daemon thinks is true, for scripts to check.
    function probe(): string {
      return JSON.stringify({ toasts: toasts.count,
        doNotDisturb: service.doNotDisturb, expanded: service.expanded,
        keyboardMode: service.keyboardMode, keyboardKey: service.keyboardKey,
        displays: service.displayNames, focusedDisplay: service.focusedDisplayName,
        targetDisplay: service.targetDisplayName,
        notificationDisplays: service.displayNames.filter(function(name) { return service.showsOn(name) }),
        surfaces: service.surfaceStates() })
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
      visible: !stepAside || hasSomethingToShow
      color: "transparent"

      WlrLayershell.namespace: "omarchy-notifications"
      WlrLayershell.layer: WlrLayer.Overlay
      readonly property bool takesKeyboard: service.keyboardMode && service.targetDisplayName === String(modelData.name)
      WlrLayershell.keyboardFocus: takesKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore

      // Constant width and full height, so the buffer is allocated once.
      anchors { top: true; bottom: true; right: true }
      implicitWidth: clipper.width + Style.space(10)

      mask: Region { item: surface.showingNotifications ? deck : null }

      Item {
        focus: surface.takesKeyboard
        Keys.onPressed: function(event) {
          event.accepted = service.keyboardPressed(event.key, event.text)
        }
      }

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
                if (pl.hidden || pl.leaving) continue
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
                  // Opening another deck would hide the keyboard's card.
                  if (service.keyboardMode && decks[i].key !== service.openDeck) service.stopKeyboard()
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
              hovered: service.keyboardMode ? service.keyboardKey === model.key : service.hoverKey === model.key
              selected: service.keyboardMode && service.keyboardKey === model.key
              actions: service.actionsOf(model.key, service.refsRevision)
              hoverX: service.hoverX
              hoverY: service.hoverY
              // A click is the mouse taking over: it ends keyboard mode, which
              // would otherwise keep the keyboard from the app it opened.
              onActionInvoked: function(identifier) { service.stopKeyboard(); service.invokeAction(model.key, identifier) }
              onExecInvoked: function(index) { service.stopKeyboard(); service.runExecAction(model.key, index) }
              onCodeCopied: function(code) { service.stopKeyboard(); service.copyCode(code, model.key) }
              onLinkOpened: service.stopKeyboard()
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
              onActivated: { service.stopKeyboard(); service.activate(model.key) }
              onDismissed: { service.stopKeyboard(); service.closeToast(model.key, "dismissed") }
            }
          }
        }
      }
    }
  }
}
