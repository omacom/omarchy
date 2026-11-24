import QtQuick
import "Model.js" as Model

QtObject {
  id: root

  required property var device
  required property bool onBattery
  required property var states
  // Some batteries take more than one poll to report their first charge rate.
  property int settleInterval: 90000

  property real heldCharge: -1
  property real settlingCharge: -1
  property bool settlingRenewed: false
  property bool awaitingChargingState: false
  property bool updatedChargingTelemetry: false
  readonly property bool batteryPresent: !!(device && device.isPresent)
  readonly property bool charging: batteryPresent && device.state === states.Charging
  readonly property real fraction: Model.batteryFraction(device)
  readonly property bool atHeldCharge: heldCharge >= 0 && Math.abs(fraction - heldCharge) < 0.01
  readonly property bool rateFresh: !settle.running
  readonly property bool holding: Model.chargeThresholdActive(device, onBattery, states, rateFresh, atHeldCharge)

  function rememberHold() {
    if (holding && !atHeldCharge) heldCharge = fraction
  }

  function clearHoldOnCharging() {
    if (!updatedChargingTelemetry || !charging || Model.chargeThresholdActive(device, onBattery, states, true)) return
    heldCharge = -1
    settlingCharge = -1
  }

  function startSettling(waitForState = false) {
    settlingCharge = fraction
    settlingRenewed = false
    awaitingChargingState = waitForState
    settle.restart()
  }

  function chargingStarted() {
    if (atHeldCharge) {
      awaitingChargingState = false
      settle.stop()
    } else if (awaitingChargingState || settlingCharge < 0 || Math.abs(fraction - settlingCharge) >= 0.01) {
      startSettling()
    } else if (settle.running && !settlingRenewed) {
      // With no new source or charging measurement, allow one renewal at this
      // level. A weak adapter can alternate between charging and discharging.
      settlingRenewed = true
      settle.restart()
    }
  }

  function resetChargeEvidence() {
    heldCharge = -1
    settlingCharge = -1
    awaitingChargingState = false
    updatedChargingTelemetry = false
    settle.stop()
  }

  onHoldingChanged: if (holding) Qt.callLater(root.rememberHold)

  onFractionChanged: {
    if (heldCharge < 0 || Math.abs(fraction - heldCharge) < 0.01) return
    heldCharge = -1
    // The level can arrive after state. The stale rate needs to settle either way.
    if (!onBattery && charging) startSettling()
    if (holding) Qt.callLater(root.rememberHold)
  }

  onOnBatteryChanged: {
    resetChargeEvidence()
    if (!onBattery && batteryPresent) startSettling(!charging)
  }

  onDeviceChanged: resetChargeEvidence()
  onBatteryPresentChanged: if (!batteryPresent) resetChargeEvidence()

  property Timer settle: Timer { interval: root.settleInterval }

  property Connections deviceSignals: Connections {
    target: root.device

    function onStateChanged() {
      root.updatedChargingTelemetry = false
      // Charging can begin without an onBattery change if a USB-C port stays online.
      if (!root.onBattery && target.isPresent && target.state === root.states.Charging)
        root.chargingStarted()
    }

    function onChangeRateChanged() {
      // A direction change can leave a cached discharge rate visible for another poll.
      if (target.state === root.states.Charging) {
        root.updatedChargingTelemetry = true
        Qt.callLater(root.clearHoldOnCharging)
      }
    }

    function onTimeToFullChanged() {
      if (target.state !== root.states.Charging) return
      // UPower can publish the rate before the state in the same message.
      // A new positive estimate corroborates it after the direction changes.
      if (target.timeToFull > 0) root.updatedChargingTelemetry = true
      if (root.updatedChargingTelemetry) Qt.callLater(root.clearHoldOnCharging)
    }
  }
}
