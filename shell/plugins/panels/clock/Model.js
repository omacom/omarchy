// Pure date and format math for the clock widget and its calendar panel.
// Everything here is locale- and Qt-free so it can be unit tested under node
// (test/shell.d/clock-test.sh); the QML owns month/weekday naming through
// Qt.locale().

var MS_PER_DAY = 86400000

// Weekday indices match both JS Date.getDay() and QML's Locale.Sunday…
// Locale.Saturday, so a locale's firstDayOfWeek can be passed straight in.
var WEEKDAY_NAMES = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]

// ---- Bar label formats. Right-clicking the clock walks these in order and
//      writes the result back to shell.json, so the label the bar shows and
//      the format the config stores are always the same thing.
//
// The locale-shaped time presets are each followed by their 12-hour twin, so
// the walk from a 24-hour label to the same label in AM/PM is a single right
// click rather than a lap of the ring. The ISO preset is deliberately left
// without one: ISO 8601 writes time on a 24-hour clock, so an AM/PM variant
// would contradict the only thing that format is for.
var CLOCK_FORMATS = [
  "dddd HH:mm",
  "dddd h:mm AP",
  "dddd HH:mm:ss",
  "dddd h:mm:ss AP",
  "HH:mm",
  "h:mm AP",
  "ddd d MMM HH:mm",
  "ddd d MMM h:mm AP",
  "d MMMM 'W'ww yyyy",
  "yyyy-MM-dd HH:mm"
]

// Vertical bars have room for a few stacked lines and nothing else, so the
// ring stays short. AM/PM costs a fourth line, which is why only the plain
// time carries it here.
var VERTICAL_CLOCK_FORMATS = [
  "HH\n—\nmm",
  "h\n—\nmm\nAP",
  "dd\nMMM\n'W'ww\n''yy",
  "HH\nmm"
]

// Whether a format prints seconds, so the widget can tick once a second only
// for the formats that show them. Quoted literals go first: the s in a 'Sat'
// is text rather than a token, and an opening quote with no closing one runs
// to the end of the format the way Qt reads it.
function clockNeedsSeconds(format) {
  var text = String(format === undefined || format === null ? "" : format)
  return /s/.test(text.replace(/'[^']*'?/g, ""))
}

function clockFormats(vertical) {
  return vertical ? VERTICAL_CLOCK_FORMATS.slice() : CLOCK_FORMATS.slice()
}

// The presets in a fixed order, plus the configured alternate and current
// format when they are something else. The order must not depend on which
// entry is current: cycling writes the result back to shell.json, and a ring
// that reshuffled itself around the current value would bounce between two
// entries instead of walking.
function clockFormatRing(configured, configuredAlt, presets) {
  var ring = []
  var candidates = (presets || []).concat([configuredAlt, configured])
  for (var i = 0; i < candidates.length; i++) {
    var format = String(candidates[i] === undefined || candidates[i] === null ? "" : candidates[i])
    if (format === "" || ring.indexOf(format) !== -1) continue
    ring.push(format)
  }
  return ring.length > 0 ? ring : ["HH:mm"]
}

// Next entry after `current`. An unknown current format (a hand-written one
// that is not in the ring) starts the walk at the top.
function nextClockFormat(ring, current) {
  if (!ring || ring.length === 0) return ""
  var index = ring.indexOf(String(current === undefined || current === null ? "" : current))
  return ring[(index + 1) % ring.length]
}

// Two-digit ISO week, substituted into a format's 'ww' token before Qt
// formats it -- Qt has no ISO week specifier of its own.
function isoWeekLiteral(year, month, day) {
  return pad2(isoWeek(year, month, day))
}

function pad2(value) {
  var n = Number(value)
  return (n < 10 ? "0" : "") + n
}

// Stable "yyyy-MM-dd" identity for a day, so a grid cell can be compared
// against today without dragging Date objects through bindings.
function dateKey(year, month, day) {
  return year + "-" + pad2(Number(month) + 1) + "-" + pad2(day)
}

function keyForDate(date) {
  return dateKey(date.getFullYear(), date.getMonth(), date.getDate())
}

function coerceWeekStart(value) {
  if (value === undefined || value === null) return null
  if (typeof value === "number")
    return isFinite(value) ? ((Math.round(value) % 7) + 7) % 7 : null

  var text = String(value).replace(/^\s+|\s+$/g, "").toLowerCase()
  if (text === "") return null

  for (var i = 0; i < WEEKDAY_NAMES.length; i++)
    if (WEEKDAY_NAMES[i] === text || WEEKDAY_NAMES[i].substr(0, 3) === text) return i

  var parsed = parseInt(text, 10)
  return isFinite(parsed) ? ((parsed % 7) + 7) % 7 : null
}

// Configured week start, falling back to the locale's own first day when
// the setting is missing or nonsense.
function normalizedWeekStart(value, fallback) {
  var configured = coerceWeekStart(value)
  if (configured !== null) return configured
  var fallbackStart = coerceWeekStart(fallback)
  return fallbackStart === null ? 1 : fallbackStart
}

function weekStartSettingName(index) {
  return WEEKDAY_NAMES[normalizedWeekStart(index, 1)]
}

// The toggle flips between the two conventions people actually switch
// between. A calendar configured to any other start (Saturday, say) is
// shown as-is and lands on Monday the first time it is toggled.
function toggledWeekStart(index) {
  return normalizedWeekStart(index, 1) === 1 ? 0 : 1
}

function weekdayOrder(weekStart) {
  var start = normalizedWeekStart(weekStart, 1)
  var out = []
  for (var i = 0; i < 7; i++) out.push((start + i) % 7)
  return out
}

// ISO-8601 week number: the week owning the Thursday of that date's
// Monday-based week. Mirrors the clock widget's 'ww' format token.
function isoWeek(year, month, day) {
  var date = new Date(Date.UTC(year, month, day))
  var weekday = date.getUTCDay() || 7
  date.setUTCDate(date.getUTCDate() + 4 - weekday)
  var yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1))
  return Math.ceil(((date.getTime() - yearStart.getTime()) / MS_PER_DAY + 1) / 7)
}

