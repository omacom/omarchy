import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "RefreshRateModel.js" as RefreshRateModel

Item {
  id: root

  property var shell: null

  // Off unless asked for. Changing what someone's panel does on battery is not
  // a thing to start doing to them on upgrade.
  readonly property var config: shell && shell.shellConfig && shell.shellConfig.refreshRate
    ? shell.shellConfig.refreshRate
    : ({})
  readonly property bool active: config.enabled === true
  readonly property int threshold: typeof config.threshold === "number" ? config.threshold : 50

  property var pending: []

  readonly property int batteryPercent: {
    var device = UPower.displayDevice
    if (!device || !device.isPresent) return -1
    return Math.round(Number(device.percentage || 0) * 100)
  }
  // Charge crossing the threshold has no UPower event of its own; this flips
  // only on the crossing, so the service reacts without a polling clock.
  readonly property bool charged: batteryPercent < 0 || batteryPercent >= threshold

  function refresh() {
    if (!active || monitorsProc.running || applyProc.running) return
    monitorsProc.running = true
  }

  function applyNext() {
    if (root.pending.length === 0) return
    var spec = root.pending[0]
    root.pending = root.pending.slice(1)
    applyProc.command = ["hyprctl", "eval", spec]
    applyProc.running = true
  }

  Process {
    id: monitorsProc
    command: ["hyprctl", "monitors", "all", "-j"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var monitors = []
        try {
          monitors = JSON.parse(String(text || "[]"))
        } catch (e) {
          return
        }
        root.pending = RefreshRateModel.pendingSpecs(
          monitors, UPower.onBattery, root.batteryPercent, root.threshold)
        root.applyNext()
      }
    }
  }

  // A rate Hyprland refuses is worth a line. Nothing here is visible to the
  // user until the panel fails to change rate, and a service that reports
  // success over a refused eval leaves nothing to look at.
  Process {
    id: applyProc
    stdout: StdioCollector {
      id: applyStdout
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (exitCode !== 0)
        console.warn("refresh-rate", "eval exited", exitCode, String(applyStdout.text || "").trim())
    }
    onRunningChanged: if (!running) root.applyNext()
  }

  // Only power changes apply a rate, so a rate picked in the display panel
  // holds until the next one.
  onActiveChanged: refresh()
  onChargedChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: UPower
    function onOnBatteryChanged() { root.refresh() }
  }
}
