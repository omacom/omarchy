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

// True once every expected screensaver window has mapped, or the launch grace
// expired with at least one window still up (partial multi-monitor).
function screensaverLaunchCompleteAfter(windowCount, expectedWindows, graceExpired) {
  if (windowCount <= 0) return false
  if (expectedWindows > 0 && windowCount >= expectedWindows) return true
  return !!graceExpired
}

// Second IdleMonitor state while a screensaver is visible.
// Launch activity and focus warps happen before launchComplete / before settle;
// only a post-settle active edge dismisses. Lock handoff must not dismiss.
function dismissStateAfter(state) {
  var visible = !!(state && state.visible)
  var launchComplete = !!(state && state.launchComplete)
  var locking = !!(state && state.locking)
  var settled = !!(state && state.settled)
  var isIdle = !!(state && state.isIdle)
  var dismissInFlight = !!(state && state.dismissInFlight)

  if (!visible || locking || !launchComplete || dismissInFlight) {
    return { settled: false, dismiss: false }
  }
  if (isIdle) return { settled: true, dismiss: false }
  if (settled) return { settled: false, dismiss: true }
  return { settled: false, dismiss: false }
}

if (typeof module !== "undefined") {
  module.exports = {
    secondsFromConfig: secondsFromConfig,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    screensaverLaunchCompleteAfter: screensaverLaunchCompleteAfter,
    dismissStateAfter: dismissStateAfter
  }
}
