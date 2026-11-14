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
  // The release whose what's-new notes are waiting to be seen. Checked when
  // the shell starts, which every update ends with and every login begins
  // with, and again when omarchy-update-whats-new-seen says they were seen.
  // An update waiting to be installed takes the icon first.
  property string whatsNewRelease: ""
  readonly property bool showingWhatsNew: !updateAvailable && whatsNewRelease !== ""

  function refresh() {
    if (updateProc.running) refreshPending = true
    else updateProc.running = true
  }

  function clear() { updateAvailable = false }

  function refreshWhatsNew() {
    whatsNewProc.running = false
    whatsNewProc.running = true
  }

  function runUpdate() {
    if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-update")
  }

  visible: updateAvailable || whatsNewRelease !== ""
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

    function refreshWhatsNew(): void {
      root.broadcast("refreshWhatsNew")
    }
  }

  Process {
    id: whatsNewProc
    command: ["omarchy-update-whats-new-notes", "--pending"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.whatsNewRelease = String(text || "").trim()
    }
  }

  Component.onCompleted: refreshWhatsNew()

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
    text: root.showingWhatsNew ? "\u{f0674}" : "\uf021"
    slotSize: Style.bar.statusSlot
    tooltipText: root.showingWhatsNew ? I18n.t("whatsNew.heading").arg(root.whatsNewRelease) : I18n.t("bar.pendingUpdates")
    onPressed: {
      if (!root.showingWhatsNew) root.runUpdate()
      else if (root.bar) root.bar.run("omarchy-update-whats-new")
    }
  }
}
