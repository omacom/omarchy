// Pure helpers for the enrollment overlay, kept out of the QML so they can
// be reasoned about (and tested) without a shell.
.pragma library

// fprintd-enroll prints "Enroll result: <status>" per stage. Map every
// status libfprint can report to what the overlay should do and say.
function stepForResult(status) {
  switch (status) {
  case "enroll-stage-passed":
    return { kind: "passed", message: "Lift, shift the finger a little, press again" }
  case "enroll-completed":
    return { kind: "done", message: "Fingerprint enrolled" }
  case "enroll-retry-scan":
    return { kind: "retry", message: "Not a clear scan. Press flat and hold for a second" }
  case "enroll-swipe-too-short":
    return { kind: "retry", message: "Too short. Hold the finger on the sensor for a second" }
  case "enroll-finger-not-centered":
    return { kind: "retry", message: "Center the finger on the sensor" }
  case "enroll-remove-and-retry":
    return { kind: "retry", message: "Lift the finger, then press again" }
  case "enroll-duplicate":
    return { kind: "failed", message: "This finger is already enrolled, possibly as another finger" }
  case "enroll-data-full":
    return { kind: "failed", message: "The reader's storage is full" }
  case "enroll-disconnected":
    return { kind: "failed", message: "The reader was disconnected" }
  case "enroll-failed":
  case "enroll-unknown-error":
    return { kind: "failed", message: "Enrollment failed. Try again" }
  default:
    return null
  }
}

// One output line from fprintd-enroll -> a step, or null for chatter.
function stepForLine(line) {
  var s = String(line || "").trim()
  // The password prompt was cancelled or failed: fprintd answers both with a
  // PermissionDenied D-Bus error, so they cannot be told apart here.
  if (/PermissionDenied|Not Authori[sz]ed/i.test(s)) return { kind: "cancelled", message: "" }
  var m = s.match(/^Enroll result:\s*(\S+)/)
  if (m) return stepForResult(m[1])
  if (/^failed to claim device/i.test(s)) return { kind: "failed", message: "The reader is busy. Close other fingerprint tools and retry" }
  // Anything else from fprintd-enroll is a D-Bus error string; keep it out of
  // the overlay (it is in the journal) and say something a person can act on.
  if (/^EnrollStart failed/i.test(s) || /^failed to /i.test(s))
    return { kind: "failed", message: "The fingerprint reader could not start. Try again, or replug it" }
  return null
}

// Where to press next. Coverage is what makes a small sensor match, so walk
// the finger around a spiral: center first, then the ring around it.
var placements = [
  "the center of the fingertip",
  "slightly above center",
  "slightly right of center",
  "slightly below center",
  "slightly left of center",
  "the upper-right",
  "the lower-right",
  "the lower-left",
  "the upper-left"
]

function placementHint(stagesPassed, totalStages) {
  if (totalStages <= 1) return "Press the finger flat on the sensor"
  var i = stagesPassed % placements.length
  return "Press " + placements[i] + " on the sensor"
}

function fingerLabel(finger) {
  var f = String(finger || "").replace(/-finger$/, "").replace(/-/g, " ")
  return f ? f.charAt(0).toUpperCase() + f.slice(1) : "finger"
}

// fprintd's finger names: thumbs have no "-finger" suffix, the rest do
var fingers = ["thumb", "index-finger", "middle-finger", "ring-finger", "little-finger"]
var hands = ["left", "right"]

function fingerId(hand, index) {
  return hands[hand] + "-" + fingers[index]
}

function validFinger(finger) {
  return /^(left|right)-(thumb|(index|middle|ring|little)-finger)$/.test(String(finger || ""))
}

// fprintd-list prints " - #0: right-index-finger" per enrolled print
function enrolledFromList(text) {
  var out = []
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var m = lines[i].match(/-\s*#\d+:\s*(\S+)/)
    if (m && validFinger(m[1])) out.push(m[1])
  }
  return out
}
