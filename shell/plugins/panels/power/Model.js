function clampIndex(index, length) {
  if (length <= 0) return 0
  return Math.max(0, Math.min(length - 1, index))
}

function selectProfileIndex(index, delta, profiles) {
  var values = Array.isArray(profiles) ? profiles : []
  if (values.length === 0) return 0
  return clampIndex(index + delta, values.length)
}

function parseKeyValue(raw) {
  var next = {}
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var idx = lines[i].indexOf("\t")
    if (idx <= 0) continue
    next[lines[i].substring(0, idx)] = lines[i].substring(idx + 1).trim()
  }
  return next
}

function parseProfiles(raw, previousIndex) {
  var lines = String(raw || "").split("\n")
  var list = []
  var active = ""
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim()
    if (!line) continue
    var parts = line.split("\t")
    list.push(parts[0])
    if (parts[1] === "1") active = parts[0]
  }
  return {
    profiles: list,
    activeProfile: active,
    profileIndex: clampIndex(previousIndex || 0, list.length)
  }
}

function profileIcon(name) {
  if (name === "power-saver") return "󰌪"
  if (name === "balanced") return "󰊚"
  if (name === "performance") return "󰓅"
  return "󰂄"
}

function batteryFraction(device) {
  return device && device.isPresent ? Math.max(0, Math.min(1, device.percentage)) : 0
}

function chargeThresholdActive(device, onBattery, states) {
  var d = device || {}
  var s = states || {}
  if (!(d && d.isPresent && !onBattery)) return false

  var fraction = batteryFraction(d)
  if (d.state === s.Discharging) return false
  if (d.state === s.PendingCharge) return true
  if (d.state === s.FullyCharged && fraction < 0.99) return true
  if (d.state !== s.Charging || fraction >= 0.99) return false

  return Number(d.changeRate || 0) <= 0.2 || Number(d.timeToFull || 0) >= 8 * 60 * 60
}

function batteryIcon(device, onBattery, states) {
  var d = device || {}
  if (!d.isPresent) return ""

  var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
  var defaultIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  var index = Math.max(0, Math.min(9, Math.floor(d.percentage * 10)))
  var threshold = chargeThresholdActive(d, onBattery, states)

  if (threshold) return defaultIcons[index]
  if (d.state === states.FullyCharged) return "󰂅"
  if (!onBattery) return chargingIcons[index]
  return defaultIcons[index]
}

function modeLabel(device, onBattery, states, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var d = device || {}
  if (!d.isPresent) return ""

  var percentage = d.isPresent ? d.percentage : 0
  if (chargeThresholdActive(d, onBattery, states)) return t("power.threshold", "Threshold")
  if (onBattery) return t("power.onBattery", "On battery")
  if (!onBattery && percentage >= 1) return t("power.fullyCharged", "Fully charged")
  return t("power.charging", "Charging")
}

// omarchy-battery-status --shell answers in plain digits with the unit
// attached ("13.1W", "75-80%"); the panel writes each number in the
// language's digits and decimal separator, keeping its decimals and unit.
function localizeReading(raw, fmt) {
  var f = typeof fmt === "function" ? fmt : function(v, d) { return d === undefined ? String(v) : Number(v).toFixed(d) }
  return String(raw === undefined || raw === null ? "" : raw).replace(/\d+(?:\.\d+)?/g, function(number) {
    var dot = number.indexOf(".")
    return f(Number(number), dot < 0 ? undefined : number.length - dot - 1)
  })
}

function profileLabel(name, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var value = String(name || "")
  if (value === "power-saver") return t("power.profilePowerSaver", "Power-saver")
  if (value === "balanced") return t("power.profileBalanced", "Balanced")
  if (value === "performance") return t("power.profilePerformance", "Performance")
  return value.charAt(0).toUpperCase() + value.slice(1)
}

// UPower names a battery's object path after the last part of its native
// path: BAT0 is battery_BAT0, and macsmc-battery is battery_macsmc_battery.
function historyDevicePath(nativePath) {
  var name = String(nativePath || "").split("/").pop()
  if (!name) return ""
  return "/org/freedesktop/UPower/devices/battery_" + name.replace(/[^A-Za-z0-9_]/g, "_")
}

// busctl --json=short answers GetHistory with
// {"type":"a(udu)","data":[[[time, percentage, state], …]]}, newest first.
// UPower writes a row with state 0 when it starts up; it marks the restart
// and is not a reading of 0%. Returns null for a reply that isn't a history.
function parseHistory(text) {
  var rows
  try {
    rows = JSON.parse(text).data[0]
  } catch (e) {
    return null
  }
  if (!Array.isArray(rows)) return null

  var entries = []
  for (var i = 0; i < rows.length; i++) {
    var row = rows[i]
    if (!Array.isArray(row) || row.length < 3) continue
    var time = Number(row[0])
    var value = Number(row[1])
    if (!(time > 0) || Number(row[2]) === 0 || !(value >= 0 && value <= 100)) continue
    entries.push({ time: time, value: value })
  }
  entries.sort(function(a, b) { return a.time - b.time })
  return entries
}

// The charge over the last `span` seconds as a step line in 0..1 on both
// axes (x along time, y down from full). UPower records the level only when
// it changes, so each reading holds until the next, the line opens at the
// level in force when the window starts, and it runs on to now at the live
// level. Without any reading the live level holds across the whole window.
function historyPoints(entries, now, span, current) {
  var list = Array.isArray(entries) ? entries : []
  var start = now - span
  var points = []
  function add(time, value) {
    points.push({ x: (time - start) / span, y: (100 - Math.max(0, Math.min(100, value))) / 100 })
  }

  var level = null
  var i = 0
  for (; i < list.length && list[i].time <= start; i++) level = list[i].value
  if (level !== null) add(start, level)
  for (; i < list.length && list[i].time <= now; i++) {
    if (level !== null) add(list[i].time, level)
    add(list[i].time, list[i].value)
    level = list[i].value
  }

  var live = Number(current) >= 0 ? Number(current) : level
  if (live === null) return []
  if (level === null) {
    add(start, live)
    level = live
  }
  add(now, level)
  if (Math.round(live) !== Math.round(level)) add(now, live)
  return points
}

if (typeof module !== "undefined") {
  module.exports = {
    clampIndex: clampIndex,
    selectProfileIndex: selectProfileIndex,
    parseKeyValue: parseKeyValue,
    parseProfiles: parseProfiles,
    profileIcon: profileIcon,
    batteryFraction: batteryFraction,
    chargeThresholdActive: chargeThresholdActive,
    batteryIcon: batteryIcon,
    modeLabel: modeLabel,
    profileLabel: profileLabel,
    localizeReading: localizeReading,
    historyDevicePath: historyDevicePath,
    parseHistory: parseHistory,
    historyPoints: historyPoints
  }
}
