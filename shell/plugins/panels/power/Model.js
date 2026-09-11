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

// The end threshold out of the `threshold` field omarchy-battery-status emits,
// which is "80%" for a single value and "75-80%" for a start-end pair. Absent
// when the battery exposes no charge-control interface, which is a meaningful
// answer rather than a missing one, so it comes back as NaN and not 0.
function parseThresholdEnd(text) {
  var digits = String(text || "").match(/\d+/g)
  if (!digits || digits.length === 0) return NaN
  return Number(digits[digits.length - 1])
}

// Whether a charge limit is actually holding the battery back.
//
// This has to be answered from the limit itself. UPower exposes no
// charge-threshold property at all, so the panel used to infer one from the
// state of charge, and inference cannot tell a real limit apart from the
// several other reasons a battery sits on AC without charging. It got three
// distinct cases wrong, and none of them are edge cases:
//
//   A cap on a nearly full battery read as no cap. Lowering a cap stops the
//   charge but does not discharge the pack, so the state is FullyCharged at
//   99% and the old `fraction >= 0.99` line returned false while the firmware
//   was holding at 60.
//
//   A dead battery read as a cap. `Not charging` (PendingCharge) only means AC
//   is present and the EC is not charging, for any reason. Returning true on it
//   unconditionally reported "Holding at 75-80%" for a pack at 0% that the EC
//   had given up on.
//
//   Hardware with no charge control at all read as a cap. Apple's SMC leaves a
//   battery alone until it falls to roughly 93%, which arrives as FullyCharged
//   below 0.99 and rendered a charge-limit row on a machine that has no
//   charge_control_end_threshold to show.
function chargeThresholdActive(device, onBattery, thresholdEnd) {
  var d = device || {}
  if (!(d && d.isPresent && !onBattery)) return false

  // No charge-control interface, or a limit of 100, which is the sysfs way of
  // saying charge to full. Neither is a limit, whatever the charge level looks
  // like.
  var limit = Number(thresholdEnd)
  if (!isFinite(limit) || limit <= 0 || limit >= 100) return false

  return Math.round(batteryFraction(d) * 100) >= limit
}

function batteryIcon(device, onBattery, states, thresholdEnd) {
  var d = device || {}
  if (!d.isPresent) return ""

  var chargingIcons = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
  var defaultIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  var index = Math.max(0, Math.min(9, Math.floor(d.percentage * 10)))
  var threshold = chargeThresholdActive(d, onBattery, thresholdEnd)

  if (threshold) return defaultIcons[index]
  if (d.state === states.FullyCharged) return "󰂅"
  if (!onBattery) return chargingIcons[index]
  return defaultIcons[index]
}

function modeLabel(device, onBattery, states, thresholdEnd) {
  var d = device || {}
  if (!d.isPresent) return ""

  var percentage = d.isPresent ? d.percentage : 0
  if (chargeThresholdActive(d, onBattery, thresholdEnd)) return "Threshold"
  if (onBattery) return "On battery"
  if (!onBattery && percentage >= 1) return "Fully charged"
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
    parseThresholdEnd: parseThresholdEnd,
    chargeThresholdActive: chargeThresholdActive,
    batteryIcon: batteryIcon,
    modeLabel: modeLabel
  }
}
