// Pure helpers for the enrollment overlay, kept out of the QML so they can
// be reasoned about (and tested) without a shell. User-facing text is
// returned as a catalog key plus its English fallback ({ key, text }); the
// overlay renders it with I18n.t(key, text).
.pragma library

// Named t so the i18n test sees every key used here as a literal reference.
function t(key, text) {
  return { key: key, text: text }
}

// fprintd-enroll prints "Enroll result: <status>" per stage. Map every
// status libfprint can report to what the overlay should do and say.
function stepForResult(status) {
  switch (status) {
  case "enroll-stage-passed":
    return { kind: "passed", message: t("fingerprint.stagePassed", "Lift, shift the finger a little, press again") }
  case "enroll-completed":
    return { kind: "done", message: t("fingerprint.enrolled", "Fingerprint enrolled") }
  case "enroll-retry-scan":
    return { kind: "retry", message: t("fingerprint.retryScan", "Not a clear scan. Press flat and hold for a second") }
  case "enroll-swipe-too-short":
    return { kind: "retry", message: t("fingerprint.tooShort", "Too short. Hold the finger on the sensor for a second") }
  case "enroll-finger-not-centered":
    return { kind: "retry", message: t("fingerprint.notCentered", "Center the finger on the sensor") }
  case "enroll-remove-and-retry":
    return { kind: "retry", message: t("fingerprint.removeAndRetry", "Lift the finger, then press again") }
  case "enroll-duplicate":
    return { kind: "failed", message: t("fingerprint.duplicate", "This finger is already enrolled, possibly as another finger") }
  case "enroll-data-full":
    return { kind: "failed", message: t("fingerprint.storageFull", "The reader's storage is full") }
  case "enroll-disconnected":
    return { kind: "failed", message: t("fingerprint.disconnected", "The reader was disconnected") }
  case "enroll-failed":
  case "enroll-unknown-error":
    return { kind: "failed", message: t("fingerprint.enrollFailed", "Enrollment failed. Try again") }
  default:
    return null
  }
}

// One output line from fprintd-enroll -> a step, or null for chatter.
function stepForLine(line) {
  var s = String(line || "").trim()
  // The password prompt was cancelled or failed: fprintd answers both with a
  // PermissionDenied D-Bus error, so they cannot be told apart here.
  if (/PermissionDenied|Not Authori[sz]ed/i.test(s)) return { kind: "cancelled", message: t("fingerprint.passwordNeeded", "Not added: your password is needed to add a fingerprint") }
  var m = s.match(/^Enroll result:\s*(\S+)/)
  if (m) return stepForResult(m[1])
  if (/^failed to claim device/i.test(s)) return { kind: "failed", message: t("fingerprint.readerBusy", "The reader is busy. Close other fingerprint tools and retry") }
  // Anything else from fprintd-enroll is a D-Bus error string; keep it out of
  // the overlay (it is in the journal) and say something a person can act on.
  if (/^EnrollStart failed/i.test(s) || /^failed to /i.test(s))
    return { kind: "failed", message: t("fingerprint.readerNotStarted", "The fingerprint reader could not start. Try again, or replug it") }
  return null
}

// Where to press next. Coverage is what makes a small sensor match, so walk
// the finger around a spiral: center first, then the ring around it.
var placements = [
  t("fingerprint.placement.center", "the center of the fingertip"),
  t("fingerprint.placement.above", "slightly above center"),
  t("fingerprint.placement.right", "slightly right of center"),
  t("fingerprint.placement.below", "slightly below center"),
  t("fingerprint.placement.left", "slightly left of center"),
  t("fingerprint.placement.upperRight", "the upper-right"),
  t("fingerprint.placement.lowerRight", "the lower-right"),
  t("fingerprint.placement.lowerLeft", "the lower-left"),
  t("fingerprint.placement.upperLeft", "the upper-left")
]

// The placement for the next press; the overlay fills it into
// fingerprint.pressAt ("Press %1 on the sensor").
function placementFor(stagesPassed) {
  return placements[stagesPassed % placements.length]
}

// A request may carry a deadline (epoch milliseconds) after which its sender
// has stopped waiting for the overlay; one without a deadline never expires.
function expired(payload, now) {
  var expires = Number(payload && payload.expires)
  return isFinite(expires) && expires > 0 && now > expires
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

// A finger's name for use inside a sentence ("your right index finger").
var fingerNames = {
  "left-thumb": t("fingerprint.finger.leftThumb", "left thumb"),
  "left-index-finger": t("fingerprint.finger.leftIndex", "left index finger"),
  "left-middle-finger": t("fingerprint.finger.leftMiddle", "left middle finger"),
  "left-ring-finger": t("fingerprint.finger.leftRing", "left ring finger"),
  "left-little-finger": t("fingerprint.finger.leftLittle", "left little finger"),
  "right-thumb": t("fingerprint.finger.rightThumb", "right thumb"),
  "right-index-finger": t("fingerprint.finger.rightIndex", "right index finger"),
  "right-middle-finger": t("fingerprint.finger.rightMiddle", "right middle finger"),
  "right-ring-finger": t("fingerprint.finger.rightRing", "right ring finger"),
  "right-little-finger": t("fingerprint.finger.rightLittle", "right little finger")
}

function fingerName(finger) {
  return fingerNames[finger] || t("fingerprint.finger.unknown", "finger")
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