function dayOfYear(year, month, day) {
  return Math.round((Date.UTC(year, month, day) - Date.UTC(year, 0, 1)) / MS_PER_DAY) + 1
}

function daysInYear(year) {
  return dayOfYear(year, 11, 31)
}

// Share of the year already behind you: whole days completed over days in
// the year, so January 1 reads 0% and December 31 reads 100%.
function yearProgress(year, month, day) {
  var total = daysInYear(year)
  if (total <= 0) return 0
  return Math.max(0, Math.min(1, (dayOfYear(year, month, day) - 1) / total))
}

function yearProgressPercent(year, month, day) {
  return Math.round(yearProgress(year, month, day) * 100)
}

// Memento mori. The default span is a round number rather than anything from
// an actuarial table: the point of the bar is the reminder, not the
// arithmetic, and whoever wants a different number can say so.
var DEFAULT_LIFE_EXPECTANCY = 90

// A birth year rather than an age, so the bar keeps counting on its own
// instead of going stale the moment it is entered. 0 means "not set", which
// is also what a blank, malformed, future, or implausibly distant year means.
function parseBirthYear(value, currentYear) {
  var now = Math.round(Number(currentYear))
  if (!isFinite(now)) return 0
  var text = String(value === undefined || value === null ? "" : value).replace(/^\s+|\s+$/g, "")
  if (!/^\d{4}$/.test(text)) return 0
  var year = parseInt(text, 10)
  if (!isFinite(year) || year > now || year < now - 120) return 0
  return year
}

// Whole years, the way people say their age: born in 1979 makes you 47 for
// all of 2026, whichever side of your birthday today falls.
function ageFromBirthYear(birthYear, currentYear) {
  var born = parseBirthYear(birthYear, currentYear)
  if (born <= 0) return 0
  return Math.round(Number(currentYear)) - born
}

// 0 means "not set", which is also what a blank, negative, fractional, or
// absurd entry means — the life bar simply stays hidden.
function parseAge(value) {
  var text = String(value === undefined || value === null ? "" : value).replace(/^\s+|\s+$/g, "")
  if (!/^\d+$/.test(text)) return 0
  var years = parseInt(text, 10)
  if (!isFinite(years) || years <= 0 || years > 120) return 0
  return years
}

// Unset or nonsense falls back to the default rather than to zero, so the
// bar always has something to measure against.
function parseLifeExpectancy(value) {
  var text = String(value === undefined || value === null ? "" : value).replace(/^\s+|\s+$/g, "")
  if (!/^\d+$/.test(text)) return DEFAULT_LIFE_EXPECTANCY
  var years = parseInt(text, 10)
  if (!isFinite(years) || years <= 0 || years > 150) return DEFAULT_LIFE_EXPECTANCY
  return years
}

