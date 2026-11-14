import QtQuick
import QtTest
import "../../../../shell/Ui"

// The search line types what its panel leaves alone, and nothing else.
Item {
  id: root
  width: 200
  height: 100

  Item {
    id: handler
    property var handled: []
    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Up || event.key === Qt.Key_Return) {
        handler.handled = handler.handled.concat([event.key])
        event.accepted = true
      } else if (event.key === Qt.Key_Backspace && input.text) {
        // Like the menu, the panel edits the query a character at a time.
        input.text = input.text.slice(0, -1)
        event.accepted = true
      }
    }
  }

  FilterInput {
    id: input
    width: parent.width
    keyHandler: handler
  }

  TestCase {
    name: "FilterInput"
    when: windowShown

    function init() {
      input.readOnly = false
      input.text = ""
      handler.handled = []
      input.forceActiveFocus()
    }

    function test_typesPrintableKeys() {
      keyClick("t")
      keyClick(Qt.Key_Space)
      keyClick("e")
      compare(input.text, "t e")
    }

    function test_handlerSeesKeysFirst() {
      keyClick(Qt.Key_Up)
      keyClick(Qt.Key_Return)
      compare(handler.handled, [Qt.Key_Up, Qt.Key_Return])
      compare(input.text, "")
    }

    function test_altAndSuperChordsDoNotType() {
      keyClick(Qt.Key_T, Qt.AltModifier)
      keyClick(Qt.Key_T, Qt.MetaModifier)
      compare(input.text, "")
    }

    function test_readOnlyTypesNothing() {
      input.readOnly = true
      keyClick(Qt.Key_T)
      compare(input.text, "")
    }

    function test_caretStaysAtTheEnd() {
      input.text = "term"
      input.cursorPosition = 0
      compare(input.cursorPosition, 4)
      keyClick(Qt.Key_S)
      compare(input.text, "terms")
    }

    function test_ctrlASelectsTheWholeQuery() {
      input.text = "term"
      keyClick(Qt.Key_A, Qt.ControlModifier)
      compare(input.selectedText, "term")
    }

    function test_typingReplacesTheSelectedQuery() {
      input.text = "term"
      keyClick(Qt.Key_A, Qt.ControlModifier)
      keyClick("f")
      compare(input.text, "f")
      compare(input.selectedText, "")
    }

    function test_backspaceClearsTheSelectedQuery() {
      input.text = "two words"
      keyClick(Qt.Key_A, Qt.ControlModifier)
      keyClick(Qt.Key_Backspace)
      compare(input.text, "")
    }
  }
}
