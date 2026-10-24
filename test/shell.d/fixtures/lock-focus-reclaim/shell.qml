import QtQuick
import Quickshell

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var lockView: null
  property var previewView: null
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

  function focusName(window) {
    var item = window.activeFocusItem
    return item ? (item.objectName || String(item)) : "none"
  }

  function passwordFocused(window) {
    var item = window.activeFocusItem
    return !!item && item.objectName === "lockPasswordInput"
  }

  // QQuickWindow::focusOutEvent does exactly this when Qt loses its focus
  // window, which is what happens to the lock surface when the compositor's
  // keyboard goes away across a suspend.
  function dropWindowFocus(window) {
    window.contentItem.focus = false
  }

  // Never shown: with no focus window in this process, Qt treats every window
  // as focusable, the same state the lock surface is left in after resume.
  Window { id: lockWindow; visible: false; width: 800; height: 600 }
  Window { id: previewWindow; visible: false; width: 800; height: 600 }

  Timer {
    interval: 50
    running: true
    repeat: true
    onTriggered: {
      try {
        if (root.step === 0) {
          var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/lock/LockView.qml", Component.PreferSynchronous)
          if (component.status !== Component.Ready) {
            root.fail("LockView failed to load: " + component.errorString())
            root.step = -1
            return
          }

          root.lockView = component.createObject(lockWindow.contentItem, { width: 800, height: 600, loadBackground: false, inputEnabled: true })
          root.previewView = component.createObject(previewWindow.contentItem, { width: 800, height: 600, loadBackground: false, inputEnabled: false })
          if (!root.lockView || !root.previewView) {
            root.fail("LockView failed to instantiate: " + component.errorString())
            root.step = -1
            return
          }
        } else if (root.step === 1) {
          root.assertTrue(root.passwordFocused(lockWindow), "password field takes focus when the lock appears, got " + root.focusName(lockWindow))

          root.dropWindowFocus(lockWindow)
          root.assertTrue(!lockWindow.activeFocusItem, "dropping window focus clears the password field's focus, got " + root.focusName(lockWindow))

          root.dropWindowFocus(previewWindow)
        } else if (root.step === 2) {
          root.assertTrue(root.passwordFocused(lockWindow), "password field takes focus back after the window loses it, got " + root.focusName(lockWindow))
          root.assertTrue(!root.passwordFocused(previewWindow), "preview never takes focus for its disabled field, got " + root.focusName(previewWindow))

          // A password check disables the field; Qt parks focus on the window
          // and hands it back when the field is enabled again.
          root.lockView.authenticatingPassword = true
        } else if (root.step === 3) {
          root.assertTrue(!root.passwordFocused(lockWindow), "a disabled field does not hold focus, got " + root.focusName(lockWindow))
          root.lockView.authenticatingPassword = false
        } else if (root.step === 4) {
          root.assertTrue(root.passwordFocused(lockWindow), "password field has focus again after a failed check, got " + root.focusName(lockWindow))
          root.step = -1
          return
        }

        root.step += 1
      } catch (error) {
        root.fail("lock focus reclaim fixture threw: " + error)
        root.step = -1
      } finally {
        if (root.step === -1) {
          running = false
          if (root.lockView) root.lockView.destroy()
          if (root.previewView) root.previewView.destroy()
          root.writeResult()
        }
      }
    }
  }
}
