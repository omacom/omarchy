import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "IdleModel.js" as IdleModel
import qs.Commons

Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string stayAwakeStateDir: home + "/.local/state/omarchy/indicators"
  readonly property string stayAwakeStatePath: stayAwakeStateDir + "/stay-awake"
  readonly property int defaultScreensaverSeconds: 150
  readonly property int defaultLockSeconds: 300
  readonly property var idleConfig: shell && shell.shellConfig && shell.shellConfig.idle
    ? shell.shellConfig.idle : (shell && shell.idleConfig ? shell.idleConfig : ({}))
  readonly property int screensaverTimeoutSeconds: secondsFromConfig(idleConfig.screensaver, defaultScreensaverSeconds)
  readonly property int lockTimeoutSeconds: secondsFromConfig(idleConfig.lock, defaultLockSeconds)
  readonly property int suspendTimeoutSeconds: IdleModel.optionalSecondsFromConfig(idleConfig.suspend)
  readonly property bool screensaverEnabled: screensaverTimeoutSeconds > 0
  readonly property bool lockEnabled: lockTimeoutSeconds > 0
  readonly property bool suspendEnabled: suspendTimeoutSeconds > 0
  readonly property bool idleTimersEnabled: screensaverEnabled || lockEnabled || suspendEnabled
  readonly property int firstIdleTimeoutSeconds: IdleModel.firstIdleTimeout(screensaverTimeoutSeconds, lockTimeoutSeconds, suspendTimeoutSeconds)
  readonly property int screensaverDelaySeconds: IdleModel.delayAfterFirstIdle(screensaverTimeoutSeconds, firstIdleTimeoutSeconds)
  readonly property int lockDelaySeconds: IdleModel.delayAfterFirstIdle(lockTimeoutSeconds, firstIdleTimeoutSeconds)
  readonly property int suspendDelaySeconds: IdleModel.delayAfterFirstIdle(suspendTimeoutSeconds, firstIdleTimeoutSeconds)
  readonly property bool idleEnabled: stayAwakeStateLoaded && !stayAwake

  property bool stayAwake: false
  property bool stayAwakeStateLoaded: false
  property bool idleMonitorArmed: true
  property bool idleTimeoutsReady: false
  property bool hasPendingStayAwakePersist: false
  property bool pendingStayAwakePersist: false
  property bool idledThisCycle: false
  property bool screensaverStartedThisCycle: false
  property bool suspendPending: false
  property int suspendGeneration: 0
  property bool sleepEventsAvailable: false
  property bool preparingForSleep: false
  property string lastEvent: "starting"
  property string lastEventAt: ""

  function secondsFromConfig(value, fallback) {
    return IdleModel.secondsFromConfig(value, fallback)
  }

  function rearmIdleMonitor() {
    if (!root.idleTimeoutsReady) return

    // ext-idle-notify keeps the old deadline after a timeout change. Toggling
    // the monitor makes the new setting effective instead of leaving it wedged.
    if (root.idledThisCycle || root.suspendPending) root.cancelIdleCycle("timeout-change")
    root.idleMonitorArmed = false
    Qt.callLater(function() { root.idleMonitorArmed = true })
  }

  onScreensaverTimeoutSecondsChanged: root.rearmIdleMonitor()
  onLockTimeoutSecondsChanged: root.rearmIdleMonitor()
  onSuspendTimeoutSecondsChanged: root.rearmIdleMonitor()

  function nowIso() {
    return new Date().toISOString()
  }

  function logEvent(event, details) {
    var suffix = details === undefined || details === null || details === "" ? "" : ": " + String(details)
    root.lastEventAt = nowIso()
    root.lastEvent = event + suffix
    console.log("omarchy idle " + root.lastEventAt + " " + root.lastEvent)
  }

  function runProcess(process, label, command) {
    if (process.running) {
      logEvent("process-skip", label + " already running")
      return false
    }
    logEvent("process-start", label + " " + command)
    process.command = ["bash", "-lc", command]
    process.running = true
    return true
  }

  function launchScreensaver() {
    root.screensaverStartedThisCycle = true
    screensaverLaunchGraceTimer.restart()
    runProcess(screensaverProcess, "screensaver", "[[ $(omarchy-shell lock isLocked 2>/dev/null) == \"true\" ]] || omarchy-launch-screensaver")
  }

  function lockSystem(reason) {
    logEvent("lock-system", reason || "requested")
    screensaverTimer.stop()
    lockTimer.stop()
    screensaverLaunchGraceTimer.stop()
    root.idledThisCycle = false
    root.screensaverStartedThisCycle = false
    runProcess(lockProcess, "lock", "omarchy-system-lock")
  }

  function startIdleCycle() {
    if (root.idledThisCycle) {
      logEvent("idle-cycle-already-running")
      return
    }

    logEvent("idle-cycle-start", "screensaver=" + root.screensaverTimeoutSeconds + " lock=" + root.lockTimeoutSeconds + " suspend=" + root.suspendTimeoutSeconds)
    root.idledThisCycle = true
    root.screensaverStartedThisCycle = false

    // Set this cycle's deadlines once: a bound interval would restart a pending
    // timer from the moment shell.json changes, locking early or late.
    if (root.screensaverEnabled) {
      if (root.screensaverDelaySeconds === 0) launchScreensaver()
      else {
        screensaverTimer.interval = root.screensaverDelaySeconds * 1000
        screensaverTimer.restart()
      }
    }

    if (root.lockEnabled) {
      if (root.lockDelaySeconds === 0) lockSystem("lock-timeout-immediate")
      else {
        lockTimer.interval = root.lockDelaySeconds * 1000
        lockTimer.restart()
      }
    }

    if (root.suspendEnabled && !root.suspendPending) {
      root.suspendPending = true
      suspendTimer.interval = root.suspendDelaySeconds * 1000
      suspendTimer.restart()
    }
  }

  function cancelIdleCycle(reason) {
    logEvent("idle-cycle-cancel", reason || "requested")
    screensaverTimer.stop()
    lockTimer.stop()
    screensaverLaunchGraceTimer.stop()
    cancelSuspendCountdown()

    if (root.idledThisCycle) runProcess(wakeProcess, "wake", "omarchy-system-wake")

    root.idledThisCycle = false
    root.screensaverStartedThisCycle = false
  }

  function cancelSuspendCountdown(reason) {
    suspendTimer.stop()
    suspendRetryTimer.stop()
    root.suspendPending = false
    root.suspendGeneration += 1
    if (reason) logEvent("suspend-cancel", reason)
  }

  function handleSessionUnlocked() {
    if (root.suspendEnabled && !root.preparingForSleep) root.rearmIdleMonitor()
  }

  function handlePrepareForSleep(sleeping) {
    root.idleMonitorArmed = false
    root.preparingForSleep = sleeping
    screensaverTimer.stop()
    lockTimer.stop()
    screensaverLaunchGraceTimer.stop()
    root.idledThisCycle = false
    root.screensaverStartedThisCycle = false
    cancelSuspendCountdown(sleeping ? "sleep" : "resume")
    if (!sleeping) rearmIdleMonitor()
  }

  function handleSleepEvent(line) {
    if (line.startsWith("The name org.freedesktop.login1 is owned by ")) {
      root.sleepEventsAvailable = true
    } else if (line === "The name org.freedesktop.login1 does not have an owner") {
      root.sleepEventsAvailable = false
      if (root.preparingForSleep) handlePrepareForSleep(false)
      logEvent("sleep-event-monitor-unavailable", "logind has no D-Bus owner")
    } else if (line === "/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (true,)") {
      handlePrepareForSleep(true)
    } else if (line === "/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (false,)") {
      handlePrepareForSleep(false)
    }
  }

  function handleActiveSignal() {
    if (!root.idledThisCycle) {
      if (root.suspendPending) cancelSuspendCountdown("activity")
      return
    }

    // Starting the screensaver can make the compositor report activity, so the
    // launch grace ignores it.
    if (root.screensaverStartedThisCycle && screensaverLaunchGraceTimer.running) {
      logEvent("idle-monitor-active", "screensaver cycle remains armed")
      return
    }

    userReturned()
  }

  function userReturned() {
    // Input the screensaver never sees (a bound media key, a touchscreen) still means the user is back.
    if (root.screensaverStartedThisCycle) screensaverStopProcess.running = true
    cancelIdleCycle("activity")
  }

  function handleScreensaverExited() {
    // Closing while the user is active is a dismissal, even inside the launch grace.
    if (root.idleEnabled && root.idledThisCycle && root.screensaverStartedThisCycle && !idleMonitor.isIdle) {
      cancelIdleCycle("screensaver-dismissed")
    }
  }

  function handleIdleChanged() {
    logEvent("idle-monitor", idleMonitor.isIdle ? "idle" : "active")
    if (!root.idleEnabled || !root.idleTimersEnabled || !root.idleMonitorArmed || root.preparingForSleep) return

    if (idleMonitor.isIdle) startIdleCycle()
    else handleActiveSignal()
  }

  function suspendStillPending(generation) {
    return generation === root.suspendGeneration && root.suspendPending
      && root.idleEnabled && root.suspendEnabled && !root.preparingForSleep
  }

  function deferSuspend(reason) {
    logEvent("suspend-deferred", reason)
    suspendRetryTimer.restart()
  }

  function attemptSuspend() {
    if (!suspendStillPending(root.suspendGeneration)) return
    if (suspendInhibitorCheck.running || suspendProcess.running) {
      deferSuspend("previous-attempt-running")
      return
    }
    if (!root.sleepEventsAvailable || !suspendInhibitorMonitor.isIdle) {
      deferSuspend(root.sleepEventsAvailable ? "wayland-inhibitor" : "sleep-events-unavailable")
      return
    }

    suspendInhibitorCheck.generation = root.suspendGeneration
    suspendInhibitorCheck.running = true
  }

  function handleInhibitorCheck(generation, exitCode, exitStatus) {
    if (!suspendStillPending(generation)) return
    if (exitCode !== 0 || exitStatus !== 0 || !root.sleepEventsAvailable || !suspendInhibitorMonitor.isIdle || suspendProcess.running) {
      deferSuspend("inhibitor-or-check-failed")
      return
    }

    suspendProcess.generation = generation
    suspendProcess.running = true
  }

  function statusJson() {
    return JSON.stringify({
      enabled: root.idleEnabled,
      stayAwake: root.stayAwake,
      stayAwakeStateLoaded: root.stayAwakeStateLoaded,
      stayAwakeStatePath: root.stayAwakeStatePath,
      idle: idleMonitor.isIdle,
      inIdleCycle: root.idledThisCycle,
      screensaverStarted: root.screensaverStartedThisCycle,
      screensaver: root.screensaverTimeoutSeconds,
      lock: root.lockTimeoutSeconds,
      suspend: root.suspendTimeoutSeconds,
      suspendPending: root.suspendPending,
      suspendInhibitorIdle: suspendInhibitorMonitor.isIdle,
      screensaverDelay: root.screensaverDelaySeconds,
      lockDelay: root.lockDelaySeconds,
      suspendDelay: root.suspendDelaySeconds,
      timers: {
        screensaver: screensaverTimer.running,
        lock: lockTimer.running,
        suspend: suspendTimer.running,
        suspendRetry: suspendRetryTimer.running,
        screensaverLaunchGrace: screensaverLaunchGraceTimer.running
      },
      processes: {
        screensaver: screensaverProcess.running,
        lock: lockProcess.running,
        wake: wakeProcess.running
      },
      lastEvent: root.lastEvent,
      lastEventAt: root.lastEventAt
    })
  }

  function persistStayAwake(value) {
    var command = value
      ? "mkdir -p \"$HOME/.local/state/omarchy/indicators\" && touch \"$HOME/.local/state/omarchy/indicators/stay-awake\""
      : "rm -f \"$HOME/.local/state/omarchy/indicators/stay-awake\""

    if (stayAwakeStateWriter.running) {
      root.pendingStayAwakePersist = !!value
      root.hasPendingStayAwakePersist = true
      return
    }

    stayAwakeStateWriter.command = ["bash", "-lc", command]
    stayAwakeStateWriter.running = true
  }

  function refreshStayAwakeState() {
    if (!stayAwakeStateProbe.running) stayAwakeStateProbe.running = true
  }

  function applyStayAwake(value, persist, reason) {
    var enabled = !!value
    var changed = !root.stayAwakeStateLoaded || root.stayAwake !== enabled

    if (persist) persistStayAwake(enabled)

    root.stayAwake = enabled
    root.stayAwakeStateLoaded = true

    if (!changed) return enabled ? "disabled" : "enabled"

    logEvent("stay-awake", (enabled ? "enabled" : "disabled") + (reason ? " " + reason : ""))
    if (enabled) cancelIdleCycle("stay-awake")
    else Qt.callLater(root.handleIdleChanged)

    return enabled ? "disabled" : "enabled"
  }

  function setIdleEnabled(value) {
    return applyStayAwake(!value, true, "ipc")
  }

  // With both timeouts at 0 the monitor stops reporting, so nothing else would end a running cycle.
  onIdleTimersEnabledChanged: if (!idleTimersEnabled) cancelIdleCycle("idle-timers-disabled")

  IdleMonitor {
    id: idleMonitor
    enabled: root.idleEnabled && root.idleTimersEnabled && root.idleMonitorArmed && !root.preparingForSleep
    timeout: Math.max(1, root.firstIdleTimeoutSeconds)
    respectInhibitors: true
    onIsIdleChanged: root.handleIdleChanged()
  }

  IdleMonitor {
    id: suspendInhibitorMonitor
    enabled: root.idleEnabled && root.suspendEnabled && !root.preparingForSleep
    // This is a gate only: the suspend clock is suspendTimer, which keeps its
    // original deadline through screensaver and lock window events.
    timeout: 1
    respectInhibitors: true
  }

  Timer {
    id: screensaverTimer
    repeat: false
    onTriggered: if (root.screensaverEnabled) root.launchScreensaver()
  }

  Timer {
    id: suspendTimer
    repeat: false
    onTriggered: root.attemptSuspend()
  }

  Timer {
    id: suspendRetryTimer
    interval: 60000
    repeat: false
    onTriggered: root.attemptSuspend()
  }

  Timer {
    id: lockTimer
    repeat: false
    onTriggered: {
      if (!root.idleEnabled || !root.idledThisCycle || !root.lockEnabled) return
      // A deadline inside the launch grace must not lock a user who is already back.
      if (root.screensaverStartedThisCycle && screensaverLaunchGraceTimer.running && !idleMonitor.isIdle) root.userReturned()
      else root.lockSystem("lock-timeout")
    }
  }

  Timer {
    id: screensaverLaunchGraceTimer
    interval: 3000
    repeat: false
    onTriggered: {
      if (root.idleEnabled && root.idledThisCycle && root.screensaverStartedThisCycle && !idleMonitor.isIdle) root.userReturned()
    }
  }

  Process {
    id: screensaverProcess
    onExited: function(exitCode, exitStatus) {
      root.logEvent("process-exit", "screensaver exitCode=" + exitCode + " status=" + exitStatus)
      root.handleScreensaverExited()
    }
  }
  Process {
    id: suspendProcess
    property int generation: 0
    command: ["systemctl", "suspend"]
    onExited: function(exitCode, exitStatus) {
      root.logEvent("process-exit", "suspend exitCode=" + exitCode + " status=" + exitStatus)
      if (!root.suspendStillPending(generation)) return
      if (exitCode === 0 && exitStatus === 0) root.cancelSuspendCountdown()
      else root.deferSuspend("suspend-command-failed")
    }
  }
  Process {
    id: suspendInhibitorCheck
    property int generation: 0
    // systemctl handles sleep inhibitors. Check idle blocks separately and
    // require a successful query and parse before asking logind to suspend.
    command: ["bash", "-o", "pipefail", "-c", "systemd-inhibit --list --json=short | jq -es 'length == 1 and (.[0] | type == \"array\" and all(.[]; (.what | type) == \"string\" and (.mode | type) == \"string\") and (any(.[]; .mode == \"block\" and (.what | split(\":\") | index(\"idle\"))) | not))' >/dev/null"]
    onExited: function(exitCode, exitStatus) { root.handleInhibitorCheck(generation, exitCode, exitStatus) }
  }
  Process {
    id: sleepEventMonitor
    running: root.suspendEnabled
    command: ["env", "LC_ALL=C", "stdbuf", "-oL", "gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1", "--object-path", "/org/freedesktop/login1"]
    stdout: SplitParser {
      onRead: function(line) { root.handleSleepEvent(line) }
    }
    onExited: function(exitCode, exitStatus) {
      root.sleepEventsAvailable = false
      if (root.preparingForSleep) root.handlePrepareForSleep(false)
      if (root.suspendEnabled) root.logEvent("sleep-event-monitor-exit", "gdbus exitCode=" + exitCode + " status=" + exitStatus)
    }
  }
  Process {
    id: screensaverStopProcess
    command: ["pkill", "-f", "[/]usr/lib/omarchy-screensaver/omarchy-screensaver"]
  }
  Process {
    id: lockProcess
    onExited: function(exitCode, exitStatus) { root.logEvent("process-exit", "lock exitCode=" + exitCode + " status=" + exitStatus) }
  }
  Process {
    id: wakeProcess
    onExited: function(exitCode, exitStatus) { root.logEvent("process-exit", "wake exitCode=" + exitCode + " status=" + exitStatus) }
  }

  Process {
    id: stayAwakeStateProbe
    command: ["bash", "-c", "mkdir -p \"$HOME/.local/state/omarchy/indicators\"; if [[ -f $HOME/.local/state/omarchy/indicators/stay-awake ]]; then echo yes; else echo no; fi"]
    stdout: SplitParser {
      onRead: function(line) { root.applyStayAwake(String(line).trim() === "yes", false, "state-file") }
    }
    onExited: function() { stayAwakeStateDirWatcher.reload() }
  }

  Process {
    id: stayAwakeStateWriter
    onExited: function() {
      if (root.hasPendingStayAwakePersist) {
        var pending = root.pendingStayAwakePersist
        root.hasPendingStayAwakePersist = false
        root.persistStayAwake(pending)
        return
      }

      root.refreshStayAwakeState()
    }
  }

  FileView {
    id: stayAwakeStateDirWatcher
    path: root.stayAwakeStateDir
    watchChanges: true
    printErrors: false
    onFileChanged: root.refreshStayAwakeState()
  }

  Component.onCompleted: {
    logEvent("service-ready")
    refreshStayAwakeState()
    root.idleTimeoutsReady = true
  }

  ShellIpc {
    target: "idle"

    function status(): string {
      return root.statusJson()
    }

    function debug(): string {
      return root.statusJson()
    }

    function enable(): string {
      return root.setIdleEnabled(true)
    }

    function disable(): string {
      return root.setIdleEnabled(false)
    }

    function toggle(): string {
      return root.setIdleEnabled(!root.idleEnabled)
    }
  }
}
