var TOMORROW_PATTERN = /^(?:tomorrow|tmrw?)\s+|\s+(?:tomorrow|tmrw?)$/
var MS_PER_MINUTE = 60000
var MS_PER_DAY = 86400000

function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

function fill(template, values) {
  var text = String(template || "")
  for (var i = 0; i < values.length; i++) text = text.replace("%" + (i + 1), values[i])
  return text
}

function validMinutes(value) {
  var minutes = String(value || "").trim()
  return /^[0-9]+$/.test(minutes) && Number(minutes) > 0 ? minutes : ""
}

function parseDuration(text) {
  var plain = validMinutes(text)
  if (plain) return Number(plain)

  var match = /^(?:in\s+)?(?:(\d+)\s*h(?:ours?|rs?)?)?\s*(?:(\d+)\s*m(?:in(?:ute)?s?)?)?$/.exec(text)
  if (!match || (match[1] === undefined && match[2] === undefined)) return 0

  return Number(match[1] || 0) * 60 + Number(match[2] || 0)
}

function parse12HourClock(text) {
  var match = /^(\d{1,2})(?:[:.](\d{2}))?\s*([ap])\.?\s*(?:m\.?)?$/.exec(text)
  if (!match) return null

  var hour = Number(match[1])
  var minute = Number(match[2] || 0)
  if (hour < 1 || hour > 12 || minute > 59) return null
  return { hour: (hour % 12) + (match[3] === "p" ? 12 : 0), minute: minute }
}

function parse24HourClock(text) {
  var match = /^(\d{1,2}):(\d{2})$/.exec(text)
  if (!match) return null

  var hour = Number(match[1])
  var minute = Number(match[2])
  if (hour > 23 || minute > 59) return null
  return { hour: hour, minute: minute }
}

function parseClock(text) {
  if (text === "noon") return { hour: 12, minute: 0 }
  if (text === "midnight") return { hour: 0, minute: 0 }
  return parse12HourClock(text) || parse24HourClock(text)
}

// Returns { kind: "duration", minutes } or { kind: "time", hour, minute, tomorrow }, or null.
function parseWhen(value) {
  var text = String(value || "").trim().toLowerCase().replace(/\s+/g, " ")
  if (!text) return null

  var minutes = parseDuration(text)
  if (minutes) return { kind: "duration", minutes: minutes }

  var clock = parseClock(text.replace(TOMORROW_PATTERN, "").replace(/^at\s+/, ""))
  if (!clock) return null
  return { kind: "time", hour: clock.hour, minute: clock.minute, tomorrow: TOMORROW_PATTERN.test(text) }
}

// Built from the calendar day so a daylight-saving shift on one day never
// carries into another.
function clockOnDay(now, daysAhead, when) {
  return new Date(now.getFullYear(), now.getMonth(), now.getDate() + daysAhead, when.hour, when.minute, 0, 0)
}

function resolveDate(when, now) {
  now = now || new Date()
  if (!when) return null
  if (when.kind === "duration") return new Date(now.getTime() + when.minutes * MS_PER_MINUTE)
  if (when.tomorrow) return clockOnDay(now, 1, when)

  var today = clockOnDay(now, 0, when)
  return today.getTime() > now.getTime() ? today : clockOnDay(now, 1, when)
}

function calendarDaysBetween(from, to) {
  var fromDay = new Date(from.getFullYear(), from.getMonth(), from.getDate())
  var toDay = new Date(to.getFullYear(), to.getMonth(), to.getDate())
  return Math.round((toDay - fromDay) / MS_PER_DAY)
}

function pad(value) {
  return (value < 10 ? "0" : "") + value
}

// tr is an optional translate(key, english) from the QML side (I18n.t);
// without it the English text stands, which is what the Node tests assert.
function formatClock(date, tr) {
  var t = translator(tr)
  var hour = date.getHours() % 12 || 12
  var meridiem = date.getHours() < 12
    ? t("reminders.meridiemAm", "AM")
    : t("reminders.meridiemPm", "PM")
  return fill(t("reminders.clock12", "%1:%2 %3"), [hour, pad(date.getMinutes()), meridiem])
}

function formatDuration(minutes, tr) {
  var t = translator(tr)
  var hours = Math.floor(minutes / 60)
  var rest = minutes % 60
  if (hours && rest) return fill(t("reminders.durationHm", "%1h %2m"), [hours, rest])
  if (hours) return fill(t("reminders.durationH", "%1h"), [hours])
  return fill(t("reminders.durationM", "%1m"), [rest])
}

function dayLabel(target, now, tr) {
  var t = translator(tr)
  var days = calendarDaysBetween(now, target)
  if (days === 0) return t("reminders.today", "today")
  if (days === 1) return t("reminders.tomorrow", "tomorrow")
  return target.toDateString()
}

function describe(when, now, tr) {
  var t = translator(tr)
  now = now || new Date()
  var target = resolveDate(when, now)
  if (!target) return ""

  if (when.kind === "duration")
    return fill(t("reminders.previewInAt", "In %1 · at %2"), [formatDuration(when.minutes, tr), formatClock(target, tr)])

  var minutesAway = Math.max(1, Math.ceil((target.getTime() - now.getTime()) / MS_PER_MINUTE))
  return fill(t("reminders.previewAtIn", "%1 %2 · in %3"), [
    formatClock(target, tr),
    dayLabel(target, now, tr),
    formatDuration(minutesAway, tr)
  ])
}

function withMessage(args, message) {
  var text = String(message || "")
  if (text.length > 0) args.push(text)
  return args
}

function reminderArgs(minutes, message) {
  var valid = validMinutes(minutes)
  if (!valid) return []
  return withMessage([valid], message)
}

// Clock times pass the requested "HH:MM" (prefixed with "tomorrow" when it
// falls tomorrow) so omarchy-reminder resolves the wall-clock time on that day.
function scheduleArgs(when, message, now) {
  now = now || new Date()
  if (!when) return []
  if (when.kind === "duration") return reminderArgs(when.minutes, message)

  var clock = pad(when.hour) + ":" + pad(when.minute)
  var isTomorrow = calendarDaysBetween(now, resolveDate(when, now)) === 1
  return withMessage([isTomorrow ? "tomorrow " + clock : clock], message)
}

if (typeof module !== "undefined") {
  module.exports = {
    validMinutes: validMinutes,
    reminderArgs: reminderArgs,
    parseWhen: parseWhen,
    resolveDate: resolveDate,
    describe: describe,
    scheduleArgs: scheduleArgs
  }
}
