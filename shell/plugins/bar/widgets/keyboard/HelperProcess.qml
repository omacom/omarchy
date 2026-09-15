import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root
  property int timeoutMs: 30000
  property int maximumBytes: 256 * 1024
  property string supervisorPath: Quickshell.env("OMARCHY_PATH") + "/shell/plugins/bar/widgets/keyboard/backend/process_supervisor.py"
  readonly property bool running: process.running
  property int generation: 0
  property int activeGeneration: 0
  property int receivedBytes: 0
  property string output: ""
  property string failure: ""
  property bool expected: false
  signal finished(string output, bool transportFailure, string error)

  function utf8Bytes(text) {
    let count = 0
    for (let index = 0; index < text.length; index++) {
      let code = text.charCodeAt(index)
      if (code < 0x80) count += 1
      else if (code < 0x800) count += 2
      else if (code >= 0xD800 && code <= 0xDBFF
          && index + 1 < text.length
          && text.charCodeAt(index + 1) >= 0xDC00
          && text.charCodeAt(index + 1) <= 0xDFFF) {
        count += 4
        index += 1
      } else count += 3
    }
    return count
  }

  function safeEnvironment() {
    let result = {"PATH": "/usr/bin"}
    let names = ["OMARCHY_PATH", "HOME", "XDG_CONFIG_HOME", "XDG_STATE_HOME", "XDG_CACHE_HOME",
      "XDG_DATA_HOME", "XDG_RUNTIME_DIR", "HYPRLAND_INSTANCE_SIGNATURE",
      "LANG", "LC_CTYPE", "LC_ALL"]
    for (let name of names) {
      let value = Quickshell.env(name)
      if (value) result[name] = value
    }
    return result
  }

  function start(action, request, deadlineMs) {
    if (process.running || expected) return false
    generation += 1
    activeGeneration = generation
    receivedBytes = 0
    output = ""
    failure = ""
    expected = true
    timeoutMs = deadlineMs
    process.command = ["/usr/bin/python3", "-I", "-B", supervisorPath,
      action, JSON.stringify(request || {})]
    deadline.generation = activeGeneration
    deadline.interval = timeoutMs
    deadline.restart()
    process.running = true
    return true
  }

  function consume(text, retain) {
    if (!expected || failure) return
    receivedBytes += utf8Bytes(String(text))
    if (receivedBytes > maximumBytes) {
      stopFor("The keyboard helper returned too much data.")
    } else if (retain) {
      output += String(text)
    }
  }

  function stopFor(reason) {
    if (!failure) failure = reason
    if (process.running) {
      process.signal(15)
      killer.generation = activeGeneration
      killer.restart()
    } else {
      complete(activeGeneration)
    }
  }

  function complete(token) {
    if (!expected || token !== activeGeneration || process.running) return
    expected = false
    deadline.stop()
    killer.stop()
    let text = output
    let reason = failure
    if (!reason && !text.trim()) reason = "The keyboard helper returned no response."
    output = ""
    finished(text, reason !== "", reason)
  }

  property Process process: Process {
    clearEnvironment: true
    environment: root.safeEnvironment()
    stdout: SplitParser {
      splitMarker: ""
      onRead: function(data) { root.consume(data, true) }
    }
    stderr: SplitParser {
      splitMarker: ""
      onRead: function(data) { root.consume(data, false) }
    }
    onRunningChanged: if (!running && root.expected) {
      let token = root.activeGeneration
      Qt.callLater(function() { root.complete(token) })
    }
  }

  property Timer deadline: Timer {
    property int generation: 0
    repeat: false
    onTriggered: if (generation === root.activeGeneration && root.process.running)
      root.stopFor("The keyboard helper timed out.")
  }

  property Timer killer: Timer {
    property int generation: 0
    interval: 2000
    repeat: false
    onTriggered: if (generation === root.activeGeneration && root.process.running)
      root.process.signal(9)
  }
}
