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

  // A real key event needs a focused window, which this fixture has none of,
  // so hand the view's key handler the fields it reads. Returns whether the
  // key was consumed.
  function pressKey(view, key, modifiers) {
    var event = { key: key, modifiers: modifiers, isAutoRepeat: false, accepted: false }
    view.handlePasswordKey(event)
    return event.accepted
  }

  // The 4px matches the slack revealedTextScale leaves inside the input.
  function assertRevealedTextFits(input, context) {
    probe.font.pixelSize = input.font.pixelSize
    probe.font.letterSpacing = input.font.letterSpacing
    probe.text = input.text
    assertTrue(probe.advanceWidth <= input.width - 4,
      "revealed text fits inside the input " + context + ", need " + probe.advanceWidth + "px of " + (input.width - 4))
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

  TextMetrics {
    id: probe
    font.family: Style.font.family
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
          return
        }

        var view = component.createObject(host, { width: 800, height: 600, loadBackground: false })
        if (!view) {
          root.fail("LockView failed to instantiate: " + component.errorString())
          return
        }

        var toggle = findByObjectName(view, "passwordRevealMouseArea")
        root.assertTrue(toggle !== null, "reveal toggle mouse area exists in the lock view")
        var input = findByObjectName(view, "passwordInput")
        root.assertTrue(input !== null, "password input exists in the lock view")

        // Empty-field no-op: neither entry point can arm a reveal with
        // nothing typed yet.
        root.assertTrue(!view.passwordRevealed, "starts hidden")
        root.assertTrue(input.echoMode === TextInput.Password, "starts masked")
        root.assertTrue(toggle && !toggle.enabled, "reveal toggle is disabled while the field is empty")
        root.assertTrue(root.pressKey(view, Qt.Key_Space, Qt.ControlModifier), "Ctrl+Space is consumed on an empty field")
        root.assertTrue(!view.passwordRevealed, "Ctrl+Space on an empty field is a no-op, mirroring the disabled mouse button")

        // Each entry point is driven through its own handler, and checked
        // against the field's echoMode rather than the passwordRevealed flag,
        // so a broken handler or a field that stays masked both fail here.
        view.passwordText = "hunter2"
        root.assertTrue(toggle && toggle.enabled, "reveal toggle is enabled once there is text")

        toggle.clicked(null)
        root.assertTrue(input.echoMode === TextInput.Normal, "clicking the toggle shows the password in plain text")
        toggle.clicked(null)
        root.assertTrue(input.echoMode === TextInput.Password, "clicking the toggle again masks the password")

        root.assertTrue(root.pressKey(view, Qt.Key_Space, Qt.ControlModifier), "Ctrl+Space is consumed")
        root.assertTrue(input.echoMode === TextInput.Normal, "Ctrl+Space shows the password in plain text")
        root.pressKey(view, Qt.Key_Space, Qt.ControlModifier)
        root.assertTrue(input.echoMode === TextInput.Password, "Ctrl+Space again masks the password")

        root.assertTrue(!root.pressKey(view, Qt.Key_Space, Qt.ControlModifier | Qt.ShiftModifier), "Ctrl+Shift+Space is left alone")
        root.assertTrue(!root.pressKey(view, Qt.Key_Space, Qt.NoModifier), "a plain space is left to be typed")
        root.assertTrue(input.echoMode === TextInput.Password, "only the exact Ctrl+Space chord toggles the reveal")

        // Reset on clear/submit: both the clear shortcuts (Escape, Ctrl+U)
        // and a submit funnel through passwordTextEdited("") externally,
        // which round-trips back into passwordText -- exactly what this
        // reproduces directly.
        toggle.clicked(null)
        root.assertTrue(input.echoMode === TextInput.Normal, "revealed before the field is cleared")
        view.passwordText = ""
        root.assertTrue(!view.passwordRevealed, "clearing the field resets reveal state, so the next attempt starts masked")
        root.assertTrue(input.echoMode === TextInput.Password, "a cleared field is masked again")

        // Revealed-text overflow: a long revealed password must still be
        // clamped to the room the input actually has, which is the field
        // minus its borders, padding, and the icons reserved on both sides.
        view.passwordText = "x".repeat(80)
        toggle.clicked(null)
        root.assertTrue(view.revealedTextScale < 1, "an 80-char revealed password shrinks to fit, got scale " + view.revealedTextScale)
        root.assertRevealedTextFits(input, "without a fingerprint icon")

        var widthWithoutFingerprint = input.width
        view.fingerprintConfigured = true
        root.assertTrue(input.width < widthWithoutFingerprint,
          "the fingerprint icon narrows the input, got " + input.width + "px vs " + widthWithoutFingerprint)
        root.assertRevealedTextFits(input, "next to the fingerprint icon")

        view.destroy()
      } catch (error) {
        root.fail("lock password reveal fixture threw: " + error)
      } finally {
        root.writeResult()
      }
    }
  }

  function findByObjectName(node, name) {
    if (!node) return null
    if (node.objectName === name) return node
    var kids = node.children || []
    for (var i = 0; i < kids.length; i++) {
      var found = findByObjectName(kids[i], name)
      if (found) return found
    }
    return null
  }
}
