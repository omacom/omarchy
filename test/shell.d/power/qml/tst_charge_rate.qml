import QtQuick
import QtTest
import "../../../../shell/plugins/panels/power" as Power

TestCase {
  id: test
  name: "ChargeRate"
  readonly property var states: ({ Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4 })
  property var battery
  property var chargeRate

  Component {
    id: batteryFactory
    QtObject {
      property bool isPresent: true
      property int state: test.states.Discharging
      property real percentage: 0.8
      property real changeRate: 0
      property real timeToFull: 0
    }
  }

  Component {
    id: chargeRateFactory
    Power.ChargeRate {
      onBattery: false
      states: test.states
      settleInterval: 300
    }
  }

  function init() {
    battery = createTemporaryObject(batteryFactory, test)
    chargeRate = createTemporaryObject(chargeRateFactory, test, { device: battery })
    verify(battery)
    verify(chargeRate)
  }

  function test_hiddenReconnectGetsItsOwnWindow() {
    chargeRate.settleInterval = 700
    battery.state = states.Charging
    verify(!chargeRate.holding)
    wait(280)
    battery.state = states.Discharging
    wait(30)
    battery.state = states.Charging
    wait(470)
    verify(!chargeRate.holding, "the old deadline must not expose the stale 0 W reading")
    tryCompare(chargeRate, "holding", true)
  }

  function test_firstChargingStateDoesNotSpendHiddenRenewal() {
    chargeRate.settleInterval = 700
    chargeRate.onBattery = true
    chargeRate.onBattery = false
    wait(90)
    battery.state = states.Charging
    wait(290)
    battery.state = states.Discharging
    wait(30)
    battery.state = states.Charging
    wait(470)
    verify(!chargeRate.holding, "the first Charging update belongs to the observed plug")
  }

  function test_explicitHoldSurvivesDirectionChanges_data() {
    return [{ tag: "pending charge", state: states.PendingCharge },
      { tag: "fully charged below 99 percent", state: states.FullyCharged }]
  }

  function test_explicitHoldSurvivesDirectionChanges(data) {
    battery.state = states.Charging
    battery.state = data.state
    tryCompare(chargeRate, "atHeldCharge", true)
    for (let i = 0; i < 2; ++i) {
      battery.state = states.Discharging
      verify(!chargeRate.holding)
      wait(20)
      battery.state = states.Charging
      verify(chargeRate.holding)
    }
  }

  function test_settledHoldIgnoresCachedDischargeRate_data() {
    return [{ tag: "separate notifications", separate: true },
      { tag: "same event-loop turn", separate: false }]
  }

  function test_settledHoldIgnoresCachedDischargeRate(data) {
    battery.state = states.Charging
    tryCompare(chargeRate, "atHeldCharge", true)
    battery.state = states.Discharging
    battery.changeRate = 14
    if (data.separate) wait(20)
    battery.state = states.Charging
    wait(20)
    verify(chargeRate.holding)
    battery.changeRate = 0
    wait(20)
    verify(chargeRate.holding)
    battery.changeRate = 29
    tryCompare(chargeRate, "holding", false)
    verify(!chargeRate.atHeldCharge)
  }

  function test_lateEstimateReleasesHoldAfterNewRate() {
    battery.state = states.PendingCharge
    tryCompare(chargeRate, "atHeldCharge", true)
    battery.timeToFull = 10 * 60 * 60
    battery.state = states.Charging
    battery.changeRate = 24
    wait(20)
    verify(chargeRate.holding)
    battery.timeToFull = 60 * 60
    tryCompare(chargeRate, "holding", false)
  }

  function test_estimateCorroboratesRatePublishedBeforeChargingState() {
    battery.state = states.PendingCharge
    tryCompare(chargeRate, "atHeldCharge", true)
    // Quickshell applies EnergyRate, State, then TimeToFull from this update.
    battery.changeRate = 24
    battery.state = states.Charging
    battery.timeToFull = 60 * 60
    tryCompare(chargeRate, "holding", false)
    verify(!chargeRate.atHeldCharge)
  }

  function test_repeatedDirectionChangesCannotSettleForever() {
    for (let i = 0; i < 5; ++i) {
      battery.state = states.Charging
      wait(80)
      battery.state = states.Discharging
      wait(55)
    }
    battery.state = states.Charging
    verify(chargeRate.holding)
  }

  function test_percentageArrivingAfterStateInvalidatesHold() {
    battery.state = states.PendingCharge
    tryCompare(chargeRate, "atHeldCharge", true)
    battery.state = states.Discharging
    wait(20)
    battery.state = states.Charging
    verify(chargeRate.holding)
    battery.percentage = 0.78
    wait(20)
    verify(!chargeRate.holding)
    verify(!chargeRate.rateFresh)
  }
}
