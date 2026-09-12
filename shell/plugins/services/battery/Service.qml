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
  property string pendingPowerSource: ""
  property string activePowerProfile: ""
  readonly property bool powerSaverOnBattery: UPower.onBattery && activePowerProfile === "power-saver"
  property bool lowBatteryClearPending: false

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
    var state = BatteryModel.shouldWarnLowBattery(UPower.displayDevice, UPower.onBattery, UPowerDeviceState.Discharging, batteryThreshold, persisted.notifiedLowBattery)
    var wasNotified = persisted.notifiedLowBattery
    persisted.notifiedLowBattery = state.notifiedLowBattery
    if (state.notifiedLowBattery) root.lowBatteryClearPending = false
    else if (wasNotified) root.lowBatteryClearPending = true
    if (state.notify) {
      // Let an in-flight dismissal finish before posting a new warning.
      // Leave the latch unset so its exit handler can recheck current power.
      if (clearWarningProcess.running) persisted.notifiedLowBattery = false
      else sendLowBatteryWarning(state.level)
    }
    // Dismissal can precede notification insertion or time out silently. Keep
    // retrying on the existing poll until a new low-battery episode starts.
    if (root.lowBatteryClearPending) clearLowBatteryWarning()
  }

  function sendLowBatteryWarning(level) {
    if (warningProcess.running) return
    warningProcess.command = [
      "omarchy-battery-low",
      String(level)
    ]
    warningProcess.running = true
  }

  function clearLowBatteryWarning() {
    if (clearWarningProcess.running) return
    clearWarningProcess.command = [
      "omarchy-notification-dismiss",
      "Time to recharge!"
    ]
    clearWarningProcess.running = true
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

  Process { id: warningProcess }
  Process {
    id: clearWarningProcess
    onExited: if (!root.lowBatteryClearPending) root.checkBattery()
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
