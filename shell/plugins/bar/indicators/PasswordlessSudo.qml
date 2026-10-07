import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  readonly property string launchCommand: "omarchy-launch-floating-terminal-with-presentation omarchy-sudo-passwordless"

  // `omarchy-sudo-passwordless status` exits 0 while a grant is live, 3 when
  // none is, and anything else when it cannot tell. An unknown answer stays
  // visible as active: a broken status must never hide a grant.
  property bool granted: false
  property bool unknown: false
  property real deadline: 0
  property real now: Date.now()
  readonly property int remainingMinutes: Math.max(0, Math.ceil((deadline - now) / 60000))

  active: granted || unknown
  activeText: "󰟵"
  inactiveText: "󰟵"
  useActiveColor: true
  activeTooltipText: unknown
    ? "Passwordless sudo status unknown. Click to check"
    : "Passwordless sudo ACTIVE, " + remainingMinutes + "m left. Click to revoke"
  inactiveTooltipText: "Passwordless Sudo"

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function update(exitCode, raw) {
    var data = exitCode === 0 ? extractData(raw) : {}
    var parsed = Date.parse(String(data.deadline || ""))
    root.now = Date.now()
    root.granted = exitCode === 0 && data.active === true && !isNaN(parsed)
    root.unknown = exitCode !== 3 && !root.granted
    root.deadline = root.granted ? parsed : 0
  }

  onBarChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  // The status command needs no sudo; polling is what notices grants made or
  // revoked from a terminal and the timer expiring them.
  Timer {
    interval: 10000
    running: !!root.bar
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: statusProc
    command: ["omarchy-sudo-passwordless", "status", "--json"]
    stdout: StdioCollector { id: statusOutput; waitForEnd: true }
    onExited: function(exitCode) { root.update(exitCode, statusOutput.text) }
  }

  // A live grant lets sudo revoke without a password, so no terminal is
  // needed. If sudo still wants one, fall back to the interactive toggle.
  Process {
    id: disableProc
    command: ["omarchy-sudo-passwordless", "disable"]
    onExited: function(exitCode) {
      if (exitCode !== 0 && root.bar) root.bar.run(root.launchCommand)
      root.refresh()
    }
  }

  onPressed: function() {
    if (!root.bar) return
    if (root.granted && !root.unknown) {
      if (!disableProc.running) disableProc.running = true
    } else {
      root.bar.run(root.launchCommand)
    }
  }
}
