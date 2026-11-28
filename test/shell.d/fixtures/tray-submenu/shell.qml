import QtQuick
import Quickshell
import qs.Commons

// The tray menu's submenu stack is the Repeater model under the row that was
// clicked, so entering or leaving a level swaps it a tick later, outside that
// row's click; and a swap queued before the menu closed and reopened must not
// land in the reopened menu.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var tray: null
  property var steps: []

  function fail(message) {
    failures.push(String(message))
  }

  function expectDepth(depth, title, message) {
    if (tray.submenuDepth !== depth || tray.currentTitle !== title)
      fail(message + " (depth " + tray.submenuDepth + " \"" + tray.currentTitle + "\", expected " + depth + " \"" + title + "\")")
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  Item { id: host }

  QtObject {
    id: mockShell
    property var shellConfig: ({ version: 1, plugins: [], bar: { layout: { left: [], center: [], right: [] } } })
    function firstPartyServiceFor(id) { return null }
    function serviceFor(id) { return null }
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

  function setUp() {
    var component = Qt.createComponent(rootPath + "/shell/plugins/bar/widgets/Tray.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      fail("tray failed to load: " + component.errorString())
      return false
    }
    tray = component.createObject(host, { moduleName: "omarchy.tray", settings: {} })
    if (!tray) {
      fail("tray failed to instantiate: " + component.errorString())
      return false
    }
    tray.bar = fakeBar
    tray.trayMenuOpen = true
    return true
  }

  // Each step runs on its own turn of the event loop, after every callback
  // the previous step queued.
  readonly property var script: [
    function() {
      tray.enterSubmenu(null, "Settings")
      expectDepth(0, "", "entering a submenu leaves the stack alone inside the click")
    },
    function() { expectDepth(1, "Settings", "the queued enter shows the submenu") },
    function() {
      tray.leaveSubmenu()
      expectDepth(1, "Settings", "leaving a submenu leaves the stack alone inside the click")
    },
    function() { expectDepth(0, "", "the queued leave returns to the root menu") },
    function() {
      tray.enterSubmenu(null, "Stale")
      tray.close()
      tray.trayMenuOpen = true
    },
    function() { expectDepth(0, "", "a submenu entered before close and reopen stays out of the reopened menu") },
    function() {
      tray.enterSubmenu(null, "Fresh")
    },
    function() { expectDepth(1, "Fresh", "the reopened menu still enters submenus") }
  ]

  Timer {
    interval: 50
    running: true
    repeat: true
    onTriggered: {
      if (root.tray === null) {
        if (!root.setUp()) {
          stop()
          root.writeResult()
          return
        }
        root.steps = root.script.slice()
        return
      }
      if (root.steps.length > 0) root.steps.shift()()
      if (root.steps.length === 0) {
        stop()
        root.writeResult()
      }
    }
  }
}
