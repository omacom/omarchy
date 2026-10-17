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

// The stay-awake state file carries the idle mode: no file means allow-idle,
// "agents" means stay awake while agents work, anything else (empty file,
// update owner stamp) means stay awake.
function stayAwakeModeFromState(exists, content) {
  if (!exists) return "allow"
  return String(content || "").trim() === "agents" ? "agents" : "awake"
}

function stayAwakeStateContent(mode) {
  if (mode === "agents") return "agents\n"
  if (mode === "awake") return "awake\n"
  return null
}

function stayAwakeEffective(mode, agentsWorking) {
  if (mode === "awake") return true
  if (mode === "agents") return !!agentsWorking
  return false
}

function nextStayAwakeMode(mode) {
  if (mode === "allow") return "awake"
  if (mode === "awake") return "agents"
  return "allow"
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
    firstIdleTimeout: firstIdleTimeout,
    delayAfterFirstIdle: delayAfterFirstIdle,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    stayAwakeModeFromState: stayAwakeModeFromState,
    stayAwakeStateContent: stayAwakeStateContent,
    stayAwakeEffective: stayAwakeEffective,
    nextStayAwakeMode: nextStayAwakeMode
  }
}
