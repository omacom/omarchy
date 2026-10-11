import QtQuick
import QtTest
import "../../../../shell/Ui"

// Delete requests: Delete and plain x/X both fire, the key event rides along
// so panels can tell Shift+Delete from Delete, and a searchable panel's "x"
// types into the filter instead of deleting.
Item {
  id: root
  width: 100
  height: 100

  property int deleteCount: 0
  property bool deleteHadEvent: false
  property int lastDeleteModifiers: -1
  property int textCount: 0
  property string lastText: ""

  PanelKeyCatcher {
    id: catcher
    anchors.fill: parent
    onDeleteRequested: function(event) {
      root.deleteCount++
      root.deleteHadEvent = (event !== undefined && event !== null)
      root.lastDeleteModifiers = root.deleteHadEvent ? event.modifiers : -1
    }
    onTextKey: function(text, modifiers) {
      root.textCount++
      root.lastText = text
    }
  }

  TestCase {
    name: "PanelKeyCatcherDelete"
    when: windowShown

    function init() {
      catcher.forceActiveFocus()
      catcher.searchable = false
      root.deleteCount = 0
      root.deleteHadEvent = false
      root.lastDeleteModifiers = -1
      root.textCount = 0
      root.lastText = ""
    }

    function test_deleteKeyFiresDelete() {
      keyClick(Qt.Key_Delete)
      compare(root.deleteCount, 1)
    }

    function test_plainXFiresDelete() {
      keyClick(Qt.Key_X)
      compare(root.deleteCount, 1)
      compare(root.textCount, 0)
    }

    function test_shiftXFiresDelete() {
      keyClick(Qt.Key_X, Qt.ShiftModifier)
      compare(root.deleteCount, 1)
      compare(root.textCount, 0)
    }

    function test_deleteCarriesEvent() {
      keyClick(Qt.Key_Delete, Qt.ShiftModifier)
      compare(root.deleteCount, 1)
      verify(root.deleteHadEvent)
      verify(root.lastDeleteModifiers & Qt.ShiftModifier)
    }

    function test_searchableXGoesToText() {
      catcher.searchable = true
      keyClick(Qt.Key_X)
      compare(root.deleteCount, 0)
      compare(root.textCount, 1)
      compare(root.lastText, "x")
    }
  }
}
