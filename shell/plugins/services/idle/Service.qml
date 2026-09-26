import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "IdleModel.js" as IdleModel

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
  readonly property int firstIdleTimeoutSeconds: Math.min(screensaverTimeoutSeconds, lockTimeoutSeconds)
  readonly property int screensaverDelaySeconds: Math.max(0, screensaverTimeoutSeconds - firstIdleTimeoutSeconds)
  readonly property int lockDelaySeconds: Math.max(0, lockTimeoutSeconds - firstIdleTimeoutSeconds)
  readonly property bool idleEnabled: stayAwakeStateLoaded && !stayAwake
  readonly property string screensaverClass: "org.omarchy.screensaver"
  readonly property bool screensaverVisible: screensaverWindowCount > 0
  // Arm dismissal only after launch has finished and never during lock handoff.
  // Stay Awake gates the main idle monitor, not pointer/touch dismissal of an
  // already-visible (e.g. force-launched) screensaver.
  readonly property bool screensaverDismissEnabled: screensaverVisible && screensaverLaunchComplete && !lockHandoff

  property bool stayAwake: false
  property bool stayAwakeStateLoaded: false
  property bool hasPendingStayAwakePersist: false
  property bool pendingStayAwakePersist: false
  property bool idledThisCycle: false
  property bool screensaverStartedThisCycle: false
  property string lastEvent: "starting"
  property string lastEventAt: ""
  property var screensaverWindows: ({})
  property int screensaverWindowCount: 0
  property int expectedScreensaverWindows: 0
  property bool screensaverLaunchComplete: false
  property bool dismissSettled: false
  property bool dismissInFlight: false
  property bool lockHandoff: false

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

  function monitorCount() {
    try {
      var values = Hyprland.monitors && Hyprland.monitors.values
      if (values && values.length > 0) return values.length
    } catch (error) {
    }
    return 1
  }

  function beginScreensaverLaunchTracking() {
    root.expectedScreensaverWindows = root.monitorCount()
    root.screensaverLaunchComplete = false
    root.dismissSettled = false
    root.dismissInFlight = false
    dismissArmTimer.stop()
    if (!screensaverLaunchGraceTimer.running) screensaverLaunchGraceTimer.restart()
  }

  function markScreensaverLaunchComplete(reason) {
    if (root.screensaverLaunchComplete) return
    root.screensaverLaunchComplete = true
    root.dismissSettled = false
    screensaverLaunchGraceTimer.stop()
    // Fixed arm delay survives jittery mice that never stay quiet long enough
    // for the dismiss IdleMonitor alone to settle.
    dismissArmTimer.restart()
    logEvent("screensaver-launch-complete", reason || ("windows=" + root.screensaverWindowCount))
  }

  function launchScreensaver() {
    root.screensaverStartedThisCycle = true
    beginScreensaverLaunchTracking()
    runProcess(screensaverProcess, "screensaver", "[[ $(omarchy-shell lock isLocked 2>/dev/null) == \"true\" ]] || omarchy-launch-screensaver")
  }

  function lockSystem(reason) {
    // Block dismiss before any monitor disable / pkill side effects so a
    // spurious active edge cannot tear the screensaver down and flash the
    // desktop ahead of the lock.
    root.lockHandoff = true
    dismissArmTimer.stop()
    logEvent("lock-system", reason || "requested")
    screensaverTimer.stop()
    lockTimer.stop()
    screensaverLaunchGraceTimer.stop()
    root.idledThisCycle = false
    root.screensaverStartedThisCycle = false

    // Keep the fullscreen screensaver over the desktop until the concealed
    // lock surface is secure on every output. Then run the normal lock cleanup
    // (which removes the screensaver). If the lock request disappears, leave
    // the screensaver mapped instead of exposing the session.
    runProcess(
      lockProcess,
      "lock",
      "omarchy-shell lock lockFromIdle >/dev/null 2>&1 || exit 1; while [[ $(omarchy-shell lock isLocked 2>/dev/null) == true ]]; do [[ $(omarchy-shell lock status 2>/dev/null | jq -r '.secure // false') == true ]] && exec omarchy-system-lock; sleep 0.05; done; exit 1"
    )
  }

  function startIdleCycle() {
    if (root.idledThisCycle) {
      logEvent("idle-cycle-already-running")
      return
    }

    logEvent("idle-cycle-start", "screensaver=" + root.screensaverTimeoutSeconds + " lock=" + root.lockTimeoutSeconds)
    root.idledThisCycle = true
    root.screensaverStartedThisCycle = false
    root.lockHandoff = false
    root.dismissInFlight = false

    // Do not clear tracked screensaver windows: a menu/force-launched
    // screensaver is already mapped and Hyprland will not send another
    // openwindow for it when this idle cycle starts.
    if (root.screensaverWindowCount === 0) {
      root.expectedScreensaverWindows = 0
      root.screensaverLaunchComplete = false
      root.dismissSettled = false
    } else {
      root.screensaverLaunchComplete = true
      root.expectedScreensaverWindows = Math.max(root.expectedScreensaverWindows, root.screensaverWindowCount)
      root.dismissSettled = false
      dismissArmTimer.restart()
    }

    if (root.screensaverDelaySeconds === 0) launchScreensaver()
    else screensaverTimer.restart()

    if (root.lockDelaySeconds === 0) lockSystem("lock-timeout-immediate")
    else lockTimer.restart()
  }

  function cancelIdleCycle(reason) {
    logEvent("idle-cycle-cancel", reason || "requested")
    screensaverTimer.stop()
    lockTimer.stop()
    screensaverLaunchGraceTimer.stop()
    dismissArmTimer.stop()

    if (root.idledThisCycle) runProcess(wakeProcess, "wake", "omarchy-system-wake")

    root.idledThisCycle = false
    root.screensaverStartedThisCycle = false
    resetScreensaverWindows()
  }

  function resetScreensaverWindows() {
    root.screensaverWindows = ({})
    root.screensaverWindowCount = 0
    root.expectedScreensaverWindows = 0
    root.screensaverLaunchComplete = false
    root.dismissSettled = false
    root.dismissInFlight = false
    dismissArmTimer.stop()
  }

  // Signal the screensaver supervisor so its exit trap restores the cursor and
  // tears down ttfx/terminals. Also match the lock cleanup path so a missed
  // supervisor still drops the windows. Window close events then cancel the
  // idle cycle when appropriate.
  function dismissScreensaver(reason) {
    if (root.lockHandoff || root.dismissInFlight || root.screensaverWindowCount === 0) return
    root.dismissInFlight = true
    root.dismissSettled = false
    dismissArmTimer.stop()
    logEvent("screensaver-dismiss", reason || "input")
    runProcess(
      dismissProcess,
      "dismiss",
      "pkill -f '[o]marchy-screensaver' 2>/dev/null || true; pkill -x ttfx 2>/dev/null || true; timeout 1s pidwait -x ttfx 2>/dev/null || true; pkill -f '[o]rg.omarchy.screensaver' 2>/dev/null || true"
    )
  }

  function armDismissAfterLaunch() {
    if (!root.screensaverVisible || root.lockHandoff || root.dismissInFlight) return
    root.dismissSettled = true
    logEvent("screensaver-dismiss-armed", "launch-timer")
    // Jittery devices may never report a full idle second; if seat activity is
    // already present after the launch quiet period, treat that as dismiss.
    if (!screensaverDismissMonitor.isIdle) dismissScreensaver("input-already-active")
  }

  function handleDismissMonitorChanged() {
    var next = IdleModel.dismissStateAfter({
      visible: root.screensaverVisible,
      launchComplete: root.screensaverLaunchComplete,
      locking: root.lockHandoff,
      settled: root.dismissSettled,
      isIdle: screensaverDismissMonitor.isIdle,
      dismissInFlight: root.dismissInFlight
    })
    root.dismissSettled = next.settled
    if (next.dismiss) {
      dismissArmTimer.stop()
      dismissScreensaver("input")
    }
  }

  function setScreensaverWindow(address, visible) {
    var next = IdleModel.screensaverWindowsAfter(root.screensaverWindows, address, visible)
    root.screensaverWindows = next.windows
    root.screensaverWindowCount = next.count
  }

  function handleScreensaverWindowOpened(address) {
    // Menu/force launches never call launchScreensaver(); start tracking here.
    if (root.expectedScreensaverWindows <= 0) beginScreensaverLaunchTracking()

    setScreensaverWindow(address, true)
    // Each newly mapped output resets settle so sequential multi-monitor
    // focus warps cannot look like user input after a premature arm.
    root.dismissSettled = false

    if (IdleModel.screensaverLaunchCompleteAfter(root.screensaverWindowCount, root.expectedScreensaverWindows, false)) {
      markScreensaverLaunchComplete("windows=" + root.screensaverWindowCount + "/" + root.expectedScreensaverWindows)
    }
  }

  function handleScreensaverWindowClosed(address) {
    setScreensaverWindow(address, false)

    if (root.screensaverWindowCount === 0) {
      root.screensaverLaunchComplete = false
      root.expectedScreensaverWindows = 0
      root.dismissSettled = false
      root.dismissInFlight = false
    }

    if (!root.idleEnabled || !root.idledThisCycle || !root.screensaverStartedThisCycle) return
    if (root.screensaverWindowCount > 0) return

    // The user dismissed the screensaver before the lock deadline. Treat that
    // as activity and cancel the pending lock; the lock timer is only allowed
    // to fire while the screensaver remains up.
    root.cancelIdleCycle("screensaver-dismissed")
  }

  function eventParts(event, count) {
    return IdleModel.eventParts(event, count)
  }

  function handleHyprlandEvent(event) {
    var name = String(event && event.name ? event.name : "")
    if (name === "openwindow") {
      var open = eventParts(event, 4)
      if (String(open[2] || "") === root.screensaverClass) root.handleScreensaverWindowOpened(open[0])
    } else if (name === "closewindow") {
      var close = eventParts(event, 1)
      var address = String(close[0] || "")
      if (root.screensaverWindows[address]) root.handleScreensaverWindowClosed(address)
    }
  }

  function handleActiveSignal() {
    if (!root.idledThisCycle) return

    // Starting the screensaver can make the compositor report activity. Keep
    // the lock timer running once the screensaver exists (or during its short
    // launch grace); Hyprland window events cancel the cycle if it exits before
    // the normal lock deadline.
    if (root.screensaverStartedThisCycle && (root.screensaverWindowCount > 0 || screensaverLaunchGraceTimer.running)) {
      logEvent("idle-monitor-active", "screensaver cycle remains armed")
      return
    }

    cancelIdleCycle("activity")
  }

  function handleIdleChanged() {
    logEvent("idle-monitor", idleMonitor.isIdle ? "idle" : "active")
    if (!root.idleEnabled) return

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
      screensaverWindows: root.screensaverWindowCount,
      expectedScreensaverWindows: root.expectedScreensaverWindows,
      screensaverLaunchComplete: root.screensaverLaunchComplete,
      screensaverDismissEnabled: root.screensaverDismissEnabled,
      dismissSettled: root.dismissSettled,
      dismissInFlight: root.dismissInFlight,
      lockHandoff: root.lockHandoff,
      timers: {
        screensaver: screensaverTimer.running,
        lock: lockTimer.running,
        screensaverLaunchGrace: screensaverLaunchGraceTimer.running
      },
      processes: {
        screensaver: screensaverProcess.running,
        lock: lockProcess.running,
        wake: wakeProcess.running,
        dismiss: dismissProcess.running
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

  IdleMonitor {
    id: idleMonitor
    enabled: root.idleEnabled
    timeout: root.firstIdleTimeoutSeconds
    respectInhibitors: true
    onIsIdleChanged: root.handleIdleChanged()
  }

  // The main idle monitor goes active when the screensaver maps and then stays
  // active for the whole display, so it never edges again on pointer/touch.
  // This short monitor arms only after launch is complete and dismisses on the
  // next seat-activity edge (keyboard, pointer, touch, BT mice).
  IdleMonitor {
    id: screensaverDismissMonitor
    enabled: root.screensaverDismissEnabled
    // Short settle so a brief quiet gap is enough; the launch arm timer covers
    // devices that never stay fully idle.
    timeout: 0.35
    respectInhibitors: false
    onEnabledChanged: root.dismissSettled = false
    onIsIdleChanged: root.handleDismissMonitorChanged()
  }

  Timer {
    id: dismissArmTimer
    interval: 1200
    repeat: false
    onTriggered: root.armDismissAfterLaunch()
  }

  Timer {
    id: screensaverTimer
    interval: root.screensaverDelaySeconds * 1000
    repeat: false
    onTriggered: root.launchScreensaver()
  }

  Timer {
    id: lockTimer
    interval: root.lockDelaySeconds * 1000
    repeat: false
    onTriggered: if (root.idleEnabled && root.idledThisCycle) root.lockSystem("lock-timeout")
  }

  Timer {
    id: screensaverLaunchGraceTimer
    interval: 3000
    repeat: false
    onTriggered: {
      if (root.screensaverWindowCount > 0 && !root.screensaverLaunchComplete) {
        root.markScreensaverLaunchComplete("grace-fallback windows=" + root.screensaverWindowCount)
        return
      }

      if (root.idleEnabled && root.idledThisCycle && root.screensaverStartedThisCycle && root.screensaverWindowCount === 0 && !idleMonitor.isIdle) {
        root.cancelIdleCycle("screensaver-not-running")
      }
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) { root.handleHyprlandEvent(event) }
  }

  Process {
    id: screensaverProcess
    onExited: function(exitCode, exitStatus) { root.logEvent("process-exit", "screensaver exitCode=" + exitCode + " status=" + exitStatus) }
  }
  Process {
    id: lockProcess
    onExited: function(exitCode, exitStatus) {
      root.lockHandoff = false
      root.resetScreensaverWindows()
      root.logEvent("process-exit", "lock exitCode=" + exitCode + " status=" + exitStatus)
    }
  }
  Process {
    id: dismissProcess
    onExited: function(exitCode, exitStatus) {
      if (root.screensaverWindowCount === 0) root.dismissInFlight = false
      root.logEvent("process-exit", "dismiss exitCode=" + exitCode + " status=" + exitStatus)
    }
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

  IpcHandler {
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
