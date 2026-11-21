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

        var dropped = [Qt.Key_A, Qt.Key_Z, Qt.Key_0, Qt.Key_Space, Qt.Key_Return, Qt.Key_Enter, Qt.Key_Escape]
        for (var i = 0; i < dropped.length; i++) {
          root.assertTrue(view.dropsAutoRepeat(dropped[i]), "auto-repeat of key " + dropped[i] + " is dropped")
        }

        var kept = [Qt.Key_Backspace, Qt.Key_Delete]
        for (var j = 0; j < kept.length; j++) {
          root.assertTrue(!view.dropsAutoRepeat(kept[j]), "auto-repeat of key " + kept[j] + " still edits the field")
        }

        view.destroy()

        // The screensaver behind the lock gives way on the release of the first
        // key, so a held wake key never repeats into the password field.
        var saverComponent = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/lock/ScreensaverView.qml", Component.PreferSynchronous)
        if (saverComponent.status !== Component.Ready) {
          root.fail("ScreensaverView failed to load: " + saverComponent.errorString())
          return
        }

        var saver = saverComponent.createObject(host, { width: 800, height: 600, active: true })
        var dismissals = 0
        saver.dismissed.connect(function() { dismissals++ })

        saver.pressKey(Qt.Key_A, false)
        saver.pressKey(Qt.Key_A, true)
        saver.releaseKey(Qt.Key_A, true)
        root.assertTrue(dismissals === 0, "a held wake key does not dismiss the screensaver")
        saver.pressKey(Qt.Key_B, false)
        saver.releaseKey(Qt.Key_B, false)
        root.assertTrue(dismissals === 0, "only the first key pressed dismisses the screensaver")
        saver.releaseKey(Qt.Key_A, false)
        root.assertTrue(dismissals === 1, "releasing the wake key dismisses the screensaver")

        saver.active = false
        saver.pressKey(Qt.Key_A, false)
        saver.releaseKey(Qt.Key_A, false)
        root.assertTrue(dismissals === 1, "keys do nothing while the screensaver is hidden")

        saver.destroy()
      } catch (error) {
        root.fail("lock autorepeat fixture threw: " + error)
      } finally {
        root.writeResult()
      }
    }
  }
}
