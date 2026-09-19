import QtQuick
import Quickshell.Io
import "NightlightModel.js" as NightlightModel

Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  // Keep in sync with bin/omarchy-toggle-nightlight, which sets the same
  // temperatures for callers outside the shell (keybindings, menu, ssh).
  readonly property int nightTemperature: 4000
  readonly property int dayTemperature: 6500

  property bool stateLoaded: false
  property var temperature: null
  readonly property bool enabled: stateLoaded && NightlightModel.isNightlight(temperature)

  property bool scheduleLoaded: false
  property bool scheduled: false
  property string scheduleTimezone: ""
  property string nextEvent: ""
  property string nextEventAt: ""
  property string scheduleError: ""
  // Keep the latest selection while an older mode is still being persisted.
  property var requestedSchedule: null

  property bool hasPendingTemperature: false
  property int pendingTemperature: 0

  function refresh() {
    if (!statusProbe.running) statusProbe.running = true
  }

  function setNightlight(value) {
    setScheduleEnabled(false)
    applyTemperature(value ? nightTemperature : dayTemperature)
  }

  function toggle() {
    setNightlight(!enabled)
  }

  function setScheduleEnabled(value) {
    if (root.requestedSchedule === null && root.scheduleLoaded && root.scheduled === value) return

    root.requestedSchedule = value
    scheduleProbe.running = false
    scheduleTimer.stop()
    if (!value) {
      root.scheduled = false
      root.scheduleLoaded = true
    }
    root.persistSchedule()
  }

  function persistSchedule() {
    if (scheduleChangeProcess.running || root.requestedSchedule === null) return

    scheduleChangeProcess.enabling = root.requestedSchedule
    scheduleChangeProcess.command = ["omarchy-nightlight-schedule", root.requestedSchedule ? "enable" : "disable"]
    scheduleChangeProcess.running = true
  }

  function applySchedule(data) {
    root.scheduleLoaded = true
    root.scheduled = data.scheduled === true
    root.scheduleError = data.error ? String(data.error) : ""
    root.scheduleTimezone = data.timezone ? String(data.timezone) : ""
    root.nextEvent = data.nextEvent ? String(data.nextEvent) : ""
    root.nextEventAt = data.nextEventAt ? String(data.nextEventAt) : ""

    scheduleTimer.stop()
    if (!root.scheduled) return
    if (root.scheduleError !== "") {
      console.warn("Night light schedule:", root.scheduleError)
      scheduleTimer.interval = 15 * 60 * 1000
      scheduleTimer.restart()
      return
    }

    var target = data.night === true ? root.nightTemperature : root.dayTemperature
    if (root.temperature !== target) root.applyTemperature(target)

    var eventTime = Date.parse(root.nextEventAt)
    var delay = isNaN(eventTime) ? 15 * 60 * 1000 : eventTime - Date.now() + 1000
    scheduleTimer.interval = Math.max(1000, Math.min(6 * 60 * 60 * 1000, delay))
    scheduleTimer.restart()
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
      // Evaluate against the freshly read display state, not a pre-sleep cache.
      if (root.requestedSchedule === null && !scheduleProbe.running) scheduleProbe.running = true
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

  Process {
    id: scheduleProbe
    command: ["omarchy-nightlight-schedule", "evaluate"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (root.requestedSchedule !== null) return

        try {
          root.applySchedule(JSON.parse(text))
        } catch (error) {
          root.scheduleLoaded = true
          root.scheduleError = "Invalid schedule response"
          console.warn("Night light schedule:", root.scheduleError)
          scheduleTimer.interval = 15 * 60 * 1000
          scheduleTimer.restart()
        }
      }
    }
  }

  Process {
    id: scheduleChangeProcess
    property bool enabling: false
    onExited: function(exitCode) {
      if (exitCode !== 0) console.warn("Night light schedule: unable to save " + (scheduleChangeProcess.enabling ? "sunset" : "manual") + " mode")
      // Finish the in-flight write before persisting any newer selection.
      if (root.requestedSchedule !== scheduleChangeProcess.enabling) {
        root.persistSchedule()
        return
      }
      root.requestedSchedule = null
      root.refresh()
    }
  }

  Timer {
    id: scheduleTimer
    repeat: false
    onTriggered: root.refresh()
  }

  Timer {
    interval: 1000
    running: root.scheduled
    repeat: true
    property double lastTick: Date.now()
    onTriggered: {
      // Qt's countdowns pause during suspend; wall time still crosses sunset.
      var now = Date.now()
      var elapsed = now - lastTick
      lastTick = now
      if (elapsed > 5000 || elapsed < 0) root.refresh()
    }
  }

  Component.onCompleted: refresh()

  IpcHandler {
    target: "nightlight"

    function status(): string {
      return JSON.stringify({
        enabled: root.enabled,
        temperature: root.temperature,
        scheduled: root.scheduled,
        timezone: root.scheduleTimezone,
        nextEvent: root.nextEvent,
        nextEventAt: root.nextEventAt,
        scheduleError: root.scheduleError
      })
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
