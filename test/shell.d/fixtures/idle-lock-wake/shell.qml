import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string lockModePath: Quickshell.env("IDLE_LOCK_WAKE_MODE")
  property var failures: []
  property var idle: null
  property int phase: -1
  property int polls: 0
  property bool wakeSettled: false

  // The wake asks the compositor helper at wake time, so the fixture flips the
  // stubbed answer on PATH between drives of the real service. Locked skips
  // the wake; unlocked and undetermined run it, exactly as before.
  readonly property var phases: [
    { mode: "locked", lastEvent: "wake-skipped: session-locked" },
    { mode: "unlocked", lastEvent: "process-exit: wake exitCode=0 status=0" },
    { mode: "undetermined", lastEvent: "process-exit: wake exitCode=0 status=0" }
  ]

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

  function finish() {
    phase = -1
    writeResult()
  }

  QtObject {
    id: fakeShell
    property var shellConfig: ({ idle: { screensaver: 86400, lock: 86400 } })
  }

  Item { id: host }

  // The stubbed helper reads its answer from the mode file, so writing the
  // file is the only way to flip it once the service is running.
  Process {
    id: modeWriter
    property int pendingPhase: -1
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.fail("mode writer exited " + exitCode)
        root.finish()
        return
      }
      root.phase = pendingPhase
      // Day-long timeouts keep the real monitor from ever firing; drive the
      // path its "active" signal takes, with a cycle the service started.
      root.idle.idledThisCycle = true
      root.idle.handleActiveSignal()
      root.polls = 0
      root.wakeSettled = false
    }
  }

  function startPhase(index) {
    phase = -1
    modeWriter.pendingPhase = index
    modeWriter.command = ["bash", "-c", "printf %s " + shellQuote(phases[index].mode) + " > " + shellQuote(lockModePath)]
    modeWriter.running = true
  }

  function nextPhase() {
    var next = phase + 1
    if (next >= phases.length) {
      finish()
      return
    }
    startPhase(next)
  }

  Timer {
    interval: 50
    repeat: true
    running: true
    onTriggered: {
      if (root.phase < 0 || !root.idle) return

      var status
      try {
        status = JSON.parse(root.idle.statusJson())
      } catch (error) {
        root.fail("statusJson threw: " + error)
        root.finish()
        return
      }

      if (status.processes.wake) {
        if (++root.polls < 200) return
        root.fail("the wake process did not exit in phase " + root.phase + " (" + root.phases[root.phase].mode + ")")
        root.finish()
        return
      }

      // Give the exit handler one tick to land before reading its event.
      if (!root.wakeSettled) {
        root.wakeSettled = true
        return
      }

      var expected = root.phases[root.phase]
      root.assertTrue(status.lastEvent === expected.lastEvent,
        "phase " + root.phase + " (" + expected.mode + ") ended on " + status.lastEvent + ", wanted " + expected.lastEvent)
      root.assertTrue(!status.inIdleCycle,
        "phase " + root.phase + " (" + expected.mode + ") still ends the idle cycle")

      root.nextPhase()
    }
  }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      try {
        var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/services/idle/Service.qml", Component.PreferSynchronous)
        if (component.status !== Component.Ready) {
          root.fail("idle service failed to load: " + component.errorString())
          root.finish()
          return
        }

        root.idle = component.createObject(host, { shell: fakeShell })
        if (!root.idle) {
          root.fail("idle service failed to instantiate: " + component.errorString())
          root.finish()
          return
        }

        root.startPhase(0)
      } catch (error) {
        root.fail("idle lock wake fixture threw: " + error)
        root.finish()
      }
    }
  }
}
