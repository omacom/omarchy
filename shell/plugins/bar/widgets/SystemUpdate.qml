import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.system-update"

  property bool updateAvailable: false
  // A refresh asked for while a check is running (say, the network coming back
  // during a check that started offline) runs once that check exits.
  property bool refreshPending: false

  function refresh() {
    if (updateProc.running) refreshPending = true
    else updateProc.running = true
  }

  function clear() { updateAvailable = false }

  function runUpdate() {
    if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-update")
  }

  visible: updateAvailable
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  ShellIpc {
    target: "omarchy.system-update"

    function refresh(): void {
      root.broadcast("refresh")
    }

    function clear(): void {
      root.broadcast("clear")
    }
  }

  Process {
    id: updateProc
    command: ["omarchy-update-available"]
    onExited: function(exitCode) {
      root.updateAvailable = exitCode === 0
      if (root.refreshPending) {
        root.refreshPending = false
        Qt.callLater(root.refresh)
      }
    }
  }

  // Recheck as soon as NetworkManager reports full internet connectivity, so a
  // check that ran before Wi-Fi came up doesn't hide the icon for six hours.
  readonly property bool online: Networking.connectivity === NetworkConnectivity.Full
  onOnlineChanged: if (online) root.refresh()

  Timer {
    interval: 21600000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf021"
    slotSize: Style.bar.statusSlot
    tooltipText: I18n.t("bar.pendingUpdates")
    onPressed: root.runUpdate()
  }
}