function lifeProgress(age, expectancy) {
  var years = parseAge(age)
  var span = parseLifeExpectancy(expectancy)
  if (years <= 0 || span <= 0) return 0
  return Math.max(0, Math.min(1, years / span))
}

function lifeProgressPercent(age, expectancy) {
  return Math.round(lifeProgress(age, expectancy) * 100)
}

// Always six rows of seven days. A fixed grid keeps the popup exactly the
// same height in every month, so stepping through the year never makes the
// panel jump under the pointer.
//
// Walked in UTC, where every day is 24 hours long. A local-midnight cursor has
// to be resolved by the engine in zones that start DST at 00:00 -- Chile every
// September, Cuba every March -- and V4 resolves the missing midnight backward
// onto the previous day while V8 resolves it forward, so the local walk repeats
// a date in the shell and not under the tests. A grid of civil dates never
// needed a wall clock in the first place.
function monthGrid(year, month, weekStart, todayKey) {
  var start = normalizedWeekStart(weekStart, 1)
  var leading = (new Date(Date.UTC(year, month, 1)).getUTCDay() - start + 7) % 7
  var cursor = new Date(Date.UTC(year, month, 1 - leading))
  var today = String(todayKey || "")
  var weeks = []

  for (var w = 0; w < 6; w++) {
    var days = []
    var thursday = null
    for (var d = 0; d < 7; d++) {
      var cellYear = cursor.getUTCFullYear()
      var cellMonth = cursor.getUTCMonth()
      var cellDay = cursor.getUTCDate()
      var weekday = cursor.getUTCDay()
      var key = dateKey(cellYear, cellMonth, cellDay)
      if (weekday === 4) thursday = { year: cellYear, month: cellMonth, day: cellDay }
      days.push({
        key: key,
        year: cellYear,
        month: cellMonth,
        day: cellDay,
        weekday: weekday,
        inMonth: cellMonth === month && cellYear === year,
        weekend: weekday === 0 || weekday === 6,
        today: key === today
      })
      cursor.setUTCDate(cursor.getUTCDate() + 1)
    }
    // Number every row by the ISO week owning its Thursday. That is the
    // definition itself for Monday-start weeks, and the only answer that
    // stays stable for the other starts, where a row straddles two ISO
    // weeks but shares all of Monday through Thursday with one of them.
    var anchor = thursday || days[0]
    weeks.push({
      week: isoWeek(anchor.year, anchor.month, anchor.day),
      days: days
    })
  }
  return weeks
}

// Milliseconds from nowMs to the next whole step (1000 or 60000), always in
// (0, step]. Counted on the epoch clock: local wall time repeats an hour when
// daylight saving ends, and a whole local minute starts on a whole epoch one.
function msUntilNextTick(nowMs, step) {
  return step - nowMs % step
}

// UTC for the same reason as the grid: the month is read back off the date, so
// a first of the month that has no local midnight would step into the wrong one.
function stepMonth(year, month, delta) {
  var target = new Date(Date.UTC(year, Number(month) + Number(delta), 1))
  return { year: target.getUTCFullYear(), month: target.getUTCMonth() }
}

// ---- countdown timer
// Longest countdown the panel accepts: a day. Anything past that is a
// reminder or a calendar entry, not a kitchen timer.
var TIMER_MAX_SECONDS = 86400

// Reads a timer duration typed into the panel and returns whole seconds, or 0
// when it does not parse. A bare number is minutes ("5"), colon forms read
// right to left as seconds, minutes, hours ("1:30", "1:00:00"), and unit forms
// take h/m/s in any combination ("90s", "25m", "1h30m", "1h 5m 10s").
function parseTimerDuration(value) {
  var text = String(value === undefined || value === null ? "" : value).trim().toLowerCase()
  if (text === "") return 0
  var seconds = 0

  if (/^\d+$/.test(text)) {
    seconds = Number(text) * 60
  } else if (/^\d+(:\d{1,2}){1,2}$/.test(text)) {
    var parts = text.split(":").map(Number)
    for (var i = 1; i < parts.length; i++) if (parts[i] >= 60) return 0
    seconds = parts.length === 2
      ? parts[0] * 60 + parts[1]
      : parts[0] * 3600 + parts[1] * 60 + parts[2]
  } else {
    var match = /^(?:(\d+)\s*h)?\s*(?:(\d+)\s*m)?\s*(?:(\d+)\s*s)?$/.exec(text)
    if (!match || (!match[1] && !match[2] && !match[3])) return 0
    seconds = Number(match[1] || 0) * 3600 + Number(match[2] || 0) * 60 + Number(match[3] || 0)
  }

  if (!(seconds > 0) || seconds > TIMER_MAX_SECONDS) return 0
  return seconds
}

