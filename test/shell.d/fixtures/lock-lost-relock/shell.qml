import QtQuick
import Quickshell

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property int checks: 0
  property var service: null
  property var sessionLock: null
  property var stabilizeTimer: null
  property var pendingTimer: null
  property int step: 0

  Item { id: host }

  function check(condition, message) {
    checks += 1
    if (!condition) failures.push(message)
  }

  function child(test, description) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (test(objects[i])) return objects[i]
    }
    throw new Error("Missing " + description)
  }

  function timer(interval, repeat) {
    return child(function(object) { return object.interval === interval && object.repeat === repeat }, "timer " + interval)
  }

  // requestSessionLock() returns while the stabilize timer runs, and every
  // path to the real lock goes through it, so it is never let stop.
  function cancelQueuedLock() {
    pendingTimer.stop()
    service.pendingSessionLock = false
    stabilizeTimer.restart()
  }

  function setUp() {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/lock/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    service = component.createObject(host, { omarchyPath: rootPath })
    if (!service) throw new Error(component.errorString())
    sessionLock = child(function(object) { return object.hasOwnProperty("secure") && object.hasOwnProperty("surface") }, "session lock")
    stabilizeTimer = timer(500, false)
    pendingTimer = timer(100, true)
    stabilizeTimer.interval = 24 * 60 * 60 * 1000
    stabilizeTimer.restart()
    service.passwordPamConfigured = true
  }

  // The lock object reports the loss; the service sees it a tick later.
  function nextStep() {
    step += 1
    stepTimer.restart()
  }

  function runStep() {
    if (step === 0) {
      setUp()
      service.lockRequested = true
      sessionLock.lockStateChanged()
      return nextStep()
    }

    if (step === 1) {
      check(service.lockRequested, "a lock that ends without authentication is not an unlock")
      check(service.pendingSessionLock, "a lock lost while requested is taken again")
      cancelQueuedLock()
      sessionLock.secureStateChanged()
      return nextStep()
    }

    if (step === 2) {
      check(service.lockRequested && service.pendingSessionLock, "losing the compositor lock takes it again")
      cancelQueuedLock()
      service.lockRequested = false
      sessionLock.lockStateChanged()
      sessionLock.secureStateChanged()
      return nextStep()
    }

    if (step === 3) {
      check(!service.lockRequested && !service.pendingSessionLock, "an unlock after authentication is not relocked")
      cancelQueuedLock()
      service.lockRequested = true
      sessionLock.secureStateChanged()
      service.finishUnlock()
      return nextStep()
    }

    if (step === 4) {
      check(!service.lockRequested && !service.pendingSessionLock, "an unlock that lands before a queued loss check is not relocked")
      cancelQueuedLock()
      finish()
    }
  }

  function finish() {
    if (service) {
      service.lockRequested = false
      service.resetAuthenticationState()
      service.destroy()
    }
    var payload = JSON.stringify({ ok: failures.length === 0, checks: checks, failures: failures })
    var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
    Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", resultPath])
  }

  Timer {
    id: stepTimer
    interval: 20
    running: true
    onTriggered: {
      try {
        root.runStep()
      } catch (error) {
        root.failures.push(String(error))
        if (root.stabilizeTimer) root.cancelQueuedLock()
        root.finish()
      }
    }
  }
}
