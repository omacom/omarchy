import QtQuick
import Quickshell.Io

// Runtime-owned foreground work. Closing its owner closes the helper and its
// broker connection; Ward owns cancellation of any corresponding host job.
QtObject {
  id: root
  required property var argv
  property var options: ({})
  property bool structured: false
  property bool cancelled: false
  property bool overflow: false
  property bool completed: false
  property bool started: false
  readonly property bool running: child.running
  readonly property var processId: child.processId
  signal finished(var result)

  function cancel() { cancelled = true; child.running = false }
  function write(text) { child.write(text) }
  function closeStdin() { child.stdinEnabled = false }
  function signal(number) { child.signal(number) }
  function checkOutput(text) {
    // Allows worst-case escaping of both bounded broker output streams.
    if (text.length > 32 * 1024 * 1024) { overflow = true; child.running = false }
  }
  function complete(code, status) {
    if (completed) return
    completed = true
    let result = {version: 1, status: "unavailable"}
    if (cancelled) result.status = "cancelled"
    else if (overflow || !started) result.status = "failed"
    else if (structured) {
      try {
        const value = JSON.parse(output.text)
        if (value.version === 1 && ["completed", "denied", "invalid", "busy", "rate_limited",
            "failed", "timed_out", "unavailable"].indexOf(value.status) !== -1) result = value
      } catch (_) {}
    } else {
      result = {version: 1, status: "completed", exitCode: code, exitStatus: status,
        stdout: output.text, stderr: errors.text}
    }
    try {
      finished(result)
      if (typeof options.onFinished === "function") options.onFinished(result)
    } finally { destroy() }
  }
  property Process child: Process {
    command: root.argv
    running: true
    stdinEnabled: root.options.stdin !== undefined || root.options.keepStdin === true
    onStarted: {
      root.started = true
      if (root.options.stdin !== undefined) {
        write(String(root.options.stdin))
        if (!root.options.keepStdin) stdinEnabled = false
      }
      if (typeof root.options.onStarted === "function") root.options.onStarted(root)
    }
    onExited: (code, status) => root.complete(code, status)
    // QProcess launch failures need not emit exited. Defer so a normal exit
    // can supply its real status before this fallback settles the job.
    onRunningChanged: if (!running) root.finishTimer.start()
    stdout: StdioCollector {
      id: output
      waitForEnd: false
      onDataChanged: root.checkOutput(text)
    }
    stderr: StdioCollector {
      id: errors
      waitForEnd: false
      onDataChanged: root.checkOutput(text)
    }
  }
  property Timer finishTimer: Timer { interval: 0; onTriggered: root.complete(-1, 1) }
}
