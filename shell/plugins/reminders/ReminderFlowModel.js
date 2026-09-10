function validMinutes(value) {
  var minutes = String(value || "").trim()
  return /^[0-9]+$/.test(minutes) && Number(minutes) > 0 ? minutes : ""
}

function normalizeWhenInput(value) {
  return String(value || "").trim().toLowerCase().replace(/\s+/g, "")
}

function formatHm(hour, minute) {
  return String(hour) + ":" + (minute < 10 ? "0" : "") + String(minute)
}

function parseClock(value) {
  var raw = normalizeWhenInput(value)
  var match
  var hour
  var minute
  var second

  match = raw.match(/^(\d{1,2})(?:[:.](\d{2}))?(?:[:.](\d{2}))?(am|pm)$/)
  if (match) {
    hour = Number(match[1])
    minute = Number(match[2] || "0")
    second = Number(match[3] || "0")
    if (hour < 1 || hour > 12 || minute > 59 || second > 59) return null
    if (match[4] === "am") hour = hour === 12 ? 0 : hour
    else hour = hour === 12 ? 12 : hour + 12
    return { hour: hour, minute: minute, second: second }
  }

  match = raw.match(/^(\d{1,2})[:.](\d{2})(?:[:.](\d{2}))?$/)
  if (match) {
    hour = Number(match[1])
    minute = Number(match[2])
    second = Number(match[3] || "0")
    if (hour > 23 || minute > 59 || second > 59) return null
    return { hour: hour, minute: minute, second: second }
  }

  return null
}

// Qt::Key / modifier values. Layer-shell exclusive focus often starts without
// the compositor's NumLock lock, so keypad keys arrive as navigation keys
// with empty event.text until NumLock is toggled on that surface.
var KEY_0 = 0x30
var KEY_9 = 0x39
var KEY_INSERT = 0x01000006
var KEY_DELETE = 0x01000007
var KEY_CLEAR = 0x0100000b
var KEY_HOME = 0x01000010
var KEY_END = 0x01000011
var KEY_LEFT = 0x01000012
var KEY_UP = 0x01000013
var KEY_RIGHT = 0x01000014
var KEY_DOWN = 0x01000015
var KEY_PAGEUP = 0x01000016
var KEY_PAGEDOWN = 0x01000017
var KEY_PERIOD = 0x2e
var KEYPAD_MOD = 0x20000000
var CTRL_ALT_META = 0x04000000 | 0x08000000 | 0x10000000

// XKB keycodes (Wayland evdev + 8), as QKeyEvent.nativeScanCode on Qt Wayland.
var XKB_KEYPAD_CHARS = {
  79: "7", 80: "8", 81: "9",
  83: "4", 84: "5", 85: "6",
  87: "1", 88: "2", 89: "3",
  90: "0", 91: "."
}

function keypadNavChar(key) {
  switch (key) {
    case KEY_INSERT: return "0"
    case KEY_END: return "1"
    case KEY_DOWN: return "2"
    case KEY_PAGEDOWN: return "3"
    case KEY_LEFT: return "4"
    case KEY_CLEAR: return "5"
    case KEY_RIGHT: return "6"
    case KEY_HOME: return "7"
    case KEY_UP: return "8"
    case KEY_PAGEUP: return "9"
    case KEY_DELETE:
    case KEY_PERIOD: return "."
    default: return ""
  }
}

function typedChar(key, modifiers, nativeScanCode, text) {
  modifiers = Number(modifiers) || 0
  if (modifiers & CTRL_ALT_META) return ""

  if (key >= KEY_0 && key <= KEY_9) return String.fromCharCode(key)

  var fromScan = XKB_KEYPAD_CHARS[Number(nativeScanCode) || 0]
  if (fromScan) return fromScan

  if (modifiers & KEYPAD_MOD) {
    var fromNav = keypadNavChar(key)
    if (fromNav) return fromNav
  }

  var raw = String(text || "")
  if (raw.length === 1) {
    var code = raw.charCodeAt(0)
    if (code >= 32 && code !== 127) return raw
  }
  return ""
}

function minutesUntil(targetMs, nowMs) {
  var remainingMs = targetMs - nowMs
  if (remainingMs <= 0) return "1"
  return String(Math.max(1, Math.ceil(remainingMs / 60000)))
}

function parseWhen(value, now) {
  var minutes = validMinutes(value)
  if (minutes) return { kind: "minutes", minutes: minutes }

  var clock = parseClock(value)
  if (!clock) return null

  var current = now instanceof Date ? now : (now ? new Date(now) : new Date())
  var target = new Date(current.getFullYear(), current.getMonth(), current.getDate(), clock.hour, clock.minute, clock.second, 0)
  if (target.getTime() <= current.getTime()) target.setDate(target.getDate() + 1)

  return {
    kind: "time",
    minutes: minutesUntil(target.getTime(), current.getTime()),
    displayTime: formatHm(clock.hour, clock.minute)
  }
}

function parseList(raw) {
  try {
    var data = JSON.parse(String(raw || ""))
    return Array.isArray(data.reminders) ? data.reminders : []
  } catch (e) {
    return []
  }
}

function validUnit(unit) {
  return /^omarchy-reminder-[0-9]+m-[0-9]+$/.test(String(unit || ""))
}

function rowTitle(item) {
  return String((item && item.label) || "Reminder")
}

function rowMeta(item) {
  var remaining = String((item && item.remaining) || "")
  var atTime = String((item && item.atTime) || "")
  if (remaining && atTime) return remaining + "  (" + atTime + ")"
  return remaining || atTime
}

function reminderArgs(minutes, message, timeLabel) {
  var valid = validMinutes(minutes)
  if (!valid) return []

  var args = [valid]
  var text = String(message || "")
  if (text.length > 0) args.push(text)
  else if (timeLabel) args.push("It's " + timeLabel)
  return args
}

if (typeof module !== "undefined") {
  module.exports = {
    validMinutes: validMinutes,
    parseClock: parseClock,
    parseWhen: parseWhen,
    reminderArgs: reminderArgs,
    typedChar: typedChar,
    parseList: parseList,
    validUnit: validUnit,
    rowTitle: rowTitle,
    rowMeta: rowMeta
  }
}
