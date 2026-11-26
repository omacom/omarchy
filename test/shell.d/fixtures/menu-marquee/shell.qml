import QtQuick
import Quickshell
import qs.Commons

// Opens a select menu much narrower than its first option. With the cursor on
// the short row, the long label is cut off and still; with the cursor on it, it
// scrolls to its end; with the cursor back on the short row, it is at rest
// again and the short label, which fits, never moves. With the cursor back on
// the long row and the menu closed, the long label is at rest too.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  // Wider than the 200 wide card it opens in, where "Short" fits (Style.space() scales both), yet
  // short enough to scroll to its end well within the fixture's time.
  readonly property string longLabel: "SUPER SHIFT + Z → Sleep when all Claude Code sessions are done (arm / disarm)"
  property var menu: null
  property var list: null
  property var longRow: null
  property int waited: 0
  property bool summoned: false
  property bool scrolled: false
  property bool atRest: false
  property bool restedAgain: false
  property bool closed: false
  property string lastWidths: "no rows"

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

  function findLabel(item, text) {
    if (item.text === text && item.elide !== undefined) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findLabel(item.children[i], text)
      if (found) return found
    }
    return null
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
      // Style reads the desktop's own animation setting; with it off nothing may
      // scroll, so hold motion on here to test the scroll itself.
      Style.reduceMotion = false
      if (++root.waited > 120) { running = false; return root.finish(root.atRest ? "the long label never scrolled to its end" : "the long label was never cut off (" + root.lastWidths + ")") }
      if (!root.menu) return
      if (!root.summoned) {
        root.summoned = true
        root.menu.open(JSON.stringify({ mode: "select", prompt: "Keys", options: [root.longLabel, "Short"], width: 200 }))
        return
      }
      for (var i = 0; i < root.menu.data.length && !root.list; i++)
        if (root.menu.data[i].contentItem) root.list = root.findList(root.menu.data[i].contentItem)
      if (!root.list || root.list.count < 2) return

      if (!root.longRow) {
        // The menu opens with the cursor on the first row; start from the short one.
        root.menu.cursorActive = true
        root.menu.selectedIndex = 1
        root.longRow = root.list.itemAtIndex(0)
        return
      }

      if (!root.atRest) {
        var label = root.findLabel(root.longRow, root.longLabel)
        if (!label) { running = false; return root.finish("the long row has no label") }
        // The row lays out after it is created; wait for the label to be cut off.
        root.lastWidths = "label " + label.width + " of " + label.implicitWidth
        if (!label.truncated) return
        if (root.longRow.marquee || label.x !== 0) { running = false; return root.finish("the long label moves without the cursor") }
        root.atRest = true
        root.menu.selectedIndex = 0
        return
      }

      var longLabel = root.findLabel(root.longRow, root.longLabel)
      if (!root.scrolled) {
        if (!root.longRow.marquee) { running = false; return root.finish("the long row with the cursor does not scroll") }
        if (longLabel.x > -root.longRow.labelOverflow + 1) return
        root.scrolled = true
        root.menu.selectedIndex = 1
        return
      }

      if (!root.restedAgain) {
        var shortRow = root.list.itemAtIndex(1)
        if (root.longRow.marquee || longLabel.x !== 0 || !longLabel.truncated) { running = false; return root.finish("the long label did not come back to rest when the cursor left it") }
        // A compositor that ignores layer-shell sizes leaves the card too narrow for
        // anything; say so rather than blame the patch.
        if (shortRow.labelOverflow > 0) { running = false; return root.finish("SETUP: the card (" + root.menu.cardWidth + " wide) is too narrow even for the short label; run on a compositor with layer-shell") }
        if (shortRow.marquee) { running = false; return root.finish("a label that fits scrolls") }
        root.restedAgain = true
        root.menu.selectedIndex = 0
        return
      }

      if (!root.closed) {
        if (!root.longRow.marquee) { running = false; return root.finish("the long row with the cursor does not scroll the second time") }
        if (longLabel.x > -1) return
        root.closed = true
        root.menu.close()
        return
      }

      running = false
      if (root.longRow.marquee || longLabel.x !== 0)
        return root.finish("the long label keeps scrolling after the menu closed")
      root.finish("")
    }
  }
}
