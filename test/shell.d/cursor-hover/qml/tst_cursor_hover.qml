import QtQuick
import QtTest
import qs.Ui

// Drives real pointer movement over CursorSurface rows, so the row-level
// HoverHandler and the Cursor handoff are both exercised. The panel state
// mirrors the first-party panels: hasCursor is the ownership predicate.
Item {
  id: root
  width: 200
  height: 190

  QtObject {
    id: panel
    property bool cursorActive: false
    property string focusSection: ""
    property int selectedIndex: -1
    property bool actionFocused: false
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

  // A row that disappears while hovered must release the cursor.
  CursorSurface {
    id: rowD
    y: 90
    width: 100
    height: 20
    hasCursor: panel.cursorActive && panel.focusSection === "d" && panel.selectedIndex === 0
    onHovered: function(isHovered) {
      Cursor.applyHover(isHovered, rowD.hasCursor, function() {
        panel.cursorActive = true
        panel.focusSection = "d"
        panel.selectedIndex = 0
      }, function() { panel.cursorActive = false })
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
    }
  }

  // Entering directly over an inline action must keep the action focused.
  // Qt delivers the action's containsMouse before the row's HoverHandler.
  CursorSurface {
    id: rowE
    y: 120
    width: 100
    height: 20
    hasCursor: panel.cursorActive && panel.focusSection === "e" && panel.selectedIndex === 0 && !panel.actionFocused
    onHovered: function(isHovered) {
      Cursor.applyHover(isHovered, rowE.hasCursor, function() {
        panel.cursorActive = true
        panel.focusSection = "e"
        panel.selectedIndex = 0
        if (!actionMouse.containsMouse) panel.actionFocused = false
      }, function() { panel.cursorActive = false })
    }

    MouseArea {
      id: actionMouse
      anchors.right: parent.right
      width: 20
      height: parent.height
      hoverEnabled: true
      onContainsMouseChanged: {
        Cursor.applyHover(containsMouse, panel.cursorActive && panel.focusSection === "e" && panel.actionFocused, function() {
          panel.cursorActive = true
          panel.focusSection = "e"
          panel.selectedIndex = 0
          panel.actionFocused = true
        }, function() {
          if (rowE.pointerInside) panel.actionFocused = false
          else panel.cursorActive = false
        })
      }
    }
  }

  // A row whose containing section hides must release too; its own visible
  // stays true, so the panel gates the row's hover with the section state.
  Item {
    id: parentF
    y: 150
    width: 100
    height: 20
    visible: true

    CursorSurface {
      id: rowF
      anchors.fill: parent
      hoverEnabled: parentF.visible
      hasCursor: panel.cursorActive && panel.focusSection === "f" && panel.selectedIndex === 0
      onHovered: function(isHovered) {
        Cursor.applyHover(isHovered, rowF.hasCursor, function() {
          panel.cursorActive = true
          panel.focusSection = "f"
          panel.selectedIndex = 0
        }, function() { panel.cursorActive = false })
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
      }
    }
  }

  TestCase {
    name: "CursorHoverRelease"
    when: windowShown

    function init() {
      panel.cursorActive = false
      panel.focusSection = ""
      panel.selectedIndex = -1
      panel.actionFocused = false
      rowD.visible = true
      parentF.visible = true
      mouseMove(root, 150, 180)
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
      mouseMove(root, 150, 180)
      tryCompare(panel, "cursorActive", false)
    }

    function test_handoff_keeps_new_row() {
      mouseMove(root, 50, 10)
      tryCompare(panel, "focusSection", "a")
      mouseMove(root, 50, 40)
      tryCompare(panel, "focusSection", "b")
      compare(panel.cursorActive, true)
      mouseMove(root, 150, 180)
      tryCompare(panel, "cursorActive", false)
    }

    function test_keyboard_selection_survives_stale_leave() {
      mouseMove(root, 50, 10)
      tryCompare(panel, "focusSection", "a")
      panel.focusSection = "b"
      panel.selectedIndex = 0
      mouseMove(root, 150, 180)
      compare(panel.cursorActive, true)
      compare(panel.focusSection, "b")
    }

    function test_disabled_row_does_not_claim() {
      mouseMove(root, 50, 70)
      wait(50)
      compare(panel.cursorActive, false)
    }

    function test_hiding_a_hovered_row_releases() {
      mouseMove(root, 50, 100)
      tryCompare(panel, "focusSection", "d")
      rowD.visible = false
      tryCompare(panel, "cursorActive", false)
    }

    function test_hiding_a_hovered_rows_parent_releases() {
      mouseMove(root, 50, 160)
      tryCompare(panel, "focusSection", "f")
      parentF.visible = false
      tryCompare(panel, "cursorActive", false)
    }

    function test_direct_action_keeps_action_focus() {
      mouseMove(root, 90, 130)
      tryCompare(panel, "focusSection", "e")
      compare(panel.actionFocused, true)
      compare(panel.cursorActive, true)
    }

    function test_leaving_the_action_clears_its_focus() {
      mouseMove(root, 90, 130)
      tryCompare(panel, "actionFocused", true)
      mouseMove(root, 150, 180)
      tryCompare(panel, "cursorActive", false)
      compare(panel.actionFocused, false)
    }
  }
}
