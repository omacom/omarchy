import QtQuick
import Quickshell
import qs.Ui

// Drives the real KeyboardPanel through open, close and reopen. The panels
// are pinned invisible so nothing maps on the desktop running the test; the
// content Loader follows `open`, not visibility.
ShellRoot {
  id: test
  property bool failed: false
  property int builds: 0
  property real formHeight: 42

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
