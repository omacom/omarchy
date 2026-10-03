import QtQuick
import QtQuick.Controls
import QtTest
import qs.Commons
import "qs/Ui"

Item {
  id: scene
  width: 520
  height: 650

  property var dropdown: null
  Component {
    id: dropdownComponent
    Dropdown {
      x: 60
      y: 40
      width: 320
    }
  }

  TestCase {
    name: "DropdownPopupGeometry"
    when: windowShown

    function init() {
      scene.dropdown = createTemporaryObject(dropdownComponent, scene)
      verify(scene.dropdown !== null)
    }

    // Popup is a nonvisual object owned by the trigger.
    function findPopup(item) {
      if (item.contentItem !== undefined && item.opened !== undefined) return item
      var data = item.data || []
      for (var i = 0; i < data.length; i++) {
        var popup = findPopup(data[i])
        if (popup) return popup
      }
      return null
    }

    function cleanup() {
      dropdown.close()
      mouseMove(scene, 500, 600)
    }

    function test_viewport_data() {
      var cases = []
      var borders = [
        {name: "default", values: {}},
        {name: "2px", values: {"popups.border-width": "2"}},
        {name: "asymmetric", values: {"popups.border-width": "3 2 5 4"}}
      ]
      var counts = [0, 1, 2, 4, 8, 12]
      var rowHeights = [20, 28, 40]
      for (var b = 0; b < borders.length; b++) {
        for (var c = 0; c < counts.length; c++) {
          for (var r = 0; r < rowHeights.length; r++) {
            cases.push({tag: borders[b].name + "-" + counts[c] + "-" + rowHeights[r],
                        border: borders[b].values, count: counts[c], rowHeight: rowHeights[r]})
          }
        }
      }
      return cases
    }

    function test_viewport(data) {
      Color.shellValues = data.border
      dropdown.popupRowHeight = data.rowHeight
      var options = []
      for (var i = 0; i < data.count; i++) options.push("Option " + (i + 1))
      dropdown.options = options
      dropdown.value = options[0] || ""
      dropdown.open()
      tryCompare(dropdown, "popupOpen", true)
      var popup = findPopup(dropdown)
      verify(popup !== null)
      var list = popup.contentItem
      var visibleRows = Math.min(data.count, 8)
      var viewport = visibleRows * data.rowHeight + Math.max(0, visibleRows - 1) * Style.spacing.labelGap
      wait(50)
      compare(list.height, viewport)
      compare(popup.height, viewport + popup.topPadding + popup.bottomPadding)
      compare(list.width, popup.width - popup.leftPadding - popup.rightPadding)
      if (data.count === 0) return
      tryCompare(list, "count", data.count)
      list.positionViewAtEnd()
      wait(100)
      var last = list.itemAtIndex(data.count - 1)
      verify(last !== null)
      verify(last.y + last.height <= list.contentY + list.height + 0.01, "last row is fully visible at the end")
      if (data.count <= 8) {
        compare(list.contentY, 0, "short lists have no scroll offset")
        // The real hover handler changes currentIndex; neither end may shift the list.
        mouseMove(list, 20, list.height - data.rowHeight / 2)
        tryCompare(list, "currentIndex", data.count - 1)
        wait(100)
        compare(list.contentY, 0, "hovering the last row does not scroll")
        mouseMove(list, 20, data.rowHeight / 2)
        tryCompare(list, "currentIndex", 0)
        wait(100)
        compare(list.contentY, 0, "hovering the first row does not scroll")
      } else {
        verify(list.contentY > 0, "long lists retain scrolling")
        list.positionViewAtBeginning()
        tryCompare(list, "contentY", 0)
        list.currentIndex = 0
        wait(100)
        list.forceActiveFocus()
        for (var index = 1; index < data.count; index++) {
          keyClick(Qt.Key_Down)
          wait(50)
        }
        tryCompare(list, "currentIndex", data.count - 1)
        tryVerify(function() { return list.contentY > 0 }, 2000, "selection can scroll to the last row")
        tryVerify(function() {
          var item = list.itemAtIndex(data.count - 1)
          return item !== null && item.y + item.height <= list.contentY + list.height + 0.01
        }, 2000, "keyboard selection keeps the last row visible")
      }
    }
  }
}
