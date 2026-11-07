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

        var icon = findByObjectName(view, "capsLockIndicator")
        root.assertTrue(icon !== null, "caps lock icon exists in the lock view")

        if (icon) {
          root.assertTrue(!icon.visible, "icon is hidden while Caps Lock is off")
          root.assertTrue(view.iconReserve === 0, "no icon space is reserved while Caps Lock is off")

          view.capsLockOn = true
          root.assertTrue(icon.visible, "icon appears when Caps Lock is on")
          root.assertTrue(view.iconReserve > icon.width, "dots keep clear of the icon")

          // The preview cannot take a password, so it has nothing to warn about.
          view.inputEnabled = false
          root.assertTrue(!icon.visible, "icon is hidden when the field takes no input")
          view.inputEnabled = true

          view.capsLockOn = false
          root.assertTrue(!icon.visible, "icon clears when Caps Lock turns off")
        }

        view.destroy()

        checkService()
      } catch (error) {
        root.fail("lock caps lock fixture threw: " + error)
      } finally {
        root.writeResult()
      }
    }
  }

  function devices(keyboards) {
    return JSON.stringify({ keyboards: keyboards })
  }

  // Feeds Service.applyCapsLock the device list hyprctl returns.
  function checkService() {
    var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/lock/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      root.fail("Service failed to load: " + component.errorString())
      return
    }
    var service = component.createObject(host, { omarchyPath: root.rootPath })
    if (!service) {
      root.fail("Service failed to instantiate: " + component.errorString())
      return
    }

    service.applyCapsLock(devices([
      { name: "at-translated-set-2-keyboard", main: false, capsLock: true },
      { name: "hl-virtual-keyboard", main: true, capsLock: false }
    ]))
    root.assertTrue(service.capsLockOn, "caps lock reads on when fcitx5's virtual keyboard holds main")

    service.applyCapsLock(devices([
      { name: "keychron-k2", main: false, capsLock: false },
      { name: "power-button", main: false, capsLock: false },
      { name: "dell-aio-wmi-hotkeys", main: true, capsLock: false },
      { name: "at-translated-set-2-keyboard", main: false, capsLock: true }
    ]))
    root.assertTrue(service.capsLockOn, "caps lock reads on from any typed keyboard")

    service.applyCapsLock(devices([
      { name: "keychron-k2", main: true, capsLock: false },
      { name: "power-button", main: false, capsLock: true }
    ]))
    root.assertTrue(!service.capsLockOn, "a power button never turns caps lock on")

    service.capsLockOn = true
    service.applyCapsLock(devices([]))
    root.assertTrue(!service.capsLockOn, "no keyboards reads as off")

    service.destroy()
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
