import QtQuick
import Quickshell

// Drives the real idle service through a lock whose command is still on its way
// to the lock service (a stub omarchy-system-lock that sleeps), re-asserting idle
// meanwhile as the compositor does, and again once the command has returned.
ShellRoot {
  id: root

  property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property var service: null

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures, lastEvent: service ? service.lastEvent : "" })
    Quickshell.execDetached(["bash", "-c", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  function processes() {
    return JSON.parse(service.statusJson()).processes
  }

  // A screensaver timeout below the lock timeout launches it the moment a cycle starts, as the defaults do.
  QtObject {
    id: fakeShell
    property var shellConfig: ({ idle: { screensaver: 86400, lock: 172800 } })
  }

  Timer {
    id: whilePending
    interval: 500
    onTriggered: {
      assertTrue(root.processes().lock, "the lock command is still running")
      service.startIdleCycle()
      assertTrue(!service.screensaverStartedThisCycle, "no screensaver launches while the lock command is pending")
      assertTrue(!service.idledThisCycle, "no idle cycle starts while the lock command is pending")
      afterLock.start()
    }
  }

  Timer {
    id: afterLock
    interval: 2000
    onTriggered: {
      assertTrue(!root.processes().lock, "the lock command has exited")
      service.startIdleCycle()
      assertTrue(service.idledThisCycle && service.screensaverStartedThisCycle, "an idle cycle starts again once the lock command has exited")
      root.writeResult()
    }
  }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/services/idle/Service.qml")
    if (component.status !== Component.Ready) {
      fail("idle service failed to load: " + component.errorString())
      writeResult()
      return
    }
    service = component.createObject(root, { shell: fakeShell })
    service.lockSystem("test")
    whilePending.start()
  }
}
