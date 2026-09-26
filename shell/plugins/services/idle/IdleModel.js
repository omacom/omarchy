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

// The Wayland notification is created only after shell config has settled, and
// a later timeout destroys that object instead of updating it. Quickshell
// replaces the notification in place, and a reused native address drops idled.
function monitorSubscription(ready, timeoutSeconds, live, armedTimeout) {
  if (!ready) {
    return {
      live: false,
      timeout: armedTimeout,
      recreate: !!live
    }
  }

  if (live && armedTimeout === timeoutSeconds) {
    return {
      live: true,
      timeout: armedTimeout,
      recreate: false
    }
  }

  return {
    live: true,
    timeout: timeoutSeconds,
    recreate: true
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    secondsFromConfig: secondsFromConfig,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    monitorSubscription: monitorSubscription
  }
}
