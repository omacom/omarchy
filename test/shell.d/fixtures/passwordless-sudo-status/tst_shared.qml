import QtQuick
import QtTest
import qs.Commons
import Quickshell.Io

TestCase {
  id: testCase
  name: "PasswordlessSudoSharedStatus"
  when: windowShown

  Component {
    id: viewComponent
    QtObject {
      readonly property bool granted: PasswordlessSudoStatus.granted
      function refresh() { PasswordlessSudoStatus.refresh() }
    }
  }

  function test_sharedPolling() {
    var views = []
    for (var i = 0; i < 6; i++) views.push(createTemporaryObject(viewComponent, testCase))
    tryVerify(function() { return ProcessHarness.processes.length === 1 })
    var probe = ProcessHarness.processes[0]
    tryCompare(probe, "startCount", 1)
    compare(probe.command[1], "--active")
    probe.complete(0, 0)
    for (var j = 0; j < views.length; j++) tryCompare(views[j], "granted", true)

    // Creating the active representation must not create another collector.
    var activeView = createTemporaryObject(viewComponent, testCase)
    tryCompare(activeView, "granted", true)
    compare(ProcessHarness.processes.length, 1)
    compare(probe.startCount, 1)

    for (var k = 0; k < views.length; k++) views[k].refresh()
    tryCompare(probe, "startCount", 2)
    for (var m = 0; m < views.length; m++) views[m].refresh()
    tryCompare(PasswordlessSudoStatus, "refreshPending", true)
    compare(probe.startCount, 2)
    probe.complete(0, 0)
    tryCompare(probe, "startCount", 3)
    probe.complete(1, 0)
    for (var n = 0; n < views.length; n++) tryCompare(views[n], "granted", false)
    tryCompare(activeView, "granted", false)

    // The existing five-second freshness bound remains session-wide.
    tryCompare(probe, "startCount", 4, 5500)
    probe.complete(0, 1)
    compare(PasswordlessSudoStatus.granted, false)
    compare(ProcessHarness.processes.length, 1)
  }
}
