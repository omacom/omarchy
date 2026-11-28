import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

// The clock's calendar popup: a month grid with ISO week numbers, built to
// sit beside the weather panel — same hero-over-detail composition, same
// spacing scale, same small-caps labels.
//
// The grid is a read-out rather than a picker: today is the only marked
// day, and the only thing that moves is which month is on screen —
// chevrons, the scroll wheel, and the arrow keys all step it.
//
// BarWidget.qml owns the bar label and hands this panel the button to
// anchor against.
Panel {
  id: root
  moduleName: "omarchy.clock"
  ipcTarget: "omarchy.clock"
  manageIpc: false

  property var anchorItem: null

  // The bar tracks the widget mounted in its slot — BarWidget.qml — not this
  // nested panel. Everything the bar identifies a panel by has to be that
  // widget: the popout coordinator (and with it the open-panel dot under the
  // pill) compares against `slot.activeItem`, and switchPanelFrom looks the
  // slot up the same way.
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  // ---- Today. The wall clock keeps this honest across midnight so the
  //      highlight rolls over without the panel being reopened.
  property date today: new Date()
  readonly property string todayKey: Model.keyForDate(today)

  // The month on screen. Stepping moves this and nothing else: the grid is
  // a read-out, not a picker, so there is no per-day cursor to keep in sync.
  property int viewYear: today.getFullYear()
  property int viewMonth: today.getMonth()

  // Local noon, so a first of the month with no midnight (Havana, April 2012)
  // still names its own month; UTC would name the previous one west of Greenwich.
  readonly property date viewDate: new Date(viewYear, viewMonth, 1, 12)
  readonly property bool viewingCurrentMonth: viewYear === today.getFullYear() && viewMonth === today.getMonth()

  // Pinned to today, not to the month being browsed — stepping through the
  // calendar does not change how much of the year is gone.
  readonly property real yearDone: Model.yearProgress(today.getFullYear(), today.getMonth(), today.getDate())
  readonly property int yearDonePercent: Model.yearProgressPercent(today.getFullYear(), today.getMonth(), today.getDate())

  // Memento mori, for anyone who goes looking: double-tapping the year bar
  // asks for a birth year and a life expectancy, and a second bar tracks one
  // against the other. A birth year rather than an age, so it keeps counting
  // on its own. Without one the bar stays hidden.
  readonly property int birthYear: Model.parseBirthYear(setting("birthYear", 0), today.getFullYear())
  readonly property int age: Model.ageFromBirthYear(birthYear, today.getFullYear())
  readonly property int lifeExpectancy: Model.parseLifeExpectancy(setting("lifeExpectancy", 0))
  readonly property real lifeDone: Model.lifeProgress(age, lifeExpectancy)
  readonly property int lifeDonePercent: Model.lifeProgressPercent(age, lifeExpectancy)
  property bool editingLife: false

  // Unset falls through to the locale's own first day, so a fresh install
  // starts out matching the rest of the desktop rather than a hardcoded
  // convention. Clicking the grid's "W" heading writes the choice back to
  // shell.json.
  readonly property int weekStart: Model.normalizedWeekStart(setting("weekStartDay", null), labelLocale.firstDayOfWeek)
  // Names and the default week start follow the Omarchy language rather than
  // the system locale, which only catches up at the next login.
  readonly property var labelLocale: Qt.locale(Commons.I18n.formatLocale)
  // Qt's MMMM is the genitive form ("октября"), right beside a day but not
  // in a month heading, so the title takes the standalone name ("октябрь")
  // and lets each language order it against the year.
  readonly property string monthYearLabel: Commons.I18n.t("clock.monthYear")
    .arg(labelLocale.standaloneMonthName(viewMonth, Locale.LongFormat))
    .arg(viewDate.toLocaleDateString(labelLocale, "yyyy"))
  readonly property string nextWeekStartLabel: labelLocale.dayName(Model.toggledWeekStart(weekStart), Locale.LongFormat)
  readonly property var weekdays: Model.weekdayOrder(weekStart)
  readonly property var weeks: Model.monthGrid(viewYear, viewMonth, weekStart, todayKey)


  // ---- Countdown timers and stopwatches under the calendar. Each is kept
  //      as timestamps rather than a counter, so it stays exact while the
  //      popup is closed and one shared ticker is all that runs. They live
  //      on the panel, not the popup, so closing the calendar does not stop
  //      them, and the bar label reads the most pressing one back.
  readonly property var timerPresets: [60, 300, 600, 1500]
  readonly property int maxTimers: 5
  // Countdowns are { kind: "timer", id, name, total, endsAt, pausedRemaining,
  // running }; stopwatches are { kind: "stopwatch", id, name, startedAt,
  // elapsedBefore, running }. Always replaced, never mutated in place, so
  // bindings see every change.
  //
  // The bar builds this panel once per monitor, but the timers are one list.
  // The first instance owns it: it holds the records, ticks, saves the state
  // file and notifies. Every other instance reads the owner's list and sends
  // its changes there, so no two copies can drift or overwrite each other.
  readonly property var timerOwner: {
    if (!root.bar || typeof root.bar.moduleWidgets !== "function") return root
    var instances = root.bar.moduleWidgets(root.moduleName)
    var first = instances.length > 0 ? instances[0] : null
    return first && first.timerPanel ? first.timerPanel : root
  }
  readonly property bool ownsTimers: timerOwner === root
  // This instance's own copy, used while it is the owner (and, at startup,
  // before the bar has said who is).
  property var ownTimers: []
  property real ownTimerNow: Date.now()
  property int ownBarTimerId: 0
  readonly property var timers: ownsTimers ? ownTimers : timerOwner.timers
  property int timerSerial: 0
  // The list is mirrored to a state file so a shell restart (or a reboot)
  // picks every timer back up where it was: the records are timestamps, so
  // nothing drifts while the shell is down. Nothing is written until the
  // file has been read, or an early save would wipe what it held.
  readonly property string timersStateDir: Quickshell.env("HOME") + "/.local/state/omarchy"
  readonly property string timersStatePath: timersStateDir + "/clock-timers.json"
  property bool timersRestored: false
  // What the file last held, so a save that changes nothing is skipped.
  property string timersStateText: ""
  readonly property real timerNow: ownsTimers ? ownTimerNow : timerOwner.timerNow
  readonly property bool anyTimerRunning: timers.some(function(t) { return t.running })
  readonly property var soonestTimer: Model.soonestTimer(timers, timerNow)
  // With no countdown to show, the bar falls back to a stopwatch, running
  // ones first.
  readonly property var barStopwatch: {
    var first = null
    for (var i = 0; i < timers.length; i++) {
      var t = timers[i]
      if (t.kind !== "stopwatch") continue
      if (!first || (t.running && !first.running)) first = t
    }
    return first
  }
  // Scrolling over the bar label picks which one it shows; 0 means "the
  // most pressing", and a pick that has since finished falls back to it.
  readonly property int barTimerId: ownsTimers ? ownBarTimerId : timerOwner.barTimerId
  readonly property var barEntry: {
    for (var i = 0; i < timers.length; i++) if (timers[i].id === barTimerId) return timers[i]
    return soonestTimer ? soonestTimer.timer : barStopwatch
  }
  // What the bar shows beside the clock: the picked timer (by default the
  // soonest countdown, or else a stopwatch), its name, and how many others
  // are waiting behind it.
  readonly property string barTimerKind: barEntry ? (barEntry.kind === "stopwatch" ? "stopwatch" : "timer") : ""
  // The time alone, for the vertical bar's narrow stack.
  readonly property string barTimerTime: barEntry
    ? localDigits(barEntry.kind === "stopwatch" ? Model.formatElapsed(Model.stopwatchElapsed(barEntry, timerNow)) : Model.formatTimer(Model.timerRemaining(barEntry, timerNow)))
    : ""
  readonly property string barTimerText: barEntry
    ? localDigits(Model.barTimerLabel(barEntry, timerNow) + (timers.length > 1 ? " +" + (timers.length - 1) : ""))
    : ""

  // Timer read-outs are built from ASCII digits; this shows them in the
  // interface language's own.
  function localDigits(text) {
    return String(text).replace(/[0-9]/g, function(d) { return Commons.I18n.formatNumber(Number(d)) })
  }

  // "5m", "1h30m" in the interface language, for unnamed timers and presets.
  function shortTimerLabel(seconds) {
    return root.localDigits(Model.shortTimerLabel(seconds, function(key, english) {
      return Commons.I18n.t(key, english)
    }))
  }

  // Steps the bar label through the timers in panel order, wrapping.
  function cycleBarTimer(step) {
    if (!root.ownsTimers) return root.timerOwner.cycleBarTimer(step)
    if (timers.length < 2 || !barEntry) return false
    var index = 0
    for (var i = 0; i < timers.length; i++) if (timers[i].id === barEntry.id) index = i
    var next = (index + step + timers.length) % timers.length
    root.ownBarTimerId = timers[next].id
    return true
  }
  // Off unless asked for: a finished timer always notifies, and the sound is
  // an extra a desk shared with other people may not want.
  readonly property bool timerSound: Model.parseBool(setting("timerSound", false))
  readonly property string timerSoundFile: "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
  // The fields' text, held here so the controls can read it without reaching
  // into the popup's content.
  property string timerInput: "5:00"
  property string timerNameInput: ""
  readonly property bool timerInputValid: Model.parseTimerDuration(timerInput) > 0
  readonly property bool canAddTimer: timers.length < maxTimers
  // Holds the add row open for the frame it takes to become focusable when
  // the keyboard asks for it; hovering or a focused field keeps it open after.
  property bool timerAddPinned: false

  // Guarded so the widget renders before the bar is injected (the bar-widget
  // contract instantiates it bare).
  readonly property color contentForeground: bar ? bar.foreground : Commons.Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property int cellWidth: Style.space(52)
  readonly property int cellHeight: Style.space(34)
  readonly property int cellSpacing: Style.space(2)
  readonly property int weekColumnWidth: Style.space(32)
  readonly property int gutterWidth: Style.space(14)

  function open() {
    refresh()
    root.controller.show()
  }

  function close() {
    // Dismissing the panel mid-edit would otherwise leave the inputs up,
    // waiting behind a closed popup for the next time it opens.
    if (root.editingLife) root.cancelEditingLife()
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function refresh() {
    root.today = new Date()
    root.goToToday()
  }

  // The same catch-up for the calendar's own clock, which is how today moves
  // after a sleep that crossed midnight. Its onDateChanged keeps a browsed
  // month, where refresh() would send it back to today.
  function resync() {
    clock.resync()
  }

  function goToToday() {
    root.viewYear = today.getFullYear()
    root.viewMonth = today.getMonth()
  }

  function moveMonth(delta) {
    var next = Model.stepMonth(viewYear, viewMonth, delta)
    root.viewYear = next.year
    root.viewMonth = next.month
  }

  function moveYear(delta) {
    moveMonth(delta * 12)
  }

  // Applied locally first so the panel redraws on the click itself; the
  // shell.json write comes back through the bar as the same value. With no
  // writable entry (the widget is not in the layout) it stays a session-only
  // preference rather than doing nothing. The host widget builds its own
  // entry when the label format is cycled, so it has to be kept in step or
  // it would write this key straight back out from a stale copy.
  function persistSettings(values) {
    var entry = { id: root.moduleName }
    for (var existing in root.settings) if (existing !== "id") entry[existing] = root.settings[existing]
    for (var key in values) entry[key] = values[key]

    root.settings = entry
    if (root.hostWidget && "settings" in root.hostWidget) root.hostWidget.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  function setWeekStart(day) {
    var next = Model.normalizedWeekStart(day, root.weekStart)
    if (next === root.weekStart) return
    persistSettings({ weekStartDay: Model.weekStartSettingName(next) })
  }

  function startEditingLife() {
    root.editingLife = true
    Qt.callLater(function() {
      var content = panel.loadedContent
      if (!content) return
      var bornField = content.bornField
      var expectancyField = content.expectancyField
      bornField.text = root.birthYear > 0 ? String(root.birthYear) : ""
      expectancyField.text = String(root.lifeExpectancy)
      bornField.selectAll()
      bornField.forceActiveFocus()
    })
  }

  function cancelEditingLife() {
    root.editingLife = false
    Qt.callLater(function() { if (panel.loadedContent) panel.loadedContent.forceActiveFocus() })
  }

  // Shared by both fields: Tab hops to the other one, Enter commits the pair,
  // Escape drops the lot.
  function handleLifeKey(event, other) {
    if (event.key === Qt.Key_Escape) {
      root.cancelEditingLife()
      event.accepted = true
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      root.commitLife()
      event.accepted = true
    } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
      other.selectAll()
      other.forceActiveFocus()
      event.accepted = true
    }
  }

  // Double-tapping the life bar puts it away again. The expectancy stays in
  // the config so setting a birth year again brings your own number back
  // rather than the default.
  function clearLife() {
    if (root.birthYear <= 0) return
    persistSettings({ birthYear: 0 })
  }

  function commitLife() {
    var content = panel.loadedContent
    if (!content) return
    var bornField = content.bornField
    var expectancyField = content.expectancyField
    var born = Model.parseBirthYear(bornField.text, today.getFullYear())
    var span = Model.parseLifeExpectancy(expectancyField.text)
    if (born !== root.birthYear || span !== root.lifeExpectancy)
      persistSettings({ birthYear: born, lifeExpectancy: span })
    cancelEditingLife()
  }

  function toggleWeekStart() {
    setWeekStart(Model.toggledWeekStart(root.weekStart))
  }

  // The add functions report whether anything started, so only the panel the
  // name was typed in clears it, and only once it was used.
  function addTimer(seconds, name) {
    if (!root.startTimer(seconds, name)) return false
    root.timerNameInput = ""
    return true
  }

  function addStopwatch(name) {
    if (!root.startStopwatch(name)) return false
    root.timerNameInput = ""
    return true
  }

  function startTimer(seconds, name) {
    if (!root.ownsTimers) return root.timerOwner.startTimer(seconds, name)
    if (!(seconds > 0) || !root.canAddTimer || !root.timersRestored) return false
    var now = Date.now()
    root.timerSerial += 1
    root.ownTimerNow = now
    root.ownTimers = root.ownTimers.concat([{
      kind: "timer",
      id: root.timerSerial,
      name: String(name || "").trim(),
      total: seconds,
      endsAt: now + seconds * 1000,
      pausedRemaining: 0,
      running: true
    }])
    // What was just started is what the next key should act on.
    root.ownBarTimerId = root.timerSerial
    return true
  }

  function startStopwatch(name) {
    if (!root.ownsTimers) return root.timerOwner.startStopwatch(name)
    if (!root.canAddTimer || !root.timersRestored) return false
    var now = Date.now()
    root.timerSerial += 1
    root.ownTimerNow = now
    root.ownTimers = root.ownTimers.concat([{
      kind: "stopwatch",
      id: root.timerSerial,
      name: String(name || "").trim(),
      startedAt: now,
      elapsedBefore: 0,
      running: true
    }])
    // What was just started is what the next key should act on.
    root.ownBarTimerId = root.timerSerial
    return true
  }

  function addTimerFromFields() {
    root.addTimer(Model.parseTimerDuration(root.timerInput), root.timerNameInput)
  }

  function updateTimer(id, change) {
    if (!root.ownsTimers) return root.timerOwner.updateTimer(id, change)
    var now = Date.now()
    root.ownTimerNow = now
    root.ownTimers = root.ownTimers.map(function(t) {
      if (t.id !== id) return t
      var next = {}
      for (var key in t) next[key] = t[key]
      change(next, now)
      return next
    })
  }

  function toggleTimerPause(id) {
    root.updateTimer(id, function(t, now) {
      if (t.kind === "stopwatch") {
        if (t.running) t.elapsedBefore = Model.stopwatchElapsed(t, now)
        else t.startedAt = now
        t.running = !t.running
      } else if (t.running) {
        t.pausedRemaining = Model.timerRemaining(t, now)
        t.running = false
      } else {
        t.endsAt = now + t.pausedRemaining * 1000
        t.running = true
      }
    })
  }

  // ---- Keyboard actions on the timer the bar is showing, so the panel and
  //      the bar always agree on which one a key will touch.
  function toggleTargetPause() {
    if (!root.barEntry) return false
    root.toggleTimerPause(root.barEntry.id)
    return true
  }

  function cancelTarget() {
    if (root.barEntry) root.cancelTimer(root.barEntry.id)
  }

  function resetTarget() {
    if (root.barEntry && root.barEntry.kind === "stopwatch") root.resetStopwatch(root.barEntry.id)
  }

  function startPreset(index) {
    if (index >= 0 && index < root.timerPresets.length) root.addTimer(root.timerPresets[index], "")
  }

  // Back to zero, staying paused or running as it was.
  function resetStopwatch(id) {
    root.updateTimer(id, function(t, now) {
      t.elapsedBefore = 0
      t.startedAt = now
    })
  }

  function cancelTimer(id) {
    if (!root.ownsTimers) return root.timerOwner.cancelTimer(id)
    root.ownTimers = root.ownTimers.filter(function(t) { return t.id !== id })
  }

  function setTimerSound(enabled) {
    persistSettings({ timerSound: enabled === true })
  }

  // One notification per timer, but a single chime for timers that land on
  // the same tick. A timer that ran out while the shell was down says when.
  function finishTimers(finished, now) {
    for (var i = 0; i < finished.length; i++) {
      var t = finished[i]
      var duration = Model.describeTimer(t.total, function(key, count, english) {
        return Commons.I18n.tn(key, count, english).arg(Commons.I18n.formatNumber(count))
      })
      if (now - t.endsAt > 5000)
        duration = Commons.I18n.t("clock.timerEndedAt").arg(duration)
          .arg(new Date(t.endsAt).toLocaleTimeString(root.labelLocale, Locale.ShortFormat))
      // The name rides in the body, after the duration, never where the
      // helper still reads options: a timer named "--help" is just text.
      var body = t.name !== ""
        ? Commons.I18n.t("clock.namedTimerUp").arg(duration).arg(t.name)
        : Commons.I18n.t("clock.timerUp").arg(duration)
      Util.execArgv(["omarchy-notification-send", "-g", "󰔟", "-u", "critical",
        Commons.I18n.t("clock.timerDone"), body])
    }
    if (finished.length > 0 && root.timerSound)
      Util.execArgv(["bash", "-c", '[[ -f $1 ]] && exec pw-play "$1"', "bash", root.timerSoundFile])
  }

  function restoreTimers(content) {
    var parsed = []
    try {
      parsed = JSON.parse(String(content || "[]"))
    } catch (e) {
      console.warn("clock", "Ignoring unreadable timer state", root.timersStatePath, e)
    }
    var restored = Model.restoreTimers(parsed)
    var serial = 0
    for (var i = 0; i < restored.length; i++) serial = Math.max(serial, restored[i].id)
    root.timerSerial = serial
    root.timersStateText = JSON.stringify(restored) + "\n"
    root.ownTimers = restored
    root.timersRestored = true
    // Settles anything that ran out while the shell was down.
    root.tickTimers()
  }

  function saveTimers() {
    if (!root.timersRestored || !root.ownsTimers) return
    var text = JSON.stringify(root.ownTimers) + "\n"
    if (text === root.timersStateText) return
    root.timersStateText = text
    timersStateFile.setText(text)
  }

  // Only the owner settles finished timers, so each notifies once. Until the
  // bar has registered its widgets nobody does: at startup every instance
  // reads the file and counts as its own owner, and each would otherwise
  // settle the same expired timers. The ticker keeps asking, so the owner
  // catches up once the bar says who it is.
  function isTimerLeader() {
    if (!root.bar || typeof root.bar.moduleWidgets !== "function") return true
    var instances = root.bar.moduleWidgets(root.moduleName)
    return instances.length > 0 && instances[0] === root.barIdentity
  }

  // Owner-side code reads ownTimers, never the timers binding: inside this
  // handler that binding may not have caught up with the change yet.
  onOwnTimersChanged: saveTimers()
  // Taking over (the owning monitor went away): pick up what it last saved.
  // The list held here is the one read at startup, so ticking, saving and
  // adding stay off until the reload has restored the current one.
  onOwnsTimersChanged: {
    if (!ownsTimers || !timersRestored) return
    timersRestored = false
    timersStateFile.reload()
  }

  function tickTimers() {
    if (!root.ownsTimers || !root.timersRestored) return
    var now = Date.now()
    root.ownTimerNow = now
    if (!root.isTimerLeader()) return
    var done = function(t) { return t.kind !== "stopwatch" && t.running && now >= t.endsAt }
    var finished = root.ownTimers.filter(done)
    if (finished.length === 0) return
    root.ownTimers = root.ownTimers.filter(function(t) { return !done(t) })
    root.finishTimers(finished, now)
  }

  // Shared by the two timer fields: Enter starts a timer, Tab hops to the
  // other field, and Enter or Escape hands the keys back to the calendar.
  function handleTimerKey(event, other, catcher) {
    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      root.addTimerFromFields()
      // Back to the calendar's keys, letting the row fold away again.
      catcher.forceActiveFocus()
      event.accepted = true
    } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
      other.selectAll()
      other.forceActiveFocus()
      event.accepted = true
    } else if (event.key === Qt.Key_Escape) {
      catcher.forceActiveFocus()
      event.accepted = true
    }
  }



  // English short day names, matching the rest of the interface.
  function weekdayLabel(weekday) {
    return String(labelLocale.dayName(weekday, Locale.ShortFormat)).toUpperCase()
  }

  WallClock {
    id: clock
    onDateChanged: {
      if (Model.keyForDate(clock.date) === String(root.todayKey)) return
      var followToday = root.viewingCurrentMonth
      root.today = clock.date
      if (followToday) root.goToToday()
    }
  }

  FileView {
    id: timersStateFile
    path: root.timersStatePath
    atomicWrites: true
    printErrors: false
    onLoaded: root.restoreTimers(text())
    // No file yet is the normal first run: start empty and save from here on.
    onLoadFailed: root.restoreTimers("[]")
  }

  Component.onCompleted: Util.execArgv(["mkdir", "-p", root.timersStateDir])

  Timer {
    id: timerTicker
    interval: 250
    repeat: true
    running: root.ownsTimers && root.timersRestored && root.anyTimerRunning
    triggeredOnStart: true
    onTriggered: root.tickTimers()
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    // Anchor under the widget rather than the middle of the bar, so the
    // popup follows wherever the widget is placed.
    centerOnBar: false
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(560))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias bornField: bornField
      property alias expectancyField: expectancyField
      implicitHeight: calendarColumn.implicitHeight
      anchors.fill: parent
      blocked: root.editingLife || timerField.activeFocus || timerNameField.activeFocus
      onMoveRequested: function(dx, dy) {
        if (dx !== 0) root.moveMonth(dx)
        if (dy !== 0) root.moveYear(dy)
      }
      onActivateRequested: root.goToToday()
      onDeleteRequested: root.cancelTarget()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "[") root.moveMonth(-1)
        else if (t === "]") root.moveMonth(1)
        else if (t === "{") root.moveYear(-1)
        else if (t === "}") root.moveYear(1)
        else if (t === "t" || t === "T") root.goToToday()
        else if (t === "w" || t === "W") root.toggleWeekStart()
        // Timers only take keys the calendar leaves free: a adds a named
        // one, s starts a stopwatch, 1–4 the presets; the rest act on the
        // one the bar shows.
        else if (t === "a" || t === "A") {
          root.timerAddPinned = true
          Qt.callLater(function() {
            timerNameField.selectAll()
            timerNameField.forceActiveFocus()
            root.timerAddPinned = false
          })
        }
        else if (t === "s" || t === "S") root.addStopwatch("")
        else if (t >= "1" && t <= "4") root.startPreset(Number(t) - 1)
        else if (t === "p" || t === "P") root.toggleTargetPause()
        else if (t === "r" || t === "R") root.resetTarget()
        else if (t === "n") root.cycleBarTimer(1)
        else if (t === "N") root.cycleBarTimer(-1)
        else if (t === "m" || t === "M") root.setTimerSound(!root.timerSound)
      }

      Flickable {
        id: calendarScroll
        anchors.fill: parent
        contentWidth: calendarColumn.width
        contentHeight: calendarColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height || contentWidth > width

        Column {
          id: calendarColumn
          // Never narrower than the grid. The popup width is capped to what
          // the screen allows, and a fixed seven-column grid would otherwise
          // lose its last days off the edge instead of scrolling.
          width: Math.max(calendarScroll.width, gridColumn.width)
          spacing: Style.space(8)

          // ---- Hero: today, centered. Once the view has stepped back
          //      it is also the way home — clicking the date you are
          //      looking for beats hunting for a reset button.
          Item {
            width: parent.width
            height: heroRow.height

            Row {
              id: heroRow
              anchors.horizontalCenter: parent.horizontalCenter
              spacing: Style.space(22)

              Text {
                // Baseline-aligned, not center-aligned: "July 26" carries a
                // descender, so centering the two boxes leaves the icon
                // sitting visibly low against the digits.
                anchors.baseline: heroDate.baseline
                text: "󰃭"
                color: heroMouse.containsMouse
                  ? Style.hoverStateColor(root.contentForeground, Commons.Color.accent)
                  : root.contentForeground
                font.family: root.contentFontFamily
                // Decorative, and deliberately outside the Style.font.*
                // scale. Sized so the glyph reads at the cap height of the
                // date beside it rather than towering over it.
                font.pixelSize: 48
              }

              Text {
                id: heroDate
                textFormat: Text.PlainText
                anchors.verticalCenter: parent.verticalCenter
                text: root.today.toLocaleDateString(root.labelLocale, Commons.I18n.t("clock.dayMonthFormat"))
                color: heroMouse.containsMouse
                  ? Style.hoverStateColor(root.contentForeground, Commons.Color.accent)
                  : root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: 52
                font.bold: true
              }
            }

            MouseArea {
              id: heroMouse
              x: heroRow.x
              y: heroRow.y
              width: heroRow.width
              height: heroRow.height
              enabled: !root.viewingCurrentMonth
              hoverEnabled: enabled
              cursorShape: Qt.PointingHandCursor
              onClicked: root.goToToday()

              PanelToolTip {
                visible: heroMouse.containsMouse
                text: Commons.I18n.t("clock.backToToday")
                fontFamily: root.contentFontFamily
              }
            }
          }

          // ---- Year progress, doubling as the rule under the hero:
          //      a plain hairline said nothing, and whole days done
          //      over days in the year says the same thing louder.
          Item {
            width: parent.width
            height: yearBlock.y + yearBlock.height

            Item {
              id: yearBlock
              y: Style.space(6)
              anchors.horizontalCenter: parent.horizontalCenter
              width: gridColumn.width
              height: Math.max(yearLabel.implicitHeight, Style.space(10))

              TapHandler {
                enabled: !root.editingLife
                onDoubleTapped: root.startEditingLife()
              }

              Row {
                visible: root.editingLife
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(10)

                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: Commons.I18n.t("clock.born")
                  textFormat: Text.PlainText
                  color: Qt.darker(root.contentForeground, 1.5)
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.letterSpacing: 1
                }

                TextField {
                  id: bornField
                  width: Style.space(70)
                  anchors.verticalCenter: parent.verticalCenter
                  placeholderText: Commons.I18n.t("clock.year")
                  foreground: root.contentForeground
                  font.family: root.contentFontFamily
                  inputMethodHints: Qt.ImhDigitsOnly

                  Keys.onPressed: function(event) { root.handleLifeKey(event, expectancyField) }
                }

                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.verticalCenterOffset: 0
                  leftPadding: Style.space(6)
                  text: Commons.I18n.t("clock.liveTo")
                  textFormat: Text.PlainText
                  color: Qt.darker(root.contentForeground, 1.5)
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.letterSpacing: 1
                }

                TextField {
                  id: expectancyField
                  width: Style.space(60)
                  anchors.verticalCenter: parent.verticalCenter
                  placeholderText: "90"
                  foreground: root.contentForeground
                  font.family: root.contentFontFamily
                  inputMethodHints: Qt.ImhDigitsOnly

                  Keys.onPressed: function(event) { root.handleLifeKey(event, bornField) }
                }
              }

              Text {
                id: yearLabel
                textFormat: Text.PlainText
                visible: !root.editingLife
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Commons.I18n.formatNumber(root.today.getFullYear())
                color: Qt.darker(root.contentForeground, 1.5)
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.bodySmall
                font.letterSpacing: 1
              }

              Text {
                id: yearPercent
                textFormat: Text.PlainText
                visible: !root.editingLife
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Commons.I18n.formatNumber(root.yearDonePercent) + "%"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.bodySmall
              }

              Rectangle {
                id: yearTrack
                visible: !root.editingLife
                anchors.left: yearLabel.right
                anchors.right: yearPercent.left
                anchors.leftMargin: Style.space(12)
                anchors.rightMargin: Style.space(12)
                anchors.verticalCenter: parent.verticalCenter
                height: Style.space(6)
                radius: Style.cornerRadius > 0 ? height / 2 : 0
                color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.12)

                Rectangle {
                  width: Math.round(parent.width * root.yearDone)
                  height: parent.height
                  radius: parent.radius
                  color: Style.selectedStateColor(root.contentForeground, Commons.Color.accent)

                  Behavior on width { NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic } }
                }
              }
            }
          }

          // ---- Memento mori. Only here once someone has gone looking and
          //      given an age; the same rail as the year above it, measured
          //      against a nominal lifetime.
          Item {
            visible: root.birthYear > 0
            width: parent.width
            height: visible ? lifeBlock.height : 0

            Item {
              id: lifeBlock
              anchors.horizontalCenter: parent.horizontalCenter
              width: gridColumn.width
              height: Math.max(lifeLabel.implicitHeight, Style.space(10))

              Text {
                id: lifeLabel
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Commons.I18n.t("clock.life")
                textFormat: Text.PlainText
                color: Qt.darker(root.contentForeground, 1.5)
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.bodySmall
                font.letterSpacing: 1
              }

              Text {
                id: lifePercent
                textFormat: Text.PlainText
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Commons.I18n.formatNumber(root.lifeDonePercent) + "%"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.bodySmall
              }

              Rectangle {
                anchors.left: lifeLabel.right
                anchors.right: lifePercent.left
                anchors.leftMargin: Style.space(12)
                anchors.rightMargin: Style.space(12)
                anchors.verticalCenter: parent.verticalCenter
                height: Style.space(6)
                radius: Style.cornerRadius > 0 ? height / 2 : 0
                color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.12)

                Rectangle {
                  width: Math.round(parent.width * root.lifeDone)
                  height: parent.height
                  radius: parent.radius
                  color: Style.selectedStateColor(root.contentForeground, Commons.Color.accent)

                  Behavior on width { NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic } }
                }
              }

              TapHandler {
                onDoubleTapped: root.clearLife()
              }

              MouseArea {
                id: lifeMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                PanelToolTip {
                  visible: lifeMouse.containsMouse
                  text: "Memento Mori"
                  fontFamily: root.contentFontFamily
                }
              }
            }
          }

          // ---- Month grid: week numbers down a gutter on the left, then
          //      the seven day columns. Always six rows, so the popup is
          //      exactly as tall in February as it is in August.
          Item {
            width: parent.width
            height: gridColumn.y + gridColumn.height

            WheelHandler {
              onWheel: function(event) {
                // Horizontal wheels and touchpad side-scrolls report y === 0;
                // without this they would every one read as "next month".
                if (event.angleDelta.y === 0) return
                root.moveMonth(event.angleDelta.y > 0 ? -1 : 1)
              }
            }

            Column {
              id: gridColumn
              // The meter above is a solid rule; the grid needs room to
              // read as its own block rather than hanging off it.
              y: Style.space(18)
              anchors.horizontalCenter: parent.horizontalCenter
              spacing: Style.space(3)

              Row {
                id: headerRow
                spacing: root.cellSpacing

                // The week-number heading doubles as the week-start toggle.
                // It is the one control in the panel whose meaning is not
                // self-evident, so it carries a tooltip naming the day the
                // click will switch to.
                Rectangle {
                  width: root.weekColumnWidth
                  height: Style.space(16)
                  radius: Style.cornerRadius
                  color: weekStartMouse.containsMouse
                    ? Style.hoverFillFor(root.contentForeground, Commons.Color.accent)
                    : "transparent"

                  Text {
                    anchors.centerIn: parent
                    textFormat: Text.PlainText
                    text: Commons.I18n.t("clock.weekShort")
                    color: weekStartMouse.containsMouse
                      ? Style.hoverStateColor(root.contentForeground, Commons.Color.accent)
                      : Qt.darker(root.contentForeground, 1.9)
                    font.family: root.contentFontFamily
                    font.pixelSize: Style.font.caption
                    font.letterSpacing: 1
                    font.bold: true
                  }

                  MouseArea {
                    id: weekStartMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleWeekStart()
                  }

                  PanelToolTip {
                    visible: weekStartMouse.containsMouse
                    text: Commons.I18n.t("clock.startWeeksOn").arg(root.nextWeekStartLabel)
                    fontFamily: root.contentFontFamily
                  }
                }

                Item {
                  width: root.gutterWidth
                  height: Style.space(16)
                }

                Repeater {
                  model: root.weekdays

                  Text {
                    textFormat: Text.PlainText
                    required property var modelData
                    width: root.cellWidth
                    height: Style.space(16)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: root.weekdayLabel(modelData)
                    color: Qt.darker(root.contentForeground, 1.5)
                    font.family: root.contentFontFamily
                    font.pixelSize: Style.font.caption
                    font.letterSpacing: 1
                    font.bold: true
                  }
                }
              }

              Repeater {
                model: root.weeks

                Row {
                  required property var modelData
                  spacing: root.cellSpacing

                  Text {
                    textFormat: Text.PlainText
                    width: root.weekColumnWidth
                    height: root.cellHeight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: Commons.I18n.formatNumber(modelData.week)
                    color: Qt.darker(root.contentForeground, 1.9)
                    font.family: root.contentFontFamily
                    font.pixelSize: Style.font.caption
                  }

                  Item {
                    width: root.gutterWidth
                    height: root.cellHeight
                  }

                  Repeater {
                    model: modelData.days

                    Rectangle {
                      required property var modelData

                      width: root.cellWidth
                      height: root.cellHeight
                      radius: Style.cornerRadius
                      // Today is outlined, not filled: a lit-up block shouts
                      // over a grid this quiet.
                      color: "transparent"
                      border.width: modelData.today ? Style.spacing.hairline : 0
                      border.color: Style.normalBorderFor(root.contentForeground, Commons.Color.accent)

                      Text {
                        textFormat: Text.PlainText
                        anchors.centerIn: parent
                        text: Commons.I18n.formatNumber(modelData.day)
                        color: modelData.inMonth
                          ? (modelData.weekend ? Qt.darker(root.contentForeground, 1.45) : root.contentForeground)
                          : Qt.darker(root.contentForeground, 2.2)
                        font.family: root.contentFontFamily
                        font.pixelSize: Style.font.body
                        font.bold: modelData.today
                      }
                    }
                  }
                }
              }
            }

            // Hairline down the week-number gutter, drawn only beside the
            // day rows so it does not cut through the header band. Placed
            // by x, so it follows the rows to the right edge when mirrored.
            Rectangle {
              readonly property real gutterOffset: root.weekColumnWidth + root.cellSpacing + Math.round((root.gutterWidth - width) / 2)
              x: LayoutMirroring.enabled
                ? gridColumn.x + gridColumn.width - gutterOffset - width
                : gridColumn.x + gutterOffset
              y: gridColumn.y + headerRow.height + gridColumn.spacing
              width: Style.spacing.hairline
              height: gridColumn.height - headerRow.height - gridColumn.spacing
              color: root.contentForeground
              opacity: 0.1
            }
          }

          // ---- Month stepping, spanning the grid it drives. The chevrons
          //      sit on the grid's outer bounds, the same edges the year
          //      rail above uses, so the row reads as the panel's other
          //      full-width rail instead of a cluster floating in space.
          //      The label is centered and fixed-width, so it holds still
          //      from "MAY" to "SEPTEMBER".
          Item {
            width: parent.width
            height: monthNav.height

            Item {
              id: monthNav
              anchors.horizontalCenter: parent.horizontalCenter
              width: gridColumn.width
              height: monthLabel.implicitHeight + Style.space(10)

              Text {
                id: monthLabel
                textFormat: Text.PlainText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                // Fixed width so the chevrons hold still between a
                // "MAY 2026" and a "SEPTEMBER 2026".
                width: Style.space(130)
                horizontalAlignment: Text.AlignHCenter
                text: root.monthYearLabel.toUpperCase()
                color: Qt.darker(root.contentForeground, 1.4)
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.body
                font.letterSpacing: 1
              }

              PanelActionButton {
                // Pulled out by the button's own padding so the glyph, not
                // its hit box, lines up with the "2026" on the year rail.
                anchors.left: parent.left
                anchors.leftMargin: -Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                // Previous points back along the reading direction.
                iconText: Commons.I18n.rightToLeft ? "󰅂" : "󰅁"
                tooltipText: Commons.I18n.t("clock.previousMonth")
                foreground: root.contentForeground
                fontFamily: root.contentFontFamily
                onClicked: root.moveMonth(-1)
              }

              PanelActionButton {
                anchors.right: parent.right
                anchors.rightMargin: -Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                iconText: Commons.I18n.rightToLeft ? "󰅁" : "󰅂"
                tooltipText: Commons.I18n.t("clock.nextMonth")
                foreground: root.contentForeground
                fontFamily: root.contentFontFamily
                onClicked: root.moveMonth(1)
              }
            }
          }

          // ---- Countdown timers, set off from the calendar by a hairline.
          //      Each running timer is the same rail as the year above,
          //      filling as its time runs out; below them a row names and
          //      starts the next one, from a preset or a typed duration.
          Item {
            width: parent.width
            height: Style.space(14)

            PanelSeparator {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.verticalCenter: parent.verticalCenter
              width: gridColumn.width
              foreground: root.contentForeground
            }
          }

          // The whole timer section is one hover zone: reaching for it is
          // what unfolds the add row, and it folds back a beat after the
          // pointer leaves, unless a field still has the keyboard.
          Item {
            id: timerSection
            width: parent.width
            height: timerSectionColumn.implicitHeight

            readonly property bool addRowOpen: root.canAddTimer
              && (timerSectionHover.hovered || timerFoldDelay.running || root.timerAddPinned
                || timerNameField.activeFocus || timerField.activeFocus)

            HoverHandler {
              id: timerSectionHover
              onHoveredChanged: if (!hovered) timerFoldDelay.restart()
            }

            Timer {
              id: timerFoldDelay
              interval: 450
            }

            Column {
              id: timerSectionColumn
              width: parent.width

              Item {
                width: parent.width
                height: timerHeader.height

                Item {
                  id: timerHeader
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: gridColumn.width
                  height: Style.space(22)

                  HoverHandler { id: timerHeaderHover }

                  PanelToolTip {
                    visible: timerHeaderHover.hovered
                    text: Commons.I18n.t("clock.timerKeys")
                    fontFamily: root.contentFontFamily
                  }

                  Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: Text.PlainText
                    text: Commons.I18n.t("clock.timers")
                    color: Qt.darker(root.contentForeground, 1.5)
                    font.family: root.contentFontFamily
                    font.pixelSize: Style.font.bodySmall
                    font.letterSpacing: 1
                  }

                  PanelActionButton {
                    anchors.right: parent.right
                    anchors.rightMargin: -Style.space(8)
                    anchors.verticalCenter: parent.verticalCenter
                    iconText: root.timerSound ? "󰂚" : "󰂛"
                    tooltipText: root.timerSound ? Commons.I18n.t("clock.timerSoundOn") : Commons.I18n.t("clock.timerSoundOff")
                    foreground: root.timerSound ? root.contentForeground : Qt.darker(root.contentForeground, 1.6)
                    fontFamily: root.contentFontFamily
                    onClicked: root.setTimerSound(!root.timerSound)
                  }
                }
              }

              Repeater {
                model: root.timers

                Item {
                  id: timerRow
                  required property var modelData
                  readonly property bool stopwatch: modelData.kind === "stopwatch"
                  readonly property real remaining: stopwatch ? 0 : Model.timerRemaining(modelData, root.timerNow)
                  readonly property real elapsed: stopwatch ? Model.stopwatchElapsed(modelData, root.timerNow) : 0
                  width: calendarColumn.width
                  height: Style.space(26)

                  Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: gridColumn.width
                    height: parent.height

                    Text {
                      id: timerName
                      textFormat: Text.PlainText
                      anchors.left: parent.left
                      anchors.verticalCenter: parent.verticalCenter
                      width: Style.space(96)
                      elide: Text.ElideRight
                      text: timerRow.modelData.name !== ""
                        ? timerRow.modelData.name
                        : (timerRow.stopwatch ? Commons.I18n.t("clock.stopwatch") : root.shortTimerLabel(timerRow.modelData.total))
                      // The one the bar shows, and so the one the keys act on.
                      color: root.timers.length > 1 && root.barEntry && root.barEntry.id === timerRow.modelData.id
                        ? Style.selectedStateColor(root.contentForeground, Commons.Color.accent)
                        : root.contentForeground
                      font.family: root.contentFontFamily
                      font.pixelSize: Style.font.bodySmall
                    }

                    PanelActionButton {
                      id: timerCancelButton
                      anchors.right: parent.right
                      anchors.rightMargin: -Style.space(8)
                      anchors.verticalCenter: parent.verticalCenter
                      iconText: "󰅖"
                      tooltipText: timerRow.stopwatch ? Commons.I18n.t("clock.removeStopwatch") : Commons.I18n.t("clock.cancelTimer")
                      foreground: root.contentForeground
                      fontFamily: root.contentFontFamily
                      onClicked: root.cancelTimer(timerRow.modelData.id)
                    }

                    PanelActionButton {
                      id: timerPauseButton
                      anchors.right: timerCancelButton.left
                      anchors.verticalCenter: parent.verticalCenter
                      iconText: timerRow.modelData.running ? "󰏤" : "󰐊"
                      tooltipText: timerRow.modelData.running ? Commons.I18n.t("clock.pauseTimer") : Commons.I18n.t("clock.resumeTimer")
                      foreground: root.contentForeground
                      fontFamily: root.contentFontFamily
                      onClicked: root.toggleTimerPause(timerRow.modelData.id)
                    }

                    // Countdowns keep the reset slot empty, so every row's
                    // time and rail line up.
                    PanelActionButton {
                      id: timerResetButton
                      opacity: timerRow.stopwatch ? 1 : 0
                      enabled: timerRow.stopwatch
                      anchors.right: timerPauseButton.left
                      anchors.verticalCenter: parent.verticalCenter
                      iconText: "󰑐"
                      tooltipText: Commons.I18n.t("clock.resetStopwatch")
                      foreground: root.contentForeground
                      fontFamily: root.contentFontFamily
                      onClicked: root.resetStopwatch(timerRow.modelData.id)
                    }

                    Text {
                      id: timerRemainingText
                      textFormat: Text.PlainText
                      anchors.right: timerResetButton.left
                      anchors.rightMargin: Style.space(6)
                      anchors.verticalCenter: parent.verticalCenter
                      text: root.localDigits(timerRow.stopwatch ? Model.formatElapsed(timerRow.elapsed) : Model.formatTimer(timerRow.remaining))
                      color: timerRow.modelData.running ? root.contentForeground : Qt.darker(root.contentForeground, 1.5)
                      font.family: root.contentFontFamily
                      font.pixelSize: Style.font.body
                      font.features: { "tnum": 1 }
                    }

                    Rectangle {
                      anchors.left: timerName.right
                      anchors.right: timerRemainingText.left
                      anchors.leftMargin: Style.space(10)
                      anchors.rightMargin: Style.space(12)
                      anchors.verticalCenter: parent.verticalCenter
                      height: Style.space(6)
                      radius: Style.cornerRadius > 0 ? height / 2 : 0
                      color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.12)

                      Rectangle {
                        // A countdown fills as it runs out; a stopwatch, with no
                        // end to measure against, sweeps once a minute like a
                        // second hand.
                        width: Math.round(parent.width * (timerRow.stopwatch
                          ? (timerRow.elapsed % 60) / 60
                          : Math.min(1, 1 - timerRow.remaining / timerRow.modelData.total)))
                        height: parent.height
                        radius: parent.radius
                        color: Style.selectedStateColor(root.contentForeground, Commons.Color.accent)

                        Behavior on width {
                          enabled: !timerRow.stopwatch || (timerRow.elapsed % 60) > 1
                          NumberAnimation { duration: Style.duration(240); easing.type: Easing.Linear }
                        }
                      }
                    }
                  }
                }
              }

              // ---- The next timer: an optional name, then a preset, a typed
              //      duration, or a stopwatch. Gone once the list is full.
              Item {
                id: timerAddReveal
                readonly property real fullHeight: timerAddRow.height + Style.space(6)
                width: parent.width
                height: timerSection.addRowOpen ? fullHeight : 0
                visible: timerSection.addRowOpen || height > 0
                clip: true

                // Leaving takes two thirds of the arrival.
                Behavior on height {
                  NumberAnimation {
                    duration: Style.duration(timerSection.addRowOpen ? 200 : 130)
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Style.easeOut
                  }
                }

                Item {
                  id: timerAddRow
                  anchors.horizontalCenter: parent.horizontalCenter
                  // Pinned to the bottom of the growing clip, so the row
                  // slides down into view rather than being uncovered.
                  y: timerAddReveal.height - timerAddReveal.fullHeight + Style.space(4)
                  opacity: timerAddReveal.fullHeight > 0 ? timerAddReveal.height / timerAddReveal.fullHeight : 0
                  width: gridColumn.width
                  height: Math.max(timerField.implicitHeight, Style.space(26))

                  TextField {
                    id: timerNameField
                    anchors.left: parent.left
                    anchors.right: timerPresetRow.left
                    anchors.rightMargin: Style.space(8)
                    anchors.verticalCenter: parent.verticalCenter
                    placeholderText: Commons.I18n.t("clock.timerName")
                    text: root.timerNameInput
                    onTextChanged: root.timerNameInput = text
                    maximumLength: 40
                    foreground: root.contentForeground
                    font.family: root.contentFontFamily
                    font.pixelSize: Style.font.bodySmall

                    Keys.onPressed: function(event) { root.handleTimerKey(event, timerField, keyCatcher) }
                  }

                  Row {
                    id: timerPresetRow
                    anchors.right: timerField.left
                    anchors.rightMargin: Style.space(8)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(4)

                    Repeater {
                      model: root.timerPresets

                      Rectangle {
                        required property var modelData
                        width: presetText.implicitWidth + Style.space(14)
                        height: Style.space(22)
                        radius: Style.cornerRadius
                        color: presetMouse.containsMouse
                          ? Style.hoverFillFor(root.contentForeground, Commons.Color.accent)
                          : "transparent"
                        border.width: Style.spacing.hairline
                        border.color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.15)

                        Text {
                          id: presetText
                          anchors.centerIn: parent
                          textFormat: Text.PlainText
                          text: root.shortTimerLabel(modelData)
                          color: presetMouse.containsMouse
                            ? Style.hoverStateColor(root.contentForeground, Commons.Color.accent)
                            : root.contentForeground
                          font.family: root.contentFontFamily
                          font.pixelSize: Style.font.bodySmall
                        }

                        MouseArea {
                          id: presetMouse
                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor
                          onClicked: {
                            root.addTimer(modelData, root.timerNameInput)
                            keyCatcher.forceActiveFocus()
                          }
                        }
                      }
                    }
                  }

                  TextField {
                    id: timerField
                    width: Style.space(64)
                    anchors.right: timerStartButton.left
                    anchors.rightMargin: Style.space(4)
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    placeholderText: "mm:ss"
                    text: root.timerInput
                    onTextChanged: root.timerInput = text
                    foreground: root.contentForeground
                    font.family: root.contentFontFamily
                    font.pixelSize: Style.font.bodySmall

                    Keys.onPressed: function(event) { root.handleTimerKey(event, timerNameField, keyCatcher) }
                  }

                  PanelActionButton {
                    id: timerStartButton
                    anchors.right: stopwatchStartButton.left
                    anchors.verticalCenter: parent.verticalCenter
                    iconText: "󰐊"
                    tooltipText: Commons.I18n.t("clock.startTimer")
                    enabled: root.timerInputValid
                    foreground: root.contentForeground
                    fontFamily: root.contentFontFamily
                    onClicked: {
                      root.addTimerFromFields()
                      keyCatcher.forceActiveFocus()
                    }
                  }

                  PanelActionButton {
                    id: stopwatchStartButton
                    anchors.right: parent.right
                    anchors.rightMargin: -Style.space(8)
                    anchors.verticalCenter: parent.verticalCenter
                    iconText: "󰔛"
                    tooltipText: Commons.I18n.t("clock.startStopwatch")
                    foreground: root.contentForeground
                    fontFamily: root.contentFontFamily
                    onClicked: {
                      root.addStopwatch(root.timerNameInput)
                      keyCatcher.forceActiveFocus()
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
