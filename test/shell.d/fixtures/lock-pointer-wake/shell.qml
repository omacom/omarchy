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
        var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/lock/LockView.qml", Component.PreferSynchronous)
        if (component.status !== Component.Ready) {
          root.fail("LockView failed to load: " + component.errorString())
          return
        }

        var view = component.createObject(host, { width: 800, height: 600, loadBackground: false })
        if (!view) {
          root.fail("LockView failed to instantiate: " + component.errorString())
          return
        }

        var wakes = 0
        view.wakeRequested.connect(function() { wakes++ })
        function moveTo(x, y) {
          var before = wakes
          view.pointerMoved(x, y)
          return wakes > before
        }

        // A surface mapped under the pointer reports where it rests, not motion.
        root.assertTrue(!moveTo(400, 300), "first position on a new surface does not wake")
        root.assertTrue(!moveTo(400, 300), "a repeated resting position does not wake")
        root.assertTrue(!moveTo(400.4, 300.2), "sub-pixel jitter does not wake")
        root.assertTrue(moveTo(410, 300), "moving the pointer wakes")

        // Slow motion on a scaled display arrives in sub-pixel steps that add up.
        root.assertTrue(!moveTo(410.4, 300), "the first sub-pixel step does not wake")
        root.assertTrue(!moveTo(410.8, 300), "the second sub-pixel step does not wake")
        root.assertTrue(moveTo(411.2, 300), "sub-pixel steps adding up to a pixel wake")

        // Leaving and re-entering, as across a hotplug, starts over.
        view.pointerLeft()
        root.assertTrue(!moveTo(20, 20), "first position after re-entering does not wake")
        root.assertTrue(moveTo(20, 30), "moving after re-entering wakes")

        view.destroy()
      } catch (error) {
        root.fail("lock pointer wake fixture threw: " + error)
      } finally {
        root.writeResult()
      }
    }
  }
}
