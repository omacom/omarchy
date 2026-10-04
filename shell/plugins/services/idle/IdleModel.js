function secondsFromConfig(value, fallback) {
  var n = Number(value)
  if (!isFinite(n) || n < 0) return fallback
  return Math.floor(n)
}

function eventParts(event, count) {
  try {
    if (event && event.parse) return event.parse(count)
  } catch (error) {
  }
  return String(event && event.data ? event.data : "").split(",")
}

// The idle-inhibit daemon writes {count, holders, pid, inhibited}. A missing
// file, unparseable JSON, or a non-numeric count all mean "no inhibitors" so
// a daemon failure clears a stale nonzero count instead of disabling the lock.
function inhibitorCountFromText(text) {
  var raw = text !== undefined && text !== null ? String(text) : ""
  if (!raw.length) return 0

  try {
    var parsed = JSON.parse(raw)
    if (parsed && typeof parsed.count === "number" && parsed.count > 0) {
      return Math.floor(parsed.count)
    }
  } catch (error) {
  }
  return 0
}

// "cancel" when the first inhibitor arrives mid-cycle, "rearm" when the last
// one is released, "noop" otherwise.
function inhibitorTransition(previous, current) {
  if (previous === 0 && current > 0) return "cancel"
  if (previous > 0 && current === 0) return "rearm"
  return "noop"
}

function screensaverWindowsAfter(windows, address, visible) {
  var key = String(address || "")
  if (!key) {
    var current = windows || {}
    var existingCount = 0
    for (var currentKey in current) {
      if (current[currentKey]) existingCount++
    }
    return { windows: current, count: existingCount }
  }

  var next = {}
  var count = 0
  for (var existing in windows || {}) {
    if (existing !== key && windows[existing]) {
      next[existing] = true
      count++
    }
  }

  if (visible) {
    next[key] = true
    count++
  }

  return {
    windows: next,
    count: count
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    secondsFromConfig: secondsFromConfig,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    inhibitorCountFromText: inhibitorCountFromText,
    inhibitorTransition: inhibitorTransition
  }
}
