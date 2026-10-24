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
  // UPower can latch energy-full on a garbage Smart Battery reading (MacBooks)
  // and then report a tenth of the real charge until it restarts. The status
  // script reads the kernel's registers past that; its percentage stands in
  // for the display device's here and in the power panel, and is -1 while
  // UPower's figure is sound. The script runs once at startup, again when
  // UPower's full charge moves by more than a factor of two (a latch appearing
  // or clearing; BatteryModel.shouldRereadKernel has the rule), and while a
  // latch holds, as UPower's own percentage moves. A sound machine runs it
  // once; shell-idle-spawn-test.sh holds it to that.
  property int kernelPercentage: -1
  property real kernelReadCapacity: -1
  property real kernelReadPercentage: 0
  // Follows power-profiles-daemon's change signals, so nothing polls it.
  // Quickshell never attaches that listener if the daemon failed when the
  // shell started, so a one-off read on startup, on a power source change and
  // after omarchy-powerprofiles-set (which asks for it over IPC) recovers.
  property string activePowerProfile: ""
  property bool powerProfileReadPending: false
  property int powerProfileSignals: 0
  property int powerProfileReadSignals: 0
  readonly property bool powerSaverOnBattery: BatteryModel.isPowerSaverOnBattery(UPower.onBattery, activePowerProfile)

  PersistentProperties {
    id: persisted
    reloadableId: "omarchy-battery"
    property bool notifiedLowBattery: false
  }

  function batteryPercentage() {
    return BatteryModel.batteryPercentage(UPower.displayDevice, kernelPercentage)
  }

  function isDischarging() {
    return BatteryModel.isDischarging(UPower.displayDevice, UPower.onBattery, UPowerDeviceState.Discharging)
  }

  function checkBattery() {
    var state = BatteryModel.shouldWarnLowBattery(UPower.displayDevice, UPower.onBattery, UPowerDeviceState.Discharging, batteryThreshold, persisted.notifiedLowBattery, kernelPercentage)
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

  function refreshKernelPercentage() {
    var device = UPower.displayDevice
    if (!BatteryModel.shouldRereadKernel(kernelReadCapacity, device.energyCapacity, kernelReadPercentage, device.percentage, kernelPercentage >= 0)) return
    if (statusProc.running) return
    kernelReadCapacity = device.energyCapacity
    kernelReadPercentage = device.percentage
    statusProc.running = true
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
    id: statusProc
    command: ["omarchy-battery-status", "--shell"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var reading = BatteryModel.kernelReading(text, root.kernelPercentage)
        root.kernelPercentage = reading.level
        if (reading.retry) root.kernelReadCapacity = -1
        root.checkBattery()
      }
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
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.checkBattery()
  }

  Connections {
    target: UPower.displayDevice
    function onEnergyCapacityChanged() { root.refreshKernelPercentage() }
    function onPercentageChanged() { root.refreshKernelPercentage() }
  }

  Connections {
    target: UPower
    function onOnBatteryChanged() {
      root.checkBattery()
      root.applyPowerProfile()
      root.refreshPowerProfile()
    }
  }

  Component.onCompleted: {
    root.refreshKernelPercentage()
    root.refreshPowerProfile()
  }
}
