import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

ShellRoot {
  id: test
  property bool failed: false

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  property QtObject connectedEthernet: QtObject {
    property int type: DeviceType.Wired
    property string name: "enp1234567890"
    property bool connected: true
    property bool nmManaged: true
  }
  property QtObject disconnectedEthernet: QtObject {
    property int type: DeviceType.Wired
    property string name: "enp2345678901"
    property bool connected: false
    property bool nmManaged: true
  }
  property QtObject thirdEthernet: QtObject {
    property int type: DeviceType.Wired
    property string name: "enp3456789012"
    property bool connected: false
    property bool nmManaged: true
  }
  property QtObject unmanagedEthernet: QtObject {
    property int type: DeviceType.Wired
    property string name: "veth-unmanaged"
    property bool connected: false
    property bool nmManaged: false
  }

  Component.onCompleted: {
    NetworkMock.devices = ({ values: [
      NetworkMock.wifi,
      connectedEthernet,
      disconnectedEthernet,
      thirdEthernet,
      unmanagedEthernet
    ] })
  }

  Item {
    Network.Panel {
      id: panel
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

  function initialChecks() {
    var devices = panel.ethernetDevices
    check(devices.indexOf(connectedEthernet) >= 0, "managed connected Ethernet device is available")
    check(devices.indexOf(disconnectedEthernet) >= 0, "managed disconnected Ethernet device is available")
    check(devices.indexOf(thirdEthernet) >= 0, "every managed Ethernet device is available")
    check(devices.indexOf(unmanagedEthernet) < 0, "unmanaged Ethernet device is excluded")
    check(devices.indexOf(NetworkMock.wifi) < 0, "Wi-Fi device is excluded from Ethernet controls")

    check(panel.testEthernetRepeater.count === devices.length, "one Ethernet control is created per managed device")
    var first = panel.testEthernetRepeater.itemAt(0)
    var last = panel.testEthernetRepeater.itemAt(panel.testEthernetRepeater.count - 1)
    var controls = [
      panel.testEthernetRepeater.itemAt(0),
      panel.testEthernetRepeater.itemAt(1),
      panel.testEthernetRepeater.itemAt(2)
    ]
    var insideBounds = controls.every(function(control) {
      return control && control.x >= 0 && control.x + control.width <= panel.testEthernetControls.width + 1
    })
    check(insideBounds, "Ethernet controls stay inside their bounded row")
    check(last && first && last.y > first.y, "multiple Ethernet controls wrap onto another row")

    check(panel.wifiNetworksVisible, "Wi-Fi results are visible while the radio is enabled")
    check(panel.testNetworkList.visible && panel.testNetworkList.count > 0, "enabled Wi-Fi radio shows network results")
    check(panel.testWifiSwitch.checked, "Wi-Fi switch reflects the enabled radio")
    panel.scanning = true
    check(panel.testWifiScanHeader.visible, "active scanning shows its status")

    panel.testWifiSwitch.toggled()
    check(!NetworkMock.wifiEnabled, "Wi-Fi toggle disables the radio")
    check(!panel.wifiNetworksVisible, "disabled Wi-Fi radio hides network results")
    check(!panel.scanning && panel.wifiNetworks.length === 0, "disabled Wi-Fi radio clears scans and stale results")
    check(!panel.testNetworkList.visible && panel.testNetworkList.count === 0, "disabled Wi-Fi radio hides the network list")
    check(!panel.testWifiScanHeader.visible, "disabled Wi-Fi radio hides scan status")
    check(!panel.testWifiSwitch.checked, "Wi-Fi switch reflects the disabled radio")

    panel.testEthernetRepeater.itemAt(0).toggled()
    commandWait.stage = 0
    commandWait.start()
  }

  function finishChecks() {
    if (failed) {
      Qt.quit()
      return
    }
    console.log("RESULT pass")
    done.start()
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      panel.testEnsureContent()
      panel.refresh(false)
      Qt.callLater(test.initialChecks)
    }
  }

  Timer {
    id: commandWait
    property int stage: 0
    interval: 20
    repeat: true
    onTriggered: {
      if (panel.ethernetPendingDevice !== "") return
      stop()
      if (stage === 0) {
        test.check(panel.ethernetActionError === "", "disconnect command succeeds")
        panel.testEthernetRepeater.itemAt(1).toggled()
        stage = 1
        start()
      } else {
        test.check(panel.ethernetActionError === "", "connect command succeeds")
        test.finishChecks()
      }
    }
  }

  Timer { id: done; interval: 200; onTriggered: Qt.quit() }
}
