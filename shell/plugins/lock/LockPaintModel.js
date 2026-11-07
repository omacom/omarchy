// A session lock can become secure without the client ever presenting a
// buffer: ext-session-lock lets the compositor time out and blank, and Qt
// emits frameSwapped even when eglSwapBuffers fails. That is an invisible
// lock the user cannot answer. A frame counts only after the shell log since
// this lock began shows no present failure. A lock that did present stays
// protected, including one that later loses a second output.

var PAINT_SETTLE_MS = 1500

var PRESENT_FAILURES = [
  "Could not create EGL surface",
  "eglSwapBuffers failed",
  "Failed to create graphics context",
  "Failed to initialize graphics backend",
  "Failed to build or resize swapchain",
  "Failed to end frame",
  "Failed to start frame",
  "eglError: 0x3003",
  "EGL error 0x3003"
]

function journalShowsPresentFailure(text) {
  var body = String(text || "")
  var i
  for (i = 0; i < PRESENT_FAILURES.length; i++) {
    if (body.indexOf(PRESENT_FAILURES[i]) !== -1) return true
  }
  return false
}

function initialState() {
  return {
    generation: 0,
    startedAtSec: 0,
    surfaces: {},
    secure: false,
    presentFailed: false,
    journal: "idle",
    settled: false,
    painted: false,
    unpainted: false,
    awaitingSettle: false,
    committed: false
  }
}

function copySurfaces(surfaces) {
  var copy = {}
  var key
  if (!surfaces) return copy
  for (key in surfaces) {
    if (!Object.prototype.hasOwnProperty.call(surfaces, key)) continue
    copy[key] = { framed: !!surfaces[key].framed, failed: !!surfaces[key].failed }
  }
  return copy
}

function copyState(state) {
  return {
    generation: state.generation | 0,
    startedAtSec: state.startedAtSec | 0,
    surfaces: copySurfaces(state.surfaces),
    secure: !!state.secure,
    presentFailed: !!state.presentFailed,
    journal: state.journal || "idle",
    settled: !!state.settled,
    painted: !!state.painted,
    unpainted: !!state.unpainted,
    awaitingSettle: !!state.awaitingSettle,
    committed: !!state.committed
  }
}

function surfaceCount(surfaces) {
  var count = 0
  var key
  for (key in surfaces) {
    if (Object.prototype.hasOwnProperty.call(surfaces, key)) count += 1
  }
  return count
}

function everySurfaceFailed(surfaces) {
  var any = false
  var key
  for (key in surfaces) {
    if (!Object.prototype.hasOwnProperty.call(surfaces, key)) continue
    any = true
    if (!surfaces[key].failed) return false
  }
  return any
}

function hasTrustedFrame(state) {
  var key
  var surface
  if (state.presentFailed) return false
  for (key in state.surfaces) {
    if (!Object.prototype.hasOwnProperty.call(state.surfaces, key)) continue
    surface = state.surfaces[key]
    if (surface.framed && !surface.failed) return true
  }
  return false
}

function unchanged(state) {
  return { state: state, settle: "keep", queryJournal: false }
}

function finish(state, settle, queryJournal) {
  return { state: state, settle: settle, queryJournal: !!queryJournal }
}

// Decide whether this lock is a prompt the user can answer. Called on a copy.
function evaluate(state) {
  var count = surfaceCount(state.surfaces)
  var trusted = hasTrustedFrame(state)
  var settle = "keep"
  var queryJournal = false

  if (state.presentFailed) {
    state.painted = false
    state.committed = false
    state.unpainted = state.secure && count > 0
    state.awaitingSettle = false
    return finish(state, "stop", false)
  }

  // A present that already cleared the log stays a healthy lock. A later
  // output losing its scene graph must not make restart tear that prompt down.
  if (state.committed) {
    state.painted = true
    state.unpainted = false
    state.awaitingSettle = false
    return finish(state, "stop", false)
  }

  if (!state.secure || count === 0) {
    state.painted = false
    state.unpainted = false
    if (state.awaitingSettle) {
      state.awaitingSettle = false
      settle = "stop"
    }
    return finish(state, settle, false)
  }

  if (everySurfaceFailed(state.surfaces)) {
    state.painted = false
    state.unpainted = true
    state.awaitingSettle = false
    return finish(state, "stop", false)
  }

  if (state.journal === "idle" && state.startedAtSec > 0) {
    state.journal = "pending"
    queryJournal = true
  }

  if (trusted && (state.journal === "clean" || state.journal === "unavailable" || (state.journal === "idle" && state.settled))) {
    state.painted = true
    state.unpainted = false
    state.committed = true
    state.awaitingSettle = false
    return finish(state, "stop", queryJournal)
  }

  if (state.settled && state.journal !== "pending" && !trusted) {
    state.painted = false
    state.unpainted = true
    state.awaitingSettle = false
    return finish(state, "stop", queryJournal)
  }

  state.painted = false
  state.unpainted = false
  if (!state.awaitingSettle) {
    state.awaitingSettle = true
    settle = "start"
  }
  return finish(state, settle, queryJournal)
}

function reduce(state, event) {
  var type
  var next
  var key
  var decision
  var sec

  state = state || initialState()
  event = event || {}
  type = event.type

  if (type === "reset") {
    next = initialState()
    next.generation = (state.generation | 0) + 1
    return finish(next, "stop", false)
  }

  if (type === "begin") {
    next = initialState()
    next.generation = (state.generation | 0) + 1
    sec = Math.floor(Number(event.nowMs) / 1000) - 1
    next.startedAtSec = sec > 0 ? sec : 0
    return finish(next, "stop", false)
  }

  if (type === "surface" || type === "frame" || type === "graphics-failed" || type === "settle" || type === "journal") {
    if ((event.generation | 0) !== (state.generation | 0)) return unchanged(state)
  } else if (type !== "secure") {
    return unchanged(state)
  }

  if (type === "frame" || type === "graphics-failed") {
    key = String(event.surface)
    if (!state.surfaces || !state.surfaces[key]) return unchanged(state)
    if (type === "frame" && state.surfaces[key].framed) return unchanged(state)
    if (type === "graphics-failed" && state.surfaces[key].failed) return unchanged(state)
  }

  next = copyState(state)

  if (type === "surface") {
    key = String(event.surface)
    if ((event.delta | 0) > 0) {
      if (!next.surfaces[key]) next.surfaces[key] = { framed: false, failed: false }
    } else if ((event.delta | 0) < 0) {
      delete next.surfaces[key]
    }
  } else if (type === "frame") {
    next.surfaces[String(event.surface)].framed = true
  } else if (type === "graphics-failed") {
    next.surfaces[String(event.surface)].failed = true
  } else if (type === "secure") {
    next.secure = !!event.secure
    if (!next.secure) next.settled = false
  } else if (type === "settle") {
    next.settled = true
    if (next.journal === "pending") next.journal = "unavailable"
  } else if (type === "journal") {
    if (event.result === "failed") {
      next.presentFailed = true
      next.journal = "failed"
    } else if (event.result === "clean") {
      next.journal = "clean"
    } else {
      next.journal = "unavailable"
    }
  }

  decision = evaluate(next)
  return finish(next, decision.settle, decision.queryJournal)
}

if (typeof module !== "undefined") {
  module.exports = {
    PAINT_SETTLE_MS: PAINT_SETTLE_MS,
    journalShowsPresentFailure: journalShowsPresentFailure,
    initialState: initialState,
    reduce: reduce
  }
}
