import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons

// The shortcut supplies the focused panel and cached device. The display helper
// serializes keys with blank and wake, and returns the level to show on the OSD.
Item {
  id: root

  // The shell host, for summoning the OSD.
  property var host: null
  // The backlight omarchy-hw-display picks. Devices do not come and go at
  // runtime, but each press refreshes it for the next.
  property string device: ""

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

    setProc.command = ["omarchy-brightness-display", "--backlight-key", device, action === "raise" ? "+5%" : "5%-"]
    setProc.running = true
    return true
  }

  function showOsd(percent) {
    if (!host) return
    host.summon("omarchy.osd", JSON.stringify({
      icon: "brightness",
      message: "",
      value: String(percent),
      progressText: I18n.formatNumber(percent) + "%",
      max: "100",
      duration: ""
    }))
  }

  Process {
    id: setProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var level = text.trim()
        if (/^[0-9]+$/.test(level)) root.showOsd(Number(level))
      }
    }
    onExited: if (!deviceProc.running) deviceProc.running = true
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
