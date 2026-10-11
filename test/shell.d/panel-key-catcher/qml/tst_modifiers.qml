import QtQuick
import QtTest
import "../../../../shell/Ui"

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

    function test_altWithTextKeyDoesNotFire() {
      keyClick(Qt.Key_T, Qt.AltModifier)
      compare(root.lastText, "")
      // -1 is the init value: proves no emission, unlike a bitmask check,
      // which passes vacuously since -1 & Qt.AltModifier is truthy.
      compare(root.lastModifiers, -1)
    }

    function test_shiftWithTextKeyDoesFire() {
      keyClick(Qt.Key_U, Qt.ShiftModifier)
      compare(root.lastText, "u")
      verify(root.lastModifiers & Qt.ShiftModifier)
    }
  }
}
