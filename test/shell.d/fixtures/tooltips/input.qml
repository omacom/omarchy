//@ pragma RespectSystemStyle
import QtQuick
import QtQuick.Controls as QQC
import QtTest
import Quickshell
import qs.Ui as Ui
import qs.Commons
import qs.Commons as Commons

// QtTest dispatches events within an offscreen window. This verifies input
// handling without controlling the user's desktop or claiming physical hover.
ShellRoot {
  FloatingWindow {
    id: window
    implicitWidth: 600
    implicitHeight: 450
    Ui.Button {
      id: source
      x: 100; y: 100
      text: "Interactive"
      focusable: true
      onClicked: rich.openForKeyboard()
      HoverHandler { id: sourceHover }
      Ui.HoverCard {
        id: rich
        delay: 80
        closeDelay: 80
        sourceHovered: sourceHover.hovered
        content: FocusScope {
          property alias first: first
          property alias second: second
          implicitHeight: actionsColumn.implicitHeight
          Column {
            id: actionsColumn
            Ui.Button { id: first; text: "First"; focusable: true; focus: true; onClicked: checks.actions++ }
            Ui.Button { id: second; text: "Second"; focusable: true }
          }
        }
      }
    }
    Ui.Button { id: outside; x: 420; y: 320; text: "Outside"; focusable: true }
    QQC.Button {
      id: ordinary
      x: 20; y: 20
      text: "Standard hint"
      hoverEnabled: true
      QQC.ToolTip.text: "An unchanged attached tooltip"
      QQC.ToolTip.visible: hovered
    }
    TestCase {
      id: checks
      name: "TooltipInput"
      when: window.visible
      property int actions: 0
      property int passed: 0
      function initTestCase() { Style.reduceMotion = true }
      function init() {
        Style.reduceMotion = true
        rich.close()
        mouseMove(window.contentItem, 580, 430)
        wait(100)
        source.forceActiveFocus()
      }
      function cleanup() {
        rich.close()
        mouseMove(window.contentItem, 580, 430)
        wait(100)
      }
      function test_standard_hint() {
        mouseMove(ordinary, ordinary.width / 2, ordinary.height / 2)
        tryCompare(ordinary.QQC.ToolTip.toolTip, "visible", true)
        verify(source.activeFocus, "plain hover keeps source focus")
        mouseMove(window.contentItem, 580, 430)
        tryCompare(ordinary.QQC.ToolTip.toolTip, "visible", false)
        passed++
      }
      function test_hover_transfer_and_leave() {
        mouseMove(source, source.width / 2, source.height / 2)
        verify(!rich.visible, "hover delay is respected")
        tryCompare(rich, "opened", true)
        verify(!rich.activeFocus, "hover does not steal focus")
        mouseMove(rich.loadedContent, 20, 20)
        wait(150)
        verify(rich.visible, "pointer transfer keeps card open")
        mouseMove(window.contentItem, 580, 430)
        tryCompare(rich, "visible", false)
        compare(rich.loadedContent, null)
        passed++
      }
      function test_pointer_action() {
        mouseMove(source, source.width / 2, source.height / 2)
        tryCompare(rich, "opened", true)
        const before = actions
        mouseClick(rich.loadedContent.first)
        compare(actions, before + 1)
        passed++
      }
      function test_cancel_hover() {
        mouseMove(source, source.width / 2, source.height / 2)
        mouseMove(window.contentItem, 580, 430)
        wait(150)
        verify(!rich.visible)
        compare(rich.loadedContent, null)
        passed++
      }
      function test_keyboard_tab_escape() {
        keyClick(Qt.Key_Return)
        tryCompare(rich, "opened", true)
        verify(rich.loadedContent.first.activeFocus)
        keyClick(Qt.Key_Tab)
        verify(rich.loadedContent.second.activeFocus)
        keyClick(Qt.Key_Escape)
        tryCompare(rich, "visible", false)
        verify(source.activeFocus)
        compare(rich.loadedContent, null)
        passed++
      }
      function test_motion_outside_focus() {
        Style.reduceMotion = false
        keyClick(Qt.Key_Return)
        tryCompare(rich, "opened", true)
        mouseClick(outside)
        tryCompare(rich, "visible", false)
        verify(outside.activeFocus, "animation completion preserves outside focus")
        passed++
      }
      function test_theme_scale_edges() {
        Commons.Color.loadShell('[tooltip]\nbackground = "#ffffff"\ntext = "#101010"\n[font]\nbase-size = 24')
        const points = [[0, 0], [window.width - source.width, 0], [0, window.height - source.height], [window.width - source.width, window.height - source.height]]
        for (let i = 0; i < points.length; i++) {
          source.x = points[i][0]
          source.y = points[i][1]
          source.forceActiveFocus()
          keyClick(Qt.Key_Return)
          tryCompare(rich, "opened", true)
          const point = rich.background.mapToItem(window.contentItem, 0, 0)
          verify(point.x >= 0 && point.y >= 0, "card starts within window at edge " + i)
          verify(point.x + rich.width <= window.width && point.y + rich.height <= window.height, "large-font card fits at edge " + i)
          compare(String(rich.background.color), "#ffffff")
          rich.close()
          tryCompare(rich, "visible", false)
        }
        source.x = 100
        source.y = 100
        Commons.Color.loadShell("")
        passed++
      }
      function test_outside_click() {
        keyClick(Qt.Key_Return)
        tryCompare(rich, "opened", true)
        mouseClick(outside)
        tryCompare(rich, "visible", false)
        verify(outside.activeFocus, "outside click keeps the clicked button focused")
        passed++
      }
      function cleanupTestCase() {
        // A failed QtTest assertion throws before its scenario increments passed.
        console.log("INPUT_RESULT " + (passed === 8 ? "pass" : "fail") + " passed=" + passed)
      }
    }
  }
}
