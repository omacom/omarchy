function secondsFromConfig(value, fallback) {
  var n = Number(value)
  if (!isFinite(n) || n < 0) return fallback
  return Math.floor(n)
}

// An IdleMonitor goes permanently deaf if `timeout` is reassigned while it is
// live, so the monitor is destroyed and rebuilt instead of retuned. This
// decides what the monitor should look like and whether it has to be replaced.
function monitorPlan(idleEnabled, timeoutSeconds, activeTimeout, monitorActive) {
  var desired = 0
  if (idleEnabled) {
    var n = Number(timeoutSeconds)
    desired = isFinite(n) && n > 0 ? Math.floor(n) : 0
  }

  var active = desired > 0
  return {
    timeout: desired,
    active: active,
    rebuild: desired !== activeTimeout || !!monitorActive !== active
  }
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
    secondsFromConfig: secondsFromConfig,
    monitorPlan: monitorPlan,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter
  }
}
