// Temperatures below the identity point count as night light. Keep in sync
// with bin/omarchy-toggle-nightlight, which applies the same threshold.
var IDENTITY_TEMPERATURE = 6000

// The warmth range the schedule offers. It stays below the identity point so
// a scheduled night always reads as night light. Keep in sync with
// bin/omarchy-nightlight-config, which validates the same range.
var MIN_TEMPERATURE = 2500
var MAX_TEMPERATURE = 5500
var TEMPERATURE_STEP = 100
var DEFAULT_SCHEDULE = { scheduled: false, day: "07:00", night: "20:00", temperature: 4000 }

function temperatureFromOutput(output) {
  var match = String(output === undefined || output === null ? "" : output).match(/[0-9]+/)
  return match ? Number(match[0]) : null
}

function isNightlight(temperature) {
  return temperature !== null && temperature !== undefined && temperature < IDENTITY_TEMPERATURE
}

function isTime(text) {
  return /^([01][0-9]|2[0-3]):[0-5][0-9]$/.test(String(text === undefined || text === null ? "" : text))
}

function pad(number) {
  return (number < 10 ? "0" : "") + number
}

// Reads a typed time the way it was meant: "7" is 07:00, "7:30" and "730"
// are 07:30, "2015" is 20:15. Returns "" when the text is not a 24-hour time.
function normalizeTime(text) {
  var value = String(text === undefined || text === null ? "" : text).trim()
  var hours
  var minutes

  var parts = value.match(/^([0-9]{1,2})(?::([0-9]{1,2}))?$/)
  if (parts) {
    hours = Number(parts[1])
    minutes = parts[2] === undefined ? 0 : Number(parts[2])
  } else if (/^[0-9]{3,4}$/.test(value)) {
    hours = Number(value.slice(0, value.length - 2))
    minutes = Number(value.slice(value.length - 2))
  } else {
    return ""
  }

  if (hours > 23 || minutes > 59) return ""
  return pad(hours) + ":" + pad(minutes)
}

function minutesOfDay(time) {
  var parts = String(time).split(":")
  return Number(parts[0]) * 60 + Number(parts[1])
}

function timeFromMinutes(total) {
  var wrapped = ((total % 1440) + 1440) % 1440
  return pad(Math.floor(wrapped / 60)) + ":" + pad(wrapped % 60)
}

// Moves a time by some minutes, wrapping around midnight. The schedule's
// arrow keys step through times with it.
function shiftTime(time, delta, fallback) {
  var normalized = normalizeTime(time) || normalizeTime(fallback) || DEFAULT_SCHEDULE.day
  return timeFromMinutes(minutesOfDay(normalized) + delta)
}

// How long the warm stretch lasts in minutes: from the night start, through
// midnight when it has to, to the day start.
function nightMinutes(day, night) {
  if (!isTime(day) || !isTime(night)) return 0
  return ((minutesOfDay(day) - minutesOfDay(night)) % 1440 + 1440) % 1440
}

function formatDuration(minutes) {
  var hours = Math.floor(minutes / 60)
  var rest = minutes % 60
  if (hours === 0) return rest + "m"
  if (rest === 0) return hours + "h"
  return hours + "h " + rest + "m"
}

function clampTemperature(value) {
  var number = Math.round(Number(value) / TEMPERATURE_STEP) * TEMPERATURE_STEP
  if (!isFinite(number)) return DEFAULT_SCHEDULE.temperature
  return Math.max(MIN_TEMPERATURE, Math.min(MAX_TEMPERATURE, number))
}

// Roughly the color a white pixel takes at a given warmth, for the editor's
// swatch. Tanner Helland's blackbody fit, which is plenty for a preview.
function kelvinColor(kelvin) {
  var t = clampTemperature(kelvin) / 100
  var r = t <= 66 ? 255 : 329.698727446 * Math.pow(t - 60, -0.1332047592)
  var g = t <= 66 ? 99.4708025861 * Math.log(t) - 161.1195681661 : 288.1221695283 * Math.pow(t - 60, -0.0755148492)
  var b = t >= 66 ? 255 : (t <= 19 ? 0 : 138.5177312231 * Math.log(t - 10) - 305.0447927307)
  function unit(v) { return Math.max(0, Math.min(255, v)) / 255 }
  return { r: unit(r), g: unit(g), b: unit(b) }
}

