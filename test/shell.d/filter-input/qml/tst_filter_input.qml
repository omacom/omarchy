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
      input.selectAll()
      compare(input.selectedText, "")
      keyClick(Qt.Key_S)
      compare(input.text, "terms")
    }
  }
}
