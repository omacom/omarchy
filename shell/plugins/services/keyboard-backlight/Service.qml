import QtQuick
import Quickshell
import Quickshell.Io
import "KeyboardBacklightModel.js" as KeyboardBacklightModel
import qs.Commons

Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string ledsPath: Quickshell.env("OMARCHY_LEDS_PATH") || "/sys/class/leds"
  readonly property string manualOffPath: home + "/.local/state/omarchy/keyboard-backlight-manual-off"
  readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
  // The last level seen, so a restart can tell what the keys changed while the
  // shell was down. It lives in the runtime dir: across a reboot the firmware
  // or systemd-backlight sets the level, not the user.
  readonly property string lastLevelPath: runtimeDir + "/omarchy-keyboard-backlight-level"
  // `omarchy-brightness-keyboard off` keeps the level it blanked here until
  // `restore`, under a lock beside it. Writes take the same lock and skip
  // while it's there, so none lands behind the blank.
  readonly property string blankPath: device !== "" ? runtimeDir + "/omarchy-brightness-keyboard-" + device : ""
  readonly property var tuning: KeyboardBacklightModel.config(shell && shell.shellConfig ? shell.shellConfig.keyboardBacklight : null)

  property bool probed: false
  property bool hasSensor: false
  property bool disabled: false
  property string device: ""
  property int maxLevel: 0
  // The sensor sits in the lid, so with the lid shut (docked, clamshell) it
  // reads dark and would light the keys under it. Read at the probe, then
  // nudged by the lid bindings.
  property bool lidClosed: false
  property bool lidRecheck: false
  property bool monitorRestart: false
  readonly property bool active: probed && hasSensor && device !== "" && maxLevel > 0 && !disabled

  // Set while the session has the keyboard blanked (lock or idle), between
  // `omarchy brightness keyboard off` and its `restore`.
  property bool paused: false

  property var state: null
  property var lux: null
  property int pendingLevel: -1
  property int writeRetries: 0
  property string savedManualOff: ""
  property string savedLevel: ""

  function probe() {
    if (!probeProcess.running) probeProcess.running = true
  }

  function applyProbe(text) {
    var sensor = false
    var off = false
    var name = ""
    var max = 0
    var closed = false
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var parts = lines[i].trim().split(/\s+/)
      if (parts[0] === "sensor") sensor = true
      else if (parts[0] === "disabled") off = true
      else if (parts[0] === "lid-closed") closed = true
      else if (parts[0] === "device" && parts.length === 3) {
        name = parts[1]
        max = parseInt(parts[2], 10) || 0
      }
    }

    root.hasSensor = sensor
    root.disabled = off
    root.device = name
    root.maxLevel = max
    root.lidClosed = closed
    root.probed = true
  }

  function readBrightness() {
    brightnessFile.reload()
    var level = parseInt(String(brightnessFile.text()).trim(), 10)
    return isNaN(level) ? null : level
  }

  function readText(file) {
    file.reload()
    return String(file.text()).trim()
  }

  function readLastLevel() {
    var level = parseInt(readText(lastLevelFile), 10)
    return isNaN(level) ? null : level
  }

  function blanked() {
    return root.blankPath !== "" && readText(blankFile) !== ""
  }

  function syncMonitor() {
    var wanted = root.active && root.state !== null
    if (monitorProcess.running !== wanted) monitorProcess.running = wanted
  }

  // A shell restarted while the session has the keys blanked starts paused,
  // and leaves the level to the wake's resume().
  function start() {
    root.lux = null
    root.paused = blanked()
    root.savedManualOff = readText(manualOffFile)
    root.savedLevel = readText(lastLevelFile)
    root.state = KeyboardBacklightModel.initialState(readBrightness(), root.maxLevel, Number(root.savedManualOff) || 0,
      root.paused ? null : readLastLevel(), Date.now())
    save()
  }

  // Picks up a level set by the keys since the last look. A reading taken
  // while our own write is in flight isn't a user change.
  function observe(now) {
    if (setProcess.running || root.pendingLevel >= 0) return
    root.state = KeyboardBacklightModel.observeBrightness(root.state, readBrightness(), now)
  }

  function save() {
    if (!root.state) return
    var manualOff = root.state.manualOffSince > 0 ? String(root.state.manualOffSince) : ""
    if (manualOff !== root.savedManualOff) {
      manualOffFile.setText(manualOff)
      root.savedManualOff = manualOff
    }
    var level = root.state.expected === null || root.state.expected === undefined ? "" : String(root.state.expected)
    if (level !== root.savedLevel) {
      lastLevelFile.setText(level)
      root.savedLevel = level
    }
  }

  // The level a write was meant to set never landed, or a write was dropped:
  // take what is there as the baseline and decide again from the light.
  function resync() {
    if (root.state) root.state = KeyboardBacklightModel.resume(root.state, readBrightness())
    save()
  }

  function step() {
    if (!root.active || !root.state || root.paused || root.lidClosed) return

    var now = Date.now()
    observe(now)

    var result = KeyboardBacklightModel.evaluate(root.state, root.lux, now, root.tuning)
    root.state = result.state

    if (result.set !== null) setLevel(result.set)
    save()

    if (result.nextCheckMs >= 0) {
      // Timer intervals are 32-bit.
      checkTimer.interval = Math.min(2147483647, Math.max(1, result.nextCheckMs))
      checkTimer.restart()
    } else {
      checkTimer.stop()
    }
  }

  function setLevel(level) {
    if (setProcess.running) {
      root.pendingLevel = level
      return
    }

    setProcess.command = ["flock", root.blankPath + ".lock", "bash", "-c",
      "if [[ -s $1 ]]; then exit 75; fi; exec brightnessctl -d \"$2\" set \"$3\" >/dev/null",
      "omarchy-keyboard-backlight", root.blankPath, root.device, String(level)]
    setProcess.running = true
  }

  function finishWrite(exitCode) {
    var level = root.pendingLevel
    root.pendingLevel = -1
    if (!root.state) return

    // A queued level waits for no blank or closed lid that came meanwhile.
    var queued = level >= 0 && root.active && !root.paused && !root.lidClosed
    if (exitCode !== 0 || (level >= 0 && !queued)) resync()

    // A write that failed (not one skipped for a blank, 75) is tried again a
    // few times, since in steady light nothing else would decide again.
    if (exitCode === 0) {
      root.writeRetries = 0
    } else if (exitCode !== 75 && !queued && root.writeRetries < 3) {
      root.writeRetries++
      retryTimer.restart()
    }
    if (queued) setLevel(level)
  }

  // Re-reads the lid, then decides. The lid bindings call this on open and
  // close, and the light measured under a closed lid is stale once it opens,
  // so monitor-sensor is restarted for a fresh first reading.
  function checkLid() {
    if (lidProcess.running) {
      root.lidRecheck = true
      return
    }
    lidProcess.running = true
  }

  function applyLid(closed) {
    var opened = root.lidClosed && !closed
    if (root.state && closed && !root.lidClosed) root.state = KeyboardBacklightModel.interrupt(root.state, Date.now())
    if (root.state && opened && !root.paused) root.state = KeyboardBacklightModel.uninterrupt(root.state, Date.now())
    root.lidClosed = closed
    if (root.lidRecheck) {
      root.lidRecheck = false
      checkLid()
      return
    }
    if (opened) rereadLight()
    else step()
  }

  function rereadLight() {
    root.lux = null
    if (!monitorProcess.running) return
    root.monitorRestart = true
    monitorProcess.running = false
  }

  // A key press only shows up at the next sensor change or check, so take
  // one last look before the blank: at this point the level is still the
  // user's, and after the wake it's the session's.
  function pause() {
    if (root.active && root.state && !root.paused) {
      observe(Date.now())
      root.state = KeyboardBacklightModel.interrupt(root.state, Date.now())
      save()
    }
    root.paused = true
    checkTimer.stop()
  }

  function resume() {
    root.paused = false
    if (!root.active || !root.state) return
    var state = root.lidClosed ? root.state : KeyboardBacklightModel.uninterrupt(root.state, Date.now())
    root.state = KeyboardBacklightModel.resume(state, readBrightness())
    step()
  }

  onActiveChanged: {
    if (active) {
      start()
    } else {
      checkTimer.stop()
      restartTimer.stop()
      root.state = null
      // What the keys do while it's off isn't a change to pick up later.
      lastLevelFile.setText("")
      root.savedLevel = ""
    }
    syncMonitor()
  }

  // The toggle is a flag file; `omarchy-toggle-keyboard-backlight-auto` nudges
  // this after flipping it.
  Process {
    id: probeProcess
    command: ["bash", "-c",
      "omarchy-hw-ambient-light && omarchy-cmd-present monitor-sensor && echo sensor; " +
      "for led in \"${OMARCHY_LEDS_PATH:-/sys/class/leds}\"/*kbd_backlight*; do [[ -e $led ]] && { echo \"device ${led##*/} $(< \"$led/max_brightness\")\"; break; }; done; " +
      "omarchy-hw-laptop-closed && echo lid-closed; " +
      "[[ -f $HOME/.local/state/omarchy/toggles/keyboard-backlight-auto-off ]] && echo disabled; true"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyProbe(text)
    }
  }

  // The backlight keys change this behind our back; the model treats any
  // level it didn't set as the user's choice. blockAllReads makes reload()
  // return the current value rather than the one from the previous load.
  FileView {
    id: brightnessFile
    path: root.device !== "" ? root.ledsPath + "/" + root.device + "/brightness" : ""
    blockAllReads: true
    printErrors: false
  }

  FileView {
    id: lastLevelFile
    path: root.lastLevelPath
    blockAllReads: true
    printErrors: false
  }

  FileView {
    id: blankFile
    path: root.blankPath
    blockAllReads: true
    printErrors: false
  }

  // Covers both ACPI lids and those only logind reads (Apple Silicon's SMC).
  Process {
    id: lidProcess
    command: ["omarchy-hw-laptop-closed"]
    onExited: function(exitCode) { root.applyLid(exitCode === 0) }
  }

  // A manual off is held across restarts, so it lives on disk as the time it
  // was made (empty when there is none).
  FileView {
    id: manualOffFile
    path: root.manualOffPath
    blockAllReads: true
    printErrors: false
  }

  // iio-sensor-proxy only reports changes, so this stays quiet in steady
  // light. Holding the claim open is what keeps the sensor reporting. The
  // pdeathsig makes the kernel end it whenever the shell exits, however it
  // exits; an orphan would keep the sensor claimed and never write again.
  // Readings are printed with %lf, so pin the C locale for a "." separator.
  // `running` is set only through syncMonitor(), never bound, so a restart
  // can't detach it from the toggle.
  Process {
    id: monitorProcess
    command: ["setpriv", "--pdeathsig", "TERM", "stdbuf", "-oL", "monitor-sensor", "--light"]
    environment: ({ LC_ALL: "C" })
    stdout: SplitParser {
      onRead: function(line) {
        var value = KeyboardBacklightModel.parseLux(line)
        if (value === null) return
        root.lux = value
        root.step()
      }
    }
    onExited: {
      if (root.monitorRestart) {
        root.monitorRestart = false
        root.syncMonitor()
      } else if (root.active) {
        restartTimer.restart()
      }
    }
  }

  Timer {
    id: restartTimer
    interval: 5000
    onTriggered: root.syncMonitor()
  }

  Timer {
    id: retryTimer
    interval: root.tuning.settleMs
    onTriggered: root.step()
  }

  // Acts on a settled reading or an expired manual off when the sensor has
  // nothing new to say.
  Timer {
    id: checkTimer
    onTriggered: root.step()
  }

  Process {
    id: setProcess
    onExited: function(exitCode) { root.finishWrite(exitCode) }
  }

  ShellIpc {
    target: "omarchy.keyboard-backlight"

    function sync(): void {
      root.probe()
    }

    // `omarchy-brightness-keyboard off` and `restore` bracket session blanking
    // with these, so the blank and the restored level aren't taken as the
    // user's choice and nothing is switched on behind a locked screen.
    function pause(): void {
      root.pause()
    }

    // Nudged by `omarchy-brightness-keyboard` after the keys change the level,
    // so a choice made in steady light is seen (and a manual off saved) right
    // away rather than at the next sensor change.
    function refresh(): void {
      root.step()
    }

    // Nudged by the lid bindings when the lid opens or closes.
    function lid(): void {
      root.checkLid()
    }

    function resume(): void {
      root.resume()
    }
  }

  Component.onCompleted: probe()
}
