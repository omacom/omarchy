pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Input devices arriving and leaving, which Hyprland raises no event for. Every
// device the kernel sees, from a USB keyboard to a Bluetooth one pairing, adds
// and removes its nodes under /dev/input, and udev records it under
// /run/udev/data once it has finished with it, which is when libinput hands it
// to Hyprland. One watch on both serves the whole shell instead of each bar
// asking Hyprland on a timer.
Singleton {
  id: root

  signal changed()

  // Tests point this at a fixture root, the way OMARCHY_PROC_ROOT and
  // OMARCHY_SYS_ROOT stand in for /proc and /sys.
  readonly property string fixtureRoot: Quickshell.env("OMARCHY_INPUT_ROOT") || ""
  readonly property string devDir: fixtureRoot + "/dev"
  readonly property string inputDir: devDir + "/input"
  readonly property string udevDir: fixtureRoot + "/run/udev/data"

  // inotifywait is restarted when it ends. One that keeps ending at once (an
  // exhausted inotify limit, say) is retried less and less often, down to once
  // a minute, rather than given up on: nothing else would notice a device.
  property real startedAt: 0
  property int quickExits: 0
  // Whether the watch has stayed up, which the keyboard widget falls back to
  // asking on a timer without.
  readonly property bool healthy: quickExits === 0

  // /dev is watched beside /dev/input for one thing: /dev/input being created
  // again after it went away with the last device, when the watch on the old
  // directory is gone and has to be set up on the new one. udev's records for
  // input devices are the c13: entries, character major 13.
  Process {
    id: watcher
    command: ["bash", "-c",
      "dirs=(\"$2\"); for dir in \"$1\" \"$3\"; do [[ -d $dir ]] && dirs+=(\"$dir\"); done; "
        + "exec inotifywait -m -q -e create,delete,delete_self,moved_to --format '%w|%e|%f' \"${dirs[@]}\"",
      "input-devices", root.inputDir, root.devDir, root.udevDir]
    running: true
    // Whatever arrived or left while no watch was set up went unseen, so read
    // the seat again once a watch is: at start, after a watch that had been
    // up, and once a failing one has stayed up a second. A watch failing at
    // once announces nothing, or each retry would ask Hyprland from every bar.
    onRunningChanged: {
      if (!running) return
      root.startedAt = Date.now()
      if (root.quickExits === 0) root.announce()
      else recovered.restart()
    }
    stdout: SplitParser {
      onRead: function(line) {
        var fields = String(line).split("|")
        var dir = fields[0].replace(/\/$/, "")
        if (dir === root.devDir) {
          if (fields[2] === "input" && fields[1].indexOf("CREATE") !== -1) {
            watcher.running = false
            root.announce()
          }
        } else if (dir === root.udevDir) {
          if (String(fields[2]).indexOf("c13:") === 0) root.announce()
        } else {
          root.announce()
        }
      }
    }
    onExited: {
      root.quickExits = Date.now() - root.startedAt < 1000 ? root.quickExits + 1 : 0
      restart.interval = Math.min(60000, 1000 * Math.pow(2, Math.max(0, root.quickExits - 4)))
      restart.start()
    }
  }

  // A device brings several nodes at once, so announce it once the burst has
  // settled, and again a few seconds on in case udev's record of it was what
  // lagged.
  function announce() {
    settle.restart()
    followUp.restart()
  }

  Timer {
    id: settle
    interval: 500
    onTriggered: root.changed()
  }

  Timer {
    id: followUp
    interval: 3000
    onTriggered: root.changed()
  }

  Timer {
    id: recovered
    interval: 1000
    onTriggered: {
      if (!watcher.running) return
      root.quickExits = 0
      root.announce()
    }
  }

  Timer {
    id: restart
    interval: 1000
    onTriggered: watcher.running = true
  }
}
