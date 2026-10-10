function batteryPercentage(device) {
  if (!device || !device.isPresent) return -1
  return Math.round(Number(device.percentage || 0) * 100)
}

function isDischarging(device, onBattery, dischargingState) {
  return !!(device && device.isPresent && onBattery && device.state === dischargingState)
}

function shouldWarnLowBattery(device, onBattery, dischargingState, threshold, alreadyNotified, afterRestart) {
  var level = batteryPercentage(device)
  if (level < 0) return { level: level, notify: false, dismiss: !!alreadyNotified, notifiedLowBattery: false }

  var low = isDischarging(device, onBattery, dischargingState) && level <= threshold
  return {
    level: level,
    notify: low && !alreadyNotified,
    // After a restart the critical toast is restored from disk but the flag is not
    dismiss: !low && !!(alreadyNotified || afterRestart),
    notifiedLowBattery: low
  }
}

// A check without a known battery level doesn't use up the restart window
function remainingRestartChecks(remaining, level) {
  return level < 0 ? remaining : Math.max(0, remaining - 1)
}

if (typeof module !== "undefined") {
  module.exports = {
    batteryPercentage: batteryPercentage,
    isDischarging: isDischarging,
    shouldWarnLowBattery: shouldWarnLowBattery,
    remainingRestartChecks: remainingRestartChecks
  }
}
