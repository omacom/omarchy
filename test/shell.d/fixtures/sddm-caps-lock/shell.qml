import QtQuick
import Quickshell

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string themePath: Quickshell.env("OMARCHY_SDDM_THEME_QML")
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
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  function findByObjectName(item, name) {
    if (item.objectName === name) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findByObjectName(item.children[i], name)
      if (found) return found
    }
    return null
  }

  // The greeter hands the theme these as context properties; the theme reads
  // them by name, so a created object finds them here.
  QtObject {
    id: keyboard
    property bool capsLock: false
  }

  QtObject {
    id: sddm
    signal loginFailed()
    signal loginSucceeded()
    function login() {}
  }

  QtObject {
    id: userModel
    property string lastUser: "sd"
  }

  QtObject {
    id: sessionModel
    property int lastIndex: 0
    function rowCount() { return 0 }
  }

  Item { id: host; width: 800; height: 600 }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      try {
        var component = Qt.createComponent("file://" + root.themePath, Component.PreferSynchronous)
        if (component.status !== Component.Ready) {
          root.fail("SDDM theme failed to load: " + component.errorString())
          return
        }

        var theme = component.createObject(host, { width: 1024, height: 768 })
        if (!theme) {
          root.fail("SDDM theme failed to instantiate: " + component.errorString())
          return
        }

        var icon = findByObjectName(theme, "capsLockIndicator")
        root.assertTrue(icon !== null, "caps lock icon exists in the login screen")

        if (icon) {
          var none = 0
          var shift = 0x02000000

          root.assertTrue(!icon.visible, "icon is hidden before anything is typed")

          // Qt.Key_CapsLock before any letter: the state is still unknown.
          theme.trackCapsLock(Qt.Key_CapsLock, "", none, false)
          root.assertTrue(!icon.visible, "icon stays hidden when Caps Lock is pressed with the state unknown")

          theme.trackCapsLock(Qt.Key_A, "A", none, false)
          root.assertTrue(icon.visible, "a capital typed without Shift shows the icon")

          // A password longer than the field holds dots: the icon stays inside
          // the field and the dots stop short of it.
          var input = findByObjectName(theme, "passwordInput")
          var dots = findByObjectName(theme, "passwordDots")
          root.assertTrue(input !== null && dots !== null, "password field and dots exist")
          if (input && dots) {
            input.text = "a".repeat(40)
            dots.forceLayout()
            root.assertTrue(icon.parent.width > 100, "password field takes the entry image's width, got " + icon.parent.width)
            root.assertTrue(icon.x >= 0 && icon.x + icon.width <= icon.parent.width, "icon sits inside the password field")
            root.assertTrue(dots.width > 0 && dots.x + dots.width < icon.x, "password dots stop short of the icon, dots end " + (dots.x + dots.width) + ", icon at " + icon.x)
            input.text = ""
          }

          theme.trackCapsLock(Qt.Key_A, "a", none, false)
          root.assertTrue(!icon.visible, "a lowercase letter clears the icon")

          theme.trackCapsLock(Qt.Key_A, "A", shift, false)
          root.assertTrue(!icon.visible, "a capital typed with Shift is no Caps Lock")

          theme.trackCapsLock(Qt.Key_A, "a", shift, false)
          root.assertTrue(icon.visible, "a lowercase letter typed with Shift shows the icon")

          theme.trackCapsLock(Qt.Key_CapsLock, "", none, true)
          root.assertTrue(icon.visible, "a repeating Caps Lock press changes nothing")

          theme.trackCapsLock(Qt.Key_CapsLock, "", none, false)
          root.assertTrue(!icon.visible, "pressing Caps Lock clears the icon once the state is known")

          theme.trackCapsLock(Qt.Key_1, "1", none, false)
          root.assertTrue(!icon.visible, "a key with no case leaves the state alone")

          // French AZERTY Shift+* types the micro sign, which Caps Lock turns
          // into Greek capital mu; neither says anything about Caps Lock.
          theme.trackCapsLock(Qt.Key_mu, "µ", shift, false)
          root.assertTrue(!icon.visible, "AZERTY Shift+* micro sign leaves the icon off")

          theme.trackCapsLock(Qt.Key_CapsLock, "", none, false)
          root.assertTrue(icon.visible, "pressing Caps Lock again brings the icon back")

          theme.trackCapsLock(0x039C, "Μ", shift, false)
          root.assertTrue(icon.visible, "AZERTY Shift+* under Caps Lock leaves the icon on")

          theme.trackCapsLock(Qt.Key_A, "a", none, false)
          keyboard.capsLock = true
          root.assertTrue(icon.visible, "a keyboard that does report Caps Lock shows the icon")
          keyboard.capsLock = false
        }

        theme.destroy()
      } catch (error) {
        root.fail("sddm caps lock fixture threw: " + error)
      } finally {
        root.writeResult()
      }
    }
  }
}
