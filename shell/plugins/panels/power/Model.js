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

// limits: the kernel's charge_control_{start,end}_threshold as { start, end },
// or one { fraction, start, end } per laptop battery. A charge can only be held
// inside a limit the battery actually has: end below 99 and the level at or
// above start. Outside that band a stalled rate (UPower reports 0 W for ~10 s
// after plug-in), a pending-charge step or a long time-to-full estimate is not
// a hold, and the bar must keep showing charging.
function limitInBand(limits, fraction) {
  var end = Number(limits && limits.end)
  if (!(end >= 1) || end >= 99) return false
  // Without a start threshold (or with start 0) the battery charges until it
  // reaches end, so it can only be held at end.
  var start = Number(limits && limits.start)
  var low = start > 0 && start < end ? start : end - 1
  return fraction * 100 >= low - 0.5
}

// With several batteries the combined device is held only when none of them
// can still charge: each one is inside its own limit or already full.
function chargeLimitsInBand(limits, fraction) {
  if (!Array.isArray(limits)) return limitInBand(limits, fraction)

  var held = false
  for (var i = 0; i < limits.length; i++) {
    var f = Number(limits[i] && limits[i].fraction)
    if (limitInBand(limits[i], f)) held = true
    else if (!(f >= 0.99)) return false
  }
  return held
}

// rateFresh is false while the charge rate still dates from before external
// power arrived. A battery that reports its rate every half minute reads
// "charging at 0 W" until then, which is not a threshold holding it.
function chargeThresholdActive(device, onBattery, states, rateFresh, limitState, limits) {
  var d = device || {}
  var s = states || {}
  if (!(d && d.isPresent && !onBattery)) return false

  var fraction = batteryFraction(d)
  if (d.state === s.Discharging) return false
  if (!chargeLimitsInBand(limits, fraction)) return false
  if (d.state === s.PendingCharge) return true
  if (d.state === s.FullyCharged && fraction < 0.99) return true
  if (d.state !== s.Charging || fraction >= 0.99) return false
  if (rateFresh === false) return false
  if (limitState === "off" || limitState === "once") return false

  return Number(d.changeRate || 0) <= 0.2 || Number(d.timeToFull || 0) >= 8 * 60 * 60
}

function batteryIcon(device, onBattery, states, rateFresh, limitState, limits) {
  var d = device || {}
  if (!d.isPresent) return ""

  var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
  var defaultIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  var index = Math.max(0, Math.min(9, Math.floor(d.percentage * 10)))
  var threshold = chargeThresholdActive(d, onBattery, states, rateFresh, limitState, limits)

  if (threshold) return defaultIcons[index]
  if (d.state === states.FullyCharged) return "󰂅"
  if (!onBattery) return chargingIcons[index]
  return defaultIcons[index]
}

function modeLabel(device, onBattery, states, tr, rateFresh, limitState, limits) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var d = device || {}
  if (!d.isPresent) return ""

  var percentage = d.isPresent ? d.percentage : 0
  if (chargeThresholdActive(d, onBattery, states, rateFresh, limitState, limits)) return t("power.threshold", "Threshold")
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

function chargeLimitFraction(batteryInfo) {
  var info = batteryInfo || {}
  if (info.limit_mode === "firmware") return 0
  var n = parseFloat(info.limit_end || "")
  if (isNaN(n) || n <= 0 || n >= 100) return 0
  return n / 100
}

function chargeLimitHeader(batteryInfo, tr, fmt) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var info = batteryInfo || {}
  var title = t("power.chargeLimitSection", "CHARGE LIMIT")
  if (info.limit_mode === "firmware" || !info.limit_end) return title
  return title + " · " + localizeReading(info.limit_end + "%", fmt)
}

function formatSleepShort(batteryInfo, fmt) {
  var info = batteryInfo || {}
  if (!info.sleep_duration) return ""
  if (info.sleep_drain_pct_hr) return localizeReading(info.sleep_drain_pct_hr, fmt)
  if (info.sleep_drain_w) return localizeReading(info.sleep_drain_w, fmt)
  return info.sleep_duration
}

function formatSleepTooltip(batteryInfo, fmt) {
  var info = batteryInfo || {}
  if (!info.sleep_duration) return ""
  var parts = [info.sleep_duration]
  if (info.sleep_drain_pct) parts.push("−" + localizeReading(info.sleep_drain_pct, fmt))
  if (info.sleep_drain_pct_hr) parts.push(localizeReading(info.sleep_drain_pct_hr, fmt))
  if (info.sleep_drain_w) parts.push(localizeReading(info.sleep_drain_w, fmt))
  if (info.sleep_mode === "s2idle" && info.sleep_s0ix) parts.push("S0ix " + localizeReading(info.sleep_s0ix, fmt))
  return parts.join(" · ")
}

function isLowS0ix(batteryInfo) {
  var info = batteryInfo || {}
  if (info.sleep_mode !== "s2idle" || !info.sleep_s0ix) return false
  var n = parseFloat(String(info.sleep_s0ix).replace("%", ""))
  return !isNaN(n) && n < 80
}

function moveFocus(focusRow, profileIndex, dx, dy, hasLimit, hasTopUp, profileCount) {
  var rows = []
  if (hasLimit) rows.push("limit")
  if (hasLimit && hasTopUp) rows.push("topup")
  rows.push("profile")

  var rowIdx = rows.indexOf(focusRow)
  if (rowIdx < 0) rowIdx = rows.length - 1
  var pIdx = clampIndex(profileIndex, profileCount)

  if (dy !== 0) {
    if (rows.length > 1) {
      rowIdx = clampIndex(rowIdx + (dy > 0 ? 1 : -1), rows.length)
      return { focusRow: rows[rowIdx], profileIndex: pIdx }
    }
    return { focusRow: "profile", profileIndex: clampIndex(pIdx + dy, profileCount) }
  }

  if (dx !== 0 && rows[rowIdx] === "profile") {
    pIdx = clampIndex(pIdx + dx, profileCount)
  }
  return { focusRow: rows[rowIdx], profileIndex: pIdx }
}

if (typeof module !== "undefined") {
  module.exports = {
    clampIndex: clampIndex,
    selectProfileIndex: selectProfileIndex,
    parseKeyValue: parseKeyValue,
    parseProfiles: parseProfiles,
    profileIcon: profileIcon,
    batteryFraction: batteryFraction,
    chargeLimitsInBand: chargeLimitsInBand,
    chargeThresholdActive: chargeThresholdActive,
    batteryIcon: batteryIcon,
    modeLabel: modeLabel,
    profileLabel: profileLabel,
    localizeReading: localizeReading,
    chargeLimitFraction: chargeLimitFraction,
    chargeLimitHeader: chargeLimitHeader,
    formatSleepShort: formatSleepShort,
    formatSleepTooltip: formatSleepTooltip,
    isLowS0ix: isLowS0ix,
    moveFocus: moveFocus
  }
}
