import QtQuick
import Quickshell

// Drives the real remote-session service against a stub gliff-server on PATH:
// idle at start, active with the ssh peer once a server runs, idle again after
// it exits. The service is never refreshed by hand: a one-shot grim capture
// raises the same Hyprland screencast event that gliff-server does, so the
// event path is what gets exercised.
ShellRoot {
  id: root

  property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property string stubPidFile: Quickshell.env("OMARCHY_QML_TEST_STUB_PID")
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
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  function captureFrame() {
    Quickshell.execDetached(["grim", "-g", "0,0 1x1", Quickshell.env("OMARCHY_QML_TEST_FRAME")])
  }

  // Polls `condition` every 100 ms for up to `timeout` ms, then continues with
  // `next` either way, recording `message` as a failure on timeout. `tick`,
  // when given, runs every 500 ms while waiting.
  function waitFor(condition, timeout, message, next, tick) {
    var timer = Qt.createQmlObject("import QtQuick; Timer { repeat: true; interval: 100 }", root)
    var waited = 0
    timer.triggered.connect(function() {
      waited += timer.interval
      if (tick && waited % 500 === 0) tick()
      if (!condition() && waited < timeout) return
      timer.stop()
      timer.destroy()
      root.assertTrue(condition(), message)
      next()
    })
    timer.start()
  }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/services/remote-session/Service.qml")
    if (component.status !== Component.Ready) {
      fail("remote session service failed to load: " + component.errorString())
      writeResult()
      return
    }
    service = component.createObject(root, { shell: null })
    if (!service) {
      fail("remote session service failed to instantiate: " + component.errorString())
      writeResult()
      return
    }

    waitFor(function() { return service.stateLoaded === true }, 3000, "service probes on startup", function() {
      root.assertTrue(service.active === false, "service starts idle without a gliff server")
      Quickshell.execDetached(["bash", "-c", "SSH_CONNECTION='10.0.0.5 51234 10.0.0.1 22' gliff-server --stdio & echo $! > " + root.shellQuote(root.stubPidFile)])
      // Each capture raises a screencast event; the first one after the stub
      // is up is what should flip the service, with no refresh() by hand.
      waitFor(function() { return service.active === true }, 4000, "a screencast event makes the service report the session while gliff-server runs", function() {
        root.assertTrue(JSON.stringify(service.peers) === JSON.stringify(["10.0.0.5"]), "service reports the ssh peer, got " + JSON.stringify(service.peers))
        Quickshell.execDetached(["bash", "-c", "kill \"$(cat " + root.shellQuote(root.stubPidFile) + ")\""])
        waitFor(function() { return service.active === false }, 5000, "service returns to idle once gliff-server exits", function() {
          root.writeResult()
        })
      }, root.captureFrame)
    })
  }
}
