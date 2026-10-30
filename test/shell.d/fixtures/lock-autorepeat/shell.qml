import QtQuick
import Quickshell
import Quickshell.Wayland
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

  PanelWindow {
    id: window
    width: 800
    height: 600
    color: "transparent"
    WlrLayershell.namespace: "omarchy-lock-autorepeat-test"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Item {
      id: host
      anchors.fill: parent

      TextInput {
        id: decoyFocusItem
        text: "decoy"
      }
    }
  }

  Timer {
    id: stepTimer
    interval: 100
    repeat: false
  }

  Timer {
    interval: 10
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

        var view = component.createObject(host, {
          width: 800,
          height: 600,
          loadBackground: false,
          inputEnabled: true
        })
        if (!view) {
          root.fail("LockView failed to instantiate: " + component.errorString())
          root.writeResult()
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

        // Wait for startup focus to settle, then verify focus recovery
        stepTimer.triggered.connect(function() {
          try {
            root.assertTrue(view.passwordActiveFocus, "password input gets active focus after startup settles")

            // Decoy steals focus away
            decoyFocusItem.forceActiveFocus()
            root.assertTrue(!view.passwordActiveFocus, "decoy takes active focus away from password input")

            // Remove decoy focus so window active focus falls back
            decoyFocusItem.focus = false

            stepTimer.triggered.disconnect(arguments.callee)
            stepTimer.triggered.connect(function() {
              try {
                root.assertTrue(view.passwordActiveFocus, "password input re-acquires active focus when window has no active focus item")
              } catch (e2) {
                root.fail("assertion step 2 failed: " + e2)
              } finally {
                view.destroy()
                root.writeResult()
              }
            })
            stepTimer.restart()
          } catch (e1) {
            root.fail("assertion step 1 failed: " + e1)
            view.destroy()
            root.writeResult()
          }
        })
        stepTimer.restart()
      } catch (error) {
        root.fail("lock autorepeat fixture threw: " + error)
        root.writeResult()
      }
    }
  }
}
