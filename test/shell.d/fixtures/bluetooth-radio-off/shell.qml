import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons
import "mocks"
import "bluetooth" as Bt

ShellRoot {
  id: test
  property bool failed: false
  property int hides: 0
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  Loader {
    id: loader
    sourceComponent: Bt.Panel {
      onVisibleChanged: if (!visible) test.hides++
      bar: QtObject {
        property color foreground: Commons.Color.foreground
        property color barForeground: Commons.Color.foreground
        property color urgent: Commons.Color.urgent
        property string fontFamily: Commons.Style.font.family
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
  readonly property var panel: loader.item

  // omarchy-bluetooth-power run the way a terminal or a keybinding would,
  // outside the panel, so toggleBluetooth() never sees it.
  Process {
    id: cli
    property var then: null
    onExited: then()
  }
  function runCli(direction, then) {
    cli.command = ["omarchy-bluetooth-power", direction]
    cli.then = then
    cli.running = true
  }

  Timer { id: wait; property var then: null; interval: 500; onTriggered: then() }
  function after(then) { wait.then = then; wait.start() }

  Timer {
    interval: 250
    running: true
    onTriggered: {
      test.check(panel.visible && panel.radioEnabled && panel.icon === "󰂯", "powered adapter shows the on widget")
      test.runCli("off", test.adapterLeaves)
    }
  }

  // The block landed and the controller lost power, so BlueZ drops the adapter.
  function adapterLeaves() {
    BluetoothMock.defaultAdapter = null
    check(panel.visible, "widget stays on the bar before rfkill has answered")
    after(blockedChecks)
  }

  function blockedChecks() {
    check(hides === 0, "turning off outside the panel never hides the widget (hid " + hides + " times)")
    check(panel.visible && panel.icon === "󰂲", "blocked radio shows the off icon")
    check(panel.heroStatusText === "Turned Off", "blocked radio reads as turned off, not as no adapter")
    panel.toggleBluetooth()
    after(adapterReturns)
  }

  function adapterReturns() {
    check(panel.visible, "turning on keeps the widget while the controller boots (hid " + hides + " times)")
    BluetoothMock.defaultAdapter = BluetoothMock.adapter
    check(panel.visible && panel.radioEnabled && panel.icon === "󰂯", "returning adapter shows the on widget")
    test.runCli("delay-query", startStaleQuery)
  }

  function startStaleQuery() {
    BluetoothMock.defaultAdapter = null
    after(overlapQuery)
  }

  function overlapQuery() {
    BluetoothMock.defaultAdapter = BluetoothMock.adapter
    test.runCli("off", function() {
      BluetoothMock.defaultAdapter = null
      test.after(function() { test.after(test.staleQueryChecks) })
    })
  }

  function staleQueryChecks() {
    check(hides === 0, "an obsolete query never hides the widget before its queued refresh")
    test.runCli("on", function() {
      BluetoothMock.defaultAdapter = BluetoothMock.adapter
      test.after(removeAdapter)
    })
  }

  function removeAdapter() {
    // No block this time: bluetoothd stopped or the module unloaded.
    BluetoothMock.defaultAdapter = null
    after(noHardwareChecks)
  }

  function noHardwareChecks() {
    check(!panel.visible, "unblocked radio with no adapter hides the widget")
    test.runCli("off", startBlocked)
  }

  // A shell started after a reboot with the block restored and no adapter.
  function startBlocked() {
    loader.active = false
    loader.active = true
    after(startupChecks)
  }

  function startupChecks() {
    check(panel.visible && panel.heroStatusText === "Turned Off", "radio already blocked at startup shows the off widget")
    // A dongle unplugged while off: its rfkill switch goes with it, and the
    // adapter was already gone, so only the switch event says so.
    test.runCli("unplug", function() { test.after(test.unplugChecks) })
  }

  function unplugChecks() {
    check(!panel.visible, "a radio unplugged while off leaves the bar with its rfkill switch")
    if (!failed) console.log("RESULT pass")
    Qt.quit()
  }
}
