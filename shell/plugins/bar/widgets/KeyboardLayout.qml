import QtQuick
import Quickshell
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "omarchy.keyboard-layout"

  // The reading itself lives in KeyboardLayoutState, shared with the password
  // fields of the lock screen and the polkit dialog.
  visible: KeyboardLayoutState.showsIndicator
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: KeyboardLayoutState.inputLabel
    fontSize: Style.font.caption
    horizontalMargin: 6
    tooltipText: KeyboardLayoutState.inputTooltip
    onPressed: function(button) {
      if (KeyboardLayoutState.multipleInputs && button === Qt.LeftButton) {
        InputMethodState.cycle()
      } else if (KeyboardLayoutState.multipleLayouts) {
        KeyboardLayoutState.cycleLayout()
      }
    }
  }
}
