import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  readonly property string stateDir: Quickshell.env("XDG_RUNTIME_DIR") + "/omarchy/agent-awake"
  property bool hasLid: false
  property bool awake: false
  property string tooltip: ""
  property bool refreshPending: false

  // Nothing to hold open on a machine without a lid, so it takes no space there.
  active: awake
  activeText: "󰈈"
  inactiveText: hasLid ? "󰈈" : ""
  keepSpace: hasLid
  activeTooltipText: tooltip
  inactiveTooltipText: "Agent Awake"

  function refresh() {
    if (statusProc.running) {
      root.refreshPending = true
      return
    }
    root.refreshPending = false
    statusProc.running = true
  }

  function update(raw) {
    var data = extractData(raw)
    root.awake = data.active === true
    root.tooltip = String(data.tooltip || "")
  }

  Component.onCompleted: lidProc.running = true

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { if (root.hasLid) root.refresh() }
  }

  // The state directory changes on every start, add and end. The poll is for
  // what changes no file: a holder that was killed.
  FileView {
    id: stateWatcher
    path: root.hasLid ? root.stateDir : ""
    watchChanges: true
    printErrors: false
    onFileChanged: root.refresh()
  }

  Timer {
    interval: 30000
    repeat: true
    running: root.hasLid
    onTriggered: root.refresh()
  }

  Process {
    id: lidProc
    command: ["omarchy-hw-laptop"]
    onExited: function(exitCode) {
      root.hasLid = exitCode === 0
      if (root.hasLid) root.refresh()
    }
  }

  Process {
    id: statusProc
    command: ["bash", "-c", "mkdir -p -m 700 \"$1\" && omarchy-agent-awake status", "agent-awake", root.stateDir]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.update(text)
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) root.awake = false
      stateWatcher.reload()
      if (root.refreshPending) Qt.callLater(root.refresh)
    }
  }

  onPressed: function() {
    Quickshell.execDetached(["omarchy-menu", "summon", "trigger.toggle.agent-awake"])
  }
}