// "4:05" under an hour, "1:02:03" past it; never negative.
function formatTimer(seconds) {
  var total = Math.max(0, Math.ceil(Number(seconds) || 0))
  var h = Math.floor(total / 3600)
  var m = Math.floor((total % 3600) / 60)
  var s = total % 60
  return h > 0 ? h + ":" + pad2(m) + ":" + pad2(s) : m + ":" + pad2(s)
}

// Human label for the finished notification: "5 minutes", "1 hour 30 minutes".
// tn(key, count, english) translates one unit, number included; without it
// the English is used.
function describeTimer(seconds, tn) {
  if (!tn) tn = function(key, count, english) { return english.replace("%1", count) }
  var total = Math.max(0, Math.round(Number(seconds) || 0))
  var h = Math.floor(total / 3600)
  var m = Math.floor((total % 3600) / 60)
  var s = total % 60
  var parts = []
  if (h > 0) parts.push(tn("clock.hours", h, h === 1 ? "%1 hour" : "%1 hours"))
  if (m > 0) parts.push(tn("clock.minutes", m, m === 1 ? "%1 minute" : "%1 minutes"))
  if (s > 0 || parts.length === 0) parts.push(tn("clock.seconds", s, s === 1 ? "%1 second" : "%1 seconds"))
  return parts.join(" ")
}

// Compact label for a timer with no name of its own: "5m", "1m30s", "1h5m".
// t(key, english) translates one unit's "%1h"-style template; without it the
// English is used.
function shortTimerLabel(seconds, t) {
  if (!t) t = function(key, english) { return english }
  var total = Math.max(0, Math.round(Number(seconds) || 0))
  var h = Math.floor(total / 3600)
  var m = Math.floor((total % 3600) / 60)
  var s = total % 60
  var label = (h ? t("clock.shortHours", "%1h").replace("%1", h) : "")
    + (m ? t("clock.shortMinutes", "%1m").replace("%1", m) : "")
    + (s || !(h || m) ? t("clock.shortSeconds", "%1s").replace("%1", s) : "")
  return label
}

// Seconds left on a timer record ({ total, endsAt, pausedRemaining, running })
// at `now` (ms since the epoch).
function timerRemaining(timer, now) {
  if (!timer) return 0
  return timer.running
    ? Math.max(0, (Number(timer.endsAt) - Number(now)) / 1000)
    : Math.max(0, Number(timer.pausedRemaining) || 0)
}

// The countdown the bar should show: the running one closest to done, else
// the paused one closest to done. Stopwatches are skipped. Null when there
// are none.
function soonestTimer(timers, now) {
  var best = null
  var bestRemaining = 0
  for (var i = 0; i < (timers || []).length; i++) {
    var timer = timers[i]
    if (timer.kind === "stopwatch") continue
    var remaining = timerRemaining(timer, now)
    var better = !best
      || (timer.running && !best.running)
      || (timer.running === best.running && remaining < bestRemaining)
    if (better) {
      best = timer
      bestRemaining = remaining
    }
  }
  return best ? { timer: best, remaining: bestRemaining } : null
}

// Settings arrive from JSON as booleans, but a hand-edited shell.json may
// carry "true"/"false" strings; anything else is off.
function parseBool(value) {
  return value === true || String(value).toLowerCase() === "true"
}

// Seconds a stopwatch record ({ elapsedBefore, startedAt, running }) has
// counted at `now` (ms since the epoch).
function stopwatchElapsed(watch, now) {
  if (!watch) return 0
  var before = Math.max(0, Number(watch.elapsedBefore) || 0)
  return watch.running ? before + Math.max(0, (Number(now) - Number(watch.startedAt)) / 1000) : before
}

