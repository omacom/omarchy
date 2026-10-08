function batteryPercentage(device) {
  if (!device || !device.isPresent) return -1
  return Math.round(Number(device.percentage || 0) * 100)
}

function isDischarging(device, onBattery, dischargingState) {
  return !!(device && device.isPresent && onBattery && device.state === dischargingState)
}

function shouldWarnLowBattery(device, onBattery, dischargingState, threshold, alreadyNotified) {
  var level = batteryPercentage(device)
  if (level < 0) return { level: level, notify: false, notifiedLowBattery: false }

  var low = isDischarging(device, onBattery, dischargingState) && level <= threshold
  return {
    level: level,
    notify: low && !alreadyNotified,
    notifiedLowBattery: low
  }
}

function lidAwakeBatteryFloor(value, fallback) {
  var parsed = Number(value)
  if (!Number.isFinite(parsed)) return fallback

  parsed = Math.round(parsed)
  return parsed >= 0 && parsed <= 100 ? parsed : fallback
}

function hasReachedLidAwakeBatteryFloor(device, onBattery, dischargingState, floor) {
  var level = batteryPercentage(device)
  return level >= 0 && floor > 0 && isDischarging(device, onBattery, dischargingState) && level <= floor
}

if (typeof module !== "undefined") {
  module.exports = {
    batteryPercentage: batteryPercentage,
    isDischarging: isDischarging,
    shouldWarnLowBattery: shouldWarnLowBattery,
    lidAwakeBatteryFloor: lidAwakeBatteryFloor,
    hasReachedLidAwakeBatteryFloor: hasReachedLidAwakeBatteryFloor
  }
}
