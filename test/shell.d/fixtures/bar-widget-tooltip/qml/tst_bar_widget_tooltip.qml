import QtQuick
import QtTest
import qs.Ui

Item {
  id: root
  width: 320
  height: 100

  QtObject {
    id: fakeBar

    property bool vertical: false
    property int barSize: 26
    property string fontFamily: "monospace"
    property color barForeground: "white"
    property color foreground: "white"
    property color urgent: "red"
    property bool foregroundAnimationEnabled: false
    property var tooltipTarget: null
    property string tooltipText: ""

    function showTooltip(target, text) {
      Qt.callLater(function() {
        if (target && target.visible !== false && target.opacity !== 0 && target.tooltipHovered === true) {
          tooltipTarget = target
          tooltipText = text
        }
      })
    }

    function hideTooltip(target) {
      if (tooltipTarget === target) {
        tooltipTarget = null
        tooltipText = ""
      }
    }

    function resetTooltip() {
      tooltipTarget = null
      tooltipText = ""
    }

    function run(command) {}
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
  }

  BarWidget {
    id: barWidget
    x: 20
    y: 16
    width: 120
    height: 26
    bar: fakeBar
  }

  MouseArea {
    id: barWidgetTooltipArea
    parent: barWidget
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    onEntered: fakeBar.showTooltip(barWidget, "bar widget tooltip")
    onExited: fakeBar.hideTooltip(barWidget)
  }

  WidgetButton {
    id: widgetButton
    x: 20
    y: 60
    width: 120
    height: 26
    bar: fakeBar
    text: "Button"
    tooltipText: "button tooltip"
  }

  TestCase {
    id: testCase
    name: "BarWidgetTooltip"
    when: windowShown

    function init() {
      barWidget.visible = true
      barWidget.opacity = 1
      widgetButton.visible = true
      widgetButton.opacity = 1
      fakeBar.resetTooltip()
      mouseMove(root, root.width - 4, root.height - 4)
    }

    function test_bar_widget_hover_entry_and_exit() {
      compare(barWidget.tooltipHovered, false)
      compare(fakeBar.tooltipTarget, null)

      mouseMove(root, barWidget.x + 60, barWidget.y + 13)
      tryCompare(barWidget, "tooltipHovered", true)
      tryCompare(fakeBar, "tooltipTarget", barWidget)
      compare(fakeBar.tooltipText, "bar widget tooltip")

      mouseMove(root, root.width - 4, root.height - 4)
      tryCompare(barWidget, "tooltipHovered", false)
      tryCompare(fakeBar, "tooltipTarget", null)
    }

    function test_bar_widget_hiding_clears_tooltip() {
      mouseMove(root, barWidget.x + 60, barWidget.y + 13)
      tryCompare(barWidget, "tooltipHovered", true)
      tryCompare(fakeBar, "tooltipTarget", barWidget)

      barWidget.visible = false
      tryCompare(barWidget, "tooltipHovered", false)
      tryCompare(fakeBar, "tooltipTarget", null)
    }

    function test_bar_widget_opacity_clears_tooltip() {
      mouseMove(root, barWidget.x + 60, barWidget.y + 13)
      tryCompare(barWidget, "tooltipHovered", true)
      tryCompare(fakeBar, "tooltipTarget", barWidget)

      barWidget.opacity = 0
      tryCompare(barWidget, "tooltipHovered", false)
      tryCompare(fakeBar, "tooltipTarget", null)
    }

    function test_widget_button_tooltip_still_works() {
      mouseMove(root, widgetButton.x + 60, widgetButton.y + 13)
      tryCompare(widgetButton, "tooltipHovered", true)
      tryCompare(fakeBar, "tooltipTarget", widgetButton)
      compare(fakeBar.tooltipText, "button tooltip")

      mouseMove(root, root.width - 4, root.height - 4)
      tryCompare(widgetButton, "tooltipHovered", false)
      tryCompare(fakeBar, "tooltipTarget", null)
    }
  }
}
