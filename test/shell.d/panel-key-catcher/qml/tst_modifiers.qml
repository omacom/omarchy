import QtQuick
import QtTest
import "../../../../shell/Ui"

// Text keys carry their modifiers, so a panel can tell Alt+T from T.
Item {
  id: root
  width: 100
  height: 100

  property string lastText: ""
  property int lastModifiers: -1

  PanelKeyCatcher {
    id: catcher
    anchors.fill: parent
    onTextKey: function(text, modifiers) {
      root.lastText = text
      root.lastModifiers = modifiers
    }
  }

  TestCase {
    name: "PanelKeyCatcherModifiers"
    when: windowShown

    function init() {
      catcher.forceActiveFocus()
      root.lastText = ""
      root.lastModifiers = -1
    }

    function test_plainLetterHasNoModifiers() {
      keyClick(Qt.Key_T)
      compare(root.lastText, "t")
      compare(root.lastModifiers & Qt.AltModifier, 0)
    }

    function test_altLetterCarriesAlt() {
      keyClick(Qt.Key_T, Qt.AltModifier)
      compare(root.lastText.toLowerCase(), "t")
      verify(root.lastModifiers & Qt.AltModifier)
    }
  }
}
