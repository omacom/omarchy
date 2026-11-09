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

function parseChargeLimit(raw) {
  var info = parseKeyValue(raw)
  var state = info.state
  if (state !== "on" && state !== "off" && state !== "mixed" && state !== "unsupported") return null

  var policy = info.policy
  var start = Number(info.start) || 0
  var end = Number(info.end) || 0
  var percentage = function(value) { return Number.isInteger(value) && value > 0 && value < 100 }
  if (state === "unsupported") policy = "unknown"
  if (policy === "range" && !(percentage(start) && percentage(end) && start < end)) policy = "unknown"
  if (policy === "end" && !percentage(end)) policy = "unknown"
  if (policy !== "range" && policy !== "end" && policy !== "firmware" && policy !== "different") policy = "unknown"
  return { state: state, policy: policy, start: policy === "range" ? start : 0, end: policy === "range" || policy === "end" ? end : 0 }
}

// stdout completion and process exit can arrive in either order. An empty
// failed read must not replace the last good state with "unsupported".
function chargeLimitReadResult(raw, exitCode) {
  if (raw === null || exitCode === null) return null
  var info = exitCode === 0 ? parseChargeLimit(raw) : null
  return { failed: info === null, info: info }
}

function chargeLimitDescription(info, tr, fmt) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var number = typeof fmt === "function" ? fmt : String
  var limit = info || {}
  var on = limit.state === "on"
  if (limit.state === "unsupported") return ""
  if (limit.state === "mixed") return t("power.chargeLimitMixed", "Batteries have different settings. Turn on to protect all supported batteries.")
  if (limit.policy === "range") {
    var range = on ? t("power.chargeLimitRangeOn", "Starts charging below %1% and stops at %2%.")
      : t("power.chargeLimitRangeOff", "Charges to full. Turn on to start below %1% and stop at %2%.")
    return range.replace("%1", number(limit.start)).replace("%2", number(limit.end))
  }
  if (limit.policy === "end") {
    var end = on ? t("power.chargeLimitEndOn", "Stops charging at %1%.")
      : t("power.chargeLimitEndOff", "Charges to full. Turn on to stop at %1%.")
    return end.replace("%1", number(limit.end))
  }
  if (limit.policy === "different") {
    return on ? t("power.chargeLimitDifferentOn", "Each supported battery uses its own charging limit.")
      : t("power.chargeLimitDifferentOff", "Charges to full. Turn on to apply each battery’s charging limit.")
  }
  return on ? t("power.chargeLimitOn", "Uses your laptop’s battery protection settings.")
    : t("power.chargeLimitOff", "Charges to full. Turn on to use your laptop’s battery protection settings.")
}

function movePowerCursor(cursor, dx, dy, chargeLimitAvailable, profiles) {
  var focused = chargeLimitAvailable && cursor.chargeFocused
  var index = cursor.profileIndex
  if (chargeLimitAvailable && dy !== 0) focused = dy > 0
  else if (!focused) index = selectProfileIndex(index, dx !== 0 ? dx : dy, profiles)
  return { chargeFocused: !!focused, profileIndex: index }
}

function chargeLimitEvent(line) {
  return /Charge(?:Start|End)?Threshold|\b(?:IsPresent|PowerSupply|Type)\b|\.Device(?:Added|Removed)\b|owned by/.test(String(line || ""))
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

if (typeof module !== "undefined") {
  module.exports = {
    clampIndex: clampIndex,
    selectProfileIndex: selectProfileIndex,
    parseKeyValue: parseKeyValue,
    parseProfiles: parseProfiles,
    parseChargeLimit: parseChargeLimit,
    chargeLimitReadResult: chargeLimitReadResult,
    chargeLimitDescription: chargeLimitDescription,
    movePowerCursor: movePowerCursor,
    chargeLimitEvent: chargeLimitEvent,
    profileIcon: profileIcon,
    batteryFraction: batteryFraction,
    chargeThresholdActive: chargeThresholdActive,
    batteryIcon: batteryIcon,
    modeLabel: modeLabel,
    profileLabel: profileLabel,
    localizeReading: localizeReading
  }
}
