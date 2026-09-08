function batteryPercentage(device) {
  if (!device || !device.isPresent) return -1
  return Math.round(Number(device.percentage || 0) * 100)
}

function isDischarging(device, onBattery, dischargingState) {
  return !!(device && device.isPresent && onBattery && device.state === dischargingState)
}

function shouldWarnLowBattery(device, onBattery, dischargingState, threshold, alreadyNotified, firstCheck) {
  var level = batteryPercentage(device)
  var low = level >= 0 && isDischarging(device, onBattery, dischargingState) && level <= threshold

  return {
    level: level,
    notify: low && !alreadyNotified,
    // A full shell restart forgets alreadyNotified but restores the critical
    // toast from disk, so the first check clears too rather than trusting the
    // flag alone.
    clear: !low && (!!alreadyNotified || !!firstCheck),
    notifiedLowBattery: low
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    batteryPercentage: batteryPercentage,
    isDischarging: isDischarging,
    shouldWarnLowBattery: shouldWarnLowBattery
  }
}
