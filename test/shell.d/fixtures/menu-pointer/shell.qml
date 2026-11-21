import QtQuick
import Quickshell

// Clicks into Bar Background the way an absolute pointer does, with no hover
// before or after, and expects the row left under the pointer to be selected.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var menu: null
  property var list: null
  property int waited: 0
  property bool summoned: false

  function finish(failure) {
    var payload = JSON.stringify({ ok: !failure, failures: failure ? [failure] : [] })
    Quickshell.execDetached(["bash", "-c", "printf '%s' \"$1\" >\"$2\"", "bash", payload, resultPath])
    if (menu) menu.close()
  }

  function findList(item) {
    if (item.indexAt && item.itemAtIndex && item.model) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findList(item.children[i])
      if (found) return found
    }
    return null
  }

  function rowIndex(itemId) {
    for (var i = 0; i < list.model.count; i++)
      if (list.model.get(i).itemId === itemId) return i
    return -1
  }

  Component.onCompleted: {
    var component = Qt.createComponent(Quickshell.env("OMARCHY_PATH") + "/shell/plugins/menu/Menu.qml", Component.PreferSynchronous)
    menu = component.createObject(root)
    if (!menu) finish("Menu.qml failed to load: " + component.errorString())
  }

  Timer {
    interval: 100
    repeat: true
    running: true
    onTriggered: {
      if (++root.waited > 100) { running = false; return root.finish("the Menu Bar submenu never settled") }
      if (!root.menu || !root.menu.rowsLoaded) return
      if (!root.summoned) {
        root.summoned = true
        root.menu.open(JSON.stringify({ menu: "appearance.top-bar" }))
      }
      if (root.menu.guardsPending) return
      // The rows live in the menu's own window.
      for (var i = 0; i < root.menu.data.length && !root.list; i++)
        if (root.menu.data[i].contentItem) root.list = root.findList(root.menu.data[i].contentItem)
      if (!root.list) return
      // Bar Background is the third row, as Clear Bar is in the submenu it opens.
      var clicked = root.rowIndex("appearance.top-bar.background")
      var row = clicked === 2 ? root.list.itemAtIndex(clicked) : null
      if (!row) return
      running = false

      var point = row.mapToItem(null, row.width / 2, row.height / 2)
      root.menu.cursorActive = true
      root.menu.selectedIndex = clicked
      root.menu.activateIndex(clicked, point)

      var selected = root.list.model.get(root.menu.selectedIndex).itemId
      if (selected !== "appearance.top-bar.background.clear")
        return root.finish("the row left under the pointer, Clear Bar, is selected, not " + selected)
      root.finish("")
    }
  }
}
