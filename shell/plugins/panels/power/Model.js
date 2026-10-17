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

function batteryIcon(device, onBattery, states, threshold) {
  var d = device || {}
  if (!d.isPresent) return ""

  var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
  var defaultIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  var index = Math.max(0, Math.min(9, Math.floor(d.percentage * 10)))
  if (typeof threshold !== "boolean") threshold = chargeThresholdActive(d, onBattery, states)

  if (threshold) return defaultIcons[index]
  if (d.state === states.FullyCharged) return "󰂅"
  if (!onBattery) return chargingIcons[index]
  return defaultIcons[index]
}

function modeLabel(device, onBattery, states, tr, threshold) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var d = device || {}
  if (!d.isPresent) return ""

  var percentage = d.isPresent ? d.percentage : 0
  if (typeof threshold !== "boolean") threshold = chargeThresholdActive(d, onBattery, states)
  if (threshold) return t("power.threshold", "Threshold")
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

// UPower exposes no cycle count, kernel charge limit or cell voltage per pack,
// so omarchy-battery-status supplies them, keyed by device name because
// enumeration order is not stable.
function parsePackMetadata(info) {
  var packs = {}
  var kv = info || {}
  Object.keys(kv).forEach(function(key) {
    var match = /^pack\.([0-9]+)\.path$/.exec(key)
    if (!match) return
    var prefix = "pack." + match[1] + "."
    packs[kv[key]] = {
      cycles: kv[prefix + "cycles"] || "",
      thresholdStart: kv[prefix + "thresholdStart"] || "",
      thresholdEnd: kv[prefix + "thresholdEnd"] || "",
      voltage: kv[prefix + "voltage"] || ""
    }
  })
  return packs
}

function deviceName(device) {
  return String(device.nativePath || "").split("/").pop()
}

function packMetadata(metadata, device) {
  return (metadata || {})[deviceName(device)] || {}
}

// An empty bay lists a battery with no capacity, which is not a pack. Keep in
// step with omarchy-battery-status.
function laptopDevices(devices) {
  return (devices || []).filter(function(device) {
    return device && device.ready && device.isPresent && device.isLaptopBattery && !(Number(device.energyCapacity) <= 0)
  }).sort(function(a, b) {
    return deviceName(a).localeCompare(deviceName(b))
  })
}

// A pack that stores no energy and moves none is dead or disconnected, unless
// it still shows a cell voltage: then it is only drained. Keep in step with
// omarchy-battery-status.
function holdsCharge(device, metadata) {
  if (Number(metadata && metadata.voltage) > 1) return true
  return !(Number(device.energy) <= 0 && !(Math.abs(Number(device.changeRate)) > 0))
}

// UPower's display device sums every pack, a dead one's capacity included, so
// it can read 49% while the pack in use is at 99%. When only one pack still
// holds charge, describe that one. Keep in step with omarchy-battery-status.
function combinedBattery(devices, display, metadata) {
  var live = laptopDevices(devices).filter(function(pack) { return holdsCharge(pack, packMetadata(metadata, pack)) })
  return live.length === 1 ? live[0] : display
}

// Firmware will not charge a pack sitting at or above its start threshold, and
// often stops a percent short of an end-only one. Some keeps reporting Charging
// at a trickle once it reaches the end. Keep in step with
// omarchy-battery-status.
function packAtLimit(device, onBattery, states, metadata) {
  if (onBattery || Math.abs(Number(device.changeRate)) > 0.2) return false
  var charging = device.state === states.Charging
  if (!charging && device.state !== states.PendingCharge && device.state !== states.FullyCharged) return false
  var end = Number(metadata.thresholdEnd)
  var start = Number(metadata.thresholdStart)
  if (!(end > 0 && end < 100)) return false
  var percent = Math.round(batteryFraction(device) * 1000) / 10
  if (device.state === states.FullyCharged && percent >= 99) return false
  if (charging) return percent >= end
  return percent >= (start > 0 && start < end ? start : end - 1)
}

// One pack still filling means the machine is charging, not holding.
function chargeThresholdActiveForPacks(packs, onBattery, states, metadata) {
  var limited = false
  for (var i = 0; i < packs.length; i++) {
    var pack = packs[i]
    var info = packMetadata(metadata, pack)
    if (!holdsCharge(pack, info)) continue
    if (packAtLimit(pack, onBattery, states, info)) limited = true
    else if (pack.state !== states.FullyCharged) return false
  }
  return limited
}

function packSummary(device, onBattery, states, metadata, tr, fmt) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var f = typeof fmt === "function" ? fmt : String
  var label = t("power.unknown", "Unknown")
  if (!holdsCharge(device, metadata)) label = t("power.notHoldingCharge", "Not holding charge")
  else if (packAtLimit(device, onBattery, states, metadata)) label = t("power.holding", "Holding")
  else if (device.state === states.Charging) label = t("power.charging", "Charging")
  else if (device.state === states.Discharging) label = t("power.discharging", "Discharging")
  else if (device.state === states.FullyCharged) label = t("power.fullyCharged", "Fully charged")
  else if (device.state === states.PendingCharge) label = onBattery ? t("power.idle", "Idle") : t("power.waitingToCharge", "Waiting to charge")
  else if (device.state === states.PendingDischarge) label = t("power.idle", "Idle")
  else if (device.state === states.Empty) label = t("power.empty", "Empty")
  return f(Math.round(batteryFraction(device) * 100)) + "% · " + label
}

function formatThreshold(metadata) {
  var start = metadata.thresholdStart
  var end = metadata.thresholdEnd
  return (start !== "" && start !== end ? start + "-" : "") + end + "%"
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
    parsePackMetadata: parsePackMetadata,
    deviceName: deviceName,
    laptopDevices: laptopDevices,
    holdsCharge: holdsCharge,
    combinedBattery: combinedBattery,
    packAtLimit: packAtLimit,
    chargeThresholdActiveForPacks: chargeThresholdActiveForPacks,
    packSummary: packSummary,
    formatThreshold: formatThreshold
  }
}
