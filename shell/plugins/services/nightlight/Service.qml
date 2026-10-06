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

  // A toggle asked for while the screen's real temperature is being re-read.
  // hyprsunset switches profiles on its own, so the cached reading can be
  // stale; the toggle direction is decided from a fresh one.
  property bool toggleQueued: false

  // The save in flight, if any. `saving` keeps a second save from starting
  // while the first still owns hyprsunset's restart.
  readonly property bool saving: saveProcess.running
  property string saveError: ""
  property var onSaveFinished: null

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
    // While a save restarts hyprsunset, touching it would race the restart.
    // Remember the latest choice and apply it once the save is done; it wins
    // over whatever the save itself restored.
    if (root.saving) {
      root.requestedDuringSave = value ? "on" : "off"
      root.temperature = value ? nightTemperature : dayTemperature
      root.stateLoaded = true
      return
    }
    applyTemperature(value ? nightTemperature : dayTemperature)
    // Turning night light on for the first time is the moment someone is
    // thinking about it, so offer the config then, once. The toggle itself
    // still happens: the editor is an offer, not a gate.
    if (value && scheduleLoaded && !schedule.saved) openConfig("first-run")
  }

  // Toggles from the screen's real state, not the cached one: a schedule can
  // have warmed or cleared the screen since the last reading.
  function toggle() {
    root.toggleQueued = true
    refresh()
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

  // Called by the config editor. The command writes the profiles and the
  // state file, restarts hyprsunset, and waits for it to answer; with
  // --keep-on it re-applies the warmth itself, so nothing here has to guess
  // when the new process is ready. `done(ok, error)` runs when it finishes.
  property string requestedDuringSave: ""
  property int savingTemperature: 0

  function saveConfig(scheduled, day, night, temperature, done) {
    var kelvin = NightlightModel.clampTemperature(temperature)
    if (root.saving) return false
    if (!NightlightModel.describeSchedule(scheduled, day, night).valid) return false

    root.requestedDuringSave = ""
    root.savingTemperature = kelvin
    root.saveError = ""
    root.onSaveFinished = done || null
    var args = ["omarchy-nightlight-config", "set"]
    if (root.enabled) args.push("--keep-on")
    saveProcess.command = args.concat([scheduled ? "on" : "off", day, night, String(kelvin)])
    saveProcess.running = true
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
      if (root.toggleQueued) {
        root.toggleQueued = false
        root.setNightlight(!root.enabled)
      }
    }
  }

  Process {
    id: saveProcess
    stderr: StdioCollector { id: saveStderr; waitForEnd: true }
    onExited: function(exitCode) {
      var ok = exitCode === 0
      var requested = root.requestedDuringSave
      root.requestedDuringSave = ""
      root.saveError = ok ? "" : (String(saveStderr.text || "").trim().split("\n").pop() || "Saving failed")
      scheduleView.reload()
      // A toggle made during the save is the latest word. Use the warmth just
      // saved: the file reload that updates nightTemperature is still pending.
      if (requested === "on") root.applyTemperature(ok ? root.savingTemperature : root.nightTemperature)
      else if (requested === "off") root.applyTemperature(root.dayTemperature)
      else root.refresh()
      var done = root.onSaveFinished
      root.onSaveFinished = null
      if (done) done(ok, root.saveError)
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
      root.armBoundary()
    }
    onLoadFailed: {
      root.schedule = NightlightModel.parseSchedule("")
      root.scheduleLoaded = true
      root.armBoundary()
    }
    onFileChanged: reload()
  }

  // hyprsunset switches profiles by itself at the day and night starts. Re-read
  // the screen just after each one so the bar and the next toggle see it.
  function armBoundary() {
    boundaryTimer.stop()
    if (!root.schedule.scheduled) return
    var wait = NightlightModel.msUntilNextBoundary(root.schedule.day, root.schedule.night, new Date())
    if (wait < 0) return
    // Timers drift across suspend; re-check at least every 10 minutes.
    boundaryTimer.interval = Math.max(1000, Math.min(wait, 600000))
    boundaryTimer.start()
  }

  Timer {
    id: boundaryTimer
    repeat: false
    onTriggered: {
      root.refresh()
      root.armBoundary()
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

    // The toggle re-reads the screen before choosing a direction, so the
    // answer is only that it was accepted; ask status() for the outcome.
    function toggle(): string {
      root.toggle()
      return "toggled"
    }

    function config(): string {
      return root.openConfig("") ? "opened" : "unavailable"
    }

    function configStatus(): string {
      return JSON.stringify(root.schedule)
    }
  }
}
