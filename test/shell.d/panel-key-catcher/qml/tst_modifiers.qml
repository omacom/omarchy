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
  property int lastMoveDx: 0
  property int lastSideways: 0

  PanelKeyCatcher {
    id: catcher
    anchors.fill: parent
    onTextKey: function(text, modifiers) {
      root.lastText = text
      root.lastModifiers = modifiers
    }
    onMoveRequested: function(dx, dy) { root.lastMoveDx = dx }
    onReorderSidewaysRequested: function(dx) { root.lastSideways = dx }
  }

  TestCase {
    name: "PanelKeyCatcherModifiers"
    when: windowShown

    function init() {
      catcher.forceActiveFocus()
      root.lastText = ""
      root.lastModifiers = -1
      root.lastMoveDx = 0
      root.lastSideways = 0
      catcher.reorderableSideways = false
    }

    function test_plainLetterHasNoModifiers() {
      keyClick(Qt.Key_T)
      compare(root.lastText, "t")
      compare(root.lastModifiers & Qt.AltModifier, 0)
    }

    // Ctrl+h/l arrange sideways only where a panel asks for it; elsewhere
    // they stay plain moves, as they were for the agents panel's Ctrl+j/k.
    function test_ctrlHorizontalMovesWithoutSideways() {
      keyClick(Qt.Key_L, Qt.ControlModifier)
      compare(root.lastMoveDx, 1)
      compare(root.lastSideways, 0)
    }

    function test_ctrlHorizontalArrangesWithSideways() {
      catcher.reorderableSideways = true
      keyClick(Qt.Key_L, Qt.ControlModifier)
      compare(root.lastSideways, 1)
      keyClick(Qt.Key_H, Qt.ControlModifier)
      compare(root.lastSideways, -1)
      keyClick(Qt.Key_Right, Qt.ControlModifier)
      compare(root.lastSideways, 1)
      compare(root.lastMoveDx, 0)
    }

    function test_altLetterCarriesAlt() {
      keyClick(Qt.Key_T, Qt.AltModifier)
      compare(root.lastText.toLowerCase(), "t")
      verify(root.lastModifiers & Qt.AltModifier)
    }
  }
}
