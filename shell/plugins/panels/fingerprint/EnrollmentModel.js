// What omarchy-setup-security-fingerprint-enroll says, as the panel reads it.
// The helper runs as root and its lines cross a pipe, so every value is
// checked against what the panel knows how to draw before it is used.

// The order fingers are registered in: the index fingers, then outward.
var FINGERS = ["right-index-finger", "left-index-finger", "right-thumb", "left-thumb", "right-middle-finger",
  "left-middle-finger", "right-ring-finger", "left-ring-finger", "right-little-finger", "left-little-finger"]
var STEPS = ["packages", "sensor", "enroll", "verify", "secure"]
var HINTS = ["short", "center", "lift", "fast", "again", "nomatch"]
// Failures one line on the panel explains.
var PLAIN_FAILURES = ["no-reader", "duplicate", "full", "disconnected", "enroll", "no-match", "denied"]
var MAX_STAGES = 100

// One line of the helper's output as { kind, value }, or null for a line the
// panel has no use for.
function parseEvent(line) {
  var parts = String(line || "").trim().split(" ")
  var kind = parts[0]
  var value = parts.length > 1 ? parts[1] : ""
  var count = /^[0-9]+$/.test(value) ? parseInt(value, 10) : 0
  // An event is its name alone or its name and one value, nothing more.
  var bare = ["enrolled", "matched", "done", "ready"].indexOf(kind) !== -1
  if (parts.length !== (bare ? 1 : 2)) return null
  switch (kind) {
  case "step":
    return STEPS.indexOf(value) !== -1 ? { kind: kind, value: value } : null
  case "scan":
    return { kind: kind, value: value === "press" || value === "swipe" ? value : "" }
  case "stages":
  case "stage":
    return count > 0 && count <= MAX_STAGES ? { kind: kind, value: count } : null
  case "retry":
    return { kind: kind, value: HINTS.indexOf(value) !== -1 ? value : "again" }
  case "fail":
    return /^[a-z][a-z-]*$/.test(value) ? { kind: kind, value: value } : null
  case "finger":
    return FINGERS.indexOf(value) !== -1 ? { kind: kind, value: value } : null
  case "enrolled":
  case "matched":
  case "done":
  case "ready":
    return { kind: kind, value: "" }
  }
  return null
}

// How a failure is shown: "line" for one the status line explains, "terminal"
// for a reader its platform keeps off until the owner agrees (the terminal
// setup explains and asks), and "log" for everything else, which opens what
// the commands said.
function failureKind(code) {
  if (PLAIN_FAILURES.indexOf(code) !== -1) return "line"
  if (code === "platform") return "terminal"
  return "log"
}

// The share of the print to light, 0 to 1.
function progress(phase, stage, stages) {
  if (phase === "verify" || phase === "secure" || phase === "done") return 1
  if (phase !== "enroll") return 0
  // Until the reader says how many touches it wants, close in on full.
  if (stages <= 0) return 1 - Math.pow(0.85, stage)
  return Math.min(0.96, stage / stages)
}

// The next finger to register, or "" once the reader holds all ten.
function suggestFinger(enrolled) {
  for (var i = 0; i < FINGERS.length; i++)
    if (enrolled.indexOf(FINGERS[i]) === -1) return FINGERS[i]
  return ""
}

if (typeof module !== "undefined") {
  module.exports = {
    FINGERS: FINGERS,
    STEPS: STEPS,
    parseEvent: parseEvent,
    failureKind: failureKind,
    progress: progress,
    suggestFinger: suggestFinger
  }
}
