import QtQuick
import Quickshell

// Back out of Appearance, entered from the root menu and then summoned straight
// into, must leave the cursor on Appearance rather than the first row.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var menu: null
  property var list: null
  property int waited: 0
  property string stage: "open"

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

  function selectedId() {
    return root.menu.cursorActive ? root.list.model.get(root.menu.selectedIndex).itemId : ""
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
      if (++root.waited > 100) { running = false; return root.finish("the menu never settled at stage " + root.stage) }
      if (!root.menu || !root.menu.rowsLoaded) return

      if (root.stage === "open") {
        root.stage = "entered"
        return root.menu.open("{}")
      }
      if (root.menu.guardsPending) return
      // The rows live in the menu's own window.
      for (var i = 0; i < root.menu.data.length && !root.list; i++)
        if (root.menu.data[i].contentItem) root.list = root.findList(root.menu.data[i].contentItem)
      if (!root.list) return

      if (root.stage === "entered") {
        var appearance = root.rowIndex("appearance")
        if (appearance <= 0) return
        root.menu.cursorActive = true
        root.menu.selectedIndex = appearance
        root.menu.activateIndex(appearance)
        if (root.menu.activeMenu !== "appearance") { running = false; return root.finish("entering Appearance opened " + root.menu.activeMenu) }
        root.menu.goBack()
        if (root.selectedId() !== "appearance") { running = false; return root.finish("back from an entered Appearance lands on " + root.selectedId() + ", not Appearance") }
        root.stage = "summoned"
        return root.menu.open(JSON.stringify({ menu: "appearance" }))
      }

      running = false
      if (root.menu.activeMenu !== "appearance") return root.finish("summoning Appearance opened " + root.menu.activeMenu)
      root.menu.goBack()
      if (root.selectedId() !== "appearance") return root.finish("back from a summoned Appearance lands on " + root.selectedId() + ", not Appearance")
      root.finish("")
    }
  }
}
