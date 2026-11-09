import QtQuick
import Quickshell
import Quickshell.Services.Pam
import qs.Commons

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

  function timer(service, interval, repeat) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (objects[i].interval === interval && objects[i].repeat === repeat && objects[i].ticksLeft === undefined) return objects[i]
    }
    throw new Error("Missing timer: " + interval + ", repeat=" + repeat)
  }

  function resumeWatch(service) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (objects[i].ticksLeft !== undefined) return objects[i]
    }
    throw new Error("Missing resume watch")
  }

  function run() {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/lock/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    var service = component.createObject(host, { omarchyPath: rootPath })
    if (!service) throw new Error(component.errorString())
    try {
      var retry = timer(service, 250, false)
      var reach = timer(service, 20000, false)
      var recheck = timer(service, 1000, false)
      service.lockRequested = true

      service.applyFingerprintProbe("Could not activate remote peer")
      check(!service.fingerprintConfigured, "unknown cannot invent an enrollment")
      check(recheck.running && recheck.interval === 1000, "unknown schedules a paced probe")

      service.applyFingerprintProbe("Could not activate remote peer")
      service.applyFingerprintProbe("No devices available")
      check(!service.fingerprintConfigured && service.fingerprintUnavailable, "an initial outage shows unavailable without inventing enrollment")
      service.nudgeFingerprint()
      check(recheck.interval === 250, "input promptly retries an initial unknown probe")

      service.applyFingerprintProbe("Fingerprints for user test on Goodix:\n - #0: right-index-finger")
      check(service.fingerprintConfigured, "a real enrollment row enables fingerprint")
      check(!service.fingerprintUnavailable && !recheck.running, "a definitive enrollment clears probe notice and recheck")
      service.applyFingerprintProbe("ListEnrolledFingers failed: Timeout was reached")
      check(service.fingerprintConfigured, "unknown preserves a known enrollment")
      service.applyFingerprintProbe("No devices available")
      service.applyFingerprintProbe("ListEnrolledFingers failed: Timeout was reached")
      check(!service.fingerprintUnavailable && !recheck.running, "known enrollment uses PAM recovery without competing probe retries")

      service.fingerprintAuthenticating = true
      retry.start()
      reach.start()
      service.applyFingerprintProbe("User test has no fingers enrolled for Goodix MOC Fingerprint Sensor.")
      check(!service.fingerprintConfigured, "empty enrollment is not a fingerprint")
      check(!retry.running, "empty enrollment stops authentication retries")
      check(!service.fingerprintAuthenticating && !reach.running, "empty enrollment closes the attempt and reach timer")

      service.fingerprintConfigured = true
      service.fingerprintAuthenticating = true
      service.fingerprintAttemptReachedDevice = false
      reach.start()
      service.settleFingerprintAttempt()
      check(service.fingerprintUnreachedStreak === 1, "an unreached attempt advances the streak")
      check(retry.running && retry.interval === 1000, "an unreached attempt retries with backoff")
      check(!reach.running, "settle cancels the reach timeout")
      service.handleFingerprintFinished(PamResult.Error)
      check(service.fingerprintUnreachedStreak === 1, "error and completion settle an attempt only once")
      check(service.lockRequested, "a PAM error never unlocks")

      service.fingerprintUnreachedStreak = 3
      service.fingerprintLastNudgeMs = 0
      retry.interval = 8000
      service.nudgeFingerprint()
      check(retry.interval === 250, "input advances a backed-off PAM retry")
      retry.interval = 8000
      service.nudgeFingerprint()
      check(retry.interval === 8000, "continuous input cannot collapse every retry")
      check(service.fingerprintUnavailable, "repeated unreached attempts report unavailable")
      service.fingerprintAuthenticating = true
      service.fingerprintAttemptPromptedAtMs = Date.now() - 5000
      service.noteFingerprintReachedDevice()
      check(Date.now() - service.fingerprintAttemptPromptedAtMs < 2000, "the prompt resets the fast-error clock after a slow claim")
      check(!service.fingerprintUnavailable, "a prompt immediately clears the unavailable notice")
      service.settleFingerprintAttempt()
      check(service.fingerprintUnreachedStreak === 0 && retry.interval === 250, "a reached attempt clears backoff")

      for (var i = 0; i < 3; i++) {
        service.fingerprintAuthenticating = true
        service.fingerprintAttemptReachedDevice = true
        service.fingerprintAttemptFastError = false
        service.fingerprintAttemptPromptedAtMs = Date.now()
        service.settleFingerprintAttempt(true)
        service.handleFingerprintFinished(PamResult.Error)
      }
      check(service.fingerprintUnreachedStreak === 3 && retry.interval === 4000, "fast errors after prompting back off and settle once")
      check(service.fingerprintUnavailable && service.lockRequested, "a prompted but failing reader is unavailable without unlocking")

      service.fingerprintAuthenticating = true
      service.fingerprintAttemptPromptedAtMs = Date.now() - 31000
      service.noteFingerprintReachedDevice()
      service.handleFingerprintFinished(PamResult.Error)
      check(service.fingerprintUnreachedStreak === 0 && retry.interval === 250, "a timeout message cannot restart the fast-error clock")

      service.fingerprintUnreachedStreak = 3
      service.fingerprintAuthenticating = true
      service.fingerprintAttemptPromptedAtMs = Date.now()
      service.handleFingerprintFinished(PamResult.Failed)
      check(service.fingerprintUnreachedStreak === 0 && retry.interval === 250, "a quick mismatch is not a device error")

      service.fingerprintAuthenticating = true
      service.fingerprintAttemptPromptedAtMs = Date.now()
      service.handleFingerprintFinished(PamResult.Error)
      check(service.fingerprintUnreachedStreak === 1, "error completion backs off even without a preceding error signal")
      service.fingerprintAuthenticating = true
      service.fingerprintAttemptReachedDevice = false
      service.fingerprintAttemptPromptedAtMs = Date.now() - 5000
      service.noteFingerprintReachedDevice()
      service.handleFingerprintFinished(PamResult.Error)
      check(service.fingerprintUnreachedStreak === 2, "a slow claim followed by a fast verification error still backs off")

      for (var i = 0; i < 8; i++) {
        service.fingerprintAuthenticating = true
        service.fingerprintAttemptReachedDevice = false
        service.settleFingerprintAttempt()
      }
      check(retry.interval === 40000 && service.fingerprintUnavailable, "persistent misses reach the capped wait")
      service.nudgeFingerprint()
      check(retry.interval === 40000, "input at the cap preserves the daemon's idle window")

      service.fingerprintAuthenticating = true
      service.restartFingerprintAfterSleep()
      check(!service.fingerprintAuthenticating, "resume settles an in-flight attempt")
      check(service.fingerprintUnreachedStreak === 1 && !service.fingerprintUnavailable, "resume grace suppresses an unavailable notice")
      check(retry.running && retry.interval === 1000, "resume retries without retaining the capped wait")
      check(service.lockRequested, "resume never unlocks")

      service.fingerprintAuthenticating = true
      reach.start()
      service.timeoutFingerprintReach()
      check(!service.fingerprintAuthenticating && !reach.running, "the reach bound closes a stuck attempt")
      check(service.lockRequested, "a timeout never unlocks")

      // runBlank and runWake would drive the real displays, so the pause they
      // call is exercised directly.
      var sleepWatch = timer(service, 1000, true)
      service.fingerprintConfigured = true
      service.fingerprintUnreachedStreak = 0
      // Close the resume grace an earlier check opened, so misses count again.
      service.fingerprintResumedAtMs = 0
      service.fingerprintAuthenticating = true
      service.fingerprintAttemptReachedDevice = false
      reach.start()
      service.pauseFingerprint()
      check(service.fingerprintAuthenticating && reach.running, "blanking lets a claim in progress finish under its reach bound")
      check(sleepWatch.running, "the sleep watch covers an attempt still running while blank")
      service.fingerprintAttemptReachedDevice = true
      service.settleFingerprintAttempt()
      check(!retry.running && !sleepWatch.running, "once that attempt ends nothing runs while the displays are off")
      service.resumeFingerprint()
      check(retry.running && retry.interval === 250 && sleepWatch.running, "a wake arms the next attempt and the sleep watch")
      retry.stop()

      for (var j = 0; j < 8; j++) {
        service.fingerprintAuthenticating = true
        service.fingerprintAttemptReachedDevice = false
        service.settleFingerprintAttempt()
      }
      check(retry.interval === 40000, "a failing reader is at its capped wait")
      var streak = service.fingerprintUnreachedStreak
      service.pauseFingerprint()
      check(!retry.running, "blanking stops the backed-off retry")
      service.resumeFingerprint()
      check(retry.running && retry.interval > 39000, "a wake keeps the capped wait so fprintd still gets its idle window")
      check(service.fingerprintUnreachedStreak === streak && streak > 0, "pause and wake keep the miss history")
      service.pauseFingerprint()
      service.fingerprintRetryDueMs = Date.now() + 5000
      service.resumeFingerprint()
      service.fingerprintLastNudgeMs = 0
      service.nudgeFingerprint()
      check(retry.running && retry.interval > 4000, "input after a wake keeps the capped retry's idle window")
      service.pauseFingerprint()
      service.fingerprintRetryDueMs = Date.now() - 1000
      service.resumeFingerprint()
      check(retry.running && retry.interval === 250, "a wait that ran out while blank retries at once on wake")

      // The blank countdown would drive the real displays, so it is stopped
      // whenever the resume path arms it.
      var resumeTimer = resumeWatch(service)
      var blankTimer = timer(service, 5000, false)
      retry.stop()
      service.pauseFingerprint()
      service.noteSleepRequested()
      check(resumeTimer.running, "a lock request while blank watches for a sleep")
      for (var k = 0; k < 20; k++) {
        resumeTimer.lastTickMs = Date.now()
        resumeTimer.triggered()
      }
      check(!resumeTimer.running && service.fingerprintPaused && !retry.running, "a repeated lock with no sleep, as the idle service makes, leaves the reader paused")

      service.noteSleepRequested()
      resumeTimer.lastTickMs = Date.now() - 60000
      resumeTimer.triggered()
      blankTimer.stop()
      check(!resumeTimer.running, "the watch ends once it sees the sleep")
      check(!service.fingerprintPaused, "a resume with no input still brings the reader back")
      check(retry.running && retry.interval === 250, "a wake after a sleep while blank recovers at once")
      check(service.fingerprintUnreachedStreak === 0, "a sleep while blank opens the resume grace")
      retry.stop()
      service.pauseFingerprint()
      service.noteSleepRequested()
      service.resetAuthenticationState()
      check(!resumeTimer.running, "unlock reset drops a pending resume")
      service.lockRequested = true
      service.fingerprintConfigured = true
      service.pauseFingerprint()

      service.lockRequested = false
      service.resetAuthenticationState()
      check(!retry.running && !reach.running && !recheck.running, "unlock reset stops every fingerprint timer")
      check(!service.fingerprintPaused, "unlock reset clears a pause so the next lock starts the reader")
      service.applyFingerprintProbe("Daemon is restarting")
      check(!recheck.running, "an unknown probe outside the lock cannot restart it")
    } finally {
      service.lockRequested = false
      service.resetAuthenticationState()
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
      var payload = JSON.stringify({ ok: root.failures.length === 0, checks: root.checks, failures: root.failures })
      var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
      Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", root.resultPath])
    }
  }
}
