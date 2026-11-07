.pragma library

.import "GlobeModel.js" as Solar

// Sunrise and sunset for a place on its own day, from the globe's own
// subsolarPoint so the strip and the terminator cannot disagree.

var DEG = Math.PI / 180

// Refraction plus the sun's radius, the figure published sunrise tables use.
var HORIZON = -0.833

function wrap180(deg) {
  return ((deg + 540) % 360) - 180
}

// Local solar noon. The subsolar meridian moves 15 degrees an hour, so three
// corrections take the residual below a second.
function solarNoonMs(lon, nearMs) {
  var t = nearMs
  for (var i = 0; i < 3; i++) {
    var sub = Solar.subsolarPoint(t)
    t += wrap180(sub.lon - lon) / 15 * 3600000
  }
  return t
}

// The zone's own local midnight, as a UTC instant.
function localMidnightMs(ms, offsetMinutes) {
  var local = ms + offsetMinutes * 60000
  return Math.floor(local / 86400000) * 86400000 - offsetMinutes * 60000
}

// Sunrise and sunset for the local day containing `ms`, as instants and as
// minutes from local midnight. The minutes may fall outside 0..1440 for a zone
// far from its own sun. `kind` is "normal", "midnightSun" or "polarNight".
function sunTimes(lat, lon, ms, offsetMinutes) {
  var midnight = localMidnightMs(ms, offsetMinutes)
  var noon = solarNoonMs(lon, midnight + 43200000)
  var dec = Solar.subsolarPoint(noon).lat

  var cosH = (Math.sin(HORIZON * DEG) - Math.sin(lat * DEG) * Math.sin(dec * DEG))
           / (Math.cos(lat * DEG) * Math.cos(dec * DEG))

  if (cosH <= -1)
    return { kind: "midnightSun", noonMs: noon, riseMs: null, setMs: null,
             riseMinutes: null, setMinutes: null, dayMinutes: 1440 }
  if (cosH >= 1)
    return { kind: "polarNight", noonMs: noon, riseMs: null, setMs: null,
             riseMinutes: null, setMinutes: null, dayMinutes: 0 }

  var halfDayMs = Math.acos(cosH) / DEG / 15 * 3600000
  var riseMs = noon - halfDayMs
  var setMs = noon + halfDayMs

  return {
    kind: "normal",
    noonMs: noon,
    riseMs: riseMs,
    setMs: setMs,
    riseMinutes: (riseMs - midnight) / 60000,
    setMinutes: (setMs - midnight) / 60000,
    dayMinutes: (setMs - riseMs) / 60000
  }
}

// The lit parts of a 24-hour strip as 0..1 spans. The day is also drawn a day
// either side, so a sunset past midnight lights the start of the bar too.
function litSpans(times) {
  if (!times) return []
  if (times.kind === "polarNight") return []
  if (times.kind === "midnightSun") return [{ x0: 0, x1: 1 }]

  var out = []
  for (var shift = -1440; shift <= 1440; shift += 1440) {
    var a = Math.max(0, Math.min(1440, times.riseMinutes + shift))
    var b = Math.max(0, Math.min(1440, times.setMinutes + shift))
    if (b > a) out.push({ x0: a / 1440, x1: b / 1440 })
  }
  return out
}

// Where an event's tick goes, or null when it falls off this bar.
function eventMark(minutes) {
  if (minutes === null || minutes === undefined) return null
  if (minutes < 0 || minutes > 1440) return null
  return minutes / 1440
}

// Daylight at `minutes`, read from the same three days litSpans draws.
function litAt(times, minutes) {
  if (!times) return false
  if (times.kind === "midnightSun") return true
  if (times.kind === "polarNight") return false
  for (var shift = -1440; shift <= 1440; shift += 1440)
    if (minutes >= times.riseMinutes + shift && minutes < times.setMinutes + shift)
      return true
  return false
}
