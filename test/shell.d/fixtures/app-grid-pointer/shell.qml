import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root

  property var appGrid: null
  property var view: null
  property var failures: []
  property int step: 0

  function check(condition, message) {
    if (!condition) failures = failures.concat([message + ": selected " + appGrid.selectedIndex])
  }

  function findGrid(item) {
    if (item.itemAtIndex && item.cellWidth) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findGrid(item.children[i])
      if (found) return found
    }
    return null
  }

  QtObject {
    id: library

    property bool expanded: false

    signal appsChanged()
    signal removalNeedsTerminal()

    function refreshIcons() {}
    function refreshVersions() {}
    function iconSource(icon) { return "" }
    function entryName(entry) { return entry.name }
    function version(entry) { return "" }
    function sortedEntries(filter) {
      var rows = []
      for (var i = 0; i < (filter && !expanded ? 2 : 21); i++)
        rows.push({ entry: { id: String(i), name: (filter ? "Result " : "App ") + i } })
      return rows
    }
  }

  TestCase { id: pointer; when: false }
  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT") }

  Component.onCompleted: {
    var component = Qt.createComponent(Quickshell.env("OMARCHY_PATH") + "/shell/plugins/dock/AppGrid.qml", Component.PreferSynchronous)
    appGrid = component.createObject(root, { appLibrary: library })
    if (!appGrid) {
      result.setText(JSON.stringify({ ok: false, failures: [component.errorString()] }))
      return
    }
    appGrid.open()
    driver.start()
  }

  Timer {
    id: driver
    interval: 300
    repeat: true
    onTriggered: {
      try {
        switch (root.step++) {
        case 0:
          for (var i = 0; i < root.appGrid.data.length && !root.view; i++)
            if (root.appGrid.data[i].contentItem) root.view = root.findGrid(root.appGrid.data[i].contentItem)
          if (!root.view) throw new Error("the real AppGrid has no grid")
          pointer.mouseMove(root.view, root.view.cellWidth * 1.5, root.view.cellHeight / 2)
          break
        case 1:
          root.appGrid.setFilter("result")
          break
        case 2:
          root.check(root.appGrid.selectedIndex === 0, "filtering keeps the first result under a resting pointer")
          pointer.mouseMove(root.view, root.view.cellWidth / 2, root.view.cellHeight / 2)
          pointer.mouseMove(root.view, root.view.cellWidth * 1.5, root.view.cellHeight / 2)
          break
        case 3:
          root.check(root.appGrid.selectedIndex === 1, "real pointer movement resumes selection")
          pointer.mouseMove(root.view, root.view.cellWidth * 2.5, root.view.cellHeight / 2)
          root.appGrid.setFilter("")
          break
        case 4:
          root.check(root.appGrid.selectedIndex === 0, "clearing a filter keeps selection when a cell returns under the pointer")
          root.appGrid.setFilter("result")
          pointer.mouseMove(root.view, root.view.cellWidth / 2, root.view.cellHeight / 2)
          pointer.mouseMove(root.view, root.view.cellWidth * 1.5, root.view.cellHeight / 2)
          break
        case 5:
          pointer.mouseMove(root.view, root.view.cellWidth * 2.5, root.view.cellHeight / 2)
          library.expanded = true
          library.appsChanged()
          break
        case 6:
          root.check(root.appGrid.selectedIndex === 1, "an app-list refresh keeps selection under a resting pointer")
          root.appGrid.close()
          result.setText(JSON.stringify({ ok: root.failures.length === 0, failures: root.failures }))
          stop()
          break
        }
      } catch (e) {
        result.setText(JSON.stringify({ ok: false, failures: [String(e)] }))
        stop()
      }
    }
  }
}
