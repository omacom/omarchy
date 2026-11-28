import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Quickshell can lose a monitor from Hyprland.monitors when the only output goes
// away and comes back (monitor power button, DPMS, KVM). Hyprland swaps in a
// FALLBACK output meanwhile; a j/monitors reply taken while only FALLBACK existed
// lands after the real output was re-added and removes it, and the refresh that
// would have fixed it was dropped because that request was still in flight.
// Hyprland.refreshMonitors() only updates monitors Quickshell already tracks, so
// nothing brings it back. Overlays that wait for their screen's HyprlandMonitor
// (OverlayWindow, the menu, third-party launchers) then never reveal, and every
// shell shortcut that opens one looks dead.
//
// Only a config reload re-queries monitors with creation allowed, so when a
// screen Quickshell shows has no Hyprland monitor for a while, reload once.
Item {
  id: root

  // Long enough for Hyprland's own monitor events and the shell's panel rebuild
  // to settle after a hotplug, so a transient gap is not mistaken for the bug.
  property int settleMs: 2000
  // A reload that does not fix it is not retried until the outputs change again.
  property bool attempted: false

  function missingScreens() {
    var tracked = {}
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) tracked[monitors[i].name] = true

    var missing = []
    var screens = Quickshell.screens
    for (var j = 0; j < screens.length; j++) {
      var name = String(screens[j].name || "")
      // Qt's placeholder screen while there are no outputs has no name.
      if (name && !tracked[name]) missing.push(name)
    }
    return missing
  }

  function schedule() {
    settle.restart()
  }

  Connections {
    target: Quickshell
    function onScreensChanged() {
      root.attempted = false
      root.schedule()
    }
  }

  Connections {
    target: Hyprland.monitors
    function onValuesChanged() { root.schedule() }
  }

  Timer {
    id: settle
    interval: root.settleMs
    onTriggered: {
      if (root.attempted || reload.running) return
      var missing = root.missingScreens()
      if (missing.length === 0) return
      root.attempted = true
      console.warn("Hyprland monitors missing from Quickshell after an output change:", missing.join(", "), "- reloading Hyprland to resync")
      reload.running = true
    }
  }

  // Reloading into half-replaced package config is what the guard prevents.
  Process {
    id: reload
    command: ["bash", "-c", "omarchy-hyprland-reload-guard paused || omarchy-restart-hyprctl"]
  }
}
