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
  readonly property string captureOwner: Date.now().toString() + "-" + Math.random().toString(36).slice(2)

  function setCaptureOverride(active, closing) {
    // Closing is recorded in Hyprland itself so an in-flight enable cannot
    // turn the override back on after the service has been destroyed.
    var owner = JSON.stringify(root.captureOwner)
    var lua = "omarchy_closed_capture_owners = omarchy_closed_capture_owners or {}; "
    if (closing) lua += "omarchy_closed_capture_owners[" + owner + "] = true; "
    lua += "if " + (closing ? "omarchy_capture_owner == " + owner : "not omarchy_closed_capture_owners[" + owner + "]") + " then "
    if (!closing) lua += "omarchy_capture_owner = " + owner + "; "
    lua += 'hl.window_rule({ name = "omarchy-remote-screen-share", match = { class = ".*" }, no_screen_share = false, enabled = ' + (active ? "true" : "false") + " }); end"
    Quickshell.execDetached(["hyprctl", "eval", lua])
  }

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
    if (!root.stateLoaded || root.active !== state.active) {
      // Override app protection rules for existing and future windows. Disabling
      // this catch-all rule restores each app's own screen sharing policy.
      root.setCaptureOverride(state.active, false)
    }
    root.peers = state.peers
    root.active = state.active
    root.stateLoaded = true
  }

  Component.onCompleted: refresh()
  Component.onDestruction: root.setCaptureOverride(false, true)

  // gliff-server captures the screen through ext-image-copy-capture, so a
  // session start surfaces as a Hyprland screencast event. The probe decides
  // whether it was gliff or another screencopy client, and a short debounce
  // folds the event bursts Hyprland sends around one transition into one probe.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event && event.name === "configreloaded") {
        root.stateLoaded = false
        root.refresh()
      }
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