// A vertical bar is one icon slot wide, so a reading stacks one unit per
// line ("1:00:00" becomes "1", "00", "00"), the way the clock stacks HH over mm.
function verticalTimerLines(reading) {
  var text = String(reading || "")
  return text === "" ? [] : text.split(":")
}

// Like formatTimer, but rounding down: a stopwatch reads "0:00" for its first
// second, where a countdown reads "0:01" until it is actually done.
function formatElapsed(seconds) {
  return formatTimer(Math.floor(Math.max(0, Number(seconds) || 0)))
}

// Rebuilds the timer list from the state file. Anything malformed is dropped
// rather than trusted: the file outlives the shell, and a hand edit or a
// half-written save must not take the panel down with it.
function restoreTimers(value) {
  var list = Array.isArray(value) ? value : []
  var restored = []
  var seen = {}
  for (var i = 0; i < list.length && restored.length < 5; i++) {
    var t = list[i]
    if (!t || typeof t !== "object") continue
    var id = Math.floor(Number(t.id))
    if (!(id > 0) || seen[id]) continue
    var name = String(t.name === undefined || t.name === null ? "" : t.name).trim().slice(0, 40)
    var running = t.running === true

    if (t.kind === "stopwatch") {
      var startedAt = Number(t.startedAt)
      var elapsedBefore = Number(t.elapsedBefore)
      if (!isFinite(startedAt) || !isFinite(elapsedBefore) || elapsedBefore < 0) continue
      restored.push({ kind: "stopwatch", id: id, name: name, startedAt: startedAt, elapsedBefore: elapsedBefore, running: running })
    } else {
      var total = Number(t.total)
      var endsAt = Number(t.endsAt)
      var pausedRemaining = Number(t.pausedRemaining)
      if (!(total > 0) || total > TIMER_MAX_SECONDS) continue
      if (running ? !isFinite(endsAt) : !(pausedRemaining >= 0 && pausedRemaining <= total)) continue
      restored.push({
        kind: "timer", id: id, name: name, total: total,
        endsAt: running ? endsAt : 0,
        pausedRemaining: running ? 0 : pausedRemaining,
        running: running
      })
    }
    seen[id] = true
  }
  return restored
}

// The bar's read-out for one timer or stopwatch: its name, cut short so the
// bar does not grow without bound, then the time on it.
var BAR_NAME_MAX = 12

function barTimerLabel(timer, now) {
  if (!timer) return ""
  var time = timer.kind === "stopwatch"
    ? formatElapsed(stopwatchElapsed(timer, now))
    : formatTimer(timerRemaining(timer, now))
  var name = String(timer.name || "").trim()
  if (name.length > BAR_NAME_MAX) name = name.slice(0, BAR_NAME_MAX - 1) + "\u2026"
  return name !== "" ? name + " " + time : time
}

if (typeof module !== "undefined") {
  module.exports = {
    msUntilNextTick: msUntilNextTick,
    dateKey: dateKey,
    keyForDate: keyForDate,
    normalizedWeekStart: normalizedWeekStart,
    weekStartSettingName: weekStartSettingName,
    toggledWeekStart: toggledWeekStart,
    weekdayOrder: weekdayOrder,
    isoWeek: isoWeek,
    dayOfYear: dayOfYear,
    daysInYear: daysInYear,
    yearProgress: yearProgress,
    yearProgressPercent: yearProgressPercent,
    parseAge: parseAge,
    parseBirthYear: parseBirthYear,
    ageFromBirthYear: ageFromBirthYear,
    parseLifeExpectancy: parseLifeExpectancy,
    lifeProgress: lifeProgress,
    lifeProgressPercent: lifeProgressPercent,
    monthGrid: monthGrid,
    stepMonth: stepMonth,
    clockFormats: clockFormats,
    clockNeedsSeconds: clockNeedsSeconds,
    clockFormatRing: clockFormatRing,
    nextClockFormat: nextClockFormat,
    isoWeekLiteral: isoWeekLiteral,
    parseTimerDuration: parseTimerDuration,
    formatTimer: formatTimer,
    describeTimer: describeTimer,
    shortTimerLabel: shortTimerLabel,
    timerRemaining: timerRemaining,
    soonestTimer: soonestTimer,
    parseBool: parseBool,
    stopwatchElapsed: stopwatchElapsed,
    formatElapsed: formatElapsed,
    verticalTimerLines: verticalTimerLines,
    restoreTimers: restoreTimers,
    barTimerLabel: barTimerLabel
  }
}
