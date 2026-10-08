import QtQuick
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  property bool lidAwake: false
  property bool laptop: false
  property bool refreshPending: false
  property double followerStartedAt: 0
  property int followerRetryDelay: 5000
  readonly property var batteryService: bar?.shell?.firstPartyServiceFor("omarchy.battery")
  readonly property bool batteryFloorReached: batteryService ? batteryService.lidAwakeFloorReached : false

  active: lidAwake
  activeText: "󰌢"
  inactiveText: "󰌢"
  activeTooltipText: "Allow Lid-Close Suspend"
  inactiveTooltipText: batteryFloorReached ? "Battery floor reached" : "Stay On With Lid Closed"

  // Only a laptop has a lid to keep awake.
  visible: laptop && belongsInBlock

  function refresh() {
    if (!root.bar) return
    // A check already running may have sampled the unit before a toggle, so
    // run one more after it rather than dropping this request.
    if (statusProc.running) {
      root.refreshPending = true
      return
    }
    statusProc.running = true
  }

  onBarChanged: refresh()
  Component.onCompleted: {
    laptopProc.running = true
    refresh()
  }

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  Process {
    id: laptopProc
    command: ["omarchy-hw-laptop"]
    onExited: function(exitCode) {
      root.laptop = exitCode === 0
    }
  }

  Process {
    id: statusProc
    command: ["systemctl", "--user", "--quiet", "is-active", "omarchy-lid-awake"]
    onExited: function(exitCode) {
      root.lidAwake = exitCode === 0
      // Follow the unit from the first time it is seen on, and never stop:
      // a laptop where Lid Awake is never used runs no follower at all.
      if (root.lidAwake && !unitFollower.running && !followerRestart.running)
        unitFollower.running = true
      if (root.refreshPending) {
        root.refreshPending = false
        root.refresh()
      }
    }
  }

  // The unit can fail, restart, or stop outside the toggle. Its journal logs
  // every change, so follow it rather than poll: lines wait in the pipe while
  // the shell is busy, so none is missed. pdeathsig stops the follower if the
  // shell dies without cleaning up its children.
  Process {
    id: unitFollower
    command: ["setpriv", "--pdeathsig", "TERM", "journalctl", "--user", "--follow", "--lines=0", "--output=cat", "--unit=omarchy-lid-awake"]
    stdout: SplitParser {
      onRead: root.refresh()
    }
    // Entries logged before the follower started are not replayed, so check
    // the unit once it is following, at startup and after a restart alike.
    onStarted: {
      root.followerStartedAt = Date.now()
      root.refresh()
    }
    // Restart a follower that exits, backing off while it keeps exiting
    // straight away, as one that cannot read the journal would, so a lasting
    // failure retries every few minutes instead of polling. A follower that
    // ran for a minute was working, so the next restart is quick again.
    onExited: {
      var ran = Date.now() - root.followerStartedAt
      root.followerRetryDelay = ran > 60000 ? 5000 : Math.min(root.followerRetryDelay * 2, 300000)
      followerRestart.interval = root.followerRetryDelay
      followerRestart.start()
    }
  }

  Timer {
    id: followerRestart
    onTriggered: unitFollower.running = true
  }

  onPressed: function() {
    if (root.bar) root.bar.run("omarchy-toggle-lid-awake")
  }
}
