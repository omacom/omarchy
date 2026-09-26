// Turns the keyboard backlight on in the dark and off in bright light, from
// ambient light sensor readings. It only acts when the room crosses from dark
// to bright or back, so a level the user picks sticks until the lighting
// actually changes. Turning the backlight off while it's dark is held (across
// restarts too) until the room has been bright for a while, a maximum age
// passes, or the user turns it back on.

var DEFAULTS = {
  onBelowLux: 10,
  offAboveLux: 50,
  settleSeconds: 5,
  brightClearMinutes: 10,
  manualOffMaxHours: 8
}

function positiveNumber(value, fallback) {
  var number = Number(value)
  return isFinite(number) && number > 0 ? number : fallback
}

function config(raw) {
  raw = raw && typeof raw === "object" ? raw : {}
  var onBelowLux = positiveNumber(raw.onBelowLux, DEFAULTS.onBelowLux)
  var offAboveLux = positiveNumber(raw.offAboveLux, DEFAULTS.offAboveLux)
  if (offAboveLux <= onBelowLux) offAboveLux = onBelowLux * 5

  return {
    onBelowLux: onBelowLux,
    offAboveLux: offAboveLux,
    settleMs: positiveNumber(raw.settleSeconds, DEFAULTS.settleSeconds) * 1000,
    brightClearMs: positiveNumber(raw.brightClearMinutes, DEFAULTS.brightClearMinutes) * 60000,
    manualOffMaxMs: positiveNumber(raw.manualOffMaxHours, DEFAULTS.manualOffMaxHours) * 3600000
  }
}

// `monitor-sensor --light` prints the first reading as
// "=== Has ambient light sensor (value: 2.000000, unit: lux)" and later ones
// as "    Light changed: 1.000000 (lux)". Vendor-unit sensors aren't lux, so
// thresholds don't apply to them. The service runs it under LC_ALL=C, but a
// comma decimal separator is accepted too rather than silently never matching.
function parseLux(line) {
  var match = /(?:value: |Light changed: )([0-9]+(?:[.,][0-9]+)?)(?:, unit: | \()(\w+)/.exec(String(line || ""))
  if (!match || match[2] !== "lux") return null
  return Number(match[1].replace(",", "."))
}

function initialState(brightness, maxLevel, manualOffSince) {
  return {
    applied: "",
    pending: "",
    pendingSince: 0,
    brightSince: 0,
    expected: brightness,
    level: brightness > 0 ? brightness : maxLevel,
    manualOffSince: manualOffSince > 0 ? manualOffSince : 0,
    held: false
  }
}

function copy(state) {
  var result = {}
  for (var key in state) result[key] = state[key]
  return result
}

function manualOffActive(state, now, cfg) {
  return state.manualOffSince > 0 && now - state.manualOffSince < cfg.manualOffMaxMs
}

function wantFor(lux, cfg) {
  if (lux < cfg.onBelowLux) return "on"
  if (lux > cfg.offAboveLux) return "off"
  return ""
}

// A level other than the one last set came from outside: the backlight keys
// or `omarchy brightness keyboard`. Either is the user's choice, so off is held
// and any other level becomes the one used when the room next gets dark.
// Session blanking and waking are not observed; see resume().
function observeBrightness(state, brightness, now) {
  if (brightness === null || brightness === undefined || brightness === state.expected) return state

  var next = copy(state)
  next.expected = brightness
  if (brightness === 0) {
    next.manualOffSince = now
    next.held = next.applied === "on"
  } else {
    next.level = brightness
    next.manualOffSince = 0
    next.held = false
  }
  return next
}

function apply(state, want, now, cfg) {
  var next = copy(state)
  next.pending = ""

  if (want === "off") {
    next.applied = "off"
    next.brightSince = now
    next.held = false
    next.expected = 0
    return { state: next, set: 0 }
  }

  if (next.brightSince > 0 && now - next.brightSince >= cfg.brightClearMs) next.manualOffSince = 0
  next.brightSince = 0
  next.applied = "on"

  if (manualOffActive(next, now, cfg)) {
    // Normally already off. After a restart or a session wake restored a
    // level, the held off is put back.
    next.held = true
    var restored = next.expected !== 0
    next.expected = 0
    return { state: next, set: restored ? 0 : null }
  }

  next.held = false
  next.expected = next.level
  return { state: next, set: next.level }
}

// After the session blanked the keyboard and restored it on wake, the restored
// level is the session's, not the user's: take it as the new baseline and
// decide again from the current light, keeping any held manual off.
function resume(state, brightness) {
  var next = copy(state)
  next.expected = brightness
  next.applied = ""
  next.pending = ""
  next.held = false
  return next
}

function nextCheckMs(state, now, cfg) {
  var delays = []
  if (state.pending !== "") delays.push(Math.max(0, state.pendingSince + cfg.settleMs - now))
  if (state.held && state.manualOffSince > 0) delays.push(Math.max(0, state.manualOffSince + cfg.manualOffMaxMs - now))
  return delays.length ? Math.min.apply(null, delays) : -1
}

// Returns the new state, the level to set (or null), and when to check again
// (-1 for never) so a settling reading or an expiring hold is acted on even if
// the sensor stays quiet.
function evaluate(state, lux, now, cfg) {
  var next = copy(state)
  var result = { state: next, set: null }

  if (next.manualOffSince > 0 && !manualOffActive(next, now, cfg)) next.manualOffSince = 0

  var want = lux === null || lux === undefined ? "" : wantFor(lux, cfg)

  if (want === "on" && next.applied === "on" && next.held && next.manualOffSince === 0) {
    result = apply(next, "on", now, cfg)
  } else if (want === "" || want === next.applied) {
    next.pending = ""
  } else if (want !== next.pending) {
    next.pending = want
    next.pendingSince = now
  } else if (now - next.pendingSince >= cfg.settleMs) {
    result = apply(next, want, now, cfg)
  }

  result.nextCheckMs = nextCheckMs(result.state, now, cfg)
  return result
}

if (typeof module !== "undefined") {
  module.exports = {
    DEFAULTS: DEFAULTS,
    config: config,
    parseLux: parseLux,
    initialState: initialState,
    observeBrightness: observeBrightness,
    resume: resume,
    evaluate: evaluate
  }
}
