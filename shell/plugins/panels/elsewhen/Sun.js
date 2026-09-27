.pragma library

.import "GlobeModel.js" as Solar

// Sunrise and sunset for a place on its own day.
//
// The strip under each row used to light a fixed 06-18 band, which was an
// honest convention while the panel had no coordinates. It has them now - the
// fetcher geocodes every city for the weather - so the band can be the real
// thing: Reykjavik's four-hour December day and Auckland's long January one
// are different shapes, and that difference is most of what a daylight bar is
// worth looking at.
//
// Built on the globe's own subsolarPoint rather than a second copy of the
// astronomy. The globe already places the sun to a fraction of a degree and
// tests/globe_check.js already checks it against Open-Meteo; a private copy
// here would be free to drift from the terminator drawn an inch above it, and
// the two disagreeing about where the sun is would be visible.
//
// Declination comes straight off that function. The equation of time is
// recovered from it rather than recomputed: subsolarPoint builds its meridian
// as `lon = -15 * (utcHours - 12) - eot`, so the same relation run backwards
// hands the correction back with no new maths to keep in step.

var DEG = Math.PI / 180

// Refraction plus the sun's own radius: the disc's upper limb touches the
// horizon while its centre is still half a degree below. Every published
// sunrise table uses this figure, so matching it is what makes our times
// comparable to theirs.
var HORIZON = -0.833

function wrap180(deg) {
  return ((deg + 540) % 360) - 180
}

// The instant the sun crosses this longitude's meridian - local solar noon,
// which is not 12:00 and can be most of an hour away from it.
//
// Found by iteration rather than by formula. The subsolar meridian sweeps west
// at a steady 15 degrees an hour, so the gap between where the sun is and
// where we want it converts straight into a time correction; three passes take
// the residual below a second, and each pass costs one solar position.
function solarNoonMs(lon, nearMs) {
  var t = nearMs
  for (var i = 0; i < 3; i++) {
    var sub = Solar.subsolarPoint(t)
    t += wrap180(sub.lon - lon) / 15 * 3600000
  }
  return t
}

// Local midnight, as a UTC instant. The day a row draws is the city's own day,
// so the strip has to be anchored to that and not to the viewer's.
function localMidnightMs(ms, offsetMinutes) {
  var local = ms + offsetMinutes * 60000
  return Math.floor(local / 86400000) * 86400000 - offsetMinutes * 60000
}

// Sunrise and sunset for the local day containing `ms`.
//
// Returns absolute instants and the same two moments as minutes from that
// local midnight, which is what the strip is drawn in. Those minutes can fall
// outside 0..1440: a zone can be hours from its own sun - Kashgar runs on
// Beijing time and sees the sun rise at 08:23 by the clock and set at 21:29 -
// and in the extreme the day the clock is showing holds an event from the
// solar day either side of it. What to do with that is the caller's business -
// see litSpans - and nothing is rounded or hidden here.
//
// `kind` is "normal", or "midnightSun" / "polarNight" where the sun does not
// cross the horizon at all that day. Those are not error cases and must not be
// drawn as a zero-length day: above the Arctic circle a bar with no boundary
// on it is the correct answer, and it is the most interesting bar in the list.
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

// The lit part of a 24-hour strip, as 0..1 fractions of the bar.
//
// A list rather than one span, because a bar really can be lit at both ends.
// This first clipped the day to the bar and threw away whatever fell outside,
// with a comment explaining that a bar lit at both ends reads as two days. That
// reasoning was wrong. Reykjavik on the June solstice sets at 00:04 - four
// minutes into the next day - which means the first four minutes of *this* day
// were lit too, by the sun that rose the morning before. Drawing them dark
// claimed the sun was down at midnight while the shared solar model put it at
// -0.689 degrees, above the horizon.
//
// So the day is drawn where it falls, and again shifted a day either side. Only
// the parts that land on the bar survive. For an ordinary city the neighbours
// miss the bar entirely and one span comes back; for a city whose clock is far
// from its sun, or whose day is nearly twenty-four hours long, the tail belongs
// to the same day and is drawn.
//
// Empty for polar night, the whole bar for midnight sun.
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

// Where to put a tick for an event, or null when it does not happen on this
// bar. Same clipping rule as the band: an event outside the day the row is
// showing gets no mark, because a mark at the very edge would claim the sun
// rose at midnight.
function eventMark(minutes) {
  if (minutes === null || minutes === undefined) return null
  if (minutes < 0 || minutes > 1440) return null
  return minutes / 1440
}

// Is the city in daylight at this moment? Read from the same span the strip
// draws, so the marker and the band can never disagree - the sun cannot be
// drawn sitting in the dark.
function litAt(times, minutes) {
  if (!times) return false
  if (times.kind === "midnightSun") return true
  if (times.kind === "polarNight") return false
  // The same three days litSpans draws, so the marker and the band cannot
  // disagree about the minutes either side of midnight.
  for (var shift = -1440; shift <= 1440; shift += 1440)
    if (minutes >= times.riseMinutes + shift && minutes < times.setMinutes + shift)
      return true
  return false
}
