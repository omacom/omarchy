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
  // runtime, so maxBrightness is cached per device and omarchy-hw-display is
  // only re-probed if reading the sysfs files fails.
  property string device: ""
  property int maxBrightness: 0
  readonly property string devicePath: device ? "/sys/class/backlight/" + device : ""

  onDeviceChanged: maxBrightness = 0

  function ensureMax() {
    if (root.maxBrightness > 0) return root.maxBrightness
    var max = readNumber(maxFile)
    if (max > 0) root.maxBrightness = max
    return root.maxBrightness
  }

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

    var max = ensureMax()
    if (!(max > 0)) {
      if (!deviceProc.running) deviceProc.running = true
      return false
    }
    var level = readNumber(brightnessFile)
    if (!(level >= 0)) {
      root.maxBrightness = 0
      if (!deviceProc.running) deviceProc.running = true
      return false
    }
    var current = Math.round(100 * level / max)

    setProc.command = ["brightnessctl", "-q", "-d", device, "set", BrightnessModel.brightnessKeyTarget(action, current) + "%"]
    setProc.running = true
    return true
  }

  // reload() reads in the background, so wait for it: text() would otherwise
  // still hold the previous reading, and a level changed elsewhere (the
  // monitor panel, a script) would step from the wrong place.
  function readNumber(file) {
    file.failed = false
    file.reload()
    file.waitForJob()
    if (file.failed) return NaN
    var raw = String(file.text() || "").trim()
    if (!raw) return NaN
    return Number(raw)
  }

  // The payload omarchy-osd builds, from the level read back after the write.
  function showOsd() {
    var max = ensureMax()
    if (!host || !(max > 0)) return
    var level = readNumber(brightnessFile)
    if (!(level >= 0)) return
    var percent = Math.round(100 * level / max)
    host.summon("omarchy.osd", JSON.stringify({
      icon: "brightness",
      message: "",
      value: String(percent),
      progressText: I18n.formatNumber(percent) + "%",
      max: "100",
      duration: ""
    }))
  }

  FileView {
    id: brightnessFile
    property bool failed: false
    path: root.devicePath ? root.devicePath + "/brightness" : ""
    blockLoading: true
    printErrors: false
    onLoadFailed: failed = true
  }

  FileView {
    id: maxFile
    property bool failed: false
    path: root.devicePath ? root.devicePath + "/max_brightness" : ""
    blockLoading: true
    printErrors: false
    onLoadFailed: failed = true
  }

  Process {
    id: setProc
    onExited: root.showOsd()
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
