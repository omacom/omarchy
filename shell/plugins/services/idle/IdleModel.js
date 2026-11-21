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

// 0 means the action is disabled, not "fire immediately". min(0, 300) would
// otherwise make IdleMonitor report idle as soon as an inhibitor is released.
function firstIdleTimeout() {
  var times = []
  for (var i = 0; i < arguments.length; i++) {
    if (arguments[i] > 0) times.push(arguments[i])
  }
  if (times.length === 0) return 0
  var min = times[0]
  for (var j = 1; j < times.length; j++) {
    if (times[j] < min) min = times[j]
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
    firstIdleTimeout: firstIdleTimeout,
    delayAfterFirstIdle: delayAfterFirstIdle
  }
}
