function secondsFromConfig(value, fallback) {
  var n = Number(value)
  if (!isFinite(n) || n < 0) return fallback
  return Math.floor(n)
}

// 0 means the action is disabled, not "fire immediately". min(0, 300) would
// otherwise make IdleMonitor report idle as soon as an inhibitor is released.
function firstIdleTimeout(screensaverSeconds, lockSeconds) {
  var times = []
  if (screensaverSeconds > 0) times.push(screensaverSeconds)
  if (lockSeconds > 0) times.push(lockSeconds)
  if (times.length === 0) return 0
  var min = times[0]
  for (var i = 1; i < times.length; i++) {
    if (times[i] < min) min = times[i]
  }
  return min
}

function delayAfterFirstIdle(timeoutSeconds, firstIdleSeconds) {
  if (!(timeoutSeconds > 0)) return 0
  var delay = timeoutSeconds - firstIdleSeconds
  return delay > 0 ? delay : 0
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

// The screensaver windows still open, read from the live toplevels rather than
// from the openwindow events tracked so far. A close event can be missed, and a
// window tracked from an earlier event that has since gone must not keep a
// cycle armed, or hold off the launch grace fallback, for the rest of the
// session.
//
// A toplevel whose wayland handle has not been attached yet reports a null app
// id. That is unknown, not absent: the handle arrives milliseconds after the
// window maps, and reading it as "not the screensaver" drops a window that is
// really up, which on a lock path fails open. Such a window is kept when the
// openwindow events already track its address, and ignored when they do not, so
// a toplevel this cannot identify never becomes a screensaver window by itself.
function screensaverWindowsFrom(entries, className, tracked) {
  var windows = {}
  var count = 0

  for (var i = 0; i < (entries ? entries.length : 0); i++) {
    var entry = entries[i] || {}
    var address = String(entry.address || "")
    if (!address || windows[address]) continue

    if (entry.appId === null) {
      if (!tracked || !tracked[address]) continue
    } else if (String(entry.appId || "") !== className) {
      continue
    }

    windows[address] = true
    count++
  }

  return { windows: windows, count: count }
}

if (typeof module !== "undefined") {
  module.exports = {
    secondsFromConfig: secondsFromConfig,
    firstIdleTimeout: firstIdleTimeout,
    delayAfterFirstIdle: delayAfterFirstIdle,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    screensaverWindowsFrom: screensaverWindowsFrom
  }
}
