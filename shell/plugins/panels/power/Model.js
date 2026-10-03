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

// The band a configured charge limit holds the pack in, as 0..1 fractions, or
// null when no real limit is configured. The threshold string is the one
// omarchy-battery-status prints: "75-80%" for a start/end pair, "80%" when only
// one value is known. An end of 100% is sysfs reporting no limit at all, and a
// start of 0 is "no start threshold" rather than "holds from empty".
function chargeHoldBand(threshold) {
  var match = /(\d+)\s*(?:-\s*(\d+))?\s*%/.exec(String(threshold || ""))
  if (!match) return null

  var end = Number(match[2] !== undefined ? match[2] : match[1])
  if (end >= 100) return null

  var start = Number(match[1])
  return { floor: (start > 0 ? start : end) / 100, end: end / 100 }
}

function chargeHoldFloor(threshold) {
  var band = chargeHoldBand(threshold)
  return band ? band.floor : -1
}

function chargeThresholdActive(device, onBattery, states, threshold) {
  var d = device || {}
  var s = states || {}
  if (!(d && d.isPresent && !onBattery)) return false

  var fraction = batteryFraction(d)
  if (d.state === s.Discharging) return false

  // Each branch below reads a stopped or stalled charge as a deliberate hold,
  // and none of them can be one without a limit configured to do the holding.
  // omarchy-battery-status gates the same cases on the same limit, and the
  // panel has to agree with the line it prints.
  var band = chargeHoldBand(threshold)
  if (!band) return false

  // Firmware and UPower do not agree on one state for a charge-limit hold:
  // both pending states have been observed while connected to AC.
  // PendingCharge and PendingDischarge are only "AC is present and the EC is not
  // charging", so the level has to have reached the band before the limit explains it.
  if (d.state === s.PendingCharge || d.state === s.PendingDischarge) return fraction >= band.floor

  // A healthy pack reports FullyCharged at the top of whatever band it is held
  // in; stopping short of full is the limit doing its job.
  if (d.state === s.FullyCharged) return fraction < 0.99

  // An AC-connected battery in a non-charging, non-discharging state is
  // holding its level even when the driver reports it as Unknown.
  if (d.state !== s.Charging) return fraction >= band.floor

  if (fraction >= 0.99) return false

  // A charge that crawls below the limit is a slow charge, not a hold.
  if (fraction < band.end) return false

  // Only use measurements that the driver actually supplied. Treating a
  // missing rate as zero caused state detection to depend on firmware quirks.
  var rate = Number(d.changeRate)
  var timeToFull = Number(d.timeToFull)
  return (isFinite(rate) && rate <= 0.2) ||
    (isFinite(timeToFull) && timeToFull >= 8 * 60 * 60)
}

function batteryIcon(device, onBattery, states, arg4, arg5) {
  var d = device || {}
  if (!d.isPresent) return ""

  var profile = ""
  var threshold = ""
  var args = [arg4, arg5]
  for (var i = 0; i < args.length; i++) {
    var val = args[i]
    if (typeof val === "string" && val.length > 0) {
      if (chargeHoldBand(val) !== null || /^\d+(?:-\d+)?%?$/.test(val.trim())) {
        threshold = val
      } else {
        profile = val
      }
    }
  }

  // battery_charging_10..100 — the MDI charging series; its codepoints are
  // scattered across the font, so the literals below are the ordered set.
  var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
  var defaultIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  var index = Math.max(0, Math.min(9, Math.floor(d.percentage * 10)))
  var holding = chargeThresholdActive(d, onBattery, states, threshold)

  // Stepped battery level with superscript plus (U+207A) for charge-limit hold.
  if (holding) return defaultIcons[index] + "⁺"
  // battery-check (U+F17E2): charged and holding, not actively charging.
  if (d.state === states.FullyCharged) return "󱟢"
  if (!onBattery) return chargingIcons[index]
  var p = String(profile || "").toLowerCase()
  // leaf (U+F032A): power-saver profile modifier on battery.
  if (p === "power-saver") return defaultIcons[index] + "󰌪"
  // speedometer (U+F04C5): performance profile modifier on battery.
  if (p === "performance") return defaultIcons[index] + "󰓅"
  return defaultIcons[index]
}

function modeLabel(device, onBattery, states, threshold) {
  var d = device || {}
  var s = states || {}
  if (!d.isPresent) return ""

  var percentage = d.isPresent ? d.percentage : 0
  if (chargeThresholdActive(d, onBattery, states, threshold)) return "Threshold"
  if (onBattery) return "On battery"
  if (d.state === s.FullyCharged || percentage >= 1) return "Fully charged"
  return "Charging"
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
    chargeHoldBand: chargeHoldBand,
    chargeHoldFloor: chargeHoldFloor,
    batteryIcon: batteryIcon,
    modeLabel: modeLabel
  }
}
