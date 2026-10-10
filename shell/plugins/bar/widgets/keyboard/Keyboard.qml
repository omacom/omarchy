import QtQuick
import qs.Ui as Ui
import qs.Commons
import "."

Ui.Panel {
  id: root
  moduleName: "omarchy.keyboard-layout"
  property var backend: Backend
  manageIpc: false
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  onOpenedChanged: if (opened) { root.backend.refresh(); picker.reset() }
  Indicator {
    id: button
    anchors.fill: parent
    bar: root.bar
    backend: root.backend
    animate: root.setting("animate", true)
    onPressed: function(mouseButton) { if (mouseButton === Qt.LeftButton) root.toggle() }
  }
  Ui.KeyboardPanel {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.opened
    focusTarget: picker
    contentWidth: fittedContentWidth(Style.space(picker.page === "picker" ? 272 : 336))
    contentHeight: fittedContentHeight(picker.implicitHeight, Style.space(580))
    Picker {
      id: picker
      anchors.fill: parent
      backend: root.backend
      onDismiss: root.close()
    }
  }
}
