var MAX_TIMEOUT_SECONDS = Math.floor(2147483647 / 1000)

function secondsFromConfig(value, fallback) {
  var n = Number(value)
  if (!isFinite(n) || n < 0) return fallback
  return Math.floor(n)
}

function optionalSecondsFromConfig(value) {
  if (value === undefined || value === null || value === "") return -1
  if (typeof value !== "number" && typeof value !== "string") return -1

  var n = Number(value)
  if (!isFinite(n)) return -1

  var seconds = Math.floor(n)
  return seconds > 0 ? Math.min(seconds, MAX_TIMEOUT_SECONDS) : -1
}

function shouldSuspend(inputIdle, inhibitorIdle, idleEnabled, timeoutSeconds) {
  return !!inputIdle && !!inhibitorIdle && !!idleEnabled && timeoutSeconds > 0
}

function eventParts(event, count) {
  try {
    if (event && event.parse) return event.parse(count)
  } catch (error) {
  }
  return String(event && event.data ? event.data : "").split(",")
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
    MAX_TIMEOUT_SECONDS: MAX_TIMEOUT_SECONDS,
    secondsFromConfig: secondsFromConfig,
    optionalSecondsFromConfig: optionalSecondsFromConfig,
    shouldSuspend: shouldSuspend,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter
  }
}
