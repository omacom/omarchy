import QtQuick
import Quickshell
import Quickshell.Io
import "NightlightModel.js" as NightlightModel
import qs.Commons

Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null
  property var manifest: null

  // Keep in sync with bin/omarchy-toggle-nightlight, which sets the same
  // temperatures for callers outside the shell (keybindings, menu, ssh).
  readonly property int dayTemperature: 6500
  // A saved schedule carries its own warmth, and the manual toggle follows it
  // so the screen looks the same whichever way night light came on.
  readonly property int nightTemperature: schedule.saved ? schedule.temperature : NightlightModel.DEFAULT_SCHEDULE.temperature

  property bool stateLoaded: false
  property var temperature: null
  readonly property bool enabled: stateLoaded && NightlightModel.isNightlight(temperature)

  property bool hasPendingTemperature: false
  property int pendingTemperature: 0

  // The config as last saved by bin/omarchy-nightlight-config. `saved` is
  // false until one has been saved, which is what makes the first turn-on
  // offer to set one up.
  property var schedule: NightlightModel.parseSchedule("")
  property bool scheduleLoaded: false
  readonly property string scheduleFile: Quickshell.env("HOME") + "/.local/state/omarchy/settings/nightlight.json"
  readonly property string pluginId: (manifest && manifest.id) || "omarchy.nightlight"

  function refresh() {
    if (!statusProbe.running) statusProbe.running = true
  }

  function setNightlight(value) {
    applyTemperature(value ? nightTemperature : dayTemperature)
    // Turning night light on for the first time is the moment someone is
    // thinking about it, so offer the config then, once. The toggle itself
    // still happens: the editor is an offer, not a gate.
    if (value && scheduleLoaded && !schedule.saved) openConfig("first-run")
  }

  function toggle() {
    setNightlight(!enabled)
  }

  function openConfig(reason) {
    if (!root.shell || typeof root.shell.summon !== "function") return false
    return root.shell.summon(root.pluginId, JSON.stringify({ reason: String(reason || "") }))
  }

  // Live warmth preview from the config editor. Only touches the screen while
  // night light is on, so dragging the slider by day never tints it.
  function previewWarmth(temperature) {
    if (!root.enabled) return
    applyTemperature(NightlightModel.clampTemperature(temperature))
  }

  // Puts the saved warmth back after a preview the editor did not save.
  function endPreview() {
    if (root.enabled && root.temperature !== root.nightTemperature) applyTemperature(root.nightTemperature)
  }

  // Called by the config editor. The command writes the state file and the
  // hyprsunset profiles; the file watch below picks the result back up.
  function saveConfig(scheduled, day, night, temperature) {
    var kelvin = NightlightModel.clampTemperature(temperature)
    if (!NightlightModel.describeSchedule(scheduled, day, night).valid) return false
    root.schedule = {
      saved: true,
      scheduled: !!scheduled,
      day: day,
      night: night,
      temperature: kelvin
    }
    var wasOn = root.enabled
    Quickshell.execDetached(["omarchy-nightlight-config", "set", scheduled ? "on" : "off", day, night, String(kelvin)])
    // Saving restarts hyprsunset, which comes back at whatever its profiles say.
    // Night light that was on should stay on at the new warmth either way.
    if (wasOn) reapplyTimer.restart()
    return true
  }

  function applyTemperature(temp) {
    root.temperature = temp
    root.stateLoaded = true

    if (applyProcess.running) {
      root.pendingTemperature = temp
      root.hasPendingTemperature = true
      return
    }

    runApply(temp)
  }

  function runApply(temp) {
    applyProcess.command = ["bash", "-lc",
      "pgrep -x hyprsunset >/dev/null || { setsid uwsm-app -- hyprsunset >/dev/null 2>&1 & sleep 1; }; " +
      "hyprctl hyprsunset temperature " + Number(temp)]
    applyProcess.running = true
  }

  Process {
    id: statusProbe
    command: ["hyprctl", "hyprsunset", "temperature"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.temperature = NightlightModel.temperatureFromOutput(text)
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
      if (root.hasPendingTemperature) {
        root.hasPendingTemperature = false
        root.runApply(root.pendingTemperature)
        return
      }

      root.refresh()
    }
  }

  // hyprsunset only follows its schedule while it runs, so a saved schedule
  // starts it with the session.
  Process {
    id: applyScheduleProcess
    command: ["omarchy-nightlight-config", "apply"]
    onExited: root.refresh()
  }

  FileView {
    id: scheduleView
    path: root.scheduleFile
    watchChanges: true
    printErrors: false
    onLoaded: {
      root.schedule = NightlightModel.parseSchedule(text())
      var firstLoad = !root.scheduleLoaded
      root.scheduleLoaded = true
      if (firstLoad && root.schedule.scheduled) applyScheduleProcess.running = true
    }
    onLoadFailed: {
      root.schedule = NightlightModel.parseSchedule("")
      root.scheduleLoaded = true
    }
    onFileChanged: reload()
  }

  Timer {
    id: reapplyTimer
    interval: 1500
    onTriggered: root.applyTemperature(root.nightTemperature)
  }

  Component.onCompleted: refresh()

  ShellIpc {
    target: "nightlight"

    function status(): string {
      return JSON.stringify({ enabled: root.enabled, temperature: root.temperature })
    }

    function refresh(): void {
      root.refresh()
      scheduleView.reload()
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

    function config(): string {
      return root.openConfig("") ? "opened" : "unavailable"
    }

    function configStatus(): string {
      return JSON.stringify(root.schedule)
    }
  }
}
