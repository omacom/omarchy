import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var view: null
  property var passwordInput: null
  property int step: 0
  property int waitedForWindow: 0

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

  function findPasswordInput(item) {
    if (!item) return null
    if (item.echoMode === TextInput.Password) return item
    var children = item.children || []
    for (var i = 0; i < children.length; i++) {
      var found = findPasswordInput(children[i])
      if (found) return found
    }
    return null
  }

  function finish() {
    stepTimer.stop()
    if (view) view.destroy()
    writeResult()
  }

  // A real window, because an item outside one never gets active focus and so
  // never loses it.
  FloatingWindow {
    id: win
    implicitWidth: 800
    implicitHeight: 600
    color: "black"

    Item {
      id: host
      anchors.fill: parent

      readonly property bool windowActive: Window.active

      // Stands in for anything else on the surface that takes focus.
      TextInput { id: decoy }
    }
  }

  // Each step takes focus from the password field, and the next checks that
  // the field took it back without a click.
  Timer {
    id: stepTimer
    interval: 200
    repeat: true
    onTriggered: {
      try {
        // Focus is only judged while the window holds the keyboard; the
        // compositor may take it away mid-test, so wait for it to come back.
        if (!host.windowActive) {
          root.waitedForWindow += 1
          if (root.waitedForWindow < 25) return
          root.fail("test window never became active")
          root.finish()
          return
        }

        if (root.step === 0) {
          root.assertTrue(root.passwordInput.activeFocus, "password field has focus once the window is active")
          decoy.forceActiveFocus()
        } else if (root.step === 1) {
          root.assertTrue(root.passwordInput.activeFocus, "password field takes focus back from another item")
          // What resume does: focus falls back to the surface's own item.
          host.forceActiveFocus()
        } else if (root.step === 2) {
          root.assertTrue(root.passwordInput.activeFocus, "password field takes focus back when it is dropped")
          root.view.authenticatingPassword = true
        } else if (root.step === 3) {
          root.view.authenticatingPassword = false
        } else if (root.step === 4) {
          root.assertTrue(root.passwordInput.activeFocus, "password field has focus after a password check")
          root.view.authenticatingPassword = true
        } else if (root.step === 5) {
          // Focus moves once the check is under way, as when resume lands during it.
          host.forceActiveFocus()
        } else if (root.step === 6) {
          root.view.authenticatingPassword = false
        } else if (root.step === 7) {
          root.assertTrue(root.passwordInput.activeFocus, "password field takes focus back after it was dropped during a password check")
          root.view.authenticatingPassword = true
        } else if (root.step === 8) {
          decoy.forceActiveFocus()
        } else if (root.step === 9) {
          root.view.authenticatingPassword = false
        } else if (root.step === 10) {
          root.assertTrue(root.passwordInput.activeFocus, "password field takes focus back after another item took it during a password check")
          // The preview surface builds the same view with input disabled.
          root.view.inputEnabled = false
          decoy.forceActiveFocus()
        } else {
          root.assertTrue(decoy.activeFocus, "password field leaves focus alone while input is disabled")
          root.finish()
          return
        }
        root.step += 1
      } catch (error) {
        root.fail("lock focus recovery fixture threw: " + error)
        root.finish()
      }
    }
  }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      try {
        var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/lock/LockView.qml", Component.PreferSynchronous)
        if (component.status !== Component.Ready) {
          root.fail("LockView failed to load: " + component.errorString())
          root.writeResult()
          return
        }

        root.view = component.createObject(host, { width: 800, height: 600, loadBackground: false, inputEnabled: true })
        if (!root.view) {
          root.fail("LockView failed to instantiate: " + component.errorString())
          root.writeResult()
          return
        }

        root.passwordInput = root.findPasswordInput(root.view)
        if (!root.passwordInput) {
          root.fail("LockView has no password field")
          root.finish()
          return
        }

        stepTimer.start()
      } catch (error) {
        root.fail("lock focus recovery fixture threw: " + error)
        root.finish()
      }
    }
  }
}
