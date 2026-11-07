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

  function findByObjectName(item, name) {
    if (!item) return null
    if (item.objectName === name) return item
    var children = item.children || []
    for (var i = 0; i < children.length; i++) {
      var found = findByObjectName(children[i], name)
      if (found) return found
    }
    return null
  }

  function finish() {
    stepTimer.stop()
    if (view) view.destroy()
    writeResult()
  }

  // The view is created before the window is mapped, the way a lock surface
  // exists before the compositor hands it keyboard focus.
  FloatingWindow {
    id: win
    implicitWidth: 800
    implicitHeight: 600
    color: "black"

    Item {
      id: host
      anchors.fill: parent

      // Stands in for anything that takes focus away from the field.
      TextInput { id: decoy }
    }
  }

  property int waitedForWindow: 0

  // Each step steals focus from the password field, then the next step checks
  // the field took it back without a click.
  Timer {
    id: stepTimer
    interval: 200
    repeat: true
    onTriggered: {
      try {
        // Focus can only be judged while the window has keyboard focus; the
        // compositor may move it away mid-test, so wait for it to come back.
        if (!root.view.windowActive) {
          root.waitedForWindow += 1
          if (root.waitedForWindow < 25) return
          root.fail("test window never became active")
          root.finish()
          return
        }

        if (root.step === 0) {
          root.assertTrue(root.passwordInput.activeFocus, "password field has keyboard focus once the window is active")
          decoy.forceActiveFocus()
        } else if (root.step === 1) {
          root.assertTrue(root.passwordInput.activeFocus, "password field takes focus back after losing it")
          root.view.authenticatingPassword = true
        } else if (root.step === 2) {
          root.view.authenticatingPassword = false
        } else {
          root.assertTrue(root.passwordInput.activeFocus, "password field takes focus back after a password check")
          root.finish()
          return
        }
        root.step += 1
      } catch (error) {
        root.fail("lock password focus fixture threw: " + error)
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

        decoy.forceActiveFocus()
        root.view = component.createObject(host, { width: 800, height: 600, loadBackground: false, inputEnabled: true })
        if (!root.view) {
          root.fail("LockView failed to instantiate: " + component.errorString())
          root.writeResult()
          return
        }

        root.passwordInput = root.findByObjectName(root.view, "lockPasswordInput")
        if (!root.passwordInput) {
          root.fail("LockView has no lockPasswordInput")
          root.finish()
          return
        }

        stepTimer.start()
      } catch (error) {
        root.fail("lock password focus fixture threw: " + error)
        root.finish()
      }
    }
  }
}
