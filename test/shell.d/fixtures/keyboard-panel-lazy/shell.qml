import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Drives the real KeyboardPanel through open, close and reopen. The panels
// are pinned invisible so nothing maps on the desktop running the test; the
// content Loader follows `open`, not visibility.
ShellRoot {
  id: test
  property bool failed: false
  property int builds: 0

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
      implicitHeight: 42
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

      lazy.editing = true
      test.check(lazy.WlrLayershell.keyboardFocus === WlrKeyboardFocus.OnDemand, "an editor can return keyboard focus to another window")
      test.check(lazy.mask.width > 0 && lazy.mask.height > 0, "the editor's card still receives pointer input")
      lazy.yielding = true
      test.check(lazy.WlrLayershell.keyboardFocus === WlrKeyboardFocus.None, "yielding also releases the keyboard during editing")
      Desktop.clicked()
      test.check(lazy.open, "a desktop click leaves a yielding editor open")
      lazy.yielding = false
      Desktop.clicked()
      test.check(!lazy.open, "a desktop click dismisses an editor")
      test.check(lazy.mask.width === 0 && lazy.mask.height === 0, "a closed editor releases pointer input before the fade")
      test.check(lazy.loadedContent === first, "closing keeps the content")

      lazy.editing = false
      lazy.open = true
      test.check(lazy.loadedContent === first && test.builds === 1, "reopening reuses the content")
      Desktop.clicked()
      test.check(lazy.open, "normal panels retain their own outside-click handling")
      lazy.open = false

      test.check(eager.loadedContent === null && eagerChild.parent !== null, "panels with direct children still build them eagerly")

      console.log(test.failed ? "RESULT fail" : "RESULT pass")
      Qt.quit()
    }
  }
}
