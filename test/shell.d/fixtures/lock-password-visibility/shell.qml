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

        // Service.qml wires the view's edits back into its passwordText, so the
        // clear and submit paths only re-mask through this loop. Without it the
        // view clears nothing and every assertion below would be vacuous.
        view.passwordTextEdited.connect(function(password) { view.passwordText = password })

        // The objectName is the handle the test wants the view to expose, but a
        // missing one must not skip the behaviour below it, so fall back to the
        // first item of the right type and say which lookup answered.
        var input = findByObjectName(view, "passwordInput")
        root.assertTrue(input !== null, "the password field exposes an objectName")

        if (!input) input = findFirstByTest(view, function(node) { return node instanceof TextInput })
        root.assertTrue(input !== null, "the password field exists in the lock view")

        if (input) {
          // omarchy display text size accepts 9 to 20, and the box narrows as
          // the icons scale with the font, so the largest size is the tight one.
          // Both font-size blocks below restore this when they are done.
          var originalBaseSize = Style.fontBaseSize

          // The reveal has to flip the mask and leave the text alone, otherwise
          // toggling it twice loses what was typed.
          view.passwordText = "hunter2"
          root.assertTrue(input.echoMode === TextInput.Password, "the field masks by default, got " + input.echoMode)

          view.passwordVisible = true
          root.assertTrue(input.echoMode === TextInput.Normal, "revealing switches the field to plain text, got " + input.echoMode)
          root.assertTrue(input.text === "hunter2", "revealing keeps the typed text, got " + input.text)

          view.passwordVisible = false
          root.assertTrue(input.echoMode === TextInput.Password, "re-masking restores the password echo mode, got " + input.echoMode)
          root.assertTrue(input.text === "hunter2", "re-masking keeps the typed text, got " + input.text)

          // The display blanks while a lock sits idle. A revealed password would
          // still be on screen when it wakes, so blanking has to re-mask, and
          // waking has to leave both the text and the mask alone.
          view.passwordText = "s3cret"
          view.passwordVisible = true
          view.displaysBlank = true
          root.assertTrue(view.passwordVisible === false, "a blanked display re-masks the password, got visible " + view.passwordVisible)

          view.displaysBlank = false
          root.assertTrue(view.passwordVisible === false, "waking the display does not re-reveal the password, got visible " + view.passwordVisible)
          root.assertTrue(view.passwordText === "s3cret", "blanking keeps what was typed, got " + JSON.stringify(view.passwordText))

          // Whatever clears the field re-masks, the submit path included: it
          // clears the text on the way out.
          view.passwordVisible = true
          view.passwordText = ""
          root.assertTrue(view.passwordVisible === false, "clearing the text re-masks, got visible " + view.passwordVisible)

          view.passwordText = "s3cret"
          view.passwordVisible = true
          view.clearPassword()
          root.assertTrue(view.passwordVisible === false, "clearPassword re-masks, got visible " + view.passwordVisible)

          // Mouse selection is the other half of the clipboard exposure, and
          // Qt copies a selection to the primary clipboard on mouse release.
          root.assertTrue(input.selectByMouse === false, "the field refuses mouse selection, got " + input.selectByMouse)

          // A revealed password renders at the field font size, so a long one
          // outgrows the box and only its middle stays on screen. It has to
          // shrink the way the dots do while masked, or the reveal is useless
          // for the long passphrases it exists to check. The largest display
          // text size is the tightest box, so measure there too.
          var plainSizes = [Style.font.baseSize, 20]
          for (var p = 0; p < plainSizes.length; p += 1) {
            Style.fontBaseSize = plainSizes[p]
            for (var length = 8; length <= 40; length += 8) {
              view.passwordText = "x".repeat(length)
              view.passwordVisible = true
              root.assertTrue(input.contentWidth <= input.width,
                "a revealed " + length + " character password fits the field at base size " + plainSizes[p]
                  + ", got " + input.contentWidth + "px of " + input.width)
            }
          }
          Style.fontBaseSize = originalBaseSize
          view.passwordVisible = false
          view.passwordText = ""

          // Qt only adds the sensitive-data hints itself while echoMode is not
          // Normal, so the property has to carry all three or the revealed mode
          // loses them. The binding is mode independent, so one check covers
          // both states.
          var requiredHints = Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
          root.assertTrue((input.inputMethodHints & requiredHints) === requiredHints,
            "the field keeps the sensitive-data hints, got " + input.inputMethodHints)

          // The icon reserve is symmetric, so the status line loses width on both
          // sides when a sensor is enrolled, and the message has to give up size
          // rather than let elide eat the attempt count. The box narrows further
          // as the display text size grows, because the icons scale with it, so
          // the largest supported size is the one that has to hold.
          // The message goes in before the lookup: the fallback identifies the
          // line by the text it renders.
          view.failureMessage = "Authentication failed (100)"
          var status = findByObjectName(view, "passwordStatusText")
          root.assertTrue(status !== null, "the status line exposes an objectName")

          if (!status) {
            // The status line is the only Text in the field rendering the
            // failure message, so its own text identifies it.
            status = findFirstByTest(view, function (node) {
              return node instanceof Text && node.text === view.failureMessage
            })
            root.assertTrue(status !== null, "the status line is identifiable by the text it renders")
          }

          if (status) {
            view.fingerprintConfigured = true
            var sizes = [originalBaseSize, 20]
            for (var i = 0; i < sizes.length; i += 1) {
              Style.fontBaseSize = sizes[i]
              root.assertTrue(!status.truncated,
                "the attempt count survives at base size " + sizes[i] + ", got elided at "
                  + status.font.pixelSize + "px of the field's " + view.fieldFontSize + "px")
              root.assertTrue(status.contentWidth <= status.width,
                "the failure message does not overflow the status line at base size " + sizes[i]
                  + ", got " + status.contentWidth + "px of " + status.width)
            }

            Style.fontBaseSize = originalBaseSize
            view.failureMessage = ""
            view.fingerprintConfigured = false
          }
        }

        view.destroy()
      } catch (error) {
        root.fail("lock password visibility fixture threw: " + error)
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

  function findFirstByTest(node, test) {
    if (!node) return null
    if (test(node)) return node
    var kids = node.children || []
    for (var i = 0; i < kids.length; i++) {
      var found = findFirstByTest(kids[i], test)
      if (found) return found
    }
    return null
  }
}
