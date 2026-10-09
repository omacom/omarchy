function batteryPercentage(device) {
  if (!device || !device.isPresent) return -1
  var raw = Math.max(0, Math.min(100, Number(device.percentage || 0) * 100))
  return raw > 0 ? Math.max(1, Math.floor((raw - 4) * 100 / 96 + 0.5 + 1e-9)) : 0
}

function isDischarging(device, onBattery, dischargingState) {
  return !!(device && device.isPresent && onBattery && device.state === dischargingState)
}

function shouldWarnLowBattery(device, onBattery, dischargingState, threshold, alreadyNotified) {
  // Preserve the battery-low hook's raw percentage contract. The notification
  // command maps its display text separately.
  var level = device && device.isPresent ? Math.round(Number(device.percentage || 0) * 100) : -1
  if (level < 0) return { level: level, notify: false, notifiedLowBattery: false }

  var low = isDischarging(device, onBattery, dischargingState) && Number(device.percentage) * 100 <= threshold
  return {
    level: level,
    // At the raw shutdown threshold the guard owns the countdown toast.
    notify: low && !alreadyNotified,
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
