import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

// Clicks into submenus of the real menu the way a pointer that lands and
// presses at once does: the press and release reach the window with no move
// before them, so Qt knows no position to hover the new rows from. Checks the
// row the menu then selects, the one Enter runs, against the row under the
// pointer.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var menu: null
  property var list: null
  // Where the last click left the pointer, in scene coordinates.
  property point pointer: Qt.point(0, 0)
  property var steps: []
  property int step: 0

  function check(condition, message) {
    if (!condition) failures = failures.concat([String(message)])
  }

  function findList(item) {
    if (!item) return null
    if (item instanceof ListView) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = root.findList(item.children[i])
      if (found) return found
    }
    return null
  }

  function label(index) {
    return index >= 0 && index < root.list.count ? root.list.model.get(index).label : "no row"
  }

  function rowUnderPointer() {
    for (var i = 0; i < root.list.count; i++) {
      var row = root.list.itemAtIndex(i)
      if (row && row.contains(row.mapFromItem(null, root.pointer.x, root.pointer.y))) return i
    }
    return -1
  }

  function click(index) {
    var row = root.list.itemAtIndex(index)
    root.pointer = row.mapToItem(null, row.width / 2, row.height / 2)
    tc.mouseClick(row, row.width / 2, row.height / 2)
  }

  TestCase {
    id: tc
    name: "menu-pointer"
    when: false
  }

  FileView {
    id: result
    path: root.resultPath
  }

  Component.onCompleted: {
    steps = [
      [function() {
        var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/menu/Menu.qml")
        if (component.status !== Component.Ready) {
          root.check(false, "Menu.qml loads: " + component.errorString())
          return
        }
        root.menu = component.createObject(root, { defaultMenuPath: Quickshell.env("MENU_FIXTURE_FILE") })
      }, 1000],
      [function() {
        root.menu.open("{}")
      }, 1000],
      [function() {
        for (var i = 0; i < root.menu.data.length && !root.list; i++) {
          if (root.menu.data[i] && root.menu.data[i].contentItem) root.list = root.findList(root.menu.data[i].contentItem)
        }
        root.check(root.list && root.list.count === 3, "the menu opens on One, Two and Three")
        root.click(2)
      }, 400],
      [function() {
        var under = root.rowUnderPointer()
        root.check(root.menu.activeMenu === "three", "clicking Three opens its submenu: " + root.menu.activeMenu)
        root.check(under > 0, "a row past the first is left under the pointer: " + root.label(under))
        root.check(root.menu.selectedIndex === under, "the row left under the pointer, " + root.label(under) + ", is selected, not " + root.label(root.menu.selectedIndex))
        var first = root.list.itemAtIndex(0)
        tc.mouseMove(first, first.width / 2, first.height / 2)
      }, 200],
      [function() {
        root.check(root.menu.selectedIndex === 0, "moving the pointer still selects the row it reaches: " + root.label(root.menu.selectedIndex))
        // What Backspace, Down, Down and Enter run.
        root.menu.goBack()
        root.menu.select(1)
        root.menu.select(1)
        root.menu.activateIndex(root.menu.selectedIndex)
      }, 400],
      [function() {
        root.check(root.menu.activeMenu === "three" && root.menu.selectedIndex === 0, "Enter into a submenu starts on its first row: " + root.menu.activeMenu + " " + root.label(root.menu.selectedIndex))
        root.menu.goBack()
      }, 400],
      [function() {
        root.click(1)
      }, 400],
      [function() {
        root.check(root.menu.activeMenu === "two" && root.rowUnderPointer() === -1, "Two's one row is not under the pointer: " + root.rowUnderPointer())
        root.check(root.menu.selectedIndex === 0, "with no row under the pointer the first stays selected: " + root.label(root.menu.selectedIndex))
      }, 100]
    ]
    stepper.start()
  }

  Timer {
    id: stepper
    interval: 10
    onTriggered: {
      if (root.step >= root.steps.length) {
        result.setText(JSON.stringify({ ok: root.failures.length === 0, failures: root.failures }))
        quitter.start()
        return
      }
      var current = root.steps[root.step++]
      try {
        current[0]()
      } catch (e) {
        root.check(false, "step " + root.step + " threw: " + e)
      }
      interval = current[1]
      restart()
    }
  }

  Timer {
    id: quitter
    interval: 200
    onTriggered: Qt.quit()
  }
}
