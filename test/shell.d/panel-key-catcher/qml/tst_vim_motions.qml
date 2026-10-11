import QtQuick
import QtTest
import "../../../../shell/Ui"

// Vim motions: h/j/k/l move the cursor on plain press only. A shifted letter
// is a text key (dropbox Shift+L logs in, elsewhen Shift+J jumps the globe);
// on searchable panels a plain letter types and Ctrl+letter moves instead.
Item {
  id: root
  width: 100
  height: 100

  property int moveCount: 0
  property int lastDx: 0
  property int lastDy: 0
  property int textCount: 0
  property string lastText: ""
  property int lastModifiers: -1
  property bool swallowG: false

  PanelKeyCatcher {
    id: catcher
    anchors.fill: parent
    onHandleCustomKeys: function(event) {
      if (root.swallowG && event.key === Qt.Key_G) event.accepted = true
    }
    onMoveRequested: function(dx, dy) {
      root.moveCount++
      root.lastDx = dx
      root.lastDy = dy
    }
    onTextKey: function(text, modifiers) {
      root.textCount++
      root.lastText = text
      root.lastModifiers = modifiers
    }
  }

  TestCase {
    name: "PanelKeyCatcherVimMotions"
    when: windowShown

    function init() {
      catcher.forceActiveFocus()
      catcher.searchable = false
      root.moveCount = 0
      root.lastDx = 0
      root.lastDy = 0
      root.textCount = 0
      root.lastText = ""
      root.lastModifiers = -1
      root.swallowG = false
    }

    function test_plainMotionsMove() {
      keyClick(Qt.Key_J)
      compare(root.lastDx, 0)
      compare(root.lastDy, 1)
      keyClick(Qt.Key_K)
      compare(root.lastDx, 0)
      compare(root.lastDy, -1)
      keyClick(Qt.Key_H)
      compare(root.lastDx, -1)
      compare(root.lastDy, 0)
      keyClick(Qt.Key_L)
      compare(root.lastDx, 1)
      compare(root.lastDy, 0)
      compare(root.moveCount, 4)
      compare(root.textCount, 0)
    }

    function test_searchablePlainLetterTypes() {
      catcher.searchable = true
      keyClick(Qt.Key_J)
      compare(root.moveCount, 0)
      compare(root.textCount, 1)
      compare(root.lastText, "j")
    }

    function test_searchableCtrlMotionMoves() {
      catcher.searchable = true
      keyClick(Qt.Key_J, Qt.ControlModifier)
      compare(root.moveCount, 1)
      compare(root.lastDx, 0)
      compare(root.lastDy, 1)
      compare(root.textCount, 0)
    }

    function test_customKeysRunFirst() {
      root.swallowG = true
      keyClick(Qt.Key_G)
      compare(root.moveCount, 0)
      compare(root.textCount, 0)
    }
  }
}
