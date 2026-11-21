import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Commons
import "BatteryModel.js" as BatteryModel

Item {
  id: root

  property var shell: null
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")

  readonly property int batteryThreshold: 10
  property string pendingPowerSource: ""
  // Follows power-profiles-daemon's change signals, so nothing polls it.
  // Quickshell never attaches that listener if the daemon failed when the
  // shell started, so a one-off read on startup, on a power source change and
  // after omarchy-powerprofiles-set (which asks for it over IPC) recovers.
  property string activePowerProfile: ""
  property bool powerProfileReadPending: false
  property int powerProfileSignals: 0
  property int powerProfileReadSignals: 0
  // UPower's first onBattery / display-device values can still reflect the
  // pre-suspend discharging state for a few seconds after shell start (#7679).
  // Hold low-battery warnings until settleTimer completes; power profiles still
  // apply immediately on charger changes.
  readonly property alias lowBatteryChecksReady: settleTimer.checksReady

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
    state = BatteryModel.gateStartupWarning(state, persisted.notifiedLowBattery, lowBatteryChecksReady)
    persisted.notifiedLowBattery = state.notifiedLowBattery
    if (state.notify) sendLowBatteryWarning(state.level)
  }

  function sendLowBatteryWarning(level) {
    if (warningProcess.running) return
    warningProcess.command = [
      "omarchy-battery-low",
      String(level)
    ]
    warningProcess.running = true
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
    // A read already running may have sampled the profile before the change
    // this refresh is for, so run another once it finishes.
    if (powerProfileReadProcess.running) {
      powerProfileReadPending = true
      return
    }
    powerProfileReadPending = false
    powerProfileReadSignals = powerProfileSignals
    powerProfileReadProcess.running = true
  }

  function profileName(profile) {
    switch (profile) {
      case PowerProfile.PowerSaver: return "power-saver"
      case PowerProfile.Performance: return "performance"
      default: return "balanced"
    }
  }

  Process { id: warningProcess }

  Process {
    id: powerProfileProcess
    onExited: {
      if (root.pendingPowerSource !== "") root.runPendingPowerProfile()
      root.refreshPowerProfile()
    }
  }

  Process {
    id: powerProfileReadProcess
    // Read the property straight from the daemon rather than via
    // `powerprofilesctl get`. That is a PyGObject script, and spawning a Python
    // interpreter for it trips a CPython 3.14 shutdown race
    // (python/cpython#124619): the GLib D-Bus worker thread re-enters the
    // interpreter after finalization and the process dies with SIGSEGV.
    command: ["busctl", "--json=short", "get-property", "net.hadess.PowerProfiles", "/net/hadess/PowerProfiles", "net.hadess.PowerProfiles", "ActiveProfile"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.activePowerProfile = BatteryModel.profileAfterRead(root.activePowerProfile, text, root.powerProfileReadSignals, root.powerProfileSignals)
    }
    onExited: {
      // Deferred: the process still reports running while it signals exit.
      if (root.powerProfileReadPending) Qt.callLater(root.refreshPowerProfile)
    }
  }

  Connections {
    target: PowerProfiles
    function onProfileChanged() {
      root.powerProfileSignals++
      root.activePowerProfile = root.profileName(PowerProfiles.profile)
    }
  }

  ShellIpc {
    target: "battery"

    function refreshPowerProfile(): void { root.refreshPowerProfile() }
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    // Wait for UPower's AC state to settle before the first check. An immediate
    // run on shell start can still see the pre-death discharging state after a
    // battery-empty suspend, and fire "Time to recharge!" while already on AC (#7679).
    triggeredOnStart: false
    onTriggered: root.checkBattery()
  }

  // Give UPower a full settle window after Quickshell has loaded the display
  // device. Opening the gate does not itself evaluate a possibly stale sample;
  // charger changes and the existing 30-second timer perform later checks.
  BatteryStartupGate {
    id: settleTimer
    deviceReady: UPower.displayDevice.ready
  }

  Connections {
    target: UPower
    function onOnBatteryChanged() {
      // Always switch profiles immediately; low-battery warnings wait for settle.
      root.applyPowerProfile()
      root.refreshPowerProfile()
      root.checkBattery()
    }
  }

  Component.onCompleted: root.refreshPowerProfile()
}
