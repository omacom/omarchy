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
  property int chargeLimitSignals: 0
  property bool lastOnBattery: UPower.onBattery

  readonly property string topUpOncePath: {
    var stateHome = Quickshell.env("XDG_STATE_HOME")
    if (!stateHome) stateHome = Quickshell.env("HOME") + "/.local/state"
    return stateHome + "/omarchy/battery/top-up-once"
  }
  readonly property bool topUpOnce: topUpOnceFile.text.trim().length > 0
  onTopUpOnceChanged: if (topUpOnce) checkTopUpOnceRearm()

  PersistentProperties {
    id: persisted
    reloadableId: "omarchy-battery"
    property bool notifiedLowBattery: false
  }

  WatchedFile {
    id: topUpOnceFile
    path: root.topUpOncePath
  }

  function batteryPercentage() {
    return BatteryModel.batteryPercentage(UPower.displayDevice)
  }

  function isDischarging() {
    return BatteryModel.isDischarging(UPower.displayDevice, UPowerDeviceState.Discharging)
  }

  function checkBattery() {
    var state = BatteryModel.shouldWarnLowBattery(UPower.displayDevice, UPowerDeviceState.Discharging, batteryThreshold, persisted.notifiedLowBattery)
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

  function refreshChargeLimit() {
    topUpOnceFile.reread()
    chargeLimitSignals++
    checkTopUpOnceRearm()
  }

  function rearmChargeLimit() {
    if (chargeLimitProcess.running) return
    chargeLimitProcess.command = ["omarchy-battery-limit", "on"]
    chargeLimitProcess.running = true
  }

  function checkTopUpOnceRearm() {
    if (!topUpOnce) return
    if (BatteryModel.shouldRearmChargeLimit(topUpOnce, UPower.displayDevice, UPower.onBattery, UPower.onBattery, UPowerDeviceState.FullyCharged))
      rearmChargeLimit()
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
    id: chargeLimitProcess
    onExited: root.refreshChargeLimit()
  }

  // Wait briefly on unplug before re-arming a one-time top-up so USB-C PD
  // power-role renegotiation glitches don't cancel a charge early.
  Timer {
    id: topUpRearmDebounce
    interval: 2000
    onTriggered: {
      if (root.topUpOnce && UPower.onBattery) root.rearmChargeLimit()
    }
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
    function refreshChargeLimit(): void { root.refreshChargeLimit() }
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
      var wasOnBattery = root.lastOnBattery
      root.lastOnBattery = UPower.onBattery
      root.checkBattery()
      root.applyPowerProfile()
      root.refreshPowerProfile()
      if (root.topUpOnce) {
        if (!wasOnBattery && UPower.onBattery) topUpRearmDebounce.restart()
        else if (!UPower.onBattery) {
          topUpRearmDebounce.stop()
          root.checkTopUpOnceRearm()
        }
      }
    }
  }

  Connections {
    target: UPower.displayDevice
    function onStateChanged() { root.checkTopUpOnceRearm() }
    function onPercentageChanged() { root.checkTopUpOnceRearm() }
  }

  Component.onCompleted: {
    root.refreshPowerProfile()
    root.checkTopUpOnceRearm()
  }
}
