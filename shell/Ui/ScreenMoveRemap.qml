import QtQuick
import Quickshell
import Quickshell.Io

// A monitor moving within the layout must not tear down the bar and
// background surfaces that follow it.
//
// Hyprland 0.57 moves an output's already-mapped layer surfaces with the
// monitor, so on current Hyprland the guard only verifies and never repairs.
// Older builds, however, leave those surfaces at the monitor's old global
// offset when a re-anchored neighbour changes size or place, and the bar and
// wallpaper then float over the wrong part of the desktop until something
// remaps them.
//
// Hazards:
//
// 1. No-op emissions. Qt re-emits a screen's x/y on every geometry
//    recomputation, even when the value did not change: rotating a monitor
//    reconfigures its output and fires xChanged/yChanged with the same
//    origin (and the re-anchoring of a neighbor reconfigures it in turn).
//    Acting on those would remap the bar of a monitor that never moved.
//    The guard therefore only reacts to a numeric origin change.
//
// 2. Surfaces left at their old offset. When a monitor's rotation re-anchors
//    a neighboring output, Hyprland leaves that output's already-mapped
//    layer surfaces at their old global offset; nothing re-places them until
//    they are remapped. The historic repair was to unmap the window briefly
//    and let the compositor re-place it on the remap — but the unmap frees
//    the layer surface and the whole scene graph, so every bar widget
//    rebuilds and any open bar-widget panel is destroyed. That visible
//    reload is exactly what rotation was doing to the top bar.
//
// The repair ladder, in order:
//
//   a. Do nothing. When the origin settles, the guard asks Hyprland where
//      its own surface actually is (hyprctl layers, matched on monitor and
//      namespace). A surface mapped at the screen's origin is fine; a
//      surface that is not mapped at all (its window hidden) is parked, not
//      misplaced.
//
//   b. Re-anchor (non-destructive). A surface mapped somewhere else gets
//      its output's position re-applied — even the value the output already
//      has — which makes Hyprland re-place the output's layer surfaces in
//      place, without a remap. The re-place is asynchronous and lands well
//      over half a second after the eval (longer under load), and a
//      re-anchor that races the reconfiguration burst can be lost, so the
//      guard re-samples the surface through a budget (maxMisplaceSamples)
//      and retries the re-anchor once from the settled state before giving
//      up.
//
//   c. Pulse (last resort). A surface that is still misplaced after two
//      re-anchors and their resample budgets, or a position that could not
//      be verified at all (the compositor query failed), gets the historic
//      remap pulse, preserving the original behavior when every cheaper
//      option is exhausted.
Item {
  id: root

  required property var window
  // The layer namespace of the owning window (its WlrLayershell.namespace).
  // The attached property is not readable back from JS, so the owner passes
  // the same literal it assigns. The query matches on monitor + namespace.
  required property var namespace

  readonly property var screen: window ? window.screen : null

  // Fold into the window's binding: visible: <shown> && !guard.remapping
  property bool remapping: false

  // The screen this guard is tracking, and the last origin it cleared
  // (verified placed or remapped). No-op re-emissions of the same value
  // never restart the settle timer. A replaced screen object (output
  // replug) resets the baseline so the first emission on the new screen
  // counts as a real move.
  property var trackedScreen: null
  property var clearedOrigin: null

  // The in-flight operation, or null: { kind: "query"|"reanchor", x, y,
  // screen }. Results are matched against this origin so an answer that
  // lands late (or after the watchdog has already failed the operation) is
  // discarded, not acted on.
  property var op: null
  // True once the re-anchor has been tried for the current move; a fresh
  // move, a placed reading, or a pulse resets it, so a later genuine
  // misplacement gets its own re-anchor before the pulse.
  property bool repairTried: false
  // Consecutive misplaced samples for the current move; the re-anchor is
  // asynchronous (measured at well over half a second to land), so the
  // surface is re-sampled until it arrives or the budget is spent.
  property int misplacedSamples: 0
  readonly property int maxMisplaceSamples: 8
  // How many re-anchors the guard tries for one move before giving up to
  // the pulse. The first can be lost when it races the reconfiguration
  // burst; a second one, issued from the settled state, lands reliably.
  property int reanchorCount: 0

  visible: false

  function currentOrigin() {
    return screen ? ({ x: screen.x, y: screen.y }) : null
  }

  // Called from the screen's x/y signals.
  function noteOrigin() {
    if (!screen) return
    if (trackedScreen !== screen) {
      trackedScreen = screen
      clearedOrigin = null
    }
    var origin = currentOrigin()
    if (clearedOrigin && clearedOrigin.x === origin.x && clearedOrigin.y === origin.y)
      return
    // A new real move starts fresh; a stale repair must not extend it.
    repairTried = false
    misplacedSamples = 0
    reanchorCount = 0
    settleTimer.restart()
  }

  // The origin has settled; decide whether the surface needs re-placing.
  function verifyPlacement() {
    // An in-flight operation will re-settle if the origin moved meanwhile;
    // do not stack a second one.
    if (op) return
    var origin = currentOrigin()
    if (!origin) return
    if (namespace === "") {
      // A missing namespace would make the query unmatchable; a caller bug
      // should not silently fall back to the destructive pulse.
      console.warn("ScreenMoveRemap: no namespace for " + (window ? window.objectName : "window") + "; skipping re-place check")
      clearedOrigin = ({ x: origin.x, y: origin.y })
      return
    }
    // A hidden window is parked off-screen by its owner, not misplaced: it
    // maps at the current origin whenever it is revealed.
    if (!window || !window.visible) {
      clearedOrigin = ({ x: origin.x, y: origin.y })
      return
    }
    op = ({ kind: "query", x: origin.x, y: origin.y, screen: trackedScreen })
    layersProc.running = true
  }

  function onQueryExited(code) {
    if (!op || op.kind !== "query") return
    var asked = op
    op = null
    // The layout moved again while the query was in flight, or the screen
    // was replaced: the answer is stale; settle and verify again.
    var now = currentOrigin()
    if (!now || asked.screen !== trackedScreen || now.x !== asked.x || now.y !== asked.y) {
      settleTimer.restart()
      return
    }
    var state = placementState(code, String(layersOut.text || ""), asked)
    if (state === "placed" || state === "absent") {
      repairTried = false
      misplacedSamples = 0
      reanchorCount = 0
      clearedOrigin = ({ x: asked.x, y: asked.y })
      return
    }
    if (state === "misplaced" && !repairTried) {
      // Tier b: ask Hyprland to re-place the surface in place.
      repairTried = true
      reanchorCount = 1
      misplacedSamples = 0
      reanchorSurface(asked)
      return
    }
    if (state === "misplaced") {
      // The re-place is asynchronous and can lag well past a second under
      // load, so sample through the budget before escalating.
      var budget = (reanchorCount >= 2)
        ? Math.floor(root.maxMisplaceSamples / 2)
        : root.maxMisplaceSamples
      if (misplacedSamples < budget) {
        misplacedSamples += 1
        resampleTimer.restart()
        return
      }
      if (reanchorCount < 2) {
        // The first re-anchor did not land (it can be lost when it races
        // the reconfiguration burst); retry once from the settled state.
        reanchorCount = 2
        misplacedSamples = 0
        reanchorSurface(asked)
        return
      }
    }
    // "misplaced" for good, or "unknown": tier c, the historic remap pulse.
    repairTried = false
    misplacedSamples = 0
    reanchorCount = 0
    pulse()
  }

  // Re-apply the output's own position so Hyprland re-places its layer
  // surfaces in place (see the header). The name comes from the compositor;
  // it is interpolated into a Lua expression, so only accept the same shape
  // the rotation CLI already requires, and fall back to the pulse otherwise.
  function reanchorSurface(asked) {
    var name = String(asked.screen.name || "")
    var x = Math.round(asked.x)
    var y = Math.round(asked.y)
    if (!/^[A-Za-z0-9._-]+$/.test(name)) {
      console.warn("ScreenMoveRemap: refusing to re-anchor for output name \"" + name + "\"")
      pulse()
      return
    }
    op = ({ kind: "reanchor", x: asked.x, y: asked.y, screen: asked.screen })
    reanchorProc.command = ["hyprctl", "eval", 'hl.monitor({ output = "' + name + '", position = "' + x + "x" + y + '" })']
    reanchorProc.running = true
  }

  function onReanchorExited(code) {
    if (!op || op.kind !== "reanchor") return
    op = null
    // Whether or not the eval was accepted, the truth is where the surface
    // is now; let the re-place land, then re-verify (tier a again, with
    // repairTried set, so a second misplacement goes straight to the pulse).
    reanchorSettleTimer.restart()
  }

  // "placed": the surface is mapped at the screen's origin. "absent": the
  // namespace is not mapped on the monitor (the window is hidden).
  // "misplaced": mapped somewhere else. "unknown": the query or its answer
  // could not be interpreted; the conservative choice is the pulse.
  function placementState(code, text, asked) {
    if (!asked) return "unknown"
    if (code !== 0) return "unknown"
    var data = null
    try {
      data = JSON.parse(text)
    } catch (e) {
      return "unknown"
    }
    if (!data) return "unknown"
    var monitor = data[asked.screen.name]
    if (!monitor || !monitor.levels) return "unknown"
    var found = false
    var levels = monitor.levels
    for (var key in levels) {
      var entries = levels[key]
      if (!Array.isArray(entries)) continue
      for (var i = 0; i < entries.length; i++) {
        var entry = entries[i]
        if (entry.namespace !== root.namespace) continue
        found = true
        if (Math.abs(entry.x - asked.x) <= 1 && Math.abs(entry.y - asked.y) <= 1)
          return "placed"
      }
    }
    return found ? "misplaced" : "absent"
  }

  // Tier c: unmap for a beat so the compositor re-places the surface at the
  // monitor's new origin.
  function pulse() {
    var origin = currentOrigin()
    if (origin) clearedOrigin = ({ x: origin.x, y: origin.y })
    remapping = true
  }

  // A layout reshuffle can move the monitor more than once before it lands.
  // Let the positions settle before verifying.
  Timer {
    id: settleTimer
    interval: 200
    onTriggered: root.verifyPlacement()
  }

  // After a re-anchor, let the compositor re-place the surface before
  // re-verifying.
  Timer {
    id: reanchorSettleTimer
    interval: 300
    onTriggered: root.verifyPlacement()
  }

  // Second-chance sampling while a re-anchor is in flight (see the header).
  Timer {
    id: resampleTimer
    interval: 400
    onTriggered: root.verifyPlacement()
  }

  // Hold the surface unmapped for a beat so the compositor processes the
  // unmap before the remap instead of coalescing them into a no-op.
  Timer {
    interval: 50
    running: root.remapping
    onTriggered: root.remapping = false
  }

  // An operation that never returns (wedged compositor IPC) would stall the
  // guard until the shell restarts. Fail it to the conservative path, the
  // historic pulse; a late real exit is then discarded by the op check.
  Timer {
    id: opWatchdog
    interval: 5000
    running: root.op !== null
    onTriggered: {
      if (!root.op) return
      console.warn("ScreenMoveRemap: " + root.op.kind + " for " + root.namespace + " timed out; falling back to remap pulse")
      root.op = null
      root.repairTried = false
      root.pulse()
    }
  }

  Process {
    id: layersProc
    command: ["hyprctl", "layers", "-j"]
    stdout: StdioCollector {
      id: layersOut
      waitForEnd: true
    }
    onExited: function(code) {
      root.onQueryExited(code)
    }
  }

  Process {
    id: reanchorProc
    stdout: StdioCollector {
      waitForEnd: true
    }
    onExited: function(code) {
      root.onReanchorExited(code)
    }
  }

  Connections {
    target: root.screen
    function onXChanged() { root.noteOrigin() }
    function onYChanged() { root.noteOrigin() }
  }
}
