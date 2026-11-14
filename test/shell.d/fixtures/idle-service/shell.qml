import QtQuick
import Quickshell

// Drives the real idle service with a stand-in shell whose idle timings change
// while the service's monitor runs, as a shell.json edit does. A monitor made
// fresh with the new timeout is the control: once it reports idle the
// compositor has, so the service must too. A second change while idle must
// leave the running cycle alone, and take effect once the user is back.
ShellRoot {
  id: root

  property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property var service: null
  property var control: null

  QtObject {
    id: shellStub
    property var shellConfig: ({ idle: { screensaver: 3600, lock: 0 } })
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

  function status() {
    return JSON.parse(service.statusJson())
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures, status: service ? status() : null })
    Quickshell.execDetached(["bash", "-c", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  // Polls `condition` every 100 ms for up to `timeout` ms, then continues with
  // `next` either way, recording `message` as a failure on timeout.
  function waitFor(condition, timeout, message, next) {
    var timer = Qt.createQmlObject("import QtQuick; Timer { repeat: true; interval: 100 }", root)
    var waited = 0
    timer.triggered.connect(function() {
      waited += timer.interval
      if (!condition() && waited < timeout) return
      timer.stop()
      timer.destroy()
      root.assertTrue(condition(), message)
      next()
    })
    timer.start()
  }

  function after(ms, next) {
    var timer = Qt.createQmlObject("import QtQuick; Timer { interval: " + ms + " }", root)
    timer.triggered.connect(function() {
      timer.destroy()
      next()
    })
    timer.start()
  }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/services/idle/Service.qml")
    if (component.status !== Component.Ready) {
      fail("idle service failed to load: " + component.errorString())
      writeResult()
      return
    }
    service = component.createObject(root, { shell: shellStub })
    if (!service) {
      fail("idle service failed to instantiate: " + component.errorString())
      writeResult()
      return
    }

    waitFor(function() { return root.status().enabled === true }, 3000, "service enables idle once Stay Awake state loads", function() {
      shellStub.shellConfig = { idle: { screensaver: 2, lock: 0 } }
      root.control = Qt.createQmlObject("import Quickshell.Wayland; IdleMonitor { timeout: 2; respectInhibitors: true }", root)

      waitFor(function() { return root.control.isIdle === true }, 6000, "a fresh 2 s monitor reports idle with no input", function() {
        waitFor(function() { return root.status().idle === true }, 2000, "service reports idle after its timeout changed from 3600 s to 2 s, as the fresh monitor did", function() {
          shellStub.shellConfig = { idle: { screensaver: 4, lock: 0 } }

          after(1000, function() {
            var now = root.status()
            root.assertTrue(now.idle === true && now.inIdleCycle === true, "a timeout change while idle keeps the running idle cycle, got idle=" + now.idle + " inIdleCycle=" + now.inIdleCycle)

            // A Shift press is the user coming back; the next cycle must use the 4 s timeout set while idle.
            Quickshell.execDetached(["wtype", "-k", "Shift_L"])
            waitFor(function() { return root.status().idle === false }, 3000, "service reports active after input", function() {
              after(2800, function() {
                root.assertTrue(root.control.isIdle === true && root.status().idle === false, "2.8 s after input the 2 s monitor is idle but the service, retimed to 4 s, is not, got control=" + root.control.isIdle + " service=" + root.status().idle)
                waitFor(function() { return root.status().idle === true }, 3000, "service goes idle again on its 4 s timeout", function() {
                  root.writeResult()
                })
              })
            })
          })
        })
      })
    })
  }
}
