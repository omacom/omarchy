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
  property var pendingStayAwakePersist: null
  property double stayAwakeUntil: 0
  property int stayAwakeRevision: 0
  property bool stayAwakeProbePending: false
  property bool idledThisCycle: false
  property bool screensaverStartedThisCycle: false
  property string lastEvent: "starting"
  property string lastEventAt: ""

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

    logEvent("idle-cycle-start", "screensaver=" + root.screensaverTimeoutSeconds + " lock=" + root.lockTimeoutSeconds)
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
  }

  function cancelIdleCycle(reason) {
    logEvent("idle-cycle-cancel", reason || "requested")
    screensaverTimer.stop()
    lockTimer.stop()
    screensaverLaunchGraceTimer.stop()

    if (root.idledThisCycle) runProcess(wakeProcess, "wake", "omarchy-system-wake")

    root.idledThisCycle = false
    root.screensaverStartedThisCycle = false
  }

  function handleActiveSignal() {
    if (!root.idledThisCycle) return

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
    if (!root.idleEnabled || !root.idleTimersEnabled) return

    if (idleMonitor.isIdle) startIdleCycle()
    else handleActiveSignal()
  }

  function statusJson() {
    return JSON.stringify({
      enabled: root.idleEnabled,
      stayAwake: root.stayAwake,
      stayAwakeUntil: root.stayAwakeUntil,
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

  function persistStayAwake(value, until) {
    if (stayAwakeStateWriter.running) {
      root.pendingStayAwakePersist = { value: value, until: until }
      return
    }

    // Rename a complete file into place. Readers must never see a timed write as
    // an empty (indefinite) file, and a symlink must not redirect a truncation.
    stayAwakeStateWriter.command = ["bash", "-c", `
      set -euo pipefail
      mkdir -p -- "$1"
      exec 9>>"$1/stay-awake.lock"
      flock 9
      if [[ $2 == "true" ]]; then
        temporary=$(mktemp "$1/.stay-awake.XXXXXX")
        trap 'rm -f -- "$temporary"' EXIT
        printf '%s' "$3" > "$temporary"
        mv -fT -- "$temporary" "$1/stay-awake"
      else
        rm -f -- "$1/stay-awake"
      fi
    `, "--", root.stayAwakeStateDir, String(value), until > 0 ? String(until) : ""]
    stayAwakeStateWriter.running = true
  }

  function refreshStayAwakeState() {
    root.stayAwakeProbePending = true
    if (stayAwakeStateWriter.running || stayAwakeStateProbe.running) return
    root.stayAwakeProbePending = false
    stayAwakeStateProbe.revision = root.stayAwakeRevision
    stayAwakeStateProbe.running = true
  }

  function applyStayAwake(value, persist, reason, until) {
    var enabled = !!value
    var changed = !root.stayAwakeStateLoaded || root.stayAwake !== enabled

    root.stayAwakeUntil = enabled ? Number(until || 0) : 0
    if (persist) {
      root.stayAwakeRevision++
      persistStayAwake(enabled, root.stayAwakeUntil)
    }

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

  function stayAwakeFor(seconds) {
    var until = IdleModel.stayAwakeDeadline(seconds, Date.now())
    if (!until) return "invalid duration"
    return applyStayAwake(true, true, "timed", until)
  }

  // Check the saved wall-clock deadline so suspend does not extend the session.
  Timer {
    interval: 1000
    repeat: true
    running: root.stayAwake && root.stayAwakeUntil > 0
    onTriggered: {
      if (Date.now() >= root.stayAwakeUntil) root.applyStayAwake(false, false, "expired")
    }
  }

  // With both timeouts at 0 the monitor stops reporting, so nothing else would end a running cycle.
  onIdleTimersEnabledChanged: if (!idleTimersEnabled) cancelIdleCycle("idle-timers-disabled")

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
    onTriggered: if (root.screensaverEnabled) root.launchScreensaver()
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
    property int revision: 0
    command: ["bash", "-c", `
      mkdir -p -- "$1" || exit
      if [[ ! -e $1/stay-awake && ! -L $1/stay-awake ]]; then
        printf no
      elif [[ -f $1/stay-awake && ! -L $1/stay-awake ]]; then
        printf 'yes:'
        head -c 64 -- "$1/stay-awake"
      else
        exit 1
      fi
    `, "--", root.stayAwakeStateDir]
    stdout: StdioCollector { id: stayAwakeStateOutput; waitForEnd: true }
    onExited: function(exitCode) {
      // A probe started before a newer choice must not replace it.
      if (revision === root.stayAwakeRevision && !stayAwakeStateWriter.running && !root.pendingStayAwakePersist) {
        var state = IdleModel.stayAwakeState(exitCode === 0 ? stayAwakeStateOutput.text : "no", Date.now())
        root.applyStayAwake(state.enabled, false, "state-file", state.until)
        if (exitCode !== 0) root.logEvent("state-read-failed", exitCode)
      }
      stayAwakeStateWatcher.reload()
      if (root.stayAwakeProbePending || revision !== root.stayAwakeRevision) root.refreshStayAwakeState()
    }
  }

  Process {
    id: stayAwakeStateWriter
    onExited: function(exitCode) {
      if (root.pendingStayAwakePersist) {
        var pending = root.pendingStayAwakePersist
        root.pendingStayAwakePersist = null
        root.persistStayAwake(pending.value, pending.until)
      } else {
        if (exitCode !== 0) {
          root.logEvent("state-write-failed", exitCode)
          Quickshell.execDetached(["omarchy-notification-send", I18n.t("idle.saveFailedTitle"), I18n.t("idle.saveFailedBody")])
        }
        root.refreshStayAwakeState()
      }
    }
  }

  FileView {
    id: stayAwakeStateWatcher
    path: root.stayAwakeStatePath
    preload: false
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

    function stayAwakeFor(seconds: int): string {
      return root.stayAwakeFor(seconds)
    }

    function toggle(): string {
      return root.setIdleEnabled(!root.idleEnabled)
    }
  }
}
