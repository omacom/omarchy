import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Ui
import qs.Commons

// Drives the real KeyboardPanel through open, close and reopen. The panels
// are pinned invisible so nothing maps on the desktop running the test; the
// content Loader follows `open`, not visibility.
ShellRoot {
  id: test
  property bool failed: false
  property int builds: 0
  property real formHeight: 42

  QtObject {
    id: audioCursor
    property var panel: scrolling
    property var root: ({focusSection: "input", selectedIndex: 0})
    // AUDIO_CURSOR_HELPER
  }

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  Item {
    id: anchor
    width: 10
    height: 10
  }

  KeyboardPanel {
    id: lazy
    anchorItem: anchor
    bar: null
    visible: false
    focusTarget: lazy.loadedContent
    scrollOverflow: true

    content: Item {
      implicitHeight: test.formHeight
      ListView {
        width: parent.width
        height: 240
        model: 20
        delegate: Item { width: 100; height: 30 }
      }
      TextInput {
        objectName: "password-field"
        y: 600
        width: 100
        height: 30
      }
      Component.onCompleted: test.builds++
    }
  }

  KeyboardPanel {
    id: scrolling
    anchorItem: anchor
    bar: null
    visible: false
    contentHeight: 220
    focusTarget: scrolling.loadedContent
    content: PanelKeyCatcher {
      property alias scrollArea: innerScroll
      property alias selectedRow: bottomRow
      implicitHeight: 700
      ScrollView {
        id: innerScroll
        anchors.fill: parent
        Column {
          width: innerScroll.availableWidth
          Item { width: 100; height: 600 }
          Item { id: bottomRow; width: 100; height: 100 }
        }
      }
    }
  }

  KeyboardPanel {
    id: powerForm
    anchorItem: anchor
    bar: null
    visible: false
    contentHeight: 180
    scrollOverflow: POWER_SCROLL_POLICY
    focusTarget: powerForm.loadedContent
    content: PanelKeyCatcher {
      implicitHeight: 700
      property alias profileButton: profileButton
      Button {
        id: profileButton
        y: 620
        width: 100
        height: 40
        text: "Power profile"
      }
    }
  }

  KeyboardPanel {
    id: eager
    anchorItem: anchor
    bar: null
    visible: false

    Item { id: eagerChild }
  }

  Timer {
    interval: 100
    running: true
    onTriggered: {
      test.check(lazy.loadedContent === null && test.builds === 0, "a closed panel has not built its content")
      test.check(lazy.loadedContentHeight === 0, "an unbuilt panel reports no content height")

      lazy.open = true
      var first = lazy.loadedContent
      test.check(first !== null && test.builds === 1, "opening builds the content")
      test.check(lazy.focusTarget === first, "a focus target inside the content resolves on open")
      test.check(lazy.loadedContentHeight === 42, "the content's height reaches the panel")

      function find(item, name) {
        if (item.objectName === name) return item
        for (var i = 0; i < item.children.length; i++) {
          var found = find(item.children[i], name)
          if (found) return found
        }
        return null
      }
      var holder = first.parent.parent
      var viewport = holder.parent.parent
      test.check(viewport.objectName === "keyboard-panel-content-viewport", "production content uses the scroll viewport")
      test.formHeight = 700
      lazy.contentHeight = 220
      test.check(viewport.contentHeight >= 700 && viewport.interactive, "a capped card keeps the full form scrollable")
      viewport.contentY = 600
      var password = find(first, "password-field")
      var point = password.mapToItem(viewport, 0, 0)
      test.check(point.y >= 0 && point.y + password.height <= viewport.height, "the lower password field can be scrolled into view")
      lazy.contentHeight = 900
      viewport.returnToBounds()
      test.check(!viewport.interactive, "scrolling disables when the complete form fits again")

      scrolling.open = true
      var inner = scrolling.loadedContent.scrollArea.contentItem
      var outer = scrolling.loadedContent.parent.parent.parent.parent
      test.check(!outer.interactive && inner.height < inner.contentHeight,
        "existing ScrollViews keep the constrained viewport and own their scrolling")
      // PanelKeyCatcher retains the focus target, just as audio's cursor model
      // does; visibility must not rely on focus moving into a selected row.
      test.check(scrolling.focusTarget === scrolling.loadedContent, "the key catcher remains the focus target")
      var selected = scrolling.loadedContent.selectedRow
      audioCursor.ensureCursorVisible(selected)
      var selectedPoint = selected.mapToItem(outer, 0, 0)
      test.check(selectedPoint.y >= -0.5 && selectedPoint.y + selected.height <= outer.height + 0.5,
        "inner keyboard scrolling can reveal the bottom selected row without outer focus changes")
      scrolling.open = false

      powerForm.open = true
      var powerViewport = powerForm.loadedContent.parent.parent.parent.parent
      var profile = powerForm.loadedContent.profileButton
      powerForm.contentHeight = 900
      powerForm.ensureItemVisible(profile)
      powerForm.contentHeight = 180
      powerViewport.revealFocusedItem()
      var profilePoint = profile.mapToItem(powerViewport, 0, 0)
      test.check(powerViewport.interactive && profilePoint.y >= 0 && profilePoint.y + profile.height <= powerViewport.height,
        "the production power scroll policy keeps its lower profile controls reachable")
      powerForm.open = false

      lazy.contentHeight = 220
      viewport.contentY = 0
      lazy.ensureItemVisible(password)
      point = password.mapToItem(viewport, 0, 0)
      test.check(point.y >= 0 && point.y + password.height <= viewport.height,
        "outer-scroll panels can reveal a selected control while the key catcher retains focus")

      lazy.open = false
      test.check(lazy.loadedContent === first, "closing keeps the content")

      lazy.open = true
      test.check(lazy.loadedContent === first && test.builds === 1, "reopening reuses the content")
      lazy.open = false

      test.check(eager.loadedContent === null && eagerChild.parent !== null, "panels with direct children still build them eagerly")

      console.log(test.failed ? "RESULT fail" : "RESULT pass")
      Qt.quit()
    }
  }
}
