function batteryPercentage(device) {
  if (!device || !device.isPresent) return -1
  return Math.round(Number(device.percentage || 0) * 100)
}

// Read the battery's own state, not UPower.onBattery: a dock or charger that supplies less than
// the machine draws keeps onBattery false while the battery drains.
function isDischarging(device, dischargingState) {
  return !!(device && device.isPresent && device.state === dischargingState)
}

// Warn once at each threshold the battery falls to while discharging. warnedAt is the lowest
// threshold already warned at (0 for none). Charging does not re-arm it, so an AC flap at a
// threshold warns once; climbing back above a threshold re-arms that one and those below it.
function shouldWarnLowBattery(device, dischargingState, thresholds, warnedAt) {
  var warned = Number(warnedAt) || 0
  var level = batteryPercentage(device)
  if (level < 0) return { level: level, notify: false, warnedAt: warned }

  // The lowest threshold the level is at or under, or 0 when above them all.
  var reached = 0
  for (var i = 0; i < thresholds.length; i++)
    if (level <= thresholds[i] && (!reached || thresholds[i] < reached)) reached = thresholds[i]

  if (warned && level > warned) warned = reached

  var notify = isDischarging(device, dischargingState) && reached > 0 && (!warned || reached < warned)
  if (notify) warned = reached
  return { level: level, notify: notify, warnedAt: warned }
}

function parseActiveProfile(text) {
  // busctl --json=short prints {"type":"s","data":"balanced"}; an empty or
  // malformed reply (daemon not running) reads as no active profile.
  try {
    return String(JSON.parse(text).data || "").trim()
  } catch (e) {
    return ""
  }
}

function profileAfterRead(current, replyText, signalsAtStart, signalsNow) {
  // A change signal that arrived during the read is newer than its reply.
  return signalsAtStart === signalsNow ? parseActiveProfile(replyText) : current
}

// Re-arm the hardware charge limit after a one-time top-up to 100% once the
// battery finishes charging or external power is unplugged.
function shouldRearmChargeLimit(topUpOnce, device, onBattery, wasOnBattery, fullyChargedState) {
  if (!topUpOnce) return false
  if (wasOnBattery === false && onBattery === true) return true
  if (onBattery || !device || !device.isPresent) return false
  return device.state === fullyChargedState || batteryPercentage(device) >= 100
}

if (typeof module !== "undefined") {
  module.exports = {
    batteryPercentage: batteryPercentage,
    isDischarging: isDischarging,
    shouldWarnLowBattery: shouldWarnLowBattery,
    parseActiveProfile: parseActiveProfile,
    profileAfterRead: profileAfterRead,
    shouldRearmChargeLimit: shouldRearmChargeLimit
  }
}
