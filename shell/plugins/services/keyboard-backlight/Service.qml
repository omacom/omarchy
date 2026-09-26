import QtQuick
import Quickshell
import Quickshell.Io
import "KeyboardBacklightModel.js" as KeyboardBacklightModel

Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string ledsPath: Quickshell.env("OMARCHY_LEDS_PATH") || "/sys/class/leds"
  readonly property string manualOffPath: home + "/.local/state/omarchy/keyboard-backlight-manual-off"
  readonly property var tuning: KeyboardBacklightModel.config(shell && shell.shellConfig ? shell.shellConfig.keyboardBacklight : null)

  property bool probed: false
  property bool hasSensor: false
  property bool disabled: false
  property string device: ""
  property int maxLevel: 0
  readonly property bool active: probed && hasSensor && device !== "" && maxLevel > 0 && !disabled

  // Set while the session has the keyboard blanked (lock or idle), between
  // `omarchy brightness keyboard off` and its `restore`.
  property bool paused: false

  property var state: null
  property var lux: null
  property int pendingLevel: -1

  function probe() {
    if (!probeProcess.running) probeProcess.running = true
  }

  function applyProbe(text) {
    var sensor = false
    var off = false
    var name = ""
    var max = 0
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var parts = lines[i].trim().split(/\s+/)
      if (parts[0] === "sensor") sensor = true
      else if (parts[0] === "disabled") off = true
      else if (parts[0] === "device" && parts.length === 3) {
        name = parts[1]
        max = parseInt(parts[2], 10) || 0
      }
    }

    root.hasSensor = sensor
    root.disabled = off
    root.device = name
    root.maxLevel = max
    root.probed = true
  }

  function readBrightness() {
    brightnessFile.reload()
    var level = parseInt(String(brightnessFile.text()).trim(), 10)
    return isNaN(level) ? null : level
  }

  function readManualOff() {
    manualOffFile.reload()
    return Number(String(manualOffFile.text()).trim()) || 0
  }

  function syncMonitor() {
    var wanted = root.active && root.state !== null
    if (monitorProcess.running !== wanted) monitorProcess.running = wanted
  }

  function start() {
    root.lux = null
    root.state = KeyboardBacklightModel.initialState(readBrightness(), root.maxLevel, readManualOff())
  }

  function step() {
    if (!root.active || !root.state || root.paused) return

    var now = Date.now()
    var manualOffBefore = root.state.manualOffSince

    // A reading taken while our own write is in flight isn't a user change.
    var writing = setProcess.running || root.pendingLevel >= 0
    var observed = writing ? root.state : KeyboardBacklightModel.observeBrightness(root.state, readBrightness(), now)

    var result = KeyboardBacklightModel.evaluate(observed, root.lux, now, root.tuning)
    root.state = result.state

    if (result.set !== null) setLevel(result.set)
    if (root.state.manualOffSince !== manualOffBefore) manualOffFile.setText(root.state.manualOffSince > 0 ? String(root.state.manualOffSince) : "")

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

    setProcess.command = ["brightnessctl", "-d", root.device, "set", String(level)]
    setProcess.running = true
  }

  function pause() {
    root.paused = true
    checkTimer.stop()
  }

  function resume() {
    root.paused = false
    if (!root.active || !root.state) return
    root.state = KeyboardBacklightModel.resume(root.state, readBrightness())
    step()
  }

  onActiveChanged: {
    if (active) {
      start()
    } else {
      checkTimer.stop()
      restartTimer.stop()
      root.state = null
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
    onExited: if (root.active) restartTimer.restart()
  }

  Timer {
    id: restartTimer
    interval: 5000
    onTriggered: root.syncMonitor()
  }

  // Acts on a settled reading or an expired manual off when the sensor has
  // nothing new to say.
  Timer {
    id: checkTimer
    onTriggered: root.step()
  }

  Process {
    id: setProcess
    onExited: {
      if (root.pendingLevel < 0) return
      var level = root.pendingLevel
      root.pendingLevel = -1
      root.setLevel(level)
    }
  }

  IpcHandler {
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

    function resume(): void {
      root.resume()
    }
  }

  Component.onCompleted: probe()
}
