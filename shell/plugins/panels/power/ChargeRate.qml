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
  readonly property bool batteryPresent: !!(device && device.isPresent)
  readonly property bool charging: batteryPresent && device.state === states.Charging
  readonly property real fraction: Model.batteryFraction(device)
  readonly property bool atHeldCharge: heldCharge >= 0 && Math.abs(fraction - heldCharge) < 0.01
  readonly property bool rateFresh: !settle.running
  readonly property bool holding: Model.chargeThresholdActive(device, onBattery, states, rateFresh, atHeldCharge)

  function rememberHold() {
    if (holding && !atHeldCharge) heldCharge = fraction
  }

  function clearHoldOnNewRate() {
    if (atHeldCharge && charging && !Model.chargeThresholdActive(device, onBattery, states, true))
      heldCharge = -1
  }

  onHoldingChanged: if (holding) Qt.callLater(root.rememberHold)

  onFractionChanged: {
    if (heldCharge < 0 || Math.abs(fraction - heldCharge) < 0.01) return
    heldCharge = -1
    // The level can arrive after state. The stale rate needs to settle either way.
    if (!onBattery && charging) settle.restart()
    if (holding) Qt.callLater(root.rememberHold)
  }

  onOnBatteryChanged: {
    heldCharge = -1
    if (onBattery) settle.stop()
    else settle.restart()
  }

  onDeviceChanged: {
    heldCharge = -1
    settle.stop()
  }

  onBatteryPresentChanged: {
    if (!batteryPresent) {
      heldCharge = -1
      settle.stop()
    }
  }

  property Timer settle: Timer { interval: root.settleInterval }

  property Connections deviceSignals: Connections {
    target: root.device

    function onStateChanged() {
      if (root.onBattery || !root.charging) return
      // Charging can begin without an onBattery change if a USB-C port stays online.
      if (root.atHeldCharge) settle.stop()
      else settle.restart()
    }

    function onChangeRateChanged() {
      // A direction change can leave a cached discharge rate visible for another poll.
      Qt.callLater(root.clearHoldOnNewRate)
    }
  }
}
