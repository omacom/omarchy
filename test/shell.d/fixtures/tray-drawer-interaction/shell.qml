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

  function assertEqual(actual, expected, message) {
    if (actual !== expected) fail(message + " expected=" + expected + " actual=" + actual)
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

  PanelWindow {
    id: hostWindow
    screen: Quickshell.screens && Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors.top: true
    anchors.left: true
    implicitWidth: 600
    implicitHeight: 100
    visible: true
    color: "transparent"

    Item {
      id: host
      anchors.fill: parent
    }
  }

  QtObject {
    id: mockShell
    property var bar: fakeBar
    property var barConfig: ({ position: "top" })
    property var shellConfig: ({ version: 1, idle: {}, plugins: [], bar: { layout: { left: [], center: [], right: [] } } })
    function firstPartyServiceFor(id) { return null }
    function serviceFor(id) { return null }
    function summon(id, payloadJson) { return true }
    function hide(id) { return true }
    function toggle(id, payloadJson) { return true }
    function updateEntryInline(moduleName, settings) { return true }
  }

  QtObject {
    id: fakeBar
    property bool vertical: false
    property int barSize: 26
    property string omarchyPath: root.rootPath
    property string fontFamily: "monospace"
    property color foreground: "white"
    property color background: "black"
    property color urgent: "red"
    property var shell: mockShell
    function run(command) {}
    function showTooltip(target, text) {}
    function hideTooltip(target) {}
    function requestPopout(owner) {}
    function releasePopout(owner) {}
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
  }

  Timer {
    interval: 50
    running: true
    repeat: false
    onTriggered: {
      try {
        var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/bar/widgets/Tray.qml", Component.PreferSynchronous)
        if (component.status !== Component.Ready) {
          root.fail("Tray.qml failed to load: " + component.errorString())
          root.writeResult()
          return
        }

        var tray = component.createObject(host, {
          moduleName: "omarchy.tray",
          bar: fakeBar,
          settings: {}
        })
        if (!tray) {
          root.fail("Tray.qml failed to instantiate: " + component.errorString())
          root.writeResult()
          return
        }

        // 1. Initial collapsed state
        root.assertEqual(tray.drawerPinned, false, "initially not pinned")
        root.assertEqual(tray.drawerAreaHovered, false, "initially not hovered")
        root.assertEqual(tray.drawerHoverSuppressed, false, "initially hover not suppressed")
        root.assertEqual(tray.expanded, false, "initially collapsed")

        // 2. Click to pin
        tray.toggleExpanded()
        root.assertEqual(tray.drawerPinned, true, "click sets drawerPinned to true")
        root.assertEqual(tray.expanded, true, "drawer is expanded when pinned")

        // 3. Click to unpin while not hovered
        tray.toggleExpanded()
        root.assertEqual(tray.drawerPinned, false, "second click unpins drawer")
        root.assertEqual(tray.drawerHoverSuppressed, false, "unpinning without hover does not suppress hover")
        root.assertEqual(tray.expanded, false, "drawer collapses after unpin")

        // 4. Hover interaction
        tray.drawerAreaHovered = true
        root.assertEqual(tray.drawerHovered, true, "drawerHovered is true when hovered")
        root.assertEqual(tray.expanded, true, "hover reveals drawer")

        // 5. Pin while hovering
        tray.toggleExpanded()
        root.assertEqual(tray.drawerPinned, true, "clicking while hovering pins open")
        root.assertEqual(tray.expanded, true, "drawer stays expanded when pinned")

        // 6. Unpin while hovering (immediate collapse with suppression)
        tray.toggleExpanded()
        root.assertEqual(tray.drawerPinned, false, "unpin toggles pinned to false")
        root.assertEqual(tray.drawerHoverSuppressed, true, "unpinning while hovered sets drawerHoverSuppressed")
        root.assertEqual(tray.drawerHovered, false, "drawerHovered is false when suppressed")
        root.assertEqual(tray.expanded, false, "drawer collapses immediately on unpin even while hovered")

        // 7. Hover exit clears suppression
        tray.drawerAreaHovered = false
        root.assertEqual(tray.drawerHoverSuppressed, false, "hover exit clears suppression")

        // 8. Subsequent hover works normally
        tray.drawerAreaHovered = true
        root.assertEqual(tray.drawerHovered, true, "subsequent hover works")
        root.assertEqual(tray.expanded, true, "subsequent hover expands drawer")
        tray.drawerAreaHovered = false
        root.assertEqual(tray.expanded, false, "exiting hover collapses drawer")

        // 9. Popup visibility keeps drawer revealed
        tray.managePopupOpen = true
        Qt.callLater(function() {
          try {
            root.assertEqual(tray.managePopupOpen, true, "managePopupOpen is true")
            root.assertTrue(tray.managePopupVisible, "managePopupVisible is true while open")
            root.assertEqual(tray.expanded || tray.managePopupVisible, true, "drawer stays effectively open during popup")

            tray.managePopupOpen = false

            // 10. Vertical layout test
            fakeBar.vertical = true
            var vertTray = component.createObject(host, {
              moduleName: "omarchy.tray",
              bar: fakeBar,
              settings: {}
            })
            root.assertTrue(vertTray !== null, "vertical tray instantiates")
            root.assertEqual(vertTray.expanded, false, "vertical tray initially collapsed")
            vertTray.toggleExpanded()
            root.assertEqual(vertTray.drawerPinned, true, "vertical tray click pins open")
            root.assertEqual(vertTray.expanded, true, "vertical tray expands when pinned")
            vertTray.toggleExpanded()
            root.assertEqual(vertTray.drawerPinned, false, "vertical tray unpins")
            vertTray.destroy()
            tray.destroy()
          } catch (err) {
            root.fail("Async runtime assertion failed: " + err)
          } finally {
            root.writeResult()
          }
        })
      } catch (err) {
        root.fail("Runtime test threw exception: " + err)
        root.writeResult()
      }
    }
  }
}
