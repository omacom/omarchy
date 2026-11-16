import QtQuick
import Quickshell
import Quickshell.Io

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
  property var afterRuleCheck: null
  property int ruleCheckAttempts: 0
  property string ruleCheckOutput: ""

  function checkCaptureOverride(enabled, next, closedOwner) {
    afterRuleCheck = next
    ruleCheckAttempts = 0
    var closedCheck = closedOwner ? "assert(omarchy_closed_capture_owners[" + JSON.stringify(closedOwner) + "]); " : ""
    var ownerCheck = enabled ? "assert(omarchy_capture_owner == " + JSON.stringify(root.service.captureOwner) + "); " : ""
    ruleCheck.command = ["hyprctl", "eval", closedCheck + ownerCheck + "assert(omarchy_test_capture_rule:is_enabled() == " + (enabled ? "true" : "false") + ")"]
    root.startRuleCheck()
  }

  function startRuleCheck() {
    ruleCheckOutput = ""
    ruleCheck.running = true
  }

  // Let the replacement claim the override before the retired instance's
  // cleanup runs, reproducing the troublesome reload ordering.
  function replaceService(component, next) {
    var retired = root.service
    root.service = component.createObject(root, { shell: null })
    waitFor(function() { return root.service.stateLoaded && root.service.active }, 3000, "replacement detects the ongoing session", function() {
      root.checkCaptureOverride(true, function() {
        var owner = retired.captureOwner
        retired.destroy()
        root.checkCaptureOverride(true, next, owner)
      })
    })
  }

  Process {
    id: ruleCheck
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.ruleCheckOutput = text.trim()
    }
    onExited: {
      if (root.ruleCheckOutput !== "ok" && ++root.ruleCheckAttempts < 20) {
        ruleCheckRetry.start()
      } else {
        root.assertTrue(root.ruleCheckOutput === "ok", "Remote capture override: " + root.ruleCheckOutput)
        root.afterRuleCheck()
      }
    }
  }

  Timer {
    id: ruleCheckRetry
    interval: 100
    onTriggered: root.startRuleCheck()
  }

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

  // One pixel of the first output: outputs need not start at 0,0.
  function captureFrame() {
    var screen = Quickshell.screens[0]
    var at = screen ? screen.x + "," + screen.y : "0,0"
    Quickshell.execDetached(["grim", "-g", at + " 1x1", Quickshell.env("OMARCHY_QML_TEST_FRAME")])
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
        root.checkCaptureOverride(true, function() {
          root.replaceService(component, function() {
            Quickshell.execDetached(["bash", "-c", "kill \"$(cat " + root.shellQuote(root.stubPidFile) + ")\""])
            waitFor(function() { return service.active === false }, 5000, "service returns to idle once gliff-server exits", function() {
              root.checkCaptureOverride(false, function() {
                // Destroy immediately after queueing an enable: cleanup must win
                // even if Hyprland receives that enable after the destruction.
                root.service.applyProbe("1\n")
                var owner = root.service.captureOwner
                root.service.destroy()
                root.service = null
                root.checkCaptureOverride(false, root.writeResult, owner)
              })
            })
          })
        })
      }, root.captureFrame)
    })
  }
}
