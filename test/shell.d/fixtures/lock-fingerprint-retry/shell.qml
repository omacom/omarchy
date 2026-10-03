import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []

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
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures
    })

    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  Item { id: host; width: 800; height: 600 }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      try {
        var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/lock/Service.qml", Component.PreferSynchronous)
        if (component.status !== Component.Ready) {
          root.fail("lock service failed to load: " + component.errorString())
          return
        }

        var service = component.createObject(host, { width: 800, height: 600 })
        if (!service) {
          root.fail("lock service failed to instantiate: " + component.errorString())
          return
        }

        root.assertTrue(service.fingerprintRetryDelay === 250,
          "fingerprint retry starts at 250ms, got " + service.fingerprintRetryDelay)

        // A reader that never engaged is a stack failure, not a rejected scan:
        // the retry must back off and it must not raise the failure feedback.
        service.fingerprintAttemptEngaged = false
        service.fingerprintRetryDelay = 4000
        service.scheduleFingerprintRetry()
        root.assertTrue(service.fingerprintRetryDelay >= 8000,
          "an unengaged failure backs the retry off, got " + service.fingerprintRetryDelay)
        root.assertTrue(service.fingerprintFailureNonce === 0,
          "an unengaged failure does not flash a rejection, nonce " + service.fingerprintFailureNonce)

        service.fingerprintRetryDelay = 30000
        service.scheduleFingerprintRetry()
        root.assertTrue(service.fingerprintRetryDelay === 30000,
          "the backoff stops at its cap, got " + service.fingerprintRetryDelay)

        // A reader that did ask for a finger was a real scan: re-arm at once
        // and flag the miss so the view can react.
        service.fingerprintAttemptEngaged = true
        service.fingerprintRetryDelay = 8000
        service.scheduleFingerprintRetry()
        root.assertTrue(service.fingerprintRetryDelay === 250,
          "a rejected scan re-arms immediately, got " + service.fingerprintRetryDelay)
        root.assertTrue(service.fingerprintFailureNonce === 1,
          "a rejected scan raises the failure signal, nonce " + service.fingerprintFailureNonce)

        service.destroy()
      } catch (error) {
        root.fail("lock fingerprint retry fixture threw: " + error)
      } finally {
        root.writeResult()
      }
    }
  }
}
