import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property int checks: 0
  property bool skipped: false

  Item { id: host }

  function check(condition, message) {
    checks += 1
    if (!condition) failures.push(message)
  }

  function findLockIpc(service) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (objects[i] && objects[i].target === "lock") return objects[i]
    }
    return null
  }

  function run() {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/lock/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    var service = component.createObject(host, { omarchyPath: rootPath })
    if (!service) throw new Error(component.errorString())

    try {
      if (service.hasRealScreen && !service.hasRealScreen()) {
        root.skipped = true
        return
      }

      var lockIpc = findLockIpc(service)
      check(lockIpc !== null, "the lock IPC handler is found")

      // 1. Initial unlocked state
      check(!service.locked, "initial state is unlocked")
      check(!service.lockRequested, "initial lockRequested is false")
      check(!service.sessionLocked, "initial sessionLocked is false")
      if (lockIpc) {
        check(lockIpc.isLocked() === "false", "initial ipc isLocked is false")
        var initStatus = JSON.parse(lockIpc.status())
        check(initStatus.locked === false && initStatus.sessionLocked === false, "initial ipc status reports unlocked")
      }

      // The drawn state follows the tracked copy on its own.
      service.sessionLocked = true
      check(service.locked, "service.locked follows sessionLocked")
      service.sessionLocked = false
      check(!service.locked, "service.locked clears with sessionLocked")

      // 2. Lock cycle 1. A granted lock is simulated, so the suite never takes
      // the real session lock of the desktop it runs on.
      service.lockRequested = true
      service.sessionLocked = true
      check(service.locked, "service is locked when requested and session locked")
      if (lockIpc) {
        check(lockIpc.isLocked() === "true", "ipc isLocked returns true while locked")
        var lockedStatus = JSON.parse(lockIpc.status())
        check(lockedStatus.locked === true, "ipc status reports locked")
      }

      // 3. Unlock cycle 1, with no lockStateChanged, as Quickshell 0.3.2 unlocks
      service.finishUnlock()
      check(!service.locked, "service.locked becomes false after finishUnlock without native lockStateChanged")
      check(!service.sessionLocked, "sessionLocked is false after finishUnlock")
      check(!service.lockRequested, "lockRequested is false after finishUnlock")
      if (lockIpc) {
        check(lockIpc.isLocked() === "false", "ipc isLocked returns false after first unlock")
        var unlockedStatus1 = JSON.parse(lockIpc.status())
        check(unlockedStatus1.locked === false && unlockedStatus1.sessionLocked === false, "ipc status reports locked=false after first unlock")
      }

      // 4. Lock cycle 2
      service.lockRequested = true
      service.sessionLocked = true
      check(service.locked, "second lock cycle marks service locked")
      if (lockIpc) {
        check(lockIpc.isLocked() === "true", "second lock cycle ipc isLocked is true")
      }

      // 5. Unlock cycle 2
      service.finishUnlock()
      check(!service.locked, "second unlock cycle reliably returns locked=false")
      check(!service.sessionLocked, "second unlock cycle clears sessionLocked")
      check(!service.lockRequested, "second unlock cycle clears lockRequested")
      if (lockIpc) {
        check(lockIpc.isLocked() === "false", "second unlock cycle ipc isLocked is false")
        var unlockedStatus2 = JSON.parse(lockIpc.status())
        check(unlockedStatus2.locked === false && unlockedStatus2.sessionLocked === false, "second unlock cycle status is consistent")
      }
    } finally {
      service.lockRequested = false
      service.sessionLocked = false
      service.destroy()
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
      var payload = JSON.stringify({ ok: root.failures.length === 0, skipped: root.skipped, checks: root.checks, failures: root.failures })
      var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
      Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", root.resultPath])
    }
  }
}
