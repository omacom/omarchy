import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Commons
import "BrightnessModel.js" as BrightnessModel

// The display brightness keys, arriving as global shortcuts. On the internal
// panel the shell chooses the target and keeps the OSD in process. External
// and Apple displays go through the script, which drives them over DDC or
// their own helper.
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

    setProc.command = ["omarchy-brightness-memory", "set", action === "raise" ? "+5%" : "5%-"]
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
      progressText: I18n.formatNumber(percent) + "%",
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

  property bool syncPending: false

  function requestSync() {
    if (syncProc.running) {
      syncPending = true
      return
    }
    syncPending = false
    syncProc.running = true
  }

  Process {
    id: syncProc
    command: ["omarchy-brightness-memory", "sync"]
    onExited: {
      if (root.syncPending) Qt.callLater(root.requestSync)
    }
  }

  Connections {
    target: UPower
    function onOnBatteryChanged() { root.requestSync() }
  }

  Component.onCompleted: root.requestSync()

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
