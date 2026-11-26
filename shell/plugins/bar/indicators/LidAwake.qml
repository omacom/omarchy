import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property string stateFile: Quickshell.env("HOME") + "/.local/state/omarchy/indicators/lid-awake"
  property bool lidAwake: false

  active: lidAwake
  activeText: "󰌢"
  inactiveText: "󰌢"
  activeTooltipText: I18n.t("bar.allowLidSleep")
  inactiveTooltipText: I18n.t("bar.lidAwake")

  // The unit's own hooks create and remove this file, so its presence is the state.
  FileView {
    id: stateWatcher
    path: root.stateFile
    watchChanges: true
    printErrors: false
    onLoaded: root.lidAwake = true
    onLoadFailed: root.lidAwake = false
    onFileChanged: reload()
  }

  Process {
    id: toggler
    command: ["omarchy-toggle-lid-awake", "toggle"]
  }

  onPressed: function() { toggler.running = true }
}
