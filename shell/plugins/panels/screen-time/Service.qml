import QtQuick
import Quickshell
import Quickshell.Io

// The single connection to the screen time daemon. The bar widget, the
// countdown window and the parent service all read their state from here,
// so there is one stream and everything shows the same numbers. Nothing in
// here is secret: it is what the daemon publishes to the account anyway.
Item {
  id: root

  property var shell: null

  property bool connected: false
  property string phase: ""          // running | idle | paused | empty | bedtime
  property string profileName: ""
  property int budgetSeconds: 0
  property int spentSeconds: 0
  property int earnedSeconds: 0
  property int grantedSeconds: 0
  property bool locked: false
  property var lockInSeconds: null   // int while a lock is counting down, else null
  property int minWarnSeconds: 60
  property bool earnEnabled: false
  property int earnRoomSeconds: 0
  property var earnEvents: []        // [{t, seconds, q}], oldest first
  property var earnOps: []
  property var earnTables: []
  property int earnCapMinutes: 0
  property int earnSecondsPerCorrect: 30
  property var budgetMinutes: ({})   // {mon: 60, ...}
  property var blockedPeriods: []    // [{label, enabled, start, end}]
  property string blockedLabel: ""   // the period blocking right now, if any
  property var nextBlock: null       // the next one that starts, for the panel
  property string philosophy: "limits"
  property string agreementText: ""
  property int agreementMinutes: 0
  property int breakNudgeMinutes: 45
  property int stretchSeconds: 0
  property var reflections: []       // [{t, text}], oldest first
  property bool pinSet: false

  // The daemon streams an update roughly every tick. Between events the
  // remaining time keeps counting down locally, so the last minutes read as a
  // clock and not as a stutter.
  property int baseRemaining: 0
  property double baseAtMs: 0
  property double nowMs: Date.now()

  readonly property bool counting: connected && phase === "running"
  readonly property int remainingSeconds: {
    var base = baseRemaining
    if (counting && baseAtMs > 0)
      base -= Math.floor((nowMs - baseAtMs) / 1000)
    return Math.max(0, base)
  }

  // The client is on PATH: the daemon publishes under /run and the client
  // reads it, so `watch` is one process per shell, not a socket.
  readonly property string clientPath: "omarchy-screen-time"

  function applyEvent(event) {
    if (!event || event.ok !== true) {
      connected = false
      return
    }
    connected = true
    phase = String(event.phase || "")
    profileName = String(event.profile_name || "")
    baseRemaining = Number(event.remaining_seconds) || 0
    baseAtMs = Date.now()
    budgetSeconds = Number(event.budget_seconds) || 0
    spentSeconds = Number(event.spent_seconds) || 0
    earnedSeconds = Number(event.earned_seconds) || 0
    grantedSeconds = Number(event.granted_seconds) || 0
    locked = event.locked === true
    lockInSeconds = (event.lock_in_seconds === null || event.lock_in_seconds === undefined)
      ? null : Number(event.lock_in_seconds)
    var warns = event.warn_seconds
    minWarnSeconds = (warns && warns.length) ? (Number(warns[warns.length - 1]) || 60) : 60
    var earn = event.earn || {}
    earnEnabled = earn.enabled === true
    earnRoomSeconds = Number(earn.room_seconds) || 0
    earnEvents = Array.isArray(earn.events) ? earn.events : []
    earnOps = Array.isArray(earn.ops) ? earn.ops : []
    earnTables = Array.isArray(earn.tables) ? earn.tables : []
    earnCapMinutes = Math.round((Number(earn.cap_seconds) || 0) / 60)
    earnSecondsPerCorrect = Number(earn.seconds_per_correct) || 30
    budgetMinutes = event.budget_minutes || {}
    blockedPeriods = event.blocked_periods || []
    blockedLabel = String(event.blocked_label || "")
    nextBlock = event.next_block || null
    philosophy = String(event.philosophy || "limits")
    agreementText = String(event.agreement_text || "")
    agreementMinutes = Number(event.agreement_minutes) || 0
    breakNudgeMinutes = Number(event.break_nudge_minutes) || 0
    stretchSeconds = Number(event.stretch_seconds) || 0
    reflections = Array.isArray(event.reflections) ? event.reflections : []
    pinSet = event.pin_set === true
  }

  Process {
    id: watchProc
    running: true
    command: [root.clientPath, "watch"]
    stdout: SplitParser {
      onRead: function(line) {
        var event
        try { event = JSON.parse(line) } catch (e) { return }
        if (event && event.ok === true) retryTimer.interval = retryTimer.quick
        root.applyEvent(event)
      }
    }
    onExited: {
      root.connected = false
      retryTimer.restart()
    }
  }

  // No daemon, or the daemon restarted: try again in a bit, forever. The
  // widget simply hides while there is nothing to show. The first retries
  // come quickly, for a daemon that is restarting; after that the wait
  // doubles up to a minute, because on the installs where screen time is
  // never turned on this would otherwise spawn a process every few seconds
  // for the life of the session.
  Timer {
    id: retryTimer
    readonly property int quick: 3000
    readonly property int slow: 60000
    interval: quick
    onTriggered: {
      watchProc.running = true
      interval = Math.min(slow, interval * 2)
    }
  }

  Timer {
    interval: 1000
    running: root.connected
    repeat: true
    onTriggered: root.nowMs = Date.now()
  }
}
