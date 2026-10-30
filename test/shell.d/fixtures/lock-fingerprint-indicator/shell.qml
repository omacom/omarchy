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

        // Long passwords shrink the dots instead of clipping, and keep
        // shrinking as they grow; the fit itself is checked below against
        // the narrower width left beside the fingerprint icon.
        view.passwordText = "x".repeat(6)
        root.assertTrue(view.passwordDotScale === 1, "short passwords keep full-size dots, got scale " + view.passwordDotScale)

        view.passwordText = "x".repeat(40)
        var longScale = view.passwordDotScale
        root.assertTrue(longScale > 0 && longScale < 1, "overflowing passwords shrink the dots, got scale " + longScale)

        view.passwordText = "x".repeat(80)
        root.assertTrue(view.passwordDotScale < longScale, "dots keep shrinking as the password grows, got " + view.passwordDotScale + " vs " + longScale)

        var indicator = view.children ? findByObjectName(view, "fingerprintIndicator") : null
        root.assertTrue(indicator !== null, "fingerprint indicator exists in the lock view")

        if (indicator) {
          view.fingerprintConfigured = false
          root.assertTrue(!indicator.visible, "fingerprint indicator is hidden when no sensor is configured")

          view.fingerprintConfigured = true
          root.assertTrue(indicator.visible, "fingerprint indicator is shown when a sensor is configured")

          // The field reserves space for the icon so a long password can never
          // slide underneath it. The reserve must exceed the icon's own width
          // (leaving a gap), and the shrunk dots must fit the reserved-clear
          // area even at extreme lengths.
          root.assertTrue(view.fingerprintReserve > indicator.width,
            "reserved space exceeds the icon width, got reserve " + view.fingerprintReserve + " vs icon " + indicator.width)

          view.passwordText = "x".repeat(80)
          var clearWidth = view.fieldWidth - 2 * view.fingerprintReserve
          probe.font.pixelSize = Math.max(1, Math.floor(view.passwordDotFontSize * view.passwordDotScale))
          probe.font.letterSpacing = view.passwordDotLetterSpacing * view.passwordDotScale
          probe.text = "●".repeat(80)
          root.assertTrue(probe.advanceWidth <= clearWidth,
            "80 dots stay clear of the fingerprint icon, need " + probe.advanceWidth + "px of " + clearWidth)

          view.fingerprintConfigured = false
          root.assertTrue(view.fingerprintReserve === 0, "no space is reserved when no sensor is configured")

          view.fingerprintConfigured = true
          var workingGlyph = indicator.text
          var workingName = indicator.Accessible.name
          root.assertTrue(workingName.length > 0, "the available reader has an accessible label")
          view.fingerprintUnavailable = true
          root.assertTrue(indicator.visible, "an unavailable reader keeps its indicator")
          root.assertTrue(indicator.text !== workingGlyph, "the glyph distinguishes an unavailable reader")
          root.assertTrue(indicator.Accessible.name.length > 0 && indicator.Accessible.name !== workingName,
            "an unavailable reader has distinct accessible feedback")
          root.assertTrue(view.fingerprintReserve > 0, "space stays reserved for the unavailable reader")
          view.fingerprintUnavailable = false
          root.assertTrue(indicator.text === workingGlyph && indicator.Accessible.name === workingName,
            "the reader's glyph and accessible label recover together")
        }

        var input = findByObjectName(view, "passwordInput")
        var status = findByObjectName(view, "authenticationIndicator")
        var statusText = findByObjectName(view, "authenticationStatusText")
        root.assertTrue(statusText !== null, "readable status supplements the icons")
        root.assertTrue(input !== null && status !== null, "password input and status are accessible")
        if (input && status) {
          view.passwordText = ""
          view.passwordTextEdited.connect(function(value) { view.passwordText = value })
          view.clearFailureRequested.connect(function() { view.failureMessage = "" })
          var readyGlyph = status.text
          var readyName = status.Accessible.name
          root.assertTrue(input.Accessible.passwordEdit && input.Accessible.description.length > 0,
            "the password field keeps its protected accessible identity")
          view.authenticatingPassword = true
          root.assertTrue(status.text !== readyGlyph && status.Accessible.name !== readyName && !input.enabled,
            "checking is distinguishable while input is temporarily disabled")
          if (statusText) root.assertTrue(statusText.visible && statusText.text === status.Accessible.name,
            "checking remains visibly readable")
          view.passwordText = "fake-password-under-test"
          if (statusText) root.assertTrue(statusText.visible && statusText.text === status.Accessible.name && statusText.text.indexOf(view.passwordText) < 0,
            "a submitted nonempty password keeps checking feedback readable without exposing its contents")
          view.passwordText = ""
          view.authenticatingPassword = false
          view.failureMessage = "Authentication failed (2)"
          root.assertTrue(status.text !== readyGlyph && status.Accessible.name === view.failureMessage,
            "failure remains available to assistive technology")
          if (statusText) root.assertTrue(statusText.visible && statusText.text === view.failureMessage,
            "the failure and attempt count remain visibly readable")
          view.failureMessage = ""
          view.fingerprintUnavailable = true
          if (statusText) root.assertTrue(statusText.visible && statusText.text === indicator.Accessible.name,
            "the unavailable reader explanation remains visibly readable")
          view.fingerprintUnavailable = false
          view.failureMessage = "Authentication failed (2)"
          input.insert(0, "test")
          if (statusText) root.assertTrue(!statusText.visible, "typing hides the obsolete status text")
          root.assertTrue(view.passwordText === "test" && view.failureMessage === "" && !status.visible,
            "typing remains usable and replaces the failure indicator with password dots")
        }

        view.destroy()
      } catch (error) {
        root.fail("lock fingerprint indicator fixture threw: " + error)
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
