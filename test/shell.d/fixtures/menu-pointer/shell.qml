import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

// Clicks into a submenu the way a pointer that lands and presses at once does,
// with no move first, so Qt sends the new rows no hover. The row the menu then
// selects, the one Enter runs, must be the row left under the pointer.
ShellRoot {
  id: root

  property var menu: null
  property var list: null
  property point pointer

  function findList(item) {
    if (item instanceof ListView) return item
    for (var i = 0; item && i < item.children.length; i++) {
      var found = root.findList(item.children[i])
      if (found) return found
    }
    return null
  }

  function rowUnderPointer() {
    for (var i = 0; i < root.list.count; i++) {
      var row = root.list.itemAtIndex(i)
      if (row && row.contains(row.mapFromItem(null, root.pointer.x, root.pointer.y))) return i
    }
    return -1
  }

  TestCase { id: tc; when: false }
  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT") }
  Timer { id: quitter; interval: 200; onTriggered: Qt.quit() }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/menu/Menu.qml")
    root.menu = component.createObject(root, { defaultMenuPath: Quickshell.env("MENU_FIXTURE_FILE") })
    opener.start()
  }

  Timer {
    id: opener
    interval: 1000
    onTriggered: { root.menu.open("{}"); clicker.start() }
  }

  Timer {
    id: clicker
    interval: 1000
    onTriggered: {
      for (var i = 0; i < root.menu.data.length && !root.list; i++) {
        if (root.menu.data[i] && root.menu.data[i].contentItem) root.list = root.findList(root.menu.data[i].contentItem)
      }
      var three = root.list.itemAtIndex(1)
      root.pointer = three.mapToItem(null, three.width / 2, three.height / 2)
      tc.mouseClick(three, three.width / 2, three.height / 2)
      checker.start()
    }
  }

  Timer {
    id: checker
    interval: 400
    onTriggered: {
      var under = root.rowUnderPointer()
      var ok = root.menu.activeMenu === "three" && under > 0 && root.menu.selectedIndex === under
      result.setText(JSON.stringify({ ok: ok, menu: root.menu.activeMenu, under: under, selected: root.menu.selectedIndex }))
      quitter.start()
    }
  }
}
