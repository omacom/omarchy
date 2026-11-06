import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "Model.js" as Model

Item {
  id: root

  property bool routedConnectivity: false
  readonly property bool checksEnabled: Networking.backend === NetworkBackendType.NetworkManager
    && Networking.canCheckConnectivity && Networking.connectivityCheckEnabled
  readonly property bool limited: Networking.connectivity === NetworkConnectivity.Limited
  property string probeStatus: ""

  function reset() {
    routedConnectivity = false
    probeStatus = ""
    probeGeneration++
    refreshInterval = 15000
    if (limited && checksEnabled) Qt.callLater(probe)
  }

  function probe() {
    if (!limited || !checksEnabled || probeProcess.running) return
    probeStatus = ""
    probeGenerationAtStart = probeGeneration
    probeProcess.running = true
  }

  // Re-probe without dropping the current answer, so a device change does not
  // flash the warning while curl is in flight.
  function reprobe() {
    probeGeneration++
    refreshInterval = 15000
    probe()
  }

  property int probeGeneration: 0
  property int probeGenerationAtStart: -1

  // NetworkManager keeps its aggregate at limited while a tunnel carries the
  // route, so connectivityChanged never fires again, and switching an exit
  // node keeps the same device. Neither case has a signal to bind to, so this
  // is the last-resort poll: one shared probe that backs off to five minutes,
  // and only while NM says limited. The panel probes every 10s while open and
  // limited.
  property int refreshInterval: 15000

  Timer {
    interval: root.refreshInterval
    repeat: true
    running: root.limited && root.checksEnabled
    onTriggered: {
      root.refreshInterval = Math.min(root.refreshInterval * 2, 300000)
      root.probe()
    }
  }

  onLimitedChanged: reset()
  onChecksEnabledChanged: reset()

  // A tunnel appearing or disappearing is a device-list change, and it is the
  // event that changes the answer without NM's aggregate moving.
  Connections {
    target: Networking.devices
    function onValuesChanged() { root.reprobe() }
  }

  Component.onCompleted: reset()

  Process {
    id: probeProcess
    command: ["curl", "--fail", "--silent", "--show-error", "--noproxy", "*",
      "--max-redirs", "0", "--max-time", "6", "--output", "/dev/null",
      "--write-out", "%{http_code}", Model.captivePortalUrl]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.probeStatus = text.trim()
    }
    onExited: function(exitCode) {
      // A device or connectivity change while curl was in flight makes this
      // answer stale: keep the current one and probe again.
      if (root.probeGenerationAtStart !== root.probeGeneration || !root.limited || !root.checksEnabled) {
        Qt.callLater(root.probe)
        return
      }
      root.routedConnectivity = Model.routedProbeSucceeded(exitCode, root.probeStatus)
    }
  }
}
