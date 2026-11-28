import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

// Drives Emojis with QtTest wheel and pointer events to verify 3-row wheel
// scrolling and PointerMoveGate filtering after keyboard and scroll changes.
ShellRoot {
  id: root

  property var failures: []
  property var picker: null
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

  TestCase { id: tc; name: "emojis-scroll"; when: false }
  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT"); atomicWrites: true }

  Component.onCompleted: {
    var path = Quickshell.env("OMARCHY_PATH")
    var comp = Qt.createComponent("file://" + path + "/shell/plugins/emojis/Emojis.qml")
    if (comp.status !== Component.Ready) { check(false, "Emojis.qml loads: " + comp.errorString()); finish(); return }
    picker = comp.createObject(root, { omarchyPath: path })
    picker.open("{}")
    poll.start()
  }

  Timer {
    id: poll
    interval: 100
    repeat: true
    onTriggered: {
      var grid = root.findItem(root.picker, "emojiGrid")
      var cell2 = grid && root.picker.filteredEmojis.length > 50 ? grid.itemAtIndex(2) : null
      if (!cell2) {
        if (++root.tries >= 30) { root.check(false, "Emojis grid and cells ready"); root.finish() }
        return
      }
      try {
        var px = Math.round(cell2.width / 2)
        var py = Math.round(cell2.height / 2)

        tc.mouseMove(cell2, px, py)
        tc.mouseMove(cell2, px + 6, py)
        root.check(root.picker.selectedIndex === 2, "deliberate pointer motion selects cell 2: " + root.picker.selectedIndex)

        root.picker.select(1)
        tc.mouseMove(cell2, px + 7, py)
        root.check(root.picker.selectedIndex === 3, "first hover after keyboard move keeps index 3: " + root.picker.selectedIndex)
        tc.mouseMove(cell2, px + 14, py)
        root.check(root.picker.selectedIndex === 2, "deliberate motion after keyboard move selects cell 2: " + root.picker.selectedIndex)

        var startY = grid.contentY
        var step = root.picker.cellHeight * 3
        tc.mouseWheel(grid, Math.round(grid.width / 2), Math.round(grid.height / 2), 0, -120)
        root.check(Math.abs((grid.contentY - startY) - step) <= 1, "wheel notch scrolls 3 rows: got " + (grid.contentY - startY) + " expected " + step)
        var scrolled = grid.itemAt(grid.width / 2, grid.contentY + grid.height / 2)
        if (scrolled) tc.mouseMove(scrolled, Math.round(scrolled.width / 2), Math.round(scrolled.height / 2))
        root.check(!!scrolled && root.picker.selectedIndex === 2, "wheel scroll blocks stationary hover steal: " + root.picker.selectedIndex)
      } catch (e) {
        root.check(false, "threw: " + e)
      }
      root.finish()
    }
  }
}
