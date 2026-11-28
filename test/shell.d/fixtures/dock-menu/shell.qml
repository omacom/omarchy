import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

// Drives AppGrid's context menu with QtTest pointer events to guard dismiss,
// hover suppression, menu switching, padding clicks, and normal launch.
ShellRoot {
  id: root

  property var failures: []
  property var launched: []
  property var appGrid: null
  property int tries: 0

  function check(cond, msg) { if (!cond) failures.push(String(msg)) }

  function findItem(item, name) {
    if (!item) return null
    if (item.objectName === name) return item
    if (item.contentItem) { var hit = findItem(item.contentItem, name); if (hit) return hit }
    var list = item.data || item.children || []
    for (var i = 0; i < list.length; i++) {
      if (list[i] === item || list[i] === item.contentItem) continue
      var found = findItem(list[i], name)
      if (found) return found
    }
    return null
  }

  function finish() {
    poll.stop()
    result.setText(JSON.stringify({ ok: failures.length === 0, failures: failures }))
  }

  QtObject {
    id: fakeLibrary
    signal appsChanged()
    signal removalNeedsTerminal()
    readonly property var entries: ["alpha", "beta", "gamma", "delta"].map(function(id) { return { id: id, name: id, icon: "" } })
    function refreshIcons() {}
    function refreshVersions() {}
    function sortedEntries() { return entries.map(function(e) { return { entry: e } }) }
    function iconSource() { return "" }
    function entryName(e) { return e ? e.name : "" }
    function version() { return "" }
    function launch(id) { root.launched.push(String(id)) }
    function remove() {}
  }

  TestCase { id: tc; name: "dock-menu"; when: false }
  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT"); atomicWrites: true }

  Component.onCompleted: {
    var comp = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/dock/AppGrid.qml")
    if (comp.status !== Component.Ready) { check(false, "AppGrid.qml loads: " + comp.errorString()); finish(); return }
    appGrid = comp.createObject(root, { appLibrary: fakeLibrary })
    appGrid.open()
    poll.start()
  }

  Timer {
    id: poll
    interval: 100
    repeat: true
    onTriggered: {
      var grid = root.findItem(root.appGrid, "appGrid")
      var menu = root.findItem(root.appGrid, "appGridMenu")
      var cell0 = grid ? grid.itemAtIndex(0) : null
      var cell3 = grid ? grid.itemAtIndex(3) : null
      if (!cell0 || !cell3 || !menu) {
        if (++root.tries >= 30) { root.check(false, "AppGrid cells and menu ready"); root.finish() }
        return
      }
      try {
        tc.mouseClick(cell0, 10, 10, Qt.RightButton)
        root.check(root.appGrid.menuEntry && root.appGrid.menuEntry.id === "alpha" && root.appGrid.selectedIndex === 0 && menu.visible, "right-click opens alpha menu")
        tc.mouseMove(cell3, cell3.width / 2, cell3.height / 2)
        root.check(root.appGrid.selectedIndex === 0, "hover while menu open keeps alpha selected")

        tc.mouseClick(cell3, cell3.width / 2, cell3.height / 2, Qt.LeftButton)
        root.check(root.appGrid.menuEntry === null && root.launched.length === 0 && root.appGrid.selectedIndex === 3, "left-click dismisses without launching and selects delta")

        tc.mouseClick(cell0, 10, 10, Qt.RightButton)
        tc.mouseClick(cell3, cell3.width / 2, cell3.height / 2, Qt.RightButton)
        root.check(root.appGrid.menuEntry && root.appGrid.menuEntry.id === "delta" && root.appGrid.selectedIndex === 3, "right-click switches menu and selection to delta")

        tc.mouseClick(menu, 2, 2, Qt.LeftButton)
        root.check(root.appGrid.menuEntry && root.appGrid.menuEntry.id === "delta" && root.launched.length === 0, "menu padding click is swallowed")

        tc.mouseClick(cell0, 10, 10, Qt.LeftButton)
        tc.mouseClick(cell3, cell3.width / 2, cell3.height / 2, Qt.LeftButton)
        root.check(JSON.stringify(root.launched) === '["delta"]', "normal click after dismiss launches delta: " + JSON.stringify(root.launched))
      } catch (e) {
        root.check(false, "threw: " + e)
      }
      root.finish()
    }
  }
}
