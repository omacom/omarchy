import QtQuick
import Quickshell
import Quickshell.Io

// Drives the real nightlight Service.qml against stubbed hyprctl and
// omarchy-nightlight-config (see nightlight-service-test.sh) through the
// orderings that used to race: quick double toggles, warmth previews around a
// save, and a toggle made while a save restarts hyprsunset.
ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string controlDir: Quickshell.env("NIGHTLIGHT_TEST_DIR")
  property var failures: []
  property var service: null
  property var steps: []
  property var lastSave: null

  function fail(message) { failures.push(String(message)) }
  function assertTrue(condition, message) { if (!condition) fail(message) }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    Quickshell.execDetached(["bash", "-c", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  // One shell command at a time, with its stdout handed to `then`.
  property var pendingThen: null
  Process {
    id: runner
    stdout: StdioCollector { id: runnerOut; waitForEnd: true }
    onExited: {
      var then = root.pendingThen
      root.pendingThen = null
      if (then) then(String(runnerOut.text || ""))
    }
  }
  function sh(script, then) {
    root.pendingThen = then || null
    runner.command = ["bash", "-c", script]
    runner.running = true
  }

  // Steps run in order; each gets `next` and calls it when done.
  function run(list) {
    root.steps = list
    advance()
  }
  function advance() {
    if (root.steps.length === 0) {
      root.writeResult()
      return
    }
    var step = root.steps.shift()
    step(function() { Qt.callLater(root.advance) })
  }
  function wait(ms) {
    return function(next) { waitTimer.callback = next; waitTimer.interval = ms; waitTimer.start() }
  }
  Timer {
    id: waitTimer
    property var callback: null
    repeat: false
    onTriggered: { var cb = callback; callback = null; if (cb) cb() }
  }

  function setScreen(kelvin) {
    return function(next) { root.sh("printf '%s\\n' " + kelvin + " > " + shellQuote(controlDir + "/state") + "; : > " + shellQuote(controlDir + "/log"), function() { next() }) }
  }
  function setControl(name, value) {
    return function(next) { root.sh("printf '%s\\n' " + shellQuote(value) + " > " + shellQuote(controlDir + "/" + name), function() { next() }) }
  }
  function refreshed(next) {
    root.service.refresh()
    root.wait(400)(next)
  }
  function withLog(check) {
    return function(next) {
      root.sh("cat " + shellQuote(controlDir + "/log"), function(text) {
        check(text.split("\n").filter(function(line) { return line !== "" }))
        next()
      })
    }
  }
  function indexOf(lines, line) { return lines.indexOf(line) }
  function sets(lines) { return lines.filter(function(line) { return line.indexOf("set ") === 0 }) }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/services/nightlight/Service.qml")
      if (component.status !== Component.Ready) {
        root.fail("Service failed to load: " + component.errorString())
        root.writeResult()
        return
      }
      root.service = component.createObject(root, { manifest: { id: "omarchy.nightlight" } })
      if (!root.service) {
        root.fail("Service failed to instantiate: " + component.errorString())
        root.writeResult()
        return
      }

      root.run([
        root.wait(600),

        // Two quick toggles cancel out instead of collapsing into one flip.
        root.setScreen(6500),
        root.refreshed,
        function(next) {
          root.assertTrue(!root.service.enabled, "starts with night light off")
          root.service.toggle()
          root.service.toggle()
          next()
        },
        root.wait(800),
        root.withLog(function(lines) {
          root.assertTrue(root.sets(lines).length === 0, "a quick double toggle leaves the screen alone: " + lines.join(" | "))
        }),
        function(next) { root.assertTrue(!root.service.enabled, "a quick double toggle ends where it started"); next() },

        // A single toggle still flips from the fresh reading.
        root.setScreen(6500),
        function(next) { root.service.toggle(); next() },
        root.wait(800),
        root.withLog(function(lines) {
          root.assertTrue(root.indexOf(lines, "set 4000") >= 0, "a single toggle warms the screen: " + lines.join(" | "))
        }),

        // A preview still running when Save is pressed finishes before the
        // save restarts hyprsunset; previews during the save are ignored.
        root.setScreen(4000),
        root.refreshed,
        root.setControl("apply-delay", "0.5"),
        root.setControl("save-delay", "0.5"),
        root.setControl("save-exit", "0"),
        function(next) {
          root.assertTrue(root.service.enabled, "night light is on before the preview")
          root.service.previewWarmth(3000)
          next()
        },
        root.wait(100),
        function(next) {
          var started = root.service.saveConfig(false, "07:00", "20:00", 3000, function(ok, error) { root.lastSave = { ok: ok, error: error } })
          root.assertTrue(started, "save starts while a preview is in flight")
          root.assertTrue(root.service.saving, "service reports saving as soon as the save is asked for")
          root.service.previewWarmth(2600)
          next()
        },
        root.wait(1800),
        root.withLog(function(lines) {
          var applied = root.indexOf(lines, "set 3000")
          var saveStart = root.indexOf(lines, "save-start --keep-on off 07:00 20:00 3000")
          root.assertTrue(applied >= 0 && saveStart >= 0 && applied < saveStart, "the save waits for the running preview: " + lines.join(" | "))
          root.assertTrue(root.indexOf(lines, "set 2600") < 0, "a preview during the save never reaches hyprsunset: " + lines.join(" | "))
          var saveEnd = root.indexOf(lines, "save-end 0")
          for (var i = saveStart + 1; i < saveEnd; i++) {
            root.assertTrue(lines[i].indexOf("set ") !== 0 && lines[i] !== "get", "nothing talks to hyprsunset during the save: " + lines[i])
          }
        }),
        function(next) {
          root.assertTrue(root.lastSave && root.lastSave.ok === true, "the save reports success")
          root.assertTrue(!root.service.saving, "saving clears when the command exits")
          next()
        },

        // A toggle made while the save restarts hyprsunset is honored after it.
        root.setControl("apply-delay", "0"),
        root.setScreen(4000),
        root.refreshed,
        root.setControl("save-delay", "0.6"),
        function(next) {
          root.service.saveConfig(true, "07:00", "20:00", 3400, null)
          next()
        },
        root.wait(150),
        function(next) {
          root.service.toggle()
          root.assertTrue(!root.service.enabled, "a toggle during the save shows night light off at once")
          next()
        },
        root.wait(1400),
        root.withLog(function(lines) {
          var saveEnd = root.indexOf(lines, "save-end 0")
          var off = lines.lastIndexOf("set 6500")
          root.assertTrue(saveEnd >= 0 && off > saveEnd, "the toggle during the save turns night light off after it: " + lines.join(" | "))
        }),
        function(next) { root.assertTrue(!root.service.enabled, "night light stays off after the save"); next() },

        // A failed save reports its error to the caller.
        root.setScreen(6500),
        root.refreshed,
        root.setControl("save-delay", "0"),
        root.setControl("save-exit", "1"),
        function(next) {
          root.lastSave = null
          root.service.saveConfig(true, "07:00", "20:00", 3400, function(ok, error) { root.lastSave = { ok: ok, error: error } })
          next()
        },
        root.wait(800),
        function(next) {
          root.assertTrue(root.lastSave && root.lastSave.ok === false, "a failed save reports failure")
          root.assertTrue(root.lastSave && root.lastSave.error === "Could not write hyprsunset.conf", "a failed save passes on the command's error: " + JSON.stringify(root.lastSave))
          next()
        }
      ])
    }
  }
}
