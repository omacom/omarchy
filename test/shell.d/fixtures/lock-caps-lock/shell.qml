import QtQuick
import Quickshell

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

        var notice = findByObjectName(view, "capsLockNotice")
        root.assertTrue(notice !== null, "caps lock notice exists in the lock view")

        if (notice) {
          root.assertTrue(!notice.visible, "notice is hidden while Caps Lock is off")

          var icon = findByObjectName(view, "capsLockIndicator")
          root.assertTrue(icon !== null && !icon.visible, "icon is hidden while Caps Lock is off")
          root.assertTrue(view.iconReserve === 0, "no icon space is reserved while Caps Lock is off")

          view.capsLockOn = true
          root.assertTrue(notice.visible, "notice appears when Caps Lock is on")
          root.assertTrue(icon !== null && icon.visible, "icon appears when Caps Lock is on")
          root.assertTrue(view.iconReserve > (icon ? icon.width : 0), "dots keep clear of the icon")

          // The preview cannot take a password, so it has nothing to warn about.
          view.inputEnabled = false
          root.assertTrue(!notice.visible, "notice is hidden when the field takes no input")
          view.inputEnabled = true

          // Both notices can show at once and must not overlap.
          view.fingerprintConfigured = true
          view.fingerprintUnavailable = true
          var fingerprintNotice = findByObjectName(view, "fingerprintUnavailableNotice")
          root.assertTrue(fingerprintNotice !== null && fingerprintNotice.visible, "fingerprint notice shows alongside")
          if (fingerprintNotice) {
            // Column positions its children on the next polish; settle it now.
            notice.parent.forceLayout()
            var capsBox = notice.mapToItem(view, 0, 0, notice.width, notice.height)
            var fingerprintBox = fingerprintNotice.mapToItem(view, 0, 0, fingerprintNotice.width, fingerprintNotice.height)
            root.assertTrue(capsBox.y + capsBox.height <= fingerprintBox.y || fingerprintBox.y + fingerprintBox.height <= capsBox.y,
              "caps lock and fingerprint notices do not overlap")
          }

          view.capsLockOn = false
          root.assertTrue(!notice.visible, "notice clears when Caps Lock turns off")
        }

        view.destroy()
      } catch (error) {
        root.fail("lock caps lock fixture threw: " + error)
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
