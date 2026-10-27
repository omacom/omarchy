import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import "mocks" as Mock
import "power" as Power

ShellRoot {
  id: test
  property bool failed: false
  property int batteryIconChanges: 0
  property int chargeHoldMarkChanges: 0

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  Item {
    Power.Panel {
      id: power
      bar: QtObject {
        property color foreground: Commons.Color.foreground
        property color barForeground: Commons.Color.foreground
        property color urgent: Commons.Color.urgent
        property string fontFamily: Style.font.family
        property string position: "top"
        property int barSize: 24
        property bool vertical: false
        property bool foregroundAnimationEnabled: false
        property var activePopout: null
        function requestPopout(owner) { activePopout = owner }
        function releasePopout(owner) { activePopout = null }
        function registerClickTarget(target) {}
        function unregisterClickTarget(target) {}
        function hideTooltip(target) {}
        function showTooltip(target, text) {}
      }
    }
  }

  Connections {
    target: power
    function onTestBatteryIconChanged() { test.batteryIconChanges++ }
    function onTestBatteryIconComponentChanged() { test.chargeHoldMarkChanges++ }
  }

  Timer {
    interval: 100
    running: true
    onTriggered: {
      var batteryIcon = power.testBatteryIcon
      Mock.UPower.onBattery = false
      Qt.callLater(function() {
        test.check(power.testBatteryIcon === batteryIcon, "charge hold keeps its noncharging battery glyph")
        test.check(power.testBatteryIconComponent !== null, "AC presence adds a plug mark during charge hold")
        Mock.UPower.onBattery = true
        Qt.callLater(function() {
          test.check(power.testBatteryIcon === batteryIcon, "unplug keeps the charge-hold battery glyph")
          test.check(power.testBatteryIconComponent === null, "unplug removes the charge-hold plug mark")
          test.check(test.chargeHoldMarkChanges >= 2, "icon binding emits change signals for both power events")
          Mock.UPower.displayDevice.state = Mock.UPowerDeviceState.FullyCharged
          Mock.UPower.displayDevice.percentage = 1
          Qt.callLater(function() {
            var fullBatteryIcon = power.testBatteryIcon
            var changesBeforePlug = test.batteryIconChanges
            Mock.UPower.onBattery = false
            Qt.callLater(function() {
              test.check(power.testBatteryIcon === "󰂅", "AC updates a stale full battery state to the connected glyph")
              test.check(test.batteryIconChanges === changesBeforePlug + 1, "AC emits a battery glyph change with state and percentage fixed")
              Mock.UPower.onBattery = true
              Qt.callLater(function() {
                test.check(power.testBatteryIcon === fullBatteryIcon && fullBatteryIcon === "󰁹", "unplug updates the stale full battery state to the battery glyph")
                test.check(test.batteryIconChanges === changesBeforePlug + 2, "unplug emits a battery glyph change with state and percentage fixed")
                if (!test.failed) console.log("RESULT pass")
                done.start()
              })
            })
          })
        })
      })
    }
  }

  Timer { id: done; interval: 100; onTriggered: Qt.quit() }
}
