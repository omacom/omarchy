import QtQuick
import QtQuick.Window
import Quickshell
import qs.Ui
import qs.Commons as Commons

// Drives qs.Ui.ContextMenu through open, keyboard navigation, activation and
// Escape close, then writes {ok, failures, activated} for run_qml_fixture to
// read. A bare Window hosts the popup: a Qt Quick Controls Popup only opens
// inside a window, and the shell's panels are windows too.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property var activatedKeys: []
  property var hoveredIndices: []

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
      failures: failures,
      activated: activatedKeys
    })

    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  // A key event shaped like the one a Keys handler receives, so the fixture can
  // drive the same code path the real handler does.
  function keyEvent(key, text) {
    return { key: key, text: text || "", modifiers: 0, accepted: false }
  }

  Window {
    id: window
    width: 320
    height: 240
    visible: true

    Item {
      id: host
      anchors.fill: parent

      ContextMenu {
        id: menu
        items: [
          { key: "connect", label: "Connect", danger: false },
          { key: "modify", label: "Modify Network…", danger: false },
          { key: "forget", label: "Forget Network", danger: true }
        ]
        onActivated: function(key) { root.activatedKeys.push(key) }
        onHovered: function(index) { root.hoveredIndices.push(index) }
      }
    }
  }

  Timer {
    interval: 100
    running: true
    repeat: false
    onTriggered: {
      root.assertTrue(!menu.popupOpen, "menu starts closed")

      menu.open()
      root.assertTrue(menu.popupOpen, "open() opens the popup")
      root.assertEqual(menu.highlightIndex, 0, "opening highlights the first row")

      // Up/Down and j/k walk the highlight; the danger row is reachable.
      menu.handleKey(root.keyEvent(Qt.Key_Down, ""))
      menu.handleKey(root.keyEvent(Qt.Key_Down, ""))
      root.assertEqual(menu.highlightIndex, 2, "Down moves the highlight to the third row")
      menu.handleKey(root.keyEvent(Qt.Key_Down, ""))
      root.assertEqual(menu.highlightIndex, 2, "Down stops at the last row")
      root.assertTrue(root.hoveredIndices.indexOf(2) >= 0, "moving the highlight reports hovered(index)")

      menu.handleKey(root.keyEvent(Qt.Key_Up, ""))
      root.assertEqual(menu.highlightIndex, 1, "Up moves the highlight back")
      menu.handleKey(root.keyEvent(0, "k"))
      root.assertEqual(menu.highlightIndex, 0, "k moves the highlight up")

      // j, then Enter, activates the highlighted key and closes.
      var j = root.keyEvent(0, "j")
      menu.handleKey(j)
      root.assertTrue(j.accepted, "j is handled")
      root.assertEqual(menu.highlightIndex, 1, "j moves the highlight down")

      var enter = root.keyEvent(Qt.Key_Return, "")
      menu.handleKey(enter)
      root.assertTrue(enter.accepted, "Enter is handled")
      root.assertEqual(root.activatedKeys.length, 1, "Enter activates exactly one row")
      root.assertEqual(root.activatedKeys[0], "modify", "Enter activates the highlighted key")
      root.assertTrue(!menu.popupOpen, "activation closes the menu")

      // Space activates too, and reopening restarts the highlight.
      menu.open()
      root.assertEqual(menu.highlightIndex, 0, "reopening highlights the first row again")
      var space = root.keyEvent(Qt.Key_Space, " ")
      menu.handleKey(space)
      root.assertTrue(space.accepted, "Space is handled")
      root.assertEqual(root.activatedKeys[1], "connect", "Space activates the highlighted key")

      // Escape closes without activating.
      menu.open()
      var escape = root.keyEvent(Qt.Key_Escape, "")
      menu.handleKey(escape)
      root.assertTrue(escape.accepted, "Escape is handled")
      root.assertTrue(!menu.popupOpen, "Escape closes the popup")
      root.assertEqual(root.activatedKeys.length, 2, "Escape activates nothing")

      // toggle() flips the open state.
      menu.toggle()
      root.assertTrue(menu.popupOpen, "toggle() opens a closed menu")
      menu.toggle()
      root.assertTrue(!menu.popupOpen, "toggle() closes an open menu")

      root.writeResult()
    }
  }
}