// A saved warmth is used as written when it is in range; only out-of-range or
// non-numeric values fall back. Rounding here would let the shell disagree
// with the profile the command wrote.
function savedTemperature(value) {
  var number = Number(value)
  if (!isFinite(number) || Math.round(number) !== number) return clampTemperature(value)
  if (number < MIN_TEMPERATURE || number > MAX_TEMPERATURE) return clampTemperature(value)
  return number
}

// Reads the saved schedule, falling back field by field to the defaults so a
// hand-edited or partial file still opens. `saved` tells a first run apart.
function parseSchedule(text) {
  var parsed = null
  try { parsed = JSON.parse(String(text === undefined || text === null ? "" : text)) } catch (e) { parsed = null }
  var saved = !!parsed && typeof parsed === "object" && !Array.isArray(parsed)
  if (!saved) parsed = {}

  return {
    saved: saved,
    scheduled: parsed.scheduled === true,
    day: isTime(parsed.day) ? parsed.day : DEFAULT_SCHEDULE.day,
    night: isTime(parsed.night) ? parsed.night : DEFAULT_SCHEDULE.night,
    temperature: parsed.temperature === undefined ? DEFAULT_SCHEDULE.temperature : savedTemperature(parsed.temperature)
  }
}

// Milliseconds from `now` until the next day or night start, so the service
// can re-read the screen when hyprsunset switches profiles on its own. Aims a
// couple of seconds past the boundary to land after hyprsunset has switched.
function msUntilNextBoundary(day, night, now) {
  if (!isTime(day) || !isTime(night)) return -1
  var date = now instanceof Date ? now : new Date(now)
  var current = date.getHours() * 3600 + date.getMinutes() * 60 + date.getSeconds()
  var best = -1
  var times = [day, night]
  for (var i = 0; i < times.length; i++) {
    var target = minutesOfDay(times[i]) * 60 + 2
    var wait = ((target - current) % 86400 + 86400) % 86400
    if (wait === 0) wait = 86400
    if (best < 0 || wait < best) best = wait
  }
  return best * 1000 - date.getMilliseconds()
}

// One line saying what the schedule will do, or why it cannot be saved.
function describeSchedule(scheduled, day, night) {
  if (!isTime(day) || !isTime(night)) return { valid: false, text: "Use 24-hour times, like 07:00 and 20:30" }
  if (day === night) return { valid: false, text: "Day and night need different start times" }
  if (!scheduled) return { valid: true, text: "Schedule off · night light stays manual" }
  return { valid: true, text: "Warm from " + night + " to " + day + " · " + formatDuration(nightMinutes(day, night)) }
}

if (typeof module !== "undefined") {
  module.exports = {
    IDENTITY_TEMPERATURE: IDENTITY_TEMPERATURE,
    MIN_TEMPERATURE: MIN_TEMPERATURE,
    MAX_TEMPERATURE: MAX_TEMPERATURE,
    TEMPERATURE_STEP: TEMPERATURE_STEP,
    DEFAULT_SCHEDULE: DEFAULT_SCHEDULE,
    temperatureFromOutput: temperatureFromOutput,
    isNightlight: isNightlight,
    isTime: isTime,
    normalizeTime: normalizeTime,
    shiftTime: shiftTime,
    nightMinutes: nightMinutes,
    formatDuration: formatDuration,
    clampTemperature: clampTemperature,
    savedTemperature: savedTemperature,
    msUntilNextBoundary: msUntilNextBoundary,
    kelvinColor: kelvinColor,
    parseSchedule: parseSchedule,
    describeSchedule: describeSchedule
  }
}
