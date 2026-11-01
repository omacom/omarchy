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
  readonly property bool screensaverEnabled: screensaverTimeoutSeconds > 0
  readonly property bool lockEnabled: lockTimeoutSeconds > 0
  readonly property bool idleTimersEnabled: screensaverEnabled || lockEnabled
  readonly property int firstIdleTimeoutSeconds: IdleModel.firstIdleTimeout(screensaverTimeoutSeconds, lockTimeoutSeconds)
  readonly property int screensaverDelaySeconds: IdleModel.delayAfterFirstIdle(screensaverTimeoutSeconds, firstIdleTimeoutSeconds)
  readonly property int lockDelaySeconds: IdleModel.delayAfterFirstIdle(lockTimeoutSeconds, firstIdleTimeoutSeconds)
  readonly property bool idleEnabled: stayAwakeStateLoaded && !stayAwake

  property bool stayAwake: false
  property bool stayAwakeStateLoaded: false
  property bool hasPendingStayAwakePersist: false
  property bool pendingStayAwakePersist: false
  property string stateMachineState: IdleModel.States.ACTIVE
  property bool idledThisCycle: stateMachineState !== IdleModel.States.ACTIVE && stateMachineState !== IdleModel.States.DISABLED
  property bool screensaverStartedThisCycle: stateMachineState === IdleModel.States.SCREENSAVER || stateMachineState === IdleModel.States.SCREENSAVER_GRACE
  property string lastEvent: "starting"
  property string lastEventAt: ""

  function isSessionLocked() {
    try {
      if (shell && typeof shell.isSessionLocked === "boolean") {
        return shell.isSessionLocked
      }
      if (shell && typeof shell.serviceFor === "function") {
        var lockService = shell.serviceFor("omarchy.lock")
        if (lockService && typeof lockService.currentlyLocked === "function") {
          return lockService.currentlyLocked()
        }
      }
    } catch (e) {}
    return false
  }

  Connections {
    target: shell
    ignoreUnknownSignals: true
    function onIsSessionLockedChanged() {
      if (shell && shell.isSessionLocked) {
        dispatchState(IdleModel.Events.SESSION_LOCKED)
      } else {
        dispatchState(IdleModel.Events.SESSION_UNLOCKED)
      }
    }
  }

  function dispatchState(event, extraContext) {
    var ctx = {
      isSessionLocked: isSessionLocked(),
      screensaverEnabled: root.screensaverEnabled,
      lockEnabled: root.lockEnabled,
      screensaverDelaySeconds: root.screensaverDelaySeconds,
      lockDelaySeconds: root.lockDelaySeconds,
      isMonitorIdle: idleMonitor.isIdle,
      stayAwake: root.stayAwake
    }
    if (extraContext) {
      for (var k in extraContext) ctx[k] = extraContext[k]
    }

    var result = IdleModel.transition(root.stateMachineState, event, ctx)
    var oldState = root.stateMachineState
    root.stateMachineState = result.nextState

    if (oldState !== result.nextState) {
      logEvent("state", oldState + " -> " + result.nextState + " (" + event + ")")
    }

    executeActions(result.actions)
  }

  function executeActions(actions) {
    if (!actions || actions.length === 0) return

    for (var i = 0; i < actions.length; i++) {
      var act = actions[i]
      switch (act) {
        case IdleModel.Actions.START_SCREENSAVER_TIMER:
          screensaverTimer.interval = root.screensaverDelaySeconds * 1000
          screensaverTimer.restart()
          break
        case IdleModel.Actions.START_LOCK_TIMER:
          lockTimer.interval = root.lockDelaySeconds * 1000
          lockTimer.restart()
          break
        case IdleModel.Actions.LAUNCH_SCREENSAVER:
          screensaverLaunchGraceTimer.restart()
          runProcess(screensaverProcess, "screensaver", "[[ $(omarchy-shell lock isLocked 2>/dev/null) == \"true\" ]] || omarchy-launch-screensaver")
          break
        case IdleModel.Actions.START_GRACE_TIMER:
          screensaverLaunchGraceTimer.restart()
          break
        case IdleModel.Actions.LOCK_SYSTEM:
          screensaverTimer.stop()
          lockTimer.stop()
          screensaverLaunchGraceTimer.stop()
          runProcess(lockProcess, "lock", "omarchy-system-lock")
          break
        case IdleModel.Actions.STOP_SCREENSAVER:
          screensaverStopProcess.running = true
          break
        case IdleModel.Actions.WAKE_SYSTEM:
          runProcess(wakeProcess, "wake", "[[ $(omarchy-shell lock isLocked 2>/dev/null) == \"true\" ]] || omarchy-hyprland-session-locked >/dev/null 2>&1 || omarchy-system-wake")
          break
        case IdleModel.Actions.STOP_TIMERS:
          screensaverTimer.stop()
          lockTimer.stop()
          screensaverLaunchGraceTimer.stop()
          break
      }
    }
  }

  function secondsFromConfig(value, fallback) {
    return IdleModel.secondsFromConfig(value, fallback)
  }

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
    dispatchState(IdleModel.Events.SCREENSAVER_TIMEOUT)
  }

  function lockSystem(reason) {
    logEvent("lock-system", reason || "requested")
    dispatchState(IdleModel.Events.LOCK_REQUESTED)
  }

  function startIdleCycle() {
    if (root.idledThisCycle) {
      logEvent("idle-cycle-already-running")
      return
    }

    logEvent("idle-cycle-start", "screensaver=" + root.screensaverTimeoutSeconds + " lock=" + root.lockTimeoutSeconds)
    dispatchState(IdleModel.Events.IDLE_START)
  }

  function cancelIdleCycle(reason) {
    logEvent("idle-cycle-cancel", reason || "requested")
    if (reason === "stay-awake") {
      dispatchState(IdleModel.Events.STAY_AWAKE_ENABLED)
    } else if (reason === "idle-timers-disabled") {
      dispatchState(IdleModel.Events.TIMERS_DISABLED)
    } else {
      dispatchState(IdleModel.Events.USER_ACTIVITY)
    }
  }

  function handleActiveSignal() {
    if (!root.idledThisCycle) return

    if (root.stateMachineState === IdleModel.States.SCREENSAVER_GRACE && screensaverLaunchGraceTimer.running) {
      logEvent("idle-monitor-active", "screensaver cycle remains armed")
      return
    }

    userReturned()
  }

  function userReturned() {
    dispatchState(IdleModel.Events.USER_ACTIVITY)
  }

  function handleScreensaverExited() {
    if (root.idleEnabled && root.idledThisCycle && !idleMonitor.isIdle) {
      dispatchState(IdleModel.Events.SCREENSAVER_DISMISSED)
    }
  }

  function handleIdleChanged() {
    logEvent("idle-monitor", idleMonitor.isIdle ? "idle" : "active")
    if (!root.idleEnabled || !root.idleTimersEnabled) return

    if (idleMonitor.isIdle) startIdleCycle()
    else handleActiveSignal()
  }

  function statusJson() {
    return JSON.stringify({
      state: root.stateMachineState,
      enabled: root.idleEnabled,
      stayAwake: root.stayAwake,
      stayAwakeStateLoaded: root.stayAwakeStateLoaded,
      stayAwakeStatePath: root.stayAwakeStatePath,
      idle: idleMonitor.isIdle,
      inIdleCycle: root.idledThisCycle,
      screensaverStarted: root.screensaverStartedThisCycle,
      screensaver: root.screensaverTimeoutSeconds,
      lock: root.lockTimeoutSeconds,
      screensaverDelay: root.screensaverDelaySeconds,
      lockDelay: root.lockDelaySeconds,
      timers: {
        screensaver: screensaverTimer.running,
        lock: lockTimer.running,
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
    if (enabled) {
      cancelIdleCycle("stay-awake")
    } else {
      dispatchState(IdleModel.Events.STAY_AWAKE_DISABLED)
      Qt.callLater(root.handleIdleChanged)
    }

    return enabled ? "disabled" : "enabled"
  }

  function setIdleEnabled(value) {
    return applyStayAwake(!value, true, "ipc")
  }

  // With both timeouts at 0 the monitor stops reporting, so nothing else would end a running cycle.
  onIdleTimersEnabledChanged: {
    if (!idleTimersEnabled) {
      cancelIdleCycle("idle-timers-disabled")
    } else if (!root.stayAwake) {
      dispatchState(IdleModel.Events.TIMERS_ENABLED)
      Qt.callLater(root.handleIdleChanged)
    }
  }

  IdleMonitor {
    id: idleMonitor
    enabled: root.idleEnabled && root.idleTimersEnabled
    timeout: Math.max(1, root.firstIdleTimeoutSeconds)
    respectInhibitors: true
    onIsIdleChanged: root.handleIdleChanged()
  }

  Timer {
    id: screensaverTimer
    repeat: false
    onTriggered: if (root.screensaverEnabled) root.dispatchState(IdleModel.Events.SCREENSAVER_TIMEOUT)
  }

  Timer {
    id: lockTimer
    repeat: false
    onTriggered: {
      if (!root.idleEnabled || !root.idledThisCycle || !root.lockEnabled) return
      root.dispatchState(IdleModel.Events.LOCK_TIMEOUT)
    }
  }

  Timer {
    id: screensaverLaunchGraceTimer
    interval: 3000
    repeat: false
    onTriggered: root.dispatchState(IdleModel.Events.GRACE_EXPIRED)
  }

  Process {
    id: screensaverProcess
    onExited: function(exitCode, exitStatus) {
      root.logEvent("process-exit", "screensaver exitCode=" + exitCode + " status=" + exitStatus)
      root.handleScreensaverExited()
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
