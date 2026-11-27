import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property string stateDir: Quickshell.env("XDG_RUNTIME_DIR") + "/omarchy"
  property bool stateDirReady: false
  property bool lidAwake: false

  active: lidAwake
  activeText: "󰌢"
  inactiveText: "󰌢"
  activeTooltipText: I18n.t("bar.allowLidSleep")
  inactiveTooltipText: I18n.t("bar.lidAwake")

  // A watch on a file whose folder is missing never fires, and the runtime dir
  // is empty after a reboot, so make the folder before watching.
  Process {
    command: ["mkdir", "-p", root.stateDir]
    running: true
    onExited: function() { root.stateDirReady = true }
  }

  // The unit's own hooks create and remove this file, so its presence is the state.
  FileView {
    path: root.stateDirReady ? root.stateDir + "/lid-awake" : ""
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
