import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs.Commons

Item {
  id: root

  property var shell: null
  property string omarchyPath: ""

  readonly property string home: Quickshell.env("HOME")
  readonly property string stateHome: home + "/.local/state"
  readonly property string userName: Quickshell.env("USER") || Quickshell.env("LOGNAME")
  readonly property string currentBackgroundLink: stateHome + "/omarchy/current/background"

  property bool lockRequested: false
  property bool pendingSessionLock: false
  property bool wakeRerunRequested: false
  property bool keyboardBlanked: false
  // Once a restore has actually run this lock session, the idle-blank timer
  // stops dimming the keyboard again for the rest of it: without this, a
  // pause of more than 5s anywhere between the lock screen becoming visible
  // (whether from a fresh lock or a resume) and actually typing the password
  // re-dims and then immediately re-lights the keyboard the moment typing
  // resumes -- a real, user-visible flicker, not a bug in the restored value
  // itself. Reset alongside keyboardBlanked at the start of each lock.
  property bool keyboardRestoredOnce: false
  property string kbdDeviceName: ""
  property string kbdBrightnessPath: ""
  // The single source of truth for what to restore the keyboard to. NOT
  // sourced from brightnessctl's own `-s`/`-r` save-restore: that trusts
  // "whatever's current right before the off call" to be the real value,
  // which breaks the instant this EC dims the keyboard on its own (measured
  // at under 2ms after a lock request -- long before any software off call
  // could run) -- the off call then saves the already-dimmed value, the exact
  // failure this property exists to avoid. Refreshed independently, on a
  // schedule that shares no trigger with locking or suspend -- see
  // kbdBrightnessSnapshotTimer -- so it stays correct regardless of how fast
  // the hardware reacts.
  property int savedKeyboardBrightness: -1
  // Tied directly to lock state rather than toggled by hand: manual toggling
  // around individual wake/blank events kept getting this wrong whenever one
  // of the several *other* wakes a lock session runs (nudges, retries) fired
  // and cleared it while still locked, letting the poll below corrupt the
  // frozen value before the real unlock ever got to use it.
  readonly property bool kbdTrackingSuspended: locked
  property bool authenticatingPassword: false
  property bool fingerprintAuthenticating: false
  property bool passwordPamConfigured: false
  property bool fingerprintConfigured: false
  property bool previewVisible: false
  property string enteredPassword: ""
  property string pendingPassword: ""
  property string failureMessage: ""
  property int failedAttempts: 0
  property string backgroundPath: ""
  property int backgroundVersion: 0
  property string lastEvent: "init"
  property string lastEventAt: ""
  property bool displaysBlank: false
  // displaysBlank tracks what the lock asked for; Hyprland reports what each
  // panel actually did. While a video is on show the two are reconciled, so a
  // blank that failed keeps playing and a panel woken behind the lock's back
  // (a resume that kept the same outputs) resumes instead of freezing.
  property var monitorDpms: ({})
  property bool monitorDpmsKnown: false
  readonly property bool videoBackground: Util.isVideoPath(backgroundPath)
  property bool strandedLock: false
  property bool strandedLockResolved: false

  readonly property bool locked: lockRequested || sessionLock.locked || sessionLock.secure
  readonly property bool authenticating: authenticatingPassword || fingerprintAuthenticating
  readonly property var batteryService: shell && shell.services ? shell.firstPartyServiceFor("omarchy.battery") : null
  readonly property bool powerSaverActive: batteryService ? batteryService.powerSaverOnBattery : false

  function realScreenCount() {
    var screens = Quickshell.screens || []
    var count = 0

    for (var i = 0; i < screens.length; i++) {
      var screen = screens[i]
      if (screen && screen.name && screen.width > 0 && screen.height > 0) count += 1
    }

    return count
  }

  function hasRealScreen() {
    return realScreenCount() > 0
  }

  function queueSessionLock() {
    pendingSessionLock = true
    if (!sessionLockStabilizeTimer.running) logEvent("lock-pending: screen-stabilizing")
    sessionLockStabilizeTimer.restart()
    if (!pendingSessionLockTimer.running) pendingSessionLockTimer.start()
  }

  function requestSessionLock() {
    if (!lockRequested || sessionLock.locked || sessionLock.secure) return
    if (sessionLockStabilizeTimer.running) return

    if (!hasRealScreen()) {
      if (!pendingSessionLock || lastEvent !== "lock-pending: no-real-screen") logEvent("lock-pending: no-real-screen")
      pendingSessionLock = true
      if (!pendingSessionLockTimer.running) pendingSessionLockTimer.start()
      return
    }

    pendingSessionLock = false
    pendingSessionLockTimer.stop()
    sessionLock.locked = true
  }

  // ext-session-lock outlives its client, and a restart carries no lock over, so
  // a session locked this early is an orphan behind Hyprland's failsafe. Outputs
  // are often still absent here, so ask until the answer means something.
  function checkStrandedLock() {
    if (strandedLockResolved || strandedLockCheckProc.running) return

    // A lock this shell took is nobody's orphan.
    if (locked || lockRequested) {
      strandedLockResolved = true
      return
    }

    strandedLockCheckProc.running = true
  }

  function recoverStrandedLock() {
    if (!strandedLock || locked || !passwordPamConfigured) return

    strandedLock = false
    logEvent("lock-stranded: recovering")
    beginLock()
  }

  function refreshBackground() {
    if (!readlinkProc.running) readlinkProc.running = true
  }

  function refreshFingerprintStatus() {
    if (!fingerprintCheckProc.running) fingerprintCheckProc.running = true
  }

  function logEvent(event) {
    lastEvent = event
    lastEventAt = new Date().toISOString()
    console.log("omarchy lock " + lastEventAt + " " + event)
  }

  function resetAuthenticationState() {
    enteredPassword = ""
    pendingPassword = ""
    failureMessage = ""
    failedAttempts = 0
    authenticatingPassword = false
    fingerprintAuthenticating = false
    fingerprintRetryTimer.stop()
    if (passwordPam.active) passwordPam.abort()
    if (fingerprintPam.active) fingerprintPam.abort()
  }

  function beginLock() {
    if (!passwordPamConfigured) {
      logEvent("lock-denied: missing-pam")
      return false
    }

    resetAuthenticationState()
    lockRequested = true
    keyboardBlanked = false
    keyboardRestoredOnce = false
    // A read done reactively at lock time loses a real race on this hardware:
    // the EC can zero the keyboard within ~2ms of the lock request itself
    // (confirmed via direct measurement -- faster than a spawned `cat` process
    // can return), so a "refresh right as locking starts" reads the
    // already-zeroed value and POISONS savedKeyboardBrightness with it for the
    // rest of the session. kbdBrightnessSnapshotTimer's periodic cadence,
    // sampling at times unrelated to any lock/suspend trigger, is what
    // actually stays correct -- see that timer for the rest of this reasoning.
    armBlankTimer()
    logEvent("lock-requested")
    queueSessionLock()

    Qt.callLater(function() {
      root.refreshBackground()
      root.refreshFingerprintStatus()
    })

    return true
  }

  function finishUnlock() {
    if (!root.locked && !lockRequested) return

    lockRequested = false
    pendingSessionLock = false
    sessionLockStabilizeTimer.stop()
    pendingSessionLockTimer.stop()
    resetAuthenticationState()
    idleBlankTimer.stop()
    sessionLock.locked = false
    logEvent("unlocked")
    runWake()
    // Independent of whatever runWake() just decided: the delayed hardware
    // reset this exists to counter (see kbdRestoreReapplyTimer) has also been
    // measured landing a second or so after the *unlock* transition itself,
    // not only after a resume -- session teardown/refocus seems to be enough
    // to trigger it on its own, with no correlation to whether this
    // particular wake needed to restore anything. A defensive reapply here
    // costs nothing when the keyboard was never touched by suspend at all
    // (same value written twice), so it isn't worth trying to detect which
    // case this is before scheduling it.
    if (root.kbdDeviceName && root.savedKeyboardBrightness >= 0) kbdRestoreReapplyTimer.restart()
  }

  function armBlankTimer() {
    // idleBlankTimer.onTriggered's own suspend check assumes the Timer gets a
    // turn to fire and notice the gap -- measured false on resume: Hyprland
    // replays a burst of a dozen-plus wake nudges within ~3s of waking, each
    // one re-arming this timer from scratch before its 5s deadline is ever
    // reached, so onTriggered never runs at all for the rest of that lock
    // session. Checking the gap here too, on every re-arm rather than only on
    // an actual firing, catches it regardless: the first re-arm in that burst
    // still sees the full frozen-duration gap against the arm from before the
    // suspend, even though the Timer object itself never got to react to it.
    var now = Date.now()
    if (idleBlankTimer.armedAt > 0 && now - idleBlankTimer.armedAt > idleBlankTimer.interval + 2000) {
      root.keyboardBlanked = true
    }
    idleBlankTimer.armedAt = now
    idleBlankTimer.restart()
  }

  function runWake() {
    root.displaysBlank = false
    root.monitorDpmsKnown = false
    // Must run before starting/queuing wakeProcess below, not after: this is
    // what can detect a suspend gap and set keyboardBlanked true (see
    // armBlankTimer), and wakeProcess's command captures keyboardBlanked at
    // the moment it starts. Checking the gap after already starting the
    // process would make the very first wake of a resume -- the one that
    // actually discovers the gap -- run with the stale, pre-detection value.
    if (lockRequested) armBlankTimer()
    // A wake already in flight (e.g. from a keystroke nudge) must not cause
    // this request to vanish: queue a rerun so the display/keyboard restore
    // this call exists for still lands once the in-flight run finishes.
    if (!wakeProcess.running) wakeProcess.running = true
    else wakeRerunRequested = true
  }

  function runBlank() {
    root.displaysBlank = true
    root.monitorDpmsKnown = false
    keyboardBlanked = true
    if (!blankProcess.running) blankProcess.running = true
  }

  function screenBlank(screenName) {
    var name = String(screenName || "")
    if (!monitorDpmsKnown || !(name in monitorDpms)) return displaysBlank
    return !monitorDpms[name]
  }

  function applyMonitorDpms(text) {
    var monitors
    try {
      monitors = JSON.parse(String(text || ""))
    } catch (error) {
      return
    }
    if (!Array.isArray(monitors)) return

    var dpms = {}
    for (var i = 0; i < monitors.length; i++) {
      var monitor = monitors[i]
      if (monitor && monitor.name && !monitor.disabled) dpms[String(monitor.name)] = !!monitor.dpmsStatus
    }
    monitorDpms = dpms
    monitorDpmsKnown = true
  }

  function submitPassword(value) {
    var password = String(value || "")
    if (!lockRequested || authenticatingPassword || password.length === 0) return

    runWake()
    pendingPassword = password
    failureMessage = ""
    authenticatingPassword = true

    if (!passwordPam.start()) {
      handlePasswordFailure()
      return
    }

    Qt.callLater(respondToPasswordPrompt)
  }

  function respondToPasswordPrompt() {
    if (!authenticatingPassword || !passwordPam.active || !passwordPam.responseRequired) return
    passwordPam.respond(pendingPassword)
  }

  function handlePasswordFailure() {
    if (!lockRequested) return

    authenticatingPassword = false
    enteredPassword = ""
    pendingPassword = ""
    failedAttempts += 1
    failureMessage = "Authentication failed (" + failedAttempts + ")"
    runWake()
  }

  function startFingerprint() {
    if (!lockRequested || !sessionLock.secure || !fingerprintConfigured) return
    if (fingerprintPam.active || fingerprintAuthenticating) return

    fingerprintAuthenticating = true
    if (!fingerprintPam.start()) {
      fingerprintAuthenticating = false
    }
  }

  function handleFingerprintFinished(result) {
    fingerprintAuthenticating = false

    if (!lockRequested) return
    if (result === PamResult.Success) {
      finishUnlock()
    } else if (fingerprintConfigured) {
      fingerprintRetryTimer.restart()
    }
  }

  WlSessionLock {
    id: sessionLock

    locked: false

    onSecureStateChanged: {
      root.logEvent("secure=" + secure)
      if (secure) {
        root.pendingSessionLock = false
        sessionLockStabilizeTimer.stop()
        pendingSessionLockTimer.stop()
        root.startFingerprint()
      }
    }

    onLockStateChanged: {
      root.logEvent("session-locked=" + locked)

      if (locked) {
        root.pendingSessionLock = false
        sessionLockStabilizeTimer.stop()
        pendingSessionLockTimer.stop()
      }

      if (!locked && root.lockRequested) {
        root.lockRequested = false
        root.pendingSessionLock = false
        sessionLockStabilizeTimer.stop()
        pendingSessionLockTimer.stop()
        root.resetAuthenticationState()
        root.runWake()
      }
    }

    WlSessionLockSurface {
      id: lockSurface
      color: Color.background

      LockView {
        id: lockView
        anchors.fill: parent
        backgroundPath: root.backgroundPath
        backgroundVersion: root.backgroundVersion
        fingerprintConfigured: root.fingerprintConfigured
        authenticatingPassword: root.authenticatingPassword
        failureMessage: root.failureMessage
        failedAttempts: root.failedAttempts
        inputEnabled: root.lockRequested
        loadBackground: root.locked
        displaysBlank: root.screenBlank(lockSurface.screen ? lockSurface.screen.name : "")
        powerSaverActive: root.powerSaverActive
        passwordText: root.enteredPassword
        onPasswordTextEdited: function(password) { root.enteredPassword = password }
        onSubmitPassword: function(password) { root.submitPassword(password) }
        onClearFailureRequested: root.failureMessage = ""
        onWakeRequested: root.runWake()
      }

    }
  }

  PanelWindow {
    id: previewWindow
    visible: root.previewVisible
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-lock-preview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    LockView {
      anchors.fill: parent
      backgroundPath: root.backgroundPath
      backgroundVersion: root.backgroundVersion
      fingerprintConfigured: root.fingerprintConfigured
      authenticatingPassword: false
      failureMessage: ""
      failedAttempts: 0
      inputEnabled: false
      loadBackground: root.previewVisible
      powerSaverActive: root.powerSaverActive
      passwordText: ""
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: root.previewVisible = false
    }
  }

  PamContext {
    id: passwordPam
    config: "omarchy-lock-password"
    user: root.userName

    onResponseRequiredChanged: root.respondToPasswordPrompt()
    onPamMessage: root.respondToPasswordPrompt()

    onCompleted: function(result) {
      root.authenticatingPassword = false
      root.pendingPassword = ""

      if (!root.lockRequested) return
      if (result === PamResult.Success) root.finishUnlock()
      else root.handlePasswordFailure()
    }

    onError: function(error) {
      root.handlePasswordFailure()
    }
  }

  PamContext {
    id: fingerprintPam
    config: "omarchy-lock-fingerprint"
    user: root.userName

    onCompleted: function(result) {
      root.handleFingerprintFinished(result)
    }

    onError: function(error) {
      root.fingerprintAuthenticating = false
      if (root.lockRequested && root.fingerprintConfigured) fingerprintRetryTimer.restart()
    }
  }

  Timer {
    id: fingerprintRetryTimer
    interval: 250
    repeat: false
    onTriggered: root.startFingerprint()
  }

  Process {
    id: readlinkProc
    command: ["readlink", "-f", root.currentBackgroundLink]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var next = String(text || "").trim()
        if (next !== root.backgroundPath) {
          root.backgroundPath = next
          root.backgroundVersion += 1
        }
      }
    }
  }

  Process {
    id: fingerprintCheckProc
    command: ["bash", "-c", "if [[ -f /etc/pam.d/omarchy-lock-fingerprint ]] && command -v fprintd-list >/dev/null 2>&1 && fprintd-list \"$USER\" 2>/dev/null | grep -qi finger; then echo yes; else echo no; fi"]
    stdout: StdioCollector { id: fingerprintCheckStdout; waitForEnd: true }
    onExited: {
      root.fingerprintConfigured = String(fingerprintCheckStdout.text || "").trim() === "yes"
      if (root.lockRequested && root.fingerprintConfigured) root.startFingerprint()
      else if (!root.fingerprintConfigured && fingerprintPam.active) fingerprintPam.abort()
    }
  }

  Process {
    id: strandedLockCheckProc
    command: ["bash", "-c", "omarchy-hyprland-session-locked"]
    onExited: function(exitCode) {
      // No output to read the lock off yet.
      if (exitCode === 2) return

      root.strandedLockResolved = true

      // A lock taken while this was in flight is this shell's own.
      root.strandedLock = exitCode === 0 && !root.locked && !root.lockRequested
      root.recoverStrandedLock()
    }
  }

  Process {
    id: wakeProcess
    // Keyboard restore only makes sense if this lock session actually blanked
    // it: otherwise it overwrites the user's current brightness (e.g. set via
    // a firmware-handled brightness key) with a stale value. Always restores
    // through savedKeyboardBrightness, never through brightnessctl's own
    // `-r restore` -- see that property's own comment for why its "-s save
    // whatever's current" semantics aren't trustworthy on this hardware.
    command: ["bash", "-c",
      "omarchy-brightness-display on" +
      (root.keyboardBlanked && root.kbdDeviceName && root.savedKeyboardBrightness >= 0
        ? ("; brightnessctl -d '" + root.kbdDeviceName + "' set " + root.savedKeyboardBrightness)
        : "") +
      "; omarchy-hyprland-monitor-clamshell >/dev/null 2>&1 || true"]

    onExited: {
      // Consumed after the first run, not before it starts: a resume from
      // suspend replays a burst of a dozen-plus wake nudges within a few
      // seconds (measured), so this exists to run at most once per blank
      // cycle. Clearing any earlier -- e.g. up front in runWake() -- would
      // race a rerun still queued from *this* burst, which reads
      // keyboardBlanked fresh at its own, later start time: a late nudge in
      // the same burst could still restore, using whatever
      // savedKeyboardBrightness has drifted to by then (a hardware
      // notification queued during the suspend/resume boundary can arrive
      // late, after this process already restored correctly, and report a
      // stale pre-restore value). Clearing only once a run has actually
      // completed closes that window: every rerun after the first sees
      // keyboardBlanked already false and leaves the keyboard alone.
      //
      // A run that DID restore schedules one follow-up re-assertion: measured
      // on this hardware, resume also triggers a genuine USB host-controller
      // resume error (kernel log: "xHC error in resume, USBSTS 0x401,
      // Reinit"), forcing a full re-enumeration a couple of seconds after the
      // EC's own wake sequence and snapping the keyboard controller back to a
      // hardware default independent of anything this restore just set.
      // There is no notification for that -- it isn't a brightness_hw_changed
      // event, just a later, unrelated reset -- so the only way to win
      // against it is to re-assert the same value once more after it's had
      // time to happen, rather than trying to detect it.
      if (root.keyboardBlanked) {
        kbdRestoreReapplyTimer.restart()
        root.keyboardRestoredOnce = true
      }
      root.keyboardBlanked = false
      if (!root.wakeRerunRequested) return
      root.wakeRerunRequested = false
      wakeProcess.running = true
    }
  }

  Process {
    id: blankProcess
    command: ["bash", "-c", "omarchy-brightness-keyboard off; omarchy-brightness-display off"]
  }

  // Quickshell exposes no DPMS signal, so the panel state is polled while a
  // video is the locked wallpaper. A wake or blank request drops the last
  // answer, so its optimistic state applies until the next poll confirms it.
  Process {
    id: monitorDpmsProcess
    command: ["hyprctl", "monitors", "-j"]
    stdout: StdioCollector {
      onStreamFinished: root.applyMonitorDpms(text)
    }
  }

  Timer {
    id: monitorDpmsTimer
    interval: 3000
    repeat: true
    triggeredOnStart: true
    running: root.locked && root.videoBackground
    onTriggered: {
      if (!monitorDpmsProcess.running) monitorDpmsProcess.running = true
    }
    onRunningChanged: {
      if (!running) root.monitorDpmsKnown = false
    }
  }

  Process {
    id: findKbdDeviceProc
    // Also reads the starting value: the watcher below only ever reports
    // changes, so without this, a session that locks before ever touching
    // the brightness key would have nothing to restore to. brightness_hw_changed
    // is itself optional -- only drivers that call
    // led_classdev_notify_brightness_hw_changed() expose it -- so check for it
    // rather than let the watcher loop forever opening a file that never exists.
    command: ["bash", "-c",
      "for c in /sys/class/leds/*kbd_backlight*; do [[ -e $c ]] && { " +
      "basename \"$c\"; cat \"$c/brightness\"; " +
      "[[ -e $c/brightness_hw_changed ]] && echo yes || echo no; break; }; done"]
    stdout: StdioCollector {
      id: findKbdDeviceStdout
      waitForEnd: true
      onStreamFinished: {
        var lines = String(text || "").trim().split("\n")
        var name = (lines[0] || "").trim()
        if (!name) return
        root.kbdDeviceName = name
        root.kbdBrightnessPath = "/sys/class/leds/" + name + "/brightness"
        var initial = parseInt((lines[1] || "").trim())
        if (!isNaN(initial)) root.savedKeyboardBrightness = initial
        if ((lines[2] || "").trim() === "yes") kbdWatcherProc.running = true
      }
    }
  }

  // Refreshes savedKeyboardBrightness from a direct read. Triggered both from
  // beginLock() and, periodically, by kbdBrightnessSnapshotTimer below.
  Process {
    id: refreshKbdBrightnessProc
    command: ["cat", root.kbdBrightnessPath]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var val = parseInt(String(text || "").trim())
        if (!isNaN(val)) root.savedKeyboardBrightness = val
      }
    }
  }

  // A live brightness_hw_changed notification (kbdWatcherProc above) is the
  // precise way to track a hardware-driven change, but it depends on the
  // watcher process actually being scheduled at the moment the EC signals it
  // -- confirmed unreliable here for the EC's own lid-close-triggered dim,
  // which lands while the suspend freezer has already stopped every user
  // process, watcher included, so the notification has nobody left to read
  // it. A single fresh read at beginLock() has the same problem in miniature:
  // when the same lid-close event fires both the lock and an almost-
  // immediate suspend, the EC can zero the value before that read's own
  // process finishes spawning. A periodic snapshot while unlocked sidesteps
  // both races entirely -- it never depends on catching the exact instant of
  // a hardware change, only on having asked recently enough that the answer
  // is still true. 5s matches idleBlankTimer's own cadence and costs one cat
  // process every 5s only while awake and unlocked, never while locked or
  // suspended.
  Timer {
    id: kbdBrightnessSnapshotTimer
    interval: 5000
    repeat: true
    running: root.kbdBrightnessPath !== "" && !root.locked
    onTriggered: refreshKbdBrightnessProc.running = true
  }

  // The keyboard backlight can change outside any script the shell calls: a
  // firmware-handled brightness key changes the sysfs value directly, and on
  // some hardware the EC zeroes it the instant the lid shuts, before this
  // session even reacts to that -- either way, a value read only in response
  // is always too late; only one already on hand beforehand survives it. The
  // LED class exposes brightness_hw_changed exactly for this: a poll()-able
  // file the driver notifies on hardware-driven changes, so this can block
  // at zero cost until one actually happens rather than checking on a timer.
  Process {
    id: kbdWatcherProc
    // Before the first hardware-notified change since boot, the kernel has
    // nothing to report yet and reads raise ENODATA rather than returning
    // content -- an unrelated error still needs to surface, so only that one
    // is swallowed, on the priming read and after each wake alike.
    command: ["python3", "-u", "-c",
      "import select, errno\n" +
      "def drain(fh):\n" +
      "    try: fh.read()\n" +
      "    except OSError as e:\n" +
      "        if e.errno != errno.ENODATA: raise\n" +
      "f = open('" + root.kbdBrightnessPath.replace(/brightness$/, "brightness_hw_changed") + "')\n" +
      "drain(f); f.seek(0)\n" +
      "p = select.poll()\n" +
      "p.register(f, select.POLLPRI | select.POLLERR)\n" +
      "while True:\n" +
      "    if p.poll():\n" +
      "        f.seek(0); drain(f)\n" +
      "        print(open('" + root.kbdBrightnessPath + "').read().strip(), flush=True)\n"]
    stdout: SplitParser {
      onRead: function(line) {
        var val = parseInt(String(line).trim())
        if (isNaN(val)) return
        if (!root.kbdTrackingSuspended) root.savedKeyboardBrightness = val
      }
    }
    // This is meant to run for the shell's whole lifetime; if it ever exits
    // (crash, the sysfs path disappearing) restart it after a short delay
    // rather than silently going dark for the rest of the session.
    onExited: kbdWatcherRestartTimer.restart()
  }

  Timer {
    id: kbdWatcherRestartTimer
    interval: 2000
    repeat: false
    onTriggered: kbdWatcherProc.running = true
  }

  // See wakeProcess.onExited for why this exists: re-asserts the same
  // restore value once more, after the USB re-enumeration a resume triggers
  // on this hardware has had time to reset the keyboard controller on its
  // own.
  Timer {
    id: kbdRestoreReapplyTimer
    interval: 3000
    repeat: false
    onTriggered: {
      if (root.kbdDeviceName && root.savedKeyboardBrightness >= 0) reapplyKbdBrightnessProc.running = true
    }
  }

  Process {
    id: reapplyKbdBrightnessProc
    command: ["brightnessctl", "-d", root.kbdDeviceName, "set", String(root.savedKeyboardBrightness)]
  }

  Timer {
    id: idleBlankTimer
    interval: 5000
    repeat: false
    property double armedAt: 0
    onTriggered: {
      // A countdown frozen by suspend fires right after resume, which would
      // blank the freshly woken unlock screen under the user. Wall-clock time
      // exposes the gap: take a fresh run-up instead of blanking.
      if (Date.now() - armedAt > interval + 2000) {
        // A real suspend happened here (that's what this gap means), and the
        // EC can reset the keyboard LED across suspend/resume on its own,
        // independent of whether this timer ever ran the blank. Let the next
        // wake restore it even though root never asked for the blank itself;
        // savedKeyboardBrightness has held the value from right before this
        // lock session started the whole time, untouched while locked.
        root.keyboardBlanked = true
        root.armBlankTimer()
        return
      }
      // Only a password check in flight should hold the display up. The
      // fingerprint PAM stays armed for the whole lock, so gating on
      // `authenticating` here would keep the panel lit until unlock.
      // keyboardRestoredOnce also gates this: once a restore has actually run
      // this session, a later idle gap here is just the user pausing before
      // typing their password, not a reason to dim and immediately re-light
      // the keyboard again -- that's a visible flicker, not a real off
      // period, and it's the suspend-detected branch above (unguarded by
      // design) that still needs to catch a genuine second suspend.
      if (!root.lockRequested || root.authenticatingPassword) return
      if (root.keyboardRestoredOnce) {
        // Suppressed, not skipped outright: without re-arming here, armedAt
        // is left at whatever it was 5s ago, so the *next* wake -- whenever
        // that happens to be, seconds or minutes later -- sees a large gap
        // against that stale value and misreads ordinary idle time as
        // another suspend (measured: this exact sequence re-triggered the
        // suspend-detected branch above on a plain pause, no suspend
        // involved). Re-arming keeps the elapsed-time math honest for
        // whichever branch runs next, while still never blanking again.
        root.armBlankTimer()
        return
      }
      root.runBlank()
    }
  }

  Timer {
    id: sessionLockStabilizeTimer
    interval: 500
    repeat: false
    onTriggered: root.requestSessionLock()
  }

  Timer {
    id: pendingSessionLockTimer
    interval: 100
    repeat: true
    onTriggered: root.requestSessionLock()
  }

  Timer {
    id: strandedLockRetryTimer
    interval: 500
    repeat: true
    // Covers the compositor settling; screens coming back re-arm it.
    readonly property int budget: 20
    property int remaining: 20
    running: !root.strandedLockResolved && remaining > 0

    function rearm() {
      if (!root.strandedLockResolved) remaining = budget
    }

    onTriggered: {
      remaining -= 1
      root.checkStrandedLock()
    }
  }

  Connections {
    target: Quickshell
    function onScreensChanged() {
      // A panel coming back is a display turning on that runWake did not ask
      // for, so the blank state has to be given up here or a visible lock
      // wallpaper stays frozen until the next keypress.
      root.displaysBlank = false
      root.requestSessionLock()

      // A monitor still coming up has no workspace, so cannot answer yet.
      strandedLockRetryTimer.rearm()
      root.checkStrandedLock()
    }
  }

  onAuthenticatingPasswordChanged: {
    if (!lockRequested) return
    if (authenticatingPassword) idleBlankTimer.stop()
    else armBlankTimer()
  }

  FileView {
    path: "/etc/pam.d/omarchy-lock-password"
    watchChanges: true
    printErrors: false
    onLoaded: root.passwordPamConfigured = true
    onLoadFailed: root.passwordPamConfigured = false
    onFileChanged: reload()
  }

  // No lock before PAM is known good. An answer from before then may be stale --
  // the failsafe can be cleared from a TTY -- so re-ask rather than act on it.
  onPasswordPamConfiguredChanged: {
    if (!passwordPamConfigured) return

    strandedLock = false
    strandedLockResolved = false
    strandedLockRetryTimer.rearm()
    checkStrandedLock()
  }

  Component.onCompleted: {
    refreshBackground()
    refreshFingerprintStatus()
    checkStrandedLock()
    findKbdDeviceProc.running = true
  }

  IpcHandler {
    target: "lock"

    function lock(): string {
      if (!root.passwordPamConfigured) return "missing-pam"
      if (!root.locked && !root.beginLock()) return "failed"
      return "ok"
    }

    function isLocked(): string {
      return root.locked ? "true" : "false"
    }

    function status(): string {
      return JSON.stringify({
        locked: root.locked,
        requested: root.lockRequested,
        pending: root.pendingSessionLock,
        sessionLocked: sessionLock.locked,
        secure: sessionLock.secure,
        realScreens: root.realScreenCount(),
        passwordPam: root.passwordPamConfigured,
        fingerprint: root.fingerprintConfigured,
        authenticating: root.authenticating,
        lastEvent: root.lastEvent,
        lastEventAt: root.lastEventAt
      })
    }

    function preview(): string {
      root.refreshBackground()
      root.refreshFingerprintStatus()
      root.previewVisible = true
      return "ok"
    }

    function hidePreview(): string {
      root.previewVisible = false
      return "ok"
    }
  }
}
