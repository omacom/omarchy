import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// The shared gauge-cluster overlay dressed for the memory bandwidth sweep:
// the 1-core end on the left, the best later rung on the right, in MB/s,
// titled with the CPU model. The dials keep separate scales, so the 1-core
// needle stays where it landed while the right gauge is the one that opens.
// One omarchy-memory-bandwidth run streams the whole sweep, so dismissal
// only has to stop the process.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property bool running: false
  property bool expectedStop: false
  property bool pendingRun: false
  property string phase: ""             // "one" | "many" | ""
  property string cpuName: ""
  property string oneCoreMBps: ""
  property real bestMBps: 0
  property string bestLabel: ""
  property string testedLabel: ""
  property string error: ""
  property string stderrText: ""

  function open(payloadJson) {
    opened = true
    runTest()
  }

  // Host-initiated close (`shell hide`). The user-initiated paths (Esc, the
  // scrim) route through shell.hide so the host's open-panel state stays
  // consistent, and land back here.
  function close() {
    opened = false
    pendingRun = false
    // Clear the phase before killing the process, so onExited reads the stop
    // as a dismissal rather than a failed run.
    phase = ""
    running = false
    if (proc.running) {
      expectedStop = true
      proc.running = false
    }
  }

  function dismiss() {
    if (shell && typeof shell.hide === "function")
      shell.hide((manifest && manifest.id) || "omarchy.memory-bandwidth")
    else close()
  }

  function runTest() {
    if (proc.running) {
      // A dismissal's SIGTERM is still in flight; Process.running stays true
      // until the child exits, so queue the fresh run for onExited.
      if (expectedStop) pendingRun = true
      return
    }
    error = ""
    cpuName = ""
    oneCoreMBps = ""
    bestMBps = 0
    bestLabel = ""
    testedLabel = ""
    stderrText = ""
    phase = "one"
    running = true
    proc.running = true
  }

  function toRate(raw) {
    var value = parseFloat(raw)
    return isFinite(value) && value > 0 ? value : 0
  }

  function coresLabel(count) {
    return count === 1 ? "1 CORE" : count + " CORES"
  }

  function coresTestedLabel(count) {
    return count === 1 ? "1 CORE TESTED" : count + " CORES TESTED"
  }

  // Lines are "cpu <model>", "cores <n>", then one "<count> <MB/s>" per rung.
  // The left dial locks on the 1-core figure. The right dial stays dark until
  // a later rung, then holds the best aggregate so a slower pass cannot pull
  // the needle down. Its top label names that rung. The line under it is how
  // many cores the sweep covered.
  function updateLine(line) {
    var parts = String(line).trim().split(/\s+/)
    if (parts.length < 2) return
    if (parts[0] === "cpu") {
      cpuName = parts.slice(1).join(" ")
      return
    }
    if (parts[0] === "cores") {
      var tested = parseInt(parts[1], 10)
      if (isFinite(tested) && tested > 0) testedLabel = coresTestedLabel(tested)
      return
    }
    if (!/^[0-9]+$/.test(parts[0])) return
    var count = parseInt(parts[0], 10)
    var value = parseFloat(parts[1])
    if (!isFinite(count) || count < 1 || !isFinite(value) || value < 0) return
    if (count === 1) {
      phase = "one"
      oneCoreMBps = String(value)
      return
    }
    phase = "many"
    if (bestMBps > 0 && value < bestMBps) return
    bestMBps = value
    bestLabel = coresLabel(count)
  }

  Process {
    id: proc
    command: ["omarchy-memory-bandwidth"]
    stdout: SplitParser { onRead: function(line) { root.updateLine(line) } }
    // Exit and stream-finished have no guaranteed order: when a failed exit
    // beat the collector and published the generic message, replace it with
    // the specific one once it lands.
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.stderrText = String(text || "").trim()
        if (root.error !== "" && root.stderrText !== "") root.error = root.stderrText
      }
    }
    onExited: function(exitCode) {
      if (root.pendingRun) {
        root.pendingRun = false
        root.expectedStop = false
        if (root.opened) Qt.callLater(root.runTest)
        return
      }

      if (!root.expectedStop && exitCode !== 0) {
        root.error = root.stderrText || "Memory bandwidth test failed"
        root.phase = ""
        root.running = false
        return
      }

      root.expectedStop = false
      root.phase = ""
      root.running = false
    }
  }

  SpeedTestOverlay {
    fontFamily: Style.font.family
    layerNamespace: "omarchy-memory-bandwidth"
    title: root.cpuName
    leftLabel: "1 CORE"
    rightLabel: root.bestLabel
    rightDetail: root.testedLabel
    unit: "MB/s"
    runAgainTooltip: "Measure again"
    running: root.running
    leftValue: root.toRate(root.oneCoreMBps)
    rightValue: root.bestMBps
    leftLive: root.running && root.phase === "one"
    rightLive: root.running && root.phase === "many"
    error: root.error
    open: root.opened
    splitScale: true
    scaleStops: [20000, 40000, 80000, 120000, 160000, 240000]
    onCloseRequested: root.dismiss()
    onRunAgainRequested: root.runTest()
  }
}
