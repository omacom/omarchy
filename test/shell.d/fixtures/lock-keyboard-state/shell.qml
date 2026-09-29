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

  function labels(view) {
    return view.stateBadges.map(function(badge) { return badge.label }).join(",")
  }

  // The lock view only reads key, nativeScanCode and modifiers off an event.
  function keyEvent(key, scanCode, modifiers) {
    return { key: key, nativeScanCode: scanCode, modifiers: modifiers }
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

        var row = findByObjectName(view, "keyboardStateBadges")
        root.assertTrue(row !== null, "keyboard state badge row exists in the lock view")

        if (row) {
          root.assertTrue(!row.visible, "no badge shows in the quiet state")
          root.assertTrue(row.y + row.height < view.height / 2,
            "badges sit above the password field, got bottom " + (row.y + row.height) + " of " + view.height)

          view.capsLockOn = true
          root.assertTrue(row.visible && labels(view) === "CAPS LOCK", "Caps Lock shows its badge, got " + labels(view))

          view.numLockOn = false
          root.assertTrue(labels(view) === "CAPS LOCK,NUM LOCK OFF", "Num Lock off adds its badge, got " + labels(view))

          view.layoutLabel = "Danish"
          root.assertTrue(labels(view).indexOf("DANISH") !== -1, "a non-default layout is named, got " + labels(view))

          view.capsLockOn = false
          view.numLockOn = true
          view.layoutLabel = ""
          root.assertTrue(!row.visible, "badges clear with the state")

          // Held modifiers come from the view's own key events, identified by
          // xkb keycode. Left Shift is keycode 50; its release must clear the
          // badge even when Qt reports the key as Caps Lock with Shift still
          // set, which shift:both_capslock_cancel produces.
          view.trackModifiers(keyEvent(Qt.Key_Shift, 50, Qt.ShiftModifier), true)
          root.assertTrue(labels(view) === "SHIFT", "a held Shift shows its badge, got " + labels(view))

          view.trackModifiers(keyEvent(Qt.Key_CapsLock, 50, Qt.ShiftModifier), false)
          root.assertTrue(!row.visible, "a Shift release reported as Caps Lock still clears the badge, got " + labels(view))

          view.trackModifiers(keyEvent(Qt.Key_Control, 37, Qt.ControlModifier), true)
          view.trackModifiers(keyEvent(Qt.Key_Alt, 64, Qt.ControlModifier | Qt.AltModifier), true)
          root.assertTrue(labels(view) === "CTRL,ALT", "held Ctrl and Alt both show, got " + labels(view))

          // An ordinary key carries the true modifier state and resyncs.
          view.trackModifiers(keyEvent(Qt.Key_A, 38, 0), true)
          root.assertTrue(!row.visible, "an unmodified keypress clears stale modifier badges, got " + labels(view))

          view.trackModifiers(keyEvent(Qt.Key_Meta, 133, Qt.MetaModifier), true)
          root.assertTrue(labels(view) === "SUPER", "a held Super shows its badge, got " + labels(view))
          view.trackModifiers(keyEvent(Qt.Key_Meta, 133, 0), false)
          root.assertTrue(!row.visible, "a Super release clears its badge")

          // Right Alt is keycode 108 either way, but where the layout makes it
          // AltGr it types characters and Qt reports it without Alt set.
          view.trackModifiers(keyEvent(Qt.Key_Alt, 108, Qt.AltModifier), true)
          root.assertTrue(labels(view) === "ALT", "a held Right Alt shows its badge, got " + labels(view))
          view.trackModifiers(keyEvent(Qt.Key_Alt, 108, 0), false)

          view.trackModifiers(keyEvent(Qt.Key_AltGr, 108, 0), true)
          root.assertTrue(!row.visible, "holding AltGr raises no ALT warning, got " + labels(view))
          view.trackModifiers(keyEvent(Qt.Key_AltGr, 108, 0), false)
        }

        view.destroy()
      } catch (error) {
        root.fail("lock keyboard state fixture threw: " + error)
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
