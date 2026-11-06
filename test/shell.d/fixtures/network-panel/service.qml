import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
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

  readonly property string statusFile: Quickshell.env("NETWORK_TEST_CURL_STATUS") || ""

  Network.Service { id: service }

  // Rewrite the fake curl's answer. The service is told to probe explicitly
  // afterwards, so the test never depends on a wall-clock interval.
  Process {
    id: writer
    command: ["bash", "-c", "printf '%s' \"$1\" > \"$2\"", "bash", "", test.statusFile]
    onExited: service.reprobe()
  }

  function writeStatus(status) {
    writer.command = ["bash", "-c", "printf '%s' \"$1\" > \"$2\"", "bash", status, test.statusFile]
    writer.running = true
  }

  property int step: 0
  Timer {
    interval: 400
    repeat: true
    running: true
    onTriggered: {
      if (test.step === 0) {
        test.check(service.routedConnectivity, "a 204 clears the limited warning")
        test.check(service.refreshInterval === 15000, "the shared refresh starts at 15s")
        test.writeStatus("301")
        test.step = 1
      } else if (test.step === 1) {
        test.check(!service.routedConnectivity, "a redirect keeps the limited warning")
        test.writeStatus("204")
        test.step = 2
      } else if (test.step === 2) {
        test.check(service.routedConnectivity, "a later 204 clears the warning again")
        service.testTimer.triggered()
        test.check(service.refreshInterval === 30000, "the shared refresh backs off after a tick")
        service.testTimer.triggered()
        test.check(service.refreshInterval === 60000, "the shared refresh backs off again")
        service.testTimer.triggered()
        test.check(service.refreshInterval === 120000, "the shared refresh keeps backing off")
        service.testTimer.triggered()
        test.check(service.refreshInterval === 240000, "the shared refresh reaches 240s")
        service.testTimer.triggered()
        test.check(service.refreshInterval === 300000, "the shared refresh caps at five minutes")
        service.testTimer.triggered()
        test.check(service.refreshInterval === 300000, "the shared refresh stays capped")
        service.reprobe()
        test.check(service.refreshInterval === 15000, "a manual re-probe resets the refresh")
        service.testTimer.triggered()
        test.check(service.refreshInterval === 30000, "the refresh can back off again")
        NetworkMock.devices.values = [NetworkMock.wifi]
        test.check(service.refreshInterval === 15000, "a device change resets the refresh")
        test.step = 3
      } else {
        test.check(service.routedConnectivity, "the device-change probe uses the current answer")
        console.log("RESULT pass")
        Qt.quit()
      }
    }
  }

  Component.onCompleted: NetworkMock.connectivity = NetworkConnectivity.Limited
}
