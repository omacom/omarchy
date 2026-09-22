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

// The lid probe prints two lines: whether the machine has a lid switch, then
// whether the lid stay-awake flag is set. Each line updates one field and
// leaves the other alone, so the lines can arrive in any order.
function lidProbeUpdate(state, line) {
  var value = String(line || "").trim()
  var next = {
    lidPresent: !!(state && state.lidPresent),
    lidStayAwake: !!(state && state.lidStayAwake)
  }
  if (value === "lid" || value === "nolid") next.lidPresent = value === "lid"
  else if (value === "yes" || value === "no") next.lidStayAwake = value === "yes"
  return next
}

// logind honours a handle-lid-switch inhibitor regardless of
// LidSwitchIgnoreInhibited, so holding one is enough to keep a closed lid from
// suspending: no logind.conf edit, no privileges. The lock is only wanted on
// hardware with a lid and only while the flag is set.
function lidInhibitorWanted(lidPresent, lidStayAwake) {
  return !!lidPresent && !!lidStayAwake
}

if (typeof module !== "undefined") {
  module.exports = {
    secondsFromConfig: secondsFromConfig,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter,
    lidProbeUpdate: lidProbeUpdate,
    lidInhibitorWanted: lidInhibitorWanted
  }
}
