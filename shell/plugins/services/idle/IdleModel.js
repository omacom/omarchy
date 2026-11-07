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

if (typeof module !== "undefined") {
  module.exports = {
    MAX_TIMEOUT_SECONDS: MAX_TIMEOUT_SECONDS,
    secondsFromConfig: secondsFromConfig,
    optionalSecondsFromConfig: optionalSecondsFromConfig,
    shouldSuspend: shouldSuspend,
    firstIdleTimeout: firstIdleTimeout,
    delayAfterFirstIdle: delayAfterFirstIdle
  }
}
