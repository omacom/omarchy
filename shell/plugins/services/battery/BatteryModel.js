function batteryPercentage(device) {
  if (!device || !device.isPresent) return -1
  return Math.round(Number(device.percentage || 0) * 100)
}

function isDischarging(device, onBattery, dischargingState) {
  return !!(device && device.isPresent && onBattery && device.state === dischargingState)
}

function shouldWarnLowBattery(device, onBattery, dischargingState, threshold, alreadyNotified) {
  var level = batteryPercentage(device)
  if (level < 0) {
    return { level: level, notify: false, notifiedLowBattery: !!alreadyNotified }
  }

  // True only while discharging at/under the threshold. AC-online flaps must not
  // clear the latch: onBattery false makes low false, and the old latch reset on
  // that alone re-fired a critical toast on every flap (~3s) until the machine died.
  var low = isDischarging(device, onBattery, dischargingState) && level <= threshold
  // Clear only after a real recovery above the threshold, not on transient AC state.
  var recovered = level > threshold
  var notifiedLowBattery = recovered ? false : !!(alreadyNotified || low)

  return {
    level: level,
    notify: low && !alreadyNotified,
    notifiedLowBattery: notifiedLowBattery
  }
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

function isPowerSaverOnBattery(onBattery, profile) {
  return !!onBattery && profile === "power-saver"
}

if (typeof module !== "undefined") {
  module.exports = {
    batteryPercentage: batteryPercentage,
    isDischarging: isDischarging,
    shouldWarnLowBattery: shouldWarnLowBattery,
    parseActiveProfile: parseActiveProfile,
    profileAfterRead: profileAfterRead,
    isPowerSaverOnBattery: isPowerSaverOnBattery
  }
}
