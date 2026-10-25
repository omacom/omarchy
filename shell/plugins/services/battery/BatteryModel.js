function batteryPercentage(device) {
  if (!device || !device.isPresent) return -1
  return Math.round(Number(device.percentage || 0) * 100)
}

function isDischarging(device, onBattery, dischargingState) {
  return !!(device && device.isPresent && onBattery && device.state === dischargingState)
}

function shouldWarnLowBattery(device, onBattery, dischargingState, threshold, alreadyNotified) {
  var level = batteryPercentage(device)
  if (level < 0) return { level: level, notify: false, recovered: !onBattery, notifiedLowBattery: false }

  var low = isDischarging(device, onBattery, dischargingState) && level <= threshold
  return {
    level: level,
    notify: low && !alreadyNotified,
    // On AC or above the threshold, so a device state UPower hasn't settled doesn't count
    recovered: !onBattery || level > threshold,
    notifiedLowBattery: low
  }
}

// The toast omarchy-battery-low sends, by sender and icon rather than its translated title
var WARNING_APP = "omarchy-action"
var WARNING_ICON = "battery-caution"

function isLowBatteryWarning(row) {
  return !!row && row.app === WARNING_APP && row.appIcon === WARNING_ICON
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

if (typeof module !== "undefined") {
  module.exports = {
    batteryPercentage: batteryPercentage,
    isDischarging: isDischarging,
    shouldWarnLowBattery: shouldWarnLowBattery,
    isLowBatteryWarning: isLowBatteryWarning,
    WARNING_APP: WARNING_APP,
    WARNING_ICON: WARNING_ICON,
    parseActiveProfile: parseActiveProfile,
    profileAfterRead: profileAfterRead
  }
}
