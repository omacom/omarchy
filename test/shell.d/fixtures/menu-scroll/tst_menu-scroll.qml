import QtQuick
import QtTest
Item {
  width: 300
  height: 500
  ScrollHarness { id: menu }
  TestCase {
    name: "MenuScroll"
    when: windowShown
    function init() {
      menu.opened = false
      menu.surface.shown = false
      menu.surface.width = 300
      menu.surface.height = 720
      menu.listHeight = 450
      menu.selectedIndex = 0
      menu.populate(9)
      menu.view.forceLayout()
      menu.view.positionViewAtBeginning()
      wait(1)
      menu.opened = true
      menu.surface.shown = true
    }
    function cursorIsVisible() {
      var row = menu.view.itemAtIndex(menu.selectedIndex)
      verify(row !== null, "Selected delegate exists")
      var top = row.y - menu.view.contentY
      verify(top >= -0.01, "Selected row clipped at top: " + top)
      verify(top + row.height <= menu.view.height + 0.01,
        "Selected row clipped at bottom: " + (top + row.height))
    }
    function firstRowIsAtTop() {
      compare(menu.selectedIndex, 0)
      cursorIsVisible()
      var first = menu.view.itemAtIndex(0)
      fuzzyCompare(first.y - menu.view.contentY, 0, 0.01)
    }
    function test_openWhileSurfaceIsOnePixel() {
      menu.surface.width = 1
      menu.surface.height = 1
      menu.listHeight = 50
      menu.view.forceLayout()
      menu.revealCursor()
      firstRowIsAtTop()
    }
    function test_surfaceGrowsWithoutGuardRefresh() {
      menu.surface.width = 1
      menu.surface.height = 1
      menu.listHeight = 50
      menu.view.forceLayout()
      menu.revealCursor()
      menu.surface.width = 300
      menu.surface.height = 720
      menu.listHeight = 450
      wait(30)
      firstRowIsAtTop()
    }
    function test_firstRowWithShortViewport() {
      menu.listHeight = 60
      menu.view.forceLayout()
      menu.revealCursor()
      firstRowIsAtTop()
    }
    function test_middleRowWithShortViewport() {
      menu.listHeight = 60
      menu.selectedIndex = 4
      menu.view.forceLayout()
      menu.revealCursor()
      cursorIsVisible()
    }
    function test_reopenAfterScrollingToEnd() {
      menu.selectedIndex = 8
      menu.revealCursor()
      cursorIsVisible()
      menu.opened = false
      menu.surface.shown = false
      menu.surface.width = 1
      menu.surface.height = 1
      menu.listHeight = 50
      wait(1)
      menu.selectedIndex = 0
      menu.populate(9)
      menu.opened = true
      menu.surface.shown = true
      menu.revealCursor()
      menu.surface.width = 300
      menu.surface.height = 720
      menu.listHeight = 450
      wait(30)
      firstRowIsAtTop()
    }
    function test_keyboardNavigationAndWrapping() {
      for (var i = 0; i < 9; i++) {
        menu.selectedIndex = i
        menu.revealCursor()
        cursorIsVisible()
      }
      menu.selectedIndex = 0
      menu.revealCursor()
      firstRowIsAtTop()
    }
    function test_modelRebuildWithPendingLayout() {
      menu.selectedIndex = 8
      menu.revealCursor()
      menu.populate(3)
      menu.selectedIndex = 0
      menu.revealCursor()
      firstRowIsAtTop()
    }
  }
}
