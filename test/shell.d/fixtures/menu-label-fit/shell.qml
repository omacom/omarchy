import QtQuick
import Quickshell
import qs.plugins.menu

ShellRoot {
  id: test
  property int step: 0
  property bool failed: false

  Menu {
    id: menu
    defaultMenuPath: Quickshell.env("MENU_LABEL_FIT_FILE")
    userMenuPath: "/nonexistent-menu-label-fit"
    fontFamily: "monospace"
  }

  function labelItem(node, seen) {
    if (!node || seen.indexOf(node) !== -1) return null
    seen.push(node)
    if (node.text === "MMMMMMMMMMMMMMMMMMMMMMMM") return node
    var children = node.data || node.children || []
    for (var i = 0; i < children.length; i++) {
      var found = labelItem(children[i], seen)
      if (found) return found
    }
    return labelItem(node.contentItem, seen)
  }

  Timer {
    interval: 150
    running: true
    repeat: true
    onTriggered: {
      if (!menu.rowsLoaded) return
      if (test.step === 0) {
        menu.open('{"menu":"fit"}')
      } else {
        var label = test.labelItem(menu, [])
        if (!label || label.truncated || label.width < label.implicitWidth || label.width - label.implicitWidth > 3) {
          test.failed = true
          console.log("RESULT fail", test.step, label ? label.width : "no label", label ? label.implicitWidth : "")
        }
        if (test.step === 1) menu.fontFamily = "DejaVu Sans"
        else if (test.step === 2) {
          menu.open('{"menu":"altfit"}')
          menu.altHeld = true
        } else {
          console.log(test.failed ? "RESULT fail" : "RESULT pass")
          Qt.quit()
        }
      }
      test.step++
    }
  }
}
