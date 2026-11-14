import QtQuick
import Quickshell

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property int checks: 0

  Item { id: host }

  function check(condition, message) {
    checks += 1
    if (!condition) failures.push(message)
  }

  function timers(service) {
    var found = []
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (objects[i].interval !== undefined && objects[i].triggered !== undefined) found.push(objects[i])
    }
    return found
  }

  function run() {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/lock/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    var service = component.createObject(host, { omarchyPath: rootPath })
    if (!service) throw new Error(component.errorString())
    try {
      service.passwordPamConfigured = true
      var started = Date.now()
      var accepted = service.beginLock()
      var elapsed = Date.now() - started
      var queued = service.pendingSessionLock

      // Timers only fire from the event loop, so stopping them in this tick
      // keeps the real session lock and the display blank from ever engaging.
      var all = timers(service)
      for (var i = 0; i < all.length; i++) all[i].stop()
      service.pendingSessionLock = false
      service.lockRequested = false

      check(accepted, "the lock request is accepted")
      check(queued, "the session lock is queued whatever the layout reset does")
      // The stub stalls for 5s, so anything near that means the request waited.
      check(elapsed < 2000, "the lock request does not wait on the layout reset (" + elapsed + "ms)")
    } finally {
      service.lockRequested = false
      service.resetAuthenticationState()
    }
  }

  Timer {
    interval: 1
    running: true
    onTriggered: {
      try {
        root.run()
      } catch (error) {
        root.failures.push(String(error))
      }
      var payload = JSON.stringify({ ok: root.failures.length === 0, checks: root.checks, failures: root.failures })
      var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
      Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", root.resultPath])
    }
  }
}
