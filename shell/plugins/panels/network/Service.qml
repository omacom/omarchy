import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "Model.js" as Model

Item {
  id: root

  property bool routedConnectivity: false
  property bool checksEnabled: Networking.backend === NetworkBackendType.NetworkManager
    && Networking.canCheckConnectivity && Networking.connectivityCheckEnabled
  readonly property bool limited: Networking.connectivity === NetworkConnectivity.Limited
  property string probeStatus: ""

  function reset() {
    routedConnectivity = false
    probeStatus = ""
    probeGeneration++
    if (limited && checksEnabled) Qt.callLater(probe)
  }

  function probe() {
    if (!limited || !checksEnabled || probeProcess.running) return
    probeStatus = ""
    probeGenerationAtStart = probeGeneration
    probeProcess.running = true
  }

  property int probeGeneration: 0
  property int probeGenerationAtStart: -1

  onLimitedChanged: reset()
  onChecksEnabledChanged: reset()

  Component.onCompleted: reset()

  Timer {
    interval: 10000
    repeat: true
    running: root.limited && root.checksEnabled
    onTriggered: root.probe()
  }

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
      if (root.probeGenerationAtStart !== root.probeGeneration || !root.limited || !root.checksEnabled) {
        Qt.callLater(root.probe)
        return
      }
      root.routedConnectivity = Model.routedProbeSucceeded(exitCode, root.probeStatus)
    }
  }
}
