import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "BatteryModel.js" as BatteryModel

Item {
  id: root

  property var shell: null
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")

  readonly property int batteryThreshold: 10
  readonly property string lowBatterySummary: "Time to recharge!"
  property bool checkedBattery: false
  property bool pendingLowBatteryClear: false
  property string pendingPowerSource: ""
  property string activePowerProfile: ""
  readonly property bool powerSaverOnBattery: UPower.onBattery && activePowerProfile === "power-saver"

  PersistentProperties {
    id: persisted
    reloadableId: "omarchy-battery"
    property bool notifiedLowBattery: false
  }

  function batteryPercentage() {
    return BatteryModel.batteryPercentage(UPower.displayDevice)
  }

  function isDischarging() {
    return BatteryModel.isDischarging(UPower.displayDevice, UPower.onBattery, UPowerDeviceState.Discharging)
  }

  function checkBattery() {
    var state = BatteryModel.shouldWarnLowBattery(UPower.displayDevice, UPower.onBattery, UPowerDeviceState.Discharging, batteryThreshold, persisted.notifiedLowBattery, !checkedBattery)
    checkedBattery = true
    persisted.notifiedLowBattery = state.notifiedLowBattery
    if (state.notify) sendLowBatteryWarning(state.level)
    else if (state.clear) clearLowBatteryWarning()
  }

  function sendLowBatteryWarning(level) {
    if (warningProcess.running) return
    warningProcess.command = [
      "omarchy-battery-low",
      String(level)
    ]
    warningProcess.running = true
  }

  // The low-battery toast is critical urgency, so the shell never expires it on
  // its own. Take it down once the charger is back rather than leaving a stale
  // warning on screen; it stays in notification history either way.
  //
  // Wait for a warning still being posted: dismissing by summary only matches
  // toasts the server already has, and checkBattery has cleared the notified
  // flag by now, so a dismissal that runs too early would never be retried and
  // the toast would linger for good. Defer rather than drop, the way
  // pendingPowerSource does for the power-profile process.
  function clearLowBatteryWarning() {
    pendingLowBatteryClear = true
    if (!warningProcess.running && !dismissProcess.running) runPendingLowBatteryClear()
  }

  function runPendingLowBatteryClear() {
    dismissProcess.command = ["omarchy-notification-dismiss", lowBatterySummary]
    pendingLowBatteryClear = false
    dismissProcess.running = true
  }

  function applyPowerProfile() {
    pendingPowerSource = UPower.onBattery ? "battery" : "ac"
    if (!powerProfileProcess.running) runPendingPowerProfile()
  }

  function runPendingPowerProfile() {
    powerProfileProcess.command = ["omarchy-powerprofiles-set", pendingPowerSource]
    pendingPowerSource = ""
    powerProfileProcess.running = true
  }

  function refreshPowerProfile() {
    if (!powerProfileReadProcess.running) powerProfileReadProcess.running = true
  }

  Process {
    id: warningProcess
    onExited: if (root.pendingLowBatteryClear && !dismissProcess.running) root.runPendingLowBatteryClear()
  }

  Process {
    id: dismissProcess
    onExited: if (root.pendingLowBatteryClear) root.runPendingLowBatteryClear()
  }

  Process {
    id: powerProfileProcess
    onExited: {
      if (root.pendingPowerSource !== "") root.runPendingPowerProfile()
      root.refreshPowerProfile()
    }
  }

  Process {
    id: powerProfileReadProcess
    command: ["powerprofilesctl", "get"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.activePowerProfile = String(text || "").trim()
    }
  }

  Timer {
    // powerprofilesctl has no portable monitor subcommand; keep profile changes
    // visible to consumers such as the wallpaper service without requiring the
    // power panel to be open.
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refreshPowerProfile()
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.checkBattery()
  }

  Connections {
    target: UPower
    function onOnBatteryChanged() {
      root.checkBattery()
      root.applyPowerProfile()
      root.refreshPowerProfile()
    }
  }

  Component.onCompleted: root.refreshPowerProfile()
}
