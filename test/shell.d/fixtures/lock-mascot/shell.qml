import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root
  property var failures: []
  property var view: null
  property var mascot: null
  property int step: 0

  function check(value, message) {
    if (!value) failures.push(message)
  }

  function find(node, name) {
    if (node.objectName === name) return node
    var children = node.children || []
    for (var i = 0; i < children.length; i++) {
      var result = find(children[i], name)
      if (result) return result
    }
    return null
  }

  function finish() {
    var result = JSON.stringify({ ok: failures.length === 0, failures: failures })
    Quickshell.execDetached(["bash", "-c", "printf '%s' \"$1\" > \"$2\"", "_", result, Quickshell.env("OMARCHY_QML_TEST_RESULT")])
    runner.stop()
  }

  Item { id: host; width: 800; height: 600 }

  Timer {
    id: runner
    interval: 150
    running: true
    repeat: true
    onTriggered: {
      try {
        switch (root.step++) {
        case 0:
          var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/lock/LockView.qml", Component.PreferSynchronous)
          if (component.status !== Component.Ready) throw new Error(component.errorString())
          root.view = component.createObject(host, { width: 800, height: 600, loadBackground: true })
          if (!root.view) throw new Error(component.errorString())
          break
        case 1:
          root.mascot = root.find(root.view, "lockMascot")
          if (!root.mascot) throw new Error("mascot missing")
          root.check(!root.mascot.eyesClosed, "eyes start open")
          root.view.passwordText = "fixture only"
          break
        case 2:
          root.check(root.mascot.eyesClosed, "eyes close with password present")
          root.view.passwordText = ""
          root.view.authenticatingPassword = true
          break
        case 3:
          root.check(root.mascot.eyesClosed, "eyes remain closed while checking")
          root.view.authenticatingPassword = false
          root.view.failureMessage = "Authentication failed (1)"
          root.view.failedAttempts = 1
          break
        case 4:
          root.check(!root.mascot.eyesClosed, "eyes reopen after failure")
          root.check(root.mascot.color.toString() === Color.lock.textError.toString(), "failure uses error color")
          root.view.displaysBlank = true
          break
        case 5:
          root.check(!root.mascot.animate && root.mascot.bob === 0 && root.mascot.shake === 0, "blanking stops and resets motion")
          root.view.displaysBlank = false
          root.view.powerSaverActive = true
          break
        case 6:
          root.check(!root.mascot.animate, "power saving stops motion")
          root.view.powerSaverActive = false
          Style.reduceMotion = true
          break
        case 7:
          root.check(!root.mascot.animate, "reduced motion stops animation")
          root.view.failureMessage = ""
          root.view.failedAttempts = 0
          root.view.passwordText = ""
          root.check(root.mascot.color.toString() === Color.accent.toString(), "normal state follows accent")
          root.view.height = 180
          break
        case 8:
          root.check(root.find(root.view, "lockMascot") === null, "small output omits decoration")
          root.view.height = 600
          break
        case 9:
          root.check(root.find(root.view, "lockMascot") !== null, "decoration returns when space permits")
          root.view.loadBackground = false
          break
        case 10:
          root.check(root.find(root.view, "lockMascot") === null, "unlocked view unloads decoration")
          root.view.destroy()
          root.finish()
        }
      } catch (error) {
        root.failures.push(String(error))
        root.finish()
      }
    }
  }
}
