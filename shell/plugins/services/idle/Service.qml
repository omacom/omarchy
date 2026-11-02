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
  // Authentication services are deliberately absent from PluginShellApi.
  // Only a recent, successful lock IPC response may authorize the input guard.
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property bool lockActive: true
  property double lockCheckedAt: 0
  property double lockProbeStartedAt: 0
  readonly property int lockStatusMaxAge: 1000
  // Lock polling runs only while an Amiga session is starting or on screen,
  // so the idle shell spawns nothing when Amiga is unused.
  property bool amigaWatching: false
  property double amigaTouchedAt: 0
  readonly property int amigaWatchGrace: 5000

  function invalidateLockStatus() {
    root.lockActive = true
    root.lockCheckedAt = 0
    amigaScreensaver.dismiss()
  }

  function lockStatusAllowsAmiga() {
    var age = Date.now() - root.lockCheckedAt
    if (root.lockActive || root.lockCheckedAt <= 0 || age < 0 || age >= root.lockStatusMaxAge) {
      root.invalidateLockStatus()
      return false
    }
    return true
  }

  function refreshLockStatus() {
    if (lockStatusProbe.running) return
    root.lockProbeStartedAt = Date.now()
    lockStatusProbe.outputReady = false
    lockStatusProbe.exitReady = false
    lockStatusProbe.running = true
  }

  function acceptLockStatus(text, exitCode, exitStatus) {
    // Age from request start, not completion: delayed replies cannot renew a lease.
    var age = Date.now() - root.lockProbeStartedAt
    if (exitCode !== 0 || exitStatus !== 0 || String(text).trim() !== "false"
        || age < 0 || age >= root.lockStatusMaxAge) {
      root.invalidateLockStatus()
      return
    }
    root.lockCheckedAt = root.lockProbeStartedAt
    root.lockActive = false
  }

  function watchAmiga() {
    root.amigaTouchedAt = Date.now()
    if (root.amigaWatching) return
    root.amigaWatching = true
    root.refreshLockStatus()
  }

  function settleAmigaWatch() {
    var quiet = Date.now() - root.amigaTouchedAt
    if (amigaScreensaver.open || (quiet >= 0 && quiet < root.amigaWatchGrace)) return
    root.amigaWatching = false
    root.invalidateLockStatus()
  }

  property bool stayAwake: false
  property bool stayAwakeStateLoaded: false
  property bool hasPendingStayAwakePersist: false
  property bool pendingStayAwakePersist: false
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
    root.invalidateLockStatus()
    root.lockProbeStartedAt = 0 // Reject any unlocked reply already in flight.
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

  Timer {
    interval: 250
    running: root.amigaWatching
    repeat: true
    onTriggered: {
      root.settleAmigaWatch()
      if (root.amigaWatching) root.refreshLockStatus()
    }
  }

  Timer {
    interval: 100
    running: root.amigaWatching
    repeat: true
    onTriggered: root.lockStatusAllowsAmiga()
  }

  Process {
    id: lockStatusProbe
    // Bound the whole canonical IPC helper, including any nested qs process.
    command: ["timeout", "--kill-after=0.2s", "0.8s", root.omarchyPath + "/bin/omarchy-shell", "lock", "isLocked"]
    property bool outputReady: false
    property bool exitReady: false
    property int resultCode: -1
    property int resultStatus: -1
    function finish() {
      if (outputReady && exitReady)
        root.acceptLockStatus(lockStatusOutput.text, resultCode, resultStatus)
    }
    stdout: StdioCollector {
      id: lockStatusOutput
      waitForEnd: true
      onStreamFinished: {
        lockStatusProbe.outputReady = true
        lockStatusProbe.finish()
      }
    }
    onExited: function(exitCode, exitStatus) {
      resultCode = exitCode
      resultStatus = exitStatus
      exitReady = true
      finish()
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

  // The controller runs inside screensaverProcess for the whole Amiga session,
  // so its exit drives the same dismissal path as the native screensaver.
  AmigaScreensaver {
    id: amigaScreensaver
  }

  ShellIpc {
    target: "idle"

    function amigaRuntime(userPrefix: bool): string {
      var directory = userPrefix ? root.home + "/.local/lib" : "/usr/lib"
      return amigaScreensaver.configure("file://" + directory + "/omarchy-amiga-runtime/guard/Guard.qml")
    }

    function amigaBegin(owner: string, monitor: string): string {
      root.watchAmiga()
      if (!root.lockStatusAllowsAmiga()) {
        root.refreshLockStatus()
        return "locked"
      }
      return amigaScreensaver.begin(owner, monitor)
    }

    function amigaPoll(owner: string): string {
      root.watchAmiga()
      if (!root.lockStatusAllowsAmiga()) return "closed"
      return amigaScreensaver.poll(owner)
    }

    function amigaPresent(owner: string, monitor: string, appId: string, title: string): string {
      root.watchAmiga()
      if (!root.lockStatusAllowsAmiga()) return "closed"
      return amigaScreensaver.present(owner, monitor, appId, title)
    }

    function amigaCommit(owner: string): string {
      root.watchAmiga()
      if (!root.lockStatusAllowsAmiga()) return "closed"
      return amigaScreensaver.commit(owner)
    }

    function amigaDirect(owner: string): string {
      root.watchAmiga()
      if (!root.lockStatusAllowsAmiga()) return "closed"
      return amigaScreensaver.direct(owner)
    }

    function amigaAudioApplied(owner: string, revision: int, muted: bool): string {
      root.watchAmiga()
      if (!root.lockStatusAllowsAmiga()) return "closed"
      return amigaScreensaver.audioApplied(owner, revision, muted)
    }

    function amigaCover(owner: string): string {
      root.watchAmiga()
      if (!root.lockStatusAllowsAmiga()) return "closed"
      return amigaScreensaver.cover(owner)
    }

    function amigaEnd(owner: string): string {
      return amigaScreensaver.end(owner)
    }

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
