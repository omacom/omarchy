import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import "BrightnessModel.js" as BrightnessModel

// The display brightness keys, arriving as global shortcuts. On the internal
// panel they step the backlight here: one brightnessctl write and the OSD in
// process, instead of omarchy-brightness-display resolving the monitor and
// device, reading, writing and reading back, then an IPC client for the OSD.
// They step, clamp and read back the way that script does, so either path
// lands on the same level and OSD. External and Apple displays go through the
// script, which drives them over DDC or their own helper.
Item {
  id: root

  // The shell host, for summoning the OSD.
  property var host: null
  // The backlight omarchy-hw-display picks. Devices do not come and go at
  // runtime, but each press refreshes it for the next.
  property string device: ""
  readonly property string devicePath: device ? "/sys/class/backlight/" + device : ""

  // Returns false when the focused display is not one to handle here, so the
  // caller falls back to the script.
  function handle(action) {
    var monitor = Hyprland.focusedMonitor
    var name = monitor ? String(monitor.name || "") : ""
    if (!/^(eDP|LVDS|DSI)-/.test(name) || !device) return false
    if (action !== "raise" && action !== "lower") return false

    // The script drops a press that overlaps one still being applied, so key
    // repeat cannot race the writes.
    if (setProc.running) return true

    var max = readNumber(maxFile)
    if (!(max > 0)) return false
    var current = Math.round(100 * readNumber(brightnessFile) / max)

    setProc.command = ["brightnessctl", "-q", "-d", device, "set", BrightnessModel.brightnessKeyTarget(action, current) + "%"]
    setProc.running = true
    return true
  }

  // reload() reads in the background, so wait for it: text() would otherwise
  // still hold the previous reading, and a level changed elsewhere (the
  // monitor panel, a script) would step from the wrong place.
  function readNumber(file) {
    file.reload()
    file.waitForJob()
    return Number(String(file.text() || "").trim())
  }

  // The payload omarchy-osd builds, from the level read back after the write.
  function showOsd() {
    var max = readNumber(maxFile)
    if (!host || !(max > 0)) return
    var percent = Math.round(100 * readNumber(brightnessFile) / max)
    host.summon("omarchy.osd", JSON.stringify({
      icon: "brightness",
      message: "",
      value: String(percent),
      progressText: percent + "%",
      max: "100",
      duration: ""
    }))
  }

  FileView {
    id: brightnessFile
    path: root.devicePath ? root.devicePath + "/brightness" : ""
    blockLoading: true
    printErrors: false
  }

  FileView {
    id: maxFile
    path: root.devicePath ? root.devicePath + "/max_brightness" : ""
    blockLoading: true
    printErrors: false
  }

  Process {
    id: setProc
    onExited: {
      root.showOsd()
      if (!deviceProc.running) deviceProc.running = true
    }
  }

  Process {
    id: deviceProc
    command: ["omarchy-hw-display"]
    running: true
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.device = String(text || "").trim()
    }
  }
}
