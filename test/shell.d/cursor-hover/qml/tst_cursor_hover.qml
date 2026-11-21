import QtQuick
import QtTest
import qs.Ui

// Drives real pointer movement over CursorSurface rows, so the row-level
// HoverHandler and the Cursor handoff are both exercised. The panel state
// mirrors the first-party panels: hasCursor is the ownership predicate.
Item {
  id: root
  width: 200
  height: 120

  QtObject {
    id: panel
    property bool cursorActive: false
    property string focusSection: ""
    property int selectedIndex: -1
  }

  CursorSurface {
    id: rowA
    width: 100
    height: 20
    hasCursor: panel.cursorActive && panel.focusSection === "a" && panel.selectedIndex === 0
    onHovered: function(isHovered) {
      Cursor.applyHover(isHovered, rowA.hasCursor, function() {
        panel.cursorActive = true
        panel.focusSection = "a"
        panel.selectedIndex = 0
      }, function() { panel.cursorActive = false })
    }

    // Real rows put their click target on top of the row. The row's
    // HoverHandler must still see the pointer through that child.
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
    }
  }

  CursorSurface {
    id: rowB
    y: 30
    width: 100
    height: 20
    hasCursor: panel.cursorActive && panel.focusSection === "b" && panel.selectedIndex === 0
    onHovered: function(isHovered) {
      Cursor.applyHover(isHovered, rowB.hasCursor, function() {
        panel.cursorActive = true
        panel.focusSection = "b"
        panel.selectedIndex = 0
      }, function() { panel.cursorActive = false })
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
    }
  }

  // A row whose click target is disabled must not claim the cursor on hover.
  CursorSurface {
    id: rowC
    y: 60
    width: 100
    height: 20
    hoverEnabled: false
    hasCursor: panel.cursorActive && panel.focusSection === "c" && panel.selectedIndex === 0
    onHovered: function(isHovered) {
      Cursor.applyHover(isHovered, rowC.hasCursor, function() {
        panel.cursorActive = true
        panel.focusSection = "c"
        panel.selectedIndex = 0
      }, function() { panel.cursorActive = false })
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
    }
  }

  TestCase {
    name: "CursorHoverRelease"
    when: windowShown

    function init() {
      panel.cursorActive = false
      panel.focusSection = ""
      panel.selectedIndex = -1
      mouseMove(root, 150, 110)
    }

    function test_enter_claims() {
      mouseMove(root, 50, 10)
      tryCompare(panel, "cursorActive", true)
      compare(panel.focusSection, "a")
      compare(panel.selectedIndex, 0)
    }

    function test_leave_releases() {
      mouseMove(root, 50, 10)
      tryCompare(panel, "cursorActive", true)
      mouseMove(root, 150, 110)
      tryCompare(panel, "cursorActive", false)
    }

    function test_handoff_keeps_new_row() {
      mouseMove(root, 50, 10)
      tryCompare(panel, "focusSection", "a")
      mouseMove(root, 50, 40)
      tryCompare(panel, "focusSection", "b")
      compare(panel.cursorActive, true)
      mouseMove(root, 150, 110)
      tryCompare(panel, "cursorActive", false)
    }

    function test_keyboard_selection_survives_stale_leave() {
      mouseMove(root, 50, 10)
      tryCompare(panel, "focusSection", "a")
      panel.focusSection = "b"
      panel.selectedIndex = 0
      mouseMove(root, 150, 110)
      compare(panel.cursorActive, true)
      compare(panel.focusSection, "b")
    }

    function test_disabled_row_does_not_claim() {
      mouseMove(root, 50, 70)
      wait(50)
      compare(panel.cursorActive, false)
    }
  }
}
