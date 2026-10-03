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
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    stayAwakeModeFromState: stayAwakeModeFromState,
    stayAwakeStateContent: stayAwakeStateContent,
    stayAwakeEffective: stayAwakeEffective,
    nextStayAwakeMode: nextStayAwakeMode
  }
}
