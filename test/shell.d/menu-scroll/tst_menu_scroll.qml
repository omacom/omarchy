import QtQuick
import QtTest

// The cursor row is always drawn whole, and the first row sits flush at the
// top whenever the cursor is on it, however short the list is.
Item {
  width: 300
  height: 500

  ScrollHarness { id: menu }

  TestCase {
    name: "MenuScroll"
    when: windowShown

    function rows(count, height) {
      var heights = []
      for (var i = 0; i < count; i++) heights.push(height)
      return heights
    }

    function reveal(index) {
      menu.selectedIndex = index
      menu.view.forceLayout()
      menu.revealCursor()
    }

    function init() {
      menu.listHeight = 450
      menu.populate(rows(9, 50))
      menu.view.positionViewAtBeginning()
      menu.selectedIndex = 0
    }

    function cursorIsWhole() {
      var row = menu.view.itemAtIndex(menu.selectedIndex)
      verify(row !== null, "the cursor row exists")
      var top = row.y - menu.view.contentY
      verify(top >= -0.01, "cursor row clipped at the top by " + (-top))
      verify(top + row.height <= menu.view.height + 0.01, "cursor row clipped at the bottom by " + (top + row.height - menu.view.height))
    }

    function firstRowIsAtTop() {
      cursorIsWhole()
      fuzzyCompare(menu.view.itemAtIndex(0).y - menu.view.contentY, 0, 0.01)
    }

    // A list shorter than a row plus the peek used to scroll row 0 up under its top edge.
    function test_firstRowWithShortList() {
      menu.listHeight = 60
      reveal(0)
      firstRowIsAtTop()
    }

    function test_middleRowWithShortList() {
      menu.listHeight = 60
      reveal(4)
      cursorIsWhole()
    }

    // --maxheight 90 over a plain row then rows with subtext folds the list to 81px,
    // too short for a 58px row and a full peek on both sides.
    function test_tallerRowInFoldedList() {
      menu.listHeight = 81
      menu.populate([50, 58, 58, 58])
      reveal(1)
      cursorIsWhole()
    }

    function test_keyboardNavigationAndWrapping() {
      for (var i = 0; i < 9; i++) {
        reveal(i)
        cursorIsWhole()
      }
      reveal(0)
      firstRowIsAtTop()
    }

    function test_modelRebuildAfterScrolling() {
      reveal(8)
      menu.populate(rows(3, 50))
      reveal(0)
      firstRowIsAtTop()
    }
  }
}
