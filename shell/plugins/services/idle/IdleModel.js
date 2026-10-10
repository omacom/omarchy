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
    firstIdleTimeout: firstIdleTimeout,
    delayAfterFirstIdle: delayAfterFirstIdle,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    screensaverLaunchCompleteAfter: screensaverLaunchCompleteAfter,
    dismissStateAfter: dismissStateAfter
  }
}
