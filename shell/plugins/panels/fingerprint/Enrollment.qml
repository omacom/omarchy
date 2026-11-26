import QtQuick
import Quickshell
import Quickshell.Io
import "EnrollmentModel.js" as Model

// The state of one fingerprint registration, driven by
// omarchy-setup-security-fingerprint-enroll. The view only reads this: which
// step, how many touches are in, and how it ended. Everything privileged
// happens in the one pkexec'd run of that helper.
Item {
  id: root
  visible: false

  // Drives the same events from a timer, touching neither root nor the reader.
  property bool demo: false
  // With demo: fail at the package install, to look at how a failure opens.
  property bool demoFails: false

  // Why the authorization prompt is asking, shown on it in place of the bare
  // command line.
  property string reason: ""

  readonly property string helper: "omarchy-setup-security-fingerprint-enroll"
  // Everything the last run's commands said, for a failure that takes more
  // than a line to explain.
  readonly property string logPath: Quickshell.env("HOME") + "/.local/state/omarchy/fingerprint.log"

  // What the reader has, read each time a registration begins.
  property string scanType: ""
  property var enrolled: []
  property var pendingEnrolled: []
  readonly property bool allEnrolled: enrolled.length >= Model.FINGERS.length

  // idle | auth | setup | enroll | verify | secure | done | failed | full
  // (full: the reader already holds all ten fingers)
  property string phase: "idle"
  property string finger: ""
  property int stage: 0
  property int stages: 0
  property string hint: ""
  property string failure: ""
  // Set when the authorization prompt was dismissed, until the next run.
  property bool dismissed: false
  property bool cancelling: false
  property bool pendingStart: false

  readonly property bool busy: ["auth", "setup", "enroll", "verify", "secure"].indexOf(phase) !== -1
  readonly property real progress: Model.progress(phase, stage, stages)
  // "line", "terminal" or "log" once a run has failed: see the model.
  readonly property string failureKind: phase === "failed" ? Model.failureKind(failure) : ""

  // Registers the next free finger: reads what the reader holds, then starts.
  function begin() {
    if (busy || run.running) return
    phase = "idle"
    stage = 0
    stages = 0
    hint = ""
    failure = ""
    dismissed = false
    pendingStart = true
    pendingEnrolled = []
    statusProc.running = false
    statusProc.running = true
  }

  function start() {
    if (run.running) return
    finger = Model.suggestFinger(enrolled)
    if (finger === "") {
      phase = "full"
      return
    }
    cancelling = false
    phase = demo ? "setup" : "auth"
    var command = demo ? [helper, demoFails ? "demo-fail" : "demo", finger] : ["pkexec", helper, "enroll", finger]
    // The polkit agent labels the prompt for this exact command line with the
    // reason. The helper's stderr, and pkexec's own, is the log of this run.
    run.command = ["bash", "-c", 'mkdir -p "${0%/*}"; [[ -z $1 ]] || omarchy-shell -q omarchy.polkit expect "$1" "$2"; shift 2; exec "$@" 2>"$0"',
      logPath, demo ? "" : helper + " enroll " + finger, reason].concat(command)
    run.running = true
  }

  function cancel() {
    if (run.running) {
      cancelling = true
      // The line reaches a helper pkexec has made root; the signal reaches
      // pkexec itself while it still waits for authorization.
      run.write("cancel\n")
      run.running = false
    }
    pendingStart = false
    phase = "idle"
    hint = ""
  }

  function fail(code) {
    // The first reason is the specific one; the helper's exit follows it. A
    // reason that lands after the exit replaces the generic one.
    if (phase === "done" || (phase === "failed" && failure !== "stopped")) return
    failure = code
    phase = "failed"
  }

  function handle(line) {
    if (cancelling) return
    var event = Model.parseEvent(line)
    if (!event) return
    switch (event.kind) {
    case "step":
      phase = event.value === "packages" || event.value === "sensor" ? "setup" : event.value
      hint = ""
      break
    case "scan":
      scanType = event.value
      break
    case "stages":
      stages = event.value
      break
    case "stage":
      stage = event.value
      hint = ""
      break
    case "retry":
      hint = event.value
      break
    case "enrolled":
    case "matched":
      hint = ""
      break
    case "done":
      phase = "done"
      break
    case "fail":
      fail(event.value)
      break
    }
  }

  Process {
    id: run
    stdinEnabled: true
    stdout: SplitParser { onRead: function(line) { root.handle(line) } }
    onExited: function(exitCode) {
      if (root.cancelling) {
        root.cancelling = false
        return
      }
      if (exitCode === 0 || root.phase === "done" || root.phase === "failed") return
      // pkexec: 126 is a dismissed prompt, 127 a refused one.
      if (exitCode === 126 && root.phase === "auth") {
        root.phase = "idle"
        root.dismissed = true
      } else if (exitCode === 127 && root.phase === "auth") {
        root.fail("denied")
      } else {
        root.fail("stopped")
      }
    }
  }

  Process {
    id: statusProc
    command: [root.helper, "status"]
    stdout: SplitParser {
      onRead: function(line) {
        var event = Model.parseEvent(line)
        if (!event) return
        if (event.kind === "scan") root.scanType = event.value
        else if (event.kind === "finger") root.pendingEnrolled = root.pendingEnrolled.concat([event.value])
        else if (event.kind === "ready") {
          root.enrolled = root.pendingEnrolled
          if (root.pendingStart) {
            root.pendingStart = false
            root.start()
          }
        }
      }
    }
  }
}
