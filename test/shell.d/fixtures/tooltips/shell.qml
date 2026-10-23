//@ pragma RespectSystemStyle
import QtQuick
import QtQuick.Controls as QQC
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui as Ui

ShellRoot {
  id: test
  property int step: 0
  property int failures: 0
  property int builds: 0
  property int destroys: 0

  function check(ok, message) {
    console.log((ok ? "PASS " : "FAIL ") + message)
    if (!ok) failures++
  }

  FloatingWindow {
    id: window
    implicitWidth: 500
    implicitHeight: 400

    QQC.Button {
      id: qtButton
      x: 15; y: 100
      text: "Unchanged Qt consumer"
      QQC.ToolTip.text: "Attached tooltip"
      QQC.ToolTip.visible: false
    }
    Item {
      id: source
      x: 200; y: 100; width: 100; height: 40
      focus: true
      Ui.PanelToolTip {
        id: hint
        delay: 0
        text: "Long tooltip content that wraps naturally and must remain within the available window width. ".repeat(4)
      }
      Ui.HoverCard {
        id: rich
        delay: 60
        closeDelay: 60
        content: FocusScope {
          implicitHeight: 70
          Component.onCompleted: test.builds++
          Component.onDestruction: test.destroys++
          Ui.Button { text: "Action"; focusable: true; focus: true }
        }
      }
    }
    Ui.ToolTipSurface {
      id: surface
      visible: false
      width: implicitWidth
      text: hint.text
      maximumWidth: 180
    }
  }

  Timer {
    interval: 300
    repeat: true
    running: true
    onTriggered: {
      switch (test.step++) {
      case 0:
        Style.reduceMotion = true
        test.check(qtButton.QQC.ToolTip.toolTip.maximumWidth !== undefined, "unchanged Qt attached tooltip uses Omarchy style")
        test.check(qtButton.QQC.ToolTip.toolTip.contentItem.fontFamily === Style.font.family, "standard Qt tooltip inherits shell font")
        test.check(rich.loadedContent === null && test.builds === 0, "rich content is not built while closed")
        hint.open()
        break
      case 1:
        test.check(hint.opened && hint.opacity === 1, "plain tooltip opens with animations disabled")
        test.check(!hint.activeFocus, "plain tooltip does not steal focus")
        test.check(hint.width <= window.width && hint.width > 0, "tooltip width is bounded by window")
        test.check(surface.implicitHeight > Style.font.bodySmall * 2, "long text wraps into multiple lines")
        Commons.Color.loadShell('[tooltip]\nbackground = "#123456"\ntext = "#abcdef"\nborder = "#fedcba"\n[font]\nbase-size = 18')
        break
      case 2:
        test.check(String(hint.contentItem.color) === "#123456", "open tooltip follows palette changes")
        test.check(String(hint.contentItem.foreground) === "#abcdef", "open tooltip follows text color changes")
        test.check(hint.contentItem.fontSize === Style.font.bodySmall && Style.font.bodySmall > 11, "font scale updates in place")
        hint.close()
        rich.sourceHovered = true
        rich.sourceHovered = false
        break
      case 3:
        test.check(!rich.visible && test.builds === 0, "cancelled hover does not open or build content")
        rich.sourceHovered = true
        break
      case 4:
        test.check(rich.opened && rich.loadedContent !== null && test.builds === 1, "hover opens and lazily loads rich content")
        test.check(!rich.activeFocus, "hover card does not steal focus")
        rich.sourceHovered = false
        break
      case 5:
        test.check(!rich.visible && rich.loadedContent === null && test.destroys === 1, "leave closes and unloads rich content")
        rich.openForKeyboard()
        break
      case 6:
        test.check(rich.opened && rich.activeFocus && rich.loadedContent !== null, "keyboard invocation opens and focuses rich content")
        rich.close()
        break
      case 7:
        test.check(source.activeFocus && rich.loadedContent === null, "keyboard close restores source focus and unloads content")
        console.log(test.failures ? "RESULT fail " + test.failures : "RESULT pass")
        Qt.quit()
      }
    }
  }
}
