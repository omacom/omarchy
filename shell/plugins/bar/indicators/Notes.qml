import QtQuick
import Quickshell
import qs.Ui

BarIndicator {
  id: root

  property string tooltip: "Take Note"

  active: false
  activeText: "󰎞"
  inactiveText: "󰎞"
  activeTooltipText: tooltip
  inactiveTooltipText: tooltip

  function openNotesFlow() {
    Quickshell.execDetached(["omarchy-notes", "-i"])
  }

  onPressed: function() {
    root.openNotesFlow()
  }
}
