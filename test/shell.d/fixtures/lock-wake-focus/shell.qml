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
    WlrLayershell.namespace: "omarchy-lock-test"
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
    interval: 50
    repeat: false
  }

  Timer {
    interval: 50
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
          "anchors.fill": host,
          loadBackground: false,
          inputEnabled: true,
          displaysBlank: false
        })
        if (!view) {
          root.fail("LockView failed to instantiate: " + component.errorString())
          root.writeResult()
          return
        }

        // Wait for initial startup focus to settle
        stepTimer.triggered.connect(function() {
          try {
            root.assertTrue(view.passwordActiveFocus, "password input gets initial focus upon load")

            // Give decoy focus and blank the displays
            view.displaysBlank = true
            decoyFocusItem.forceActiveFocus()
            root.assertTrue(!view.passwordActiveFocus, "decoy takes active focus away from password input")

            // Wait a turn with displaysBlank=true, then unblank (wake)
            stepTimer.triggered.disconnect(arguments.callee)
            stepTimer.triggered.connect(function() {
              try {
                // Wake the displays
                view.displaysBlank = false

                // In the next turn, check that wake restored password focus
                stepTimer.triggered.disconnect(arguments.callee)
                stepTimer.triggered.connect(function() {
                  try {
                    root.assertTrue(view.passwordActiveFocus, "password input re-acquires active focus when displays unblank on wake")
                  } catch (e3) {
                    root.fail("assertion step 3 failed: " + e3)
                  } finally {
                    view.destroy()
                    root.writeResult()
                  }
                })
                stepTimer.restart()
              } catch (e2) {
                root.fail("assertion step 2 failed: " + e2)
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
        root.fail("lock wake focus fixture threw: " + error)
        root.writeResult()
      }
    }
  }
}
