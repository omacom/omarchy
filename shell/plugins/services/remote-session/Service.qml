import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "RemoteSessionModel.js" as RemoteSessionModel

// Watches for gliff-server, the Hyprland remote desktop, so the machine being
// controlled can see that someone is on it: the RemoteSession bar indicator
// reads `active` and `peers`.
Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  property bool stateLoaded: false
  property bool active: false
  property var peers: []

  property bool refreshPending: false

  function refresh() {
    if (statusProbe.running) {
      root.refreshPending = true
      return
    }
    root.refreshPending = false
    statusProbe.running = true
  }

  function applyProbe(text) {
    var state = RemoteSessionModel.stateFromOutput(text)
    root.peers = state.peers
    root.active = state.active
    root.stateLoaded = true
  }

  Component.onCompleted: refresh()

  // gliff-server captures the screen through ext-image-copy-capture, so a
  // session start surfaces as a Hyprland screencast event. The probe decides
  // whether it was gliff or another screencopy client, and a short debounce
  // folds the event bursts Hyprland sends around one transition into one probe.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (RemoteSessionModel.isCaptureEvent(event ? event.name : "")) eventDebounce.restart()
    }
  }

  Timer {
    id: eventDebounce
    interval: 150
    repeat: false
    onTriggered: root.refresh()
  }

  // The end of a session often has no event: Hyprland reports the screencast
  // stopped as soon as frames pause for half a second, and says nothing more
  // when the server later exits. So poll while a session is active.
  Timer {
    interval: 2000
    repeat: true
    running: root.active
    onTriggered: root.refresh()
  }

  Process {
    id: statusProbe
    command: ["bash", Quickshell.env("OMARCHY_PATH") + "/shell/plugins/services/remote-session/probe.sh"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyProbe(text)
    }
    onExited: function() {
      if (root.refreshPending) Qt.callLater(root.refresh)
    }
  }
}
