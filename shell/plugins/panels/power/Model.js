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

// The caller settles whether the battery is holding at a charge limit; the
// panel has one answer for that whether the machine has one pack or several.
function batteryIcon(device, onBattery, states, threshold) {
  var d = device || {}
  if (!d.isPresent) return ""

  var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
  var defaultIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  var index = Math.max(0, Math.min(9, Math.floor(d.percentage * 10)))

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

// UPower exposes no cycle count or kernel charge limit per pack, and only
// omarchy-battery-status decides whether a pack holds charge or sits at its
// limit, so it supplies them, keyed by device name because enumeration order
// is not stable.
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
      holdsCharge: kv[prefix + "holdsCharge"] !== "false",
      atLimit: kv[prefix + "atLimit"] === "true"
    }
  })
  return packs
}

function deviceName(device) {
  return String(device.nativePath || "").split("/").pop()
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

// UPower's display device sums every pack, a dead one's capacity included, so
// it can read 49% while the pack in use is at 99%. omarchy-battery-status
// names the one pack still holding charge when the others are dead; otherwise
// the display device describes them together.
function headlineBattery(devices, display, name) {
  var named = laptopDevices(devices).filter(function(pack) { return deviceName(pack) === name })
  return named.length === 1 ? named[0] : display
}

function packSummary(device, onBattery, states, metadata, tr, fmt) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var f = typeof fmt === "function" ? fmt : String
  var m = metadata || {}
  var label = t("power.unknown", "Unknown")
  if (m.holdsCharge === false) label = t("power.notHoldingCharge", "Not holding charge")
  else if (m.atLimit) label = t("power.holding", "Holding")
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
    headlineBattery: headlineBattery,
    packSummary: packSummary,
    formatThreshold: formatThreshold
  }
}
