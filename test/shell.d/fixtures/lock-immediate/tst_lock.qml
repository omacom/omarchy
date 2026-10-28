import QtQuick
import QtTest

TestCase {
  name: "LockImmediate"
  Component { id: policyComponent; LockTiming {} }

  function makePolicy() {
    return createTemporaryObject(policyComponent, this)
  }

  function test_normalLockStillWaits() {
    var p = makePolicy()
    compare(p.apiLock(), "ok")
    wait(250)
    compare(p.sessionLocked, false)
    tryCompare(p, "sessionLocked", true, 1000)
  }

  function test_immediateLockUsesSharedSetup() {
    var p = makePolicy()
    compare(p.apiLockImmediate(), "ok")
    compare(p.sessionLocked, true)
    compare(p.authenticationResets, 1)
    compare(p.sleepRequests, 0)
    compare(p.apiLockImmediate(), "ok")
    compare(p.authenticationResets, 1, "an existing lock must not be restarted")
  }

  function test_missingPamRefusesImmediateLock() {
    var p = makePolicy()
    p.passwordPamConfigured = false
    compare(p.apiLockImmediate(), "missing-pam")
    compare(p.lockRequested, false)
    compare(p.sessionLocked, false)
    compare(p.authenticationResets, 0)
  }

  function test_immediateLockWaitsForARealScreen() {
    var p = makePolicy()
    p.testScreens = [{ name: "", width: 0, height: 0 }]
    compare(p.apiLockImmediate(), "ok")
    wait(600)
    compare(p.sessionLocked, false)
    compare(p.pendingSessionLock, true)
    p.testScreens = [{ name: "eDP-1", width: 1920, height: 1080 }]
    tryCompare(p, "sessionLocked", true, 500)
  }

  function test_immediateCannotAcceleratePendingNormalLock() {
    var p = makePolicy()
    compare(p.apiLock(), "ok")
    wait(200)
    compare(p.apiLockImmediate(), "ok")
    wait(100)
    compare(p.sessionLocked, false)
    compare(p.authenticationResets, 1)
    tryCompare(p, "sessionLocked", true, 1000)
  }
}
