import QtQuick
import Quickshell
import Quickshell.Io
import "KeyboardBacklightModel.js" as KeyboardBacklightModel

Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string manualOffPath: home + "/.local/state/omarchy/keyboard-backlight-manual-off"
  readonly property var tuning: KeyboardBacklightModel.config(shell && shell.shellConfig ? shell.shellConfig.keyboardBacklight : null)

  property bool probed: false
  property bool hasSensor: false
  property bool disabled: false
  property string device: ""
  property int maxLevel: 0
  readonly property bool active: probed && hasSensor && device !== "" && maxLevel > 0 && !disabled

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

  function start() {
    root.lux = null
    root.state = KeyboardBacklightModel.initialState(readBrightness(), root.maxLevel, readManualOff())
  }

  function step() {
    if (!root.active || !root.state) return

    var now = Date.now()
    var manualOffBefore = root.state.manualOffSince
    var observed = KeyboardBacklightModel.observeBrightness(root.state, readBrightness(), now)
    var result = KeyboardBacklightModel.evaluate(observed, root.lux, now, root.tuning)
    root.state = result.state

    if (result.set !== null) setLevel(result.set)
    if (root.state.manualOffSince !== manualOffBefore) manualOffFile.setText(root.state.manualOffSince > 0 ? String(root.state.manualOffSince) : "")

    if (result.nextCheckMs >= 0) {
      checkTimer.interval = Math.max(1, result.nextCheckMs)
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

  onActiveChanged: {
    if (active) {
      start()
    } else {
      checkTimer.stop()
      root.state = null
    }
  }

  // The toggle is a flag file; `omarchy-toggle-keyboard-backlight-auto` nudges
  // this after flipping it.
  Process {
    id: probeProcess
    command: ["bash", "-c",
      "omarchy-hw-ambient-light && omarchy-cmd-present monitor-sensor && echo sensor; " +
      "for led in /sys/class/leds/*kbd_backlight*; do [[ -e $led ]] && { echo \"device ${led##*/} $(< \"$led/max_brightness\")\"; break; }; done; " +
      "[[ -f $HOME/.local/state/omarchy/toggles/keyboard-backlight-auto-off ]] && echo disabled; true"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyProbe(text)
    }
  }

  // Idle blanking and the backlight keys change this behind our back; the
  // model treats any level it didn't set as the user's choice.
  FileView {
    id: brightnessFile
    path: root.device !== "" ? "/sys/class/leds/" + root.device + "/brightness" : ""
    blockLoading: true
    printErrors: false
  }

  // A manual off is held across restarts, so it lives on disk as the time it
  // was made (empty when there is none).
  FileView {
    id: manualOffFile
    path: root.manualOffPath
    blockLoading: true
    printErrors: false
  }

  // iio-sensor-proxy only reports changes, so this stays quiet in steady
  // light. Holding the claim open is what keeps the sensor reporting. The
  // pdeathsig makes the kernel end it whenever the shell exits, however it
  // exits; an orphan would keep the sensor claimed and never write again.
  Process {
    id: monitorProcess
    running: root.active && root.state !== null
    command: ["setpriv", "--pdeathsig", "TERM", "stdbuf", "-oL", "monitor-sensor", "--light"]
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
    onTriggered: if (root.active && !monitorProcess.running) monitorProcess.running = true
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
  }

  Component.onCompleted: probe()
}
