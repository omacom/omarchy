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

// Hyprland reports window addresses without the 0x prefix on socket events but
// with it in hyprctl, so normalize to the hyprctl form before comparing or closing.
function normalizeWindowAddress(address) {
  var raw = String(address || "").trim()
  var hex = raw.indexOf("0x") === 0 ? raw.slice(2) : raw
  if (!/^[0-9a-fA-F]+$/.test(hex)) return ""
  return "0x" + hex.toLowerCase()
}

// Windows this idle cycle opened, keyed by normalized address. Only windows
// opened while the cycle's screensaver launch was in progress are owned; a
// screensaver the user started themselves is never added.
function ownedWindowsAfterOpen(owned, address, ownsWindow) {
  var next = {}
  for (var existing in owned || {}) {
    if (owned[existing]) next[existing] = true
  }

  var key = normalizeWindowAddress(address)
  if (ownsWindow && key) next[key] = true
  return next
}

function ownedWindowsAfterClose(owned, address) {
  var next = {}
  var key = normalizeWindowAddress(address)
  for (var existing in owned || {}) {
    if (owned[existing] && existing !== key) next[existing] = true
  }
  return next
}

function addressesToClose(owned) {
  var addresses = []
  for (var existing in owned || {}) {
    if (owned[existing]) addresses.push(existing)
  }
  return addresses
}

// A cancelled launch opens one window per screen. Only that many late windows
// can belong to it; anything beyond that was started by someone else.
function lateWindowBudget(screenCount, ownedCount) {
  return Math.max(0, (screenCount || 0) - (ownedCount || 0))
}

// Closes by address rather than by pattern, so only the windows this cycle
// opened are affected.
function closeWindowsCommand(addresses) {
  var commands = []
  for (var i = 0; i < addresses.length; i++) {
    var key = normalizeWindowAddress(addresses[i])
    if (!key) continue
    commands.push("hyprctl dispatch \"hl.dsp.window.close({ window = \\\"address:" + key + "\\\" })\" >/dev/null 2>&1")
  }
  return commands.length ? commands.join("; ") : "true"
}

if (typeof module !== "undefined") {
  module.exports = {
    secondsFromConfig: secondsFromConfig,
    firstIdleTimeout: firstIdleTimeout,
    delayAfterFirstIdle: delayAfterFirstIdle,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    normalizeWindowAddress: normalizeWindowAddress,
    ownedWindowsAfterOpen: ownedWindowsAfterOpen,
    ownedWindowsAfterClose: ownedWindowsAfterClose,
    addressesToClose: addressesToClose,
    closeWindowsCommand: closeWindowsCommand,
    lateWindowBudget: lateWindowBudget
  }
}
