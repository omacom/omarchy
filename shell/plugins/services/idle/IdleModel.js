// Empty legacy files mean indefinitely. A timed file contains its deadline in milliseconds.
var maxStayAwakeSeconds = 24 * 60 * 60

function stayAwakeDeadline(seconds, now) {
  var duration = Number(seconds)
  if (!Number.isInteger(duration) || duration <= 0 || duration > maxStayAwakeSeconds) return 0
  return now + duration * 1000
}

function stayAwakeState(raw, now) {
  var disabled = { enabled: false, until: 0 }
  if (raw === "yes:") return { enabled: true, until: 0 }
  if (raw.indexOf("yes:") !== 0 || raw.length > 32) return disabled

  var value = raw.slice(4).replace(/\n+$/, "")
  if (/^[0-9]{1,10}:[0-9]{1,5}:[0-9]{1,5}$/.test(value)) return { enabled: true, until: 0 }
  var until = Number(value)
  if (!/^[0-9]{1,16}$/.test(value) || !Number.isSafeInteger(until)) return disabled
  if (until <= now || until > now + maxStayAwakeSeconds * 1000) return disabled
  return { enabled: true, until: until }
}

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

if (typeof module !== "undefined") {
  module.exports = {
    stayAwakeState: stayAwakeState,
    stayAwakeDeadline: stayAwakeDeadline,
    secondsFromConfig: secondsFromConfig,
    firstIdleTimeout: firstIdleTimeout,
    delayAfterFirstIdle: delayAfterFirstIdle
  }
}
