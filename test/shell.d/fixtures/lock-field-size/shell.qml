import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property int waited: 0

  function fail(message) {
    failures.push(String(message))
  }

  function assertEqual(actual, expected, message) {
    if (actual !== expected) fail(message + ": expected " + expected + ", got " + actual)
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

  function run() {
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

      // The test's shell.toml sets [lock] field-width = 300, field-height = 52.
      root.assertEqual(view.fieldWidth, 300, "field-width from shell.toml sizes the field")
      root.assertEqual(view.fieldHeight, 52, "field-height from shell.toml sizes the field")

      // Without the keys, the field keeps its original size.
      Commons.Color.shellValues = ({})
      root.assertEqual(view.fieldWidth, 381, "field keeps its default width without field-width")
      root.assertEqual(view.fieldHeight, 67, "field keeps its default height without field-height")

      view.destroy()
    } catch (error) {
      root.fail("lock field size fixture threw: " + error)
    } finally {
      root.writeResult()
    }
  }

  Item { id: host; width: 800; height: 600 }

  // Wait for Color to parse the test's shell.toml before building the view.
  Timer {
    interval: 50
    running: true
    repeat: true
    onTriggered: {
      root.waited += interval
      if (Commons.Color.shellValues["lock.field-width"] !== undefined || root.waited >= 4000) {
        stop()
        if (Commons.Color.shellValues["lock.field-width"] === undefined)
          root.fail("shell.toml [lock] values were never loaded")
        root.run()
      }
    }
  }
}
