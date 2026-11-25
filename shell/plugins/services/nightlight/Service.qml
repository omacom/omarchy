import QtQuick
import Quickshell.Io
import "NightlightModel.js" as NightlightModel
import qs.Commons

Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  // Keep in sync with bin/omarchy-toggle-nightlight, which sets the same
  // temperatures for callers outside the shell (keybindings, menu, ssh).
  readonly property int nightTemperature: 4000

  property bool stateLoaded: false
  property var temperature: null
  property bool identity: false
  readonly property bool enabled: stateLoaded && NightlightModel.isNightlight(temperature, identity)

  property bool hasPendingValue: false
  property bool pendingValue: false

  function refresh() {
    if (!statusProbe.running) statusProbe.running = true
  }

  function setNightlight(value) {
    // hyprsunset keeps the temperature while identity is on.
    root.temperature = nightTemperature
    root.identity = !value
    root.stateLoaded = true

    if (applyProcess.running) {
      root.pendingValue = value
      root.hasPendingValue = true
      return
    }

    runApply(value)
  }

  function toggle() {
    setNightlight(!enabled)
  }

  function runApply(value) {
    applyProcess.command = ["bash", "-lc",
      "pgrep -x hyprsunset >/dev/null || { setsid uwsm-app -- hyprsunset >/dev/null 2>&1 & sleep 1; }; " +
      // Off is one identity request, so Hyprland fades straight back from the
      // warm matrix; stepping through daylight first restarts the fade there.
      (value ? "hyprctl hyprsunset temperature " + root.nightTemperature : "hyprctl hyprsunset identity")]
    applyProcess.running = true
  }

  Process {
    id: statusProbe
    command: ["sh", "-c", "hyprctl hyprsunset temperature && echo --- && hyprctl hyprsunset identity get"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var parts = text.split("---")
        root.temperature = NightlightModel.temperatureFromOutput(parts[0])
        root.identity = NightlightModel.identityFromOutput(parts[1])
        root.stateLoaded = true
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.temperature = null
        root.stateLoaded = true
      }
    }
  }

  Process {
    id: applyProcess
    onExited: function() {
      if (root.hasPendingValue) {
        root.hasPendingValue = false
        root.runApply(root.pendingValue)
        return
      }

      root.refresh()
    }
  }

  Component.onCompleted: refresh()

  ShellIpc {
    target: "nightlight"

    function status(): string {
      return JSON.stringify({ enabled: root.enabled, temperature: root.temperature })
    }

    function refresh(): void {
      root.refresh()
    }

    function enable(): string {
      root.setNightlight(true)
      return "enabled"
    }

    function disable(): string {
      root.setNightlight(false)
      return "disabled"
    }

    function toggle(): string {
      var enabling = !root.enabled
      root.setNightlight(enabling)
      return enabling ? "enabled" : "disabled"
    }
  }
}
