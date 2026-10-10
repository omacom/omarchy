import QtQuick
import Quickshell.Io
import "Model.js" as Model

// A late read may never overwrite a newer selection or a local slider edit.
Item {
  id: root
  property string helperDirectory: ""
  property string targetName: ""
  property string identity: ""
  property string hardwareIdentity: ""
  property bool active: false
  property bool suspended: false
  property int value: 0
  property bool available: false
  property string status: "loading"
  property string scope: "unknown"
  property var affectedDisplays: []
  property string backend: ""
  property string error: ""
  property int failures: 0
  property int revision: 0
  property int pendingValue: -1
  readonly property bool busy: writer.running || debounce.running || pendingValue >= 0
  readonly property bool reading: reader.running

  function command() {
    return ["python3", "-B", helperDirectory + "monitor_state.py",
      "--brightness", targetName, "--identity", identity, "--token", hardwareIdentity]
  }
  function invalidate() {
    revision++
    available = false
    status = "loading"
    scope = "unknown"
    affectedDisplays = []
    backend = ""
    value = 0
    error = ""
    failures = 0
    pendingValue = -1
    debounce.stop()
    if (active) Qt.callLater(read)
  }
  function read() {
    if (!active || suspended || busy || reader.running || !targetName || !identity) return
    reader.requestRevision = revision
    reader.received = false
    reader.command = command()
    reader.running = true
  }
  function preview(next) {
    if (suspended || !available || !isFinite(next)) return
    revision++
    value = Model.clampBrightness(next)
    pendingValue = value
    debounce.restart()
  }
  function cancelPreview() { debounce.stop() }
  function setValue(next) {
    if (suspended || !available || !targetName || !isFinite(next)) return
    revision++
    value = Model.clampBrightness(next)
    pendingValue = value
    debounce.stop()
    flush()
  }
  function flush() {
    if (suspended || writer.running || reader.running || pendingValue < 0) return
    writer.requestRevision = revision
    error = ""
    writer.command = command().concat(["--value", String(pendingValue)])
    pendingValue = -1
    writer.running = true
  }
  onTargetNameChanged: invalidate()
  onIdentityChanged: invalidate()
  onHardwareIdentityChanged: invalidate()
  onActiveChanged: if (active) read()
  onSuspendedChanged: if (!suspended && active) read()

  function accept(text) {
    try {
      var result = JSON.parse(text)
      if (result.name !== targetName || result.description !== identity) return false
      if (result.status === "available" && result.identity !== hardwareIdentity) {
        status = "disconnected"
        available = false
        value = 0
        error = "Display connection changed. Refresh the display selection."
        return true
      }
      status = result.status || "io_error"
      scope = result.scope || "unknown"
      affectedDisplays = result.affectedDisplays || []
      backend = result.backend || ""
      available = status === "available" && typeof result.brightness === "number" && isFinite(result.brightness)
        && result.brightness >= 0 && result.brightness <= 100
      value = available ? result.brightness : 0
      error = result.message || ""
      if (status === "available" && !available) {
        status = "io_error"
        error = "The display returned an invalid brightness value."
      }
      failures = available ? 0 : Math.min(5, failures + 1)
      return true
    } catch (e) { return false }
  }

  Timer { id: debounce; interval: 180; onTriggered: root.flush() }
  Timer {
    interval: root.status === "busy" ? 1000
      : ["timeout", "io_error", "disconnected"].indexOf(root.status) >= 0 ? Math.min(60000, 5000 * Math.pow(2, Math.max(0, root.failures - 1)))
      : root.available ? 15000 : 60000
    repeat: true
    running: root.active && !root.suspended
    onTriggered: root.read()
  }
  Process {
    id: reader
    property int requestRevision: -1
    property bool received: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (reader.requestRevision !== root.revision || root.suspended || root.busy) return
        reader.received = root.accept(text)
      }
    }
    onExited: {
      if (requestRevision === root.revision && !root.busy && !root.suspended && !received) {
        root.status = "io_error"
        root.available = false
        root.value = 0
        root.error = "Could not read this display's brightness."
      }
      if (root.pendingValue >= 0) Qt.callLater(root.flush)
      else if (requestRevision !== root.revision) Qt.callLater(root.read)
    }
  }
  Process {
    id: writer
    property int requestRevision: -1
    property bool received: false
    onRunningChanged: if (running) received = false
    stderr: StdioCollector { id: writeError; waitForEnd: true }
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (writer.requestRevision === root.revision) writer.received = root.accept(text)
    }
    onExited: function(code) {
      if ((code !== 0 || !received) && requestRevision === root.revision) {
        root.status = "io_error"
        root.error = String(writeError.text || "Could not set display brightness").trim()
        root.available = false
        root.value = 0
      }
      if (root.pendingValue >= 0) Qt.callLater(root.flush)
      else if (requestRevision !== root.revision) Qt.callLater(root.read)
    }
  }
}
