import QtQuick
import QtQuick.Controls
import QtTest
import qs.Commons
import qs.Commons as Commons
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

  Component {
    id: searchableDropdownComponent
    SearchableDropdown {
      x: 60
      y: 40
      width: 320
    }
  }

  Component {
    id: panelSliderComponent
    PanelSlider { x: 60; y: 40; width: 200; minimum: 0; maximum: 10; step: 1; integer: true; value: 5 }
  }

  Component {
    id: wheelScrollHostComponent
    Item {
      id: wheelHost
      x: 60; y: 40; width: 160; height: 120
      property alias flick: wheelFlick
      property int outerWheels: 0
      MouseArea {
        anchors.fill: parent
        onWheel: function(wheel) { wheelHost.outerWheels++; wheel.accepted = true }
        Flickable {
          id: wheelFlick
          anchors.fill: parent; contentWidth: width; contentHeight: 400; contentY: 50
          flickableDirection: Flickable.VerticalFlick
          WheelScroll { flickable: wheelFlick }
        }
      }
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
      // Park the pointer on empty scene so a stale position cannot stay over
      // the popup for the next data row.
      mouseMove(scene, 0, 0)
    }

    function test_viewport_data() {
      return [
        {tag: "default-0-28", border: {}, count: 0, rowHeight: 28},
        {tag: "default-1-28", border: {}, count: 1, rowHeight: 28},
        {tag: "default-4-20", border: {}, count: 4, rowHeight: 20},
        {tag: "default-8-28", border: {}, count: 8, rowHeight: 28},
        {tag: "default-12-28", border: {}, count: 12, rowHeight: 28},
        {tag: "2px-2-40", border: {"popups.border-width": "2"}, count: 2, rowHeight: 40},
        {tag: "2px-12-20", border: {"popups.border-width": "2"}, count: 12, rowHeight: 20},
        {tag: "asymmetric-1-40", border: {"popups.border-width": "3 2 5 4"}, count: 1, rowHeight: 40},
        {tag: "asymmetric-8-28", border: {"popups.border-width": "3 2 5 4"}, count: 8, rowHeight: 28},
        {tag: "asymmetric-12-40", border: {"popups.border-width": "3 2 5 4"}, count: 12, rowHeight: 40}
      ]
    }

    function test_viewport(data) {
      Commons.Color.shellValues = data.border
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
      wait(50)
      var last = list.itemAtIndex(data.count - 1)
      verify(last !== null)
      verify(last.y + last.height <= list.contentY + list.height + 0.01, "last row is fully visible at the end")
      if (data.count <= 8) {
        compare(list.contentY, 0, "short lists have no scroll offset")
        // The real hover handler changes currentIndex; neither end may shift the list.
        // PointerMoveGate absorbs the first hover sample after opening as the baseline,
        // so follow up with a small real move across the row.
        mouseMove(list, 20, list.height - data.rowHeight / 2)
        mouseMove(list, 24, list.height - data.rowHeight / 2)
        tryCompare(list, "currentIndex", data.count - 1)
        wait(50)
        compare(list.contentY, 0, "hovering the last row does not scroll")
        mouseMove(list, 20, data.rowHeight / 2)
        tryCompare(list, "currentIndex", 0)
        wait(50)
        compare(list.contentY, 0, "hovering the first row does not scroll")
      } else {
        verify(list.contentY > 0, "long lists retain scrolling")
        // The delegates change currentIndex on hover, and the keyboard walk
        // scrolls rows under the pointer. A row that scrolls under a pointer
        // left over the list takes the selection back mid-walk. Park it off
        // the popup before walking.
        mouseMove(scene, 0, 0)
        list.positionViewAtBeginning()
        tryCompare(list, "contentY", 0)
        list.currentIndex = 0
        wait(50)
        list.forceActiveFocus()
        for (var index = 1; index < data.count; index++) {
          keyClick(Qt.Key_Down)
          // A press that leaves the selection behind fails here now and then in
          // CI and nowhere else. Say what the list looked like when it did: who
          // has focus, which row the pointer is over, and whether another
          // press gets through.
          if (list.currentIndex !== index) {
            var hovered = []
            var rows = list.contentItem.children
            for (var r = 0; r < rows.length; r++) {
              if (rows[r].index === undefined) continue
              var parts = rows[r].children
              for (var c = 0; c < parts.length; c++)
                if (parts[c].containsMouse) hovered.push(rows[r].index + "@" + parts[c].mouseX + "," + parts[c].mouseY)
            }
            console.warn("STALL want", index, "cur", list.currentIndex, "popupOpened", popup.opened, "listFocus", list.activeFocus,
                         "winActive", scene.Window.active, "afi", scene.Window.activeFocusItem, "contentY", list.contentY, "hovered", hovered)
            keyClick(Qt.Key_Down)
            console.warn("STALL second press cur", list.currentIndex)
            wait(200)
            console.warn("STALL settled cur", list.currentIndex)
            fail("keyboard walk stalled at " + index)
          }
          tryCompare(list, "currentIndex", index)
        }
        tryCompare(list, "currentIndex", data.count - 1)
        tryVerify(function() { return list.contentY > 0 }, 2000, "selection can scroll to the last row")
        tryVerify(function() {
          var item = list.itemAtIndex(data.count - 1)
          return item !== null && item.y + item.height <= list.contentY + list.height + 0.01
        }, 2000, "keyboard selection keeps the last row visible")
      }
    }

    function findText(item, text) {
      if (!item || !item.visible) return null
      if (item.text === text) return item
      for (var i = 0; i < item.children.length; i++) {
        var hit = findText(item.children[i], text)
        if (hit) return hit
      }
      return null
    }

    function test_stationary_click_selects_clicked_row_data() {
      return [
        {tag: "dropdown", searchable: false},
        {tag: "searchable", searchable: true}
      ]
    }

    function test_stationary_click_selects_clicked_row(data) {
      mouseMove(scene, scene.width - 1, scene.height - 1)
      var picker = createTemporaryObject(data.searchable ? searchableDropdownComponent : dropdownComponent, scene, {
        value: "alpha",
        options: [
          {value: "alpha", label: "Alpha"},
          {value: "beta", label: "Beta"}
        ]
      })
      verify(picker !== null)
      var emitted = []
      picker.changed.connect(function(v) { emitted.push(v) })

      picker.open()
      tryCompare(picker, "popupOpen", true)
      if (data.searchable) {
        tryVerify(function() {
          var item = scene.Window.window.activeFocusItem
          return item && item.hasOwnProperty("placeholderText")
        })
        keyClick(Qt.Key_Down)
      }

      var beta = null
      tryVerify(function() {
        beta = findText(Overlay.overlay, "Beta")
        return beta !== null
      })
      for (var p = beta.parent; p; p = p.parent) {
        if (isPolishScheduled(p)) verify(waitForPolish(p))
      }

      // Alpha is the highlighted row. Press and release Beta without moving over it.
      mousePress(beta)
      mouseRelease(beta)
      compare(emitted, ["beta"])
      compare(picker.value, "beta")
    }

    function findListView(item) {
      if (!item) return null
      if (item.model !== undefined && item.currentIndex !== undefined && item.contentY !== undefined) return item
      for (var i = 0; i < (item.children || []).length; i++) {
        var found = findListView(item.children[i])
        if (found) return found
      }
      return null
    }

    function test_stationary_pointer_during_keyboard_and_wheel_data() {
      return [
        {tag: "dropdown", searchable: false},
        {tag: "searchable", searchable: true}
      ]
    }

    function test_stationary_pointer_during_keyboard_and_wheel(data) {
      var options = []
      for (var i = 0; i < 12; i++) options.push("Option " + (i + 1))
      var picker = createTemporaryObject(data.searchable ? searchableDropdownComponent : dropdownComponent, scene, {
        value: options[0],
        options: options
      })
      verify(picker !== null)

      picker.open()
      tryCompare(picker, "popupOpen", true)
      var list = findListView(findPopup(picker).contentItem)
      verify(list !== null)
      tryCompare(list, "count", options.length)

      if (data.searchable) {
        tryVerify(function() {
          var item = scene.Window.window.activeFocusItem
          return item && item.hasOwnProperty("placeholderText")
        })
        keyClick(Qt.Key_Down)
      }
      tryCompare(list, "activeFocus", true)

      // Park the pointer over row 1 after priming PointerMoveGate.
      var row1 = null
      tryVerify(function() {
        row1 = list.itemAtIndex(1)
        return row1 !== null && row1.height > 0 && list.height >= row1.y + row1.height
      })
      for (var p = row1; p; p = p.parent) {
        if (isPolishScheduled(p)) verify(waitForPolish(p))
      }
      var hoverY = row1.y - list.contentY + row1.height / 2
      mouseMove(list, 20, hoverY)
      mouseMove(list, 26, hoverY)
      tryCompare(list, "currentIndex", 1)

      // Keyboard walk and wheel scroll must not let rows under the stationary pointer steal selection.
      for (var idx = 2; idx < options.length; idx++) {
        keyClick(Qt.Key_Down)
        tryCompare(list, "currentIndex", idx)
      }
      tryVerify(function() { return list.contentY > 0 }, 2000, "keyboard walk scrolled the list")
      wait(50)
      compare(list.currentIndex, options.length - 1, "stationary pointer did not steal keyboard selection")

      var beforeY = list.contentY
      mouseWheel(list, 26, hoverY, 0, 120)
      tryVerify(function() { return list.contentY < beforeY }, 2000, "wheel scrolled the list up")
      wait(50)
      compare(list.currentIndex, options.length - 1, "stationary pointer did not steal selection during wheel scroll")

      // Deliberate pointer movement restores hover selection.
      var targetIndex = list.indexAt(36, list.contentY + hoverY)
      verify(targetIndex >= 0 && targetIndex !== options.length - 1)
      mouseMove(list, 30, hoverY)
      mouseMove(list, 36, hoverY)
      tryCompare(list, "currentIndex", targetIndex)
    }

    function test_panel_slider_wheel() {
      var slider = createTemporaryObject(panelSliderComponent, scene)
      verify(slider !== null)
      var moved = []
      slider.moved.connect(function(v) { moved.push(v) })

      // Horizontal wheel must be ignored rather than decrementing the slider.
      mouseWheel(slider, slider.width / 2, slider.height / 2, 120, 0)
      mouseWheel(slider, slider.width / 2, slider.height / 2, -120, 0)
      compare(slider.liveValue, 5)
      compare(moved, [])

      // Vertical wheel still increments and decrements by step.
      mouseWheel(slider, slider.width / 2, slider.height / 2, 0, 120)
      compare(slider.liveValue, 6)
      mouseWheel(slider, slider.width / 2, slider.height / 2, 0, -120)
      compare(slider.liveValue, 5)
      compare(moved, [6, 5])
    }

    function test_wheel_scroll_horizontal_passthrough() {
      var host = createTemporaryObject(wheelScrollHostComponent, scene)
      verify(host !== null)

      mouseWheel(host.flick, 50, 50, 120, 0)
      compare(host.flick.contentY, 50, "horizontal wheel does not scroll vertical Flickable")
      compare(host.outerWheels, 1, "horizontal wheel passes through unaccepted")

      mouseWheel(host.flick, 50, 50, 0, -120)
      verify(host.flick.contentY > 50, "vertical wheel scrolls the Flickable")
      compare(host.outerWheels, 1, "vertical wheel is consumed by WheelScroll")
    }
  }
}
