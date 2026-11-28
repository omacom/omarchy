import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons

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

          // An unreachable reader must announce itself instead of silently
          // inviting touches that can never unlock.
          view.fingerprintConfigured = true
          var notice = findByObjectName(view, "fingerprintUnavailableNotice")
          root.assertTrue(notice !== null, "unavailable notice exists in the lock view")

          if (notice) {
            var workingGlyph = indicator.text
            root.assertTrue(!notice.visible, "notice stays hidden while the reader works")

            view.fingerprintUnavailable = true
            root.assertTrue(notice.visible, "notice appears when the reader is unavailable")
            root.assertTrue(indicator.visible, "icon stays visible when the reader is unavailable")
            root.assertTrue(indicator.text !== workingGlyph, "icon crosses out when the reader is unavailable")
            root.assertTrue(view.fingerprintReserve > 0, "space stays reserved for the crossed-out icon")

            view.fingerprintUnavailable = false
            root.assertTrue(!notice.visible, "notice clears when the reader recovers")
            root.assertTrue(indicator.text === workingGlyph, "icon restores when the reader recovers")
          }

          // A reader matching a finger: the field says it is checking and the
          // icon breathes. The breath runs a few frames before it is stopped,
          // so its reset is checked on an icon it has really faded.
          root.checkScan(view, indicator)
          return
        }

        view.destroy()
        root.writeResult()
      } catch (error) {
        root.fail("lock fingerprint indicator fixture threw: " + error)
        root.writeResult()
      }
    }
  }

  property var scanView: null
  property var scanIndicator: null
  property var scanPulse: null
  property bool scanMotion: false

  // Animations are resources, not visual children, so this walks data.
  function findInData(node, name) {
    if (!node) return null
    if (node.objectName === name) return node
    var kids = node.data || node.children || []
    for (var i = 0; i < kids.length; i++) {
      var found = findInData(kids[i], name)
      if (found) return found
    }
    return null
  }

  function checkScan(view, indicator) {
    var pulse = findInData(indicator, "fingerprintPulse")
    var placeholder = findByObjectName(view, "passwordPlaceholder")
    root.assertTrue(pulse !== null && placeholder !== null, "the icon has its pulse and the field its prompt")
    if (!pulse || !placeholder) {
      view.destroy()
      root.writeResult()
      return
    }

    var prompt = placeholder.text
    var checking = I18n.t("lock.checking")
    root.assertTrue(prompt !== checking, "the field prompts for a password while nothing is checked")

    view.fingerprintConfigured = true
    view.fingerprintUnavailable = false
    root.assertTrue(!pulse.running, "the icon is still while no finger is on the reader")
    var restingColor = indicator.color
    // The palette comes from the theme, which this scratch home lacks; the
    // colours are compared only where the two differ.
    var coloredPalette = !Qt.colorEqual(Commons.Color.lock.text, Commons.Color.lock.placeholder)

    view.fingerprintScanning = true
    root.assertTrue(placeholder.text === checking, "the field says it is checking while the reader matches")
    if (coloredPalette) root.assertTrue(Qt.colorEqual(indicator.color, Commons.Color.lock.text), "the icon brightens while the reader matches")

    view.fingerprintScanning = false
    root.assertTrue(placeholder.text === prompt, "the field prompts for a password again once the scan ends")
    if (coloredPalette) root.assertTrue(Qt.colorEqual(indicator.color, restingColor), "the icon rests again once the scan ends")

    view.fingerprintScanning = true
    view.fingerprintConfigured = false
    root.assertTrue(!pulse.running, "nothing pulses without a reader to show")
    view.fingerprintConfigured = true
    view.fingerprintUnavailable = true
    root.assertTrue(!pulse.running, "the crossed-out icon of an unreachable reader never pulses")
    view.fingerprintUnavailable = false

    // `omarchy toggle animations` turns the shell's motion off; the field
    // still says it is checking.
    scanMotion = Style.reduceMotion
    Style.reduceMotion = true
    root.assertTrue(!pulse.running, "the pulse stays off with animations off")
    root.assertTrue(placeholder.text === checking, "the field still says it is checking with animations off")

    // A rejected finger: red, with one dip of the icon where animations run,
    // and the red alone where they don't. The red holds through the next scan.
    var dip = findInData(indicator, "fingerprintRejectDip")
    root.assertTrue(dip !== null, "the icon has its rejection dip")
    if (dip) {
      view.fingerprintScanning = false
      view.fingerprintRejected = true
      if (coloredPalette) root.assertTrue(Qt.colorEqual(indicator.color, Commons.Color.lock.textError), "the icon turns red for a rejected finger")
      root.assertTrue(!dip.running, "the dip stays off with animations off")
      root.assertTrue(placeholder.text === prompt, "a rejection leaves the field's prompt alone")
      view.fingerprintRejected = false
      if (coloredPalette) root.assertTrue(Qt.colorEqual(indicator.color, restingColor), "the icon rests again once the rejection passes")
      view.fingerprintScanning = true
    }

    Style.reduceMotion = false
    root.assertTrue(pulse.running, "the icon pulses while the reader matches")
    scanView = view
    scanIndicator = indicator
    scanPulse = pulse
    scanDip = dip
    pulseTimer.start()
  }

  property var scanDip: null

  // A few frames into the pulse the icon has faded; stopping the scan then
  // must draw it whole again, which only the animation's own reset does.
  Timer {
    id: pulseTimer
    interval: 160
    repeat: false
    onTriggered: {
      try {
        root.assertTrue(root.scanIndicator.opacity < 1, "the pulse has faded the icon, at opacity " + root.scanIndicator.opacity)
        root.scanView.fingerprintScanning = false
        root.assertTrue(!root.scanPulse.running, "the pulse stops with the scan")
        root.assertTrue(root.scanIndicator.opacity === 1, "the icon is drawn whole once the scan ends, at opacity " + root.scanIndicator.opacity)

        // With animations on, a rejection dips the icon once and holds the
        // breath for its moment, even with the next finger already matching.
        if (root.scanDip) {
          root.scanView.fingerprintRejected = true
          root.scanView.fingerprintRejectCount += 1
          root.assertTrue(root.scanDip.running, "a rejected finger dips the icon")
          dipTimer.start()
          return
        }
      } catch (error) {
        root.fail("lock fingerprint indicator fixture threw: " + error)
      }
      root.finishScan()
    }
  }

  Timer {
    id: dipTimer
    interval: 60
    repeat: false
    onTriggered: {
      try {
        root.assertTrue(root.scanIndicator.opacity < 1, "the dip has faded the icon, at opacity " + root.scanIndicator.opacity)
        root.scanView.fingerprintScanning = true
        root.assertTrue(root.scanDip.running, "a new scan leaves the dip to finish")
        root.assertTrue(!root.scanPulse.running, "and the breath waits for the rejection's moment to pass")
        root.scanView.fingerprintRejected = false
        root.assertTrue(root.scanPulse.running, "the breath takes over once the rejection passes")
        root.scanView.fingerprintScanning = false
        root.assertTrue(root.scanIndicator.opacity === 1, "the icon is drawn whole once both end, at opacity " + root.scanIndicator.opacity)

        // Back-to-back rejections: the red is still up when the next lands.
        root.scanView.fingerprintRejected = true
        root.scanView.fingerprintRejectCount += 1
        againTimer.start()
        return
      } catch (error) {
        root.fail("lock fingerprint indicator fixture threw: " + error)
      }
      root.finishScan()
    }
  }

  Timer {
    id: againTimer
    interval: 450
    repeat: false
    onTriggered: {
      try {
        root.assertTrue(!root.scanDip.running && root.scanView.fingerprintRejected, "the first dip has ended with the red still up")
        root.scanView.fingerprintRejectCount += 1
        root.assertTrue(root.scanDip.running, "a second rejection while the red still shows dips again")
        root.scanDip.stop()
        root.scanView.fingerprintRejected = false
        root.assertTrue(root.scanIndicator.opacity === 1, "the icon is drawn whole once the red passes, at opacity " + root.scanIndicator.opacity)

        // The breath handing over to a rejection's dip.
        root.scanView.fingerprintScanning = true
        handoverTimer.start()
        return
      } catch (error) {
        root.fail("lock fingerprint indicator fixture threw: " + error)
      }
      root.finishScan()
    }
  }

  Timer {
    id: handoverTimer
    interval: 160
    repeat: false
    onTriggered: {
      try {
        root.assertTrue(root.scanIndicator.opacity < 1, "the breath has faded the icon, at opacity " + root.scanIndicator.opacity)
        root.scanView.fingerprintRejected = true
        root.scanView.fingerprintRejectCount += 1
        root.assertTrue(!root.scanPulse.running && root.scanDip.running, "a rejection mid-breath hands over to the dip")
        root.assertTrue(root.scanIndicator.opacity < 1, "the handover doesn't flash the icon whole, at opacity " + root.scanIndicator.opacity)
        root.scanDip.stop()
        root.scanView.fingerprintScanning = false
        root.scanView.fingerprintRejected = false
        root.assertTrue(root.scanIndicator.opacity === 1, "the icon is drawn whole once it all ends, at opacity " + root.scanIndicator.opacity)
      } catch (error) {
        root.fail("lock fingerprint indicator fixture threw: " + error)
      }
      root.finishScan()
    }
  }

  function finishScan() {
    Style.reduceMotion = root.scanMotion
    root.scanView.destroy()
    root.writeResult()
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
