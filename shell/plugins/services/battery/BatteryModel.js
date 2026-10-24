// omarchy-battery-status --shell adds a source line when it has read the
// kernel's charge registers past a latched UPower energy-full (see the script);
// its percentage then stands in for the display device's. Any other output,
// or none, leaves UPower's figure: -1 here.
function kernelPercentage(raw) {
  var lines = String(raw || "").split("\n")
  var source = ""
  var percentage = ""
  for (var i = 0; i < lines.length; i++) {
    var idx = lines[i].indexOf("\t")
    if (idx <= 0) continue
    var key = lines[i].substring(0, idx)
    var value = lines[i].substring(idx + 1).trim()
    if (key === "source") source = value
    else if (key === "percentage") percentage = value
  }
  if (source !== "kernel") return -1
  var level = parseInt(percentage, 10)
  return isNaN(level) ? -1 : Math.max(0, Math.min(100, level))
}

// What a finished status-script run leaves. A run that printed nothing found no
// battery for a moment (around AC plug events) and is no answer: the last
// level stands and the script runs again on UPower's next change.
function kernelReading(raw, lastLevel) {
  if (String(raw || "").trim() === "") return { level: lastLevel, retry: true }
  return { level: kernelPercentage(raw), retry: false }
}

// Whether UPower's figures have moved enough since the status script last
// ran to be worth running it again. A latch takes energy-full at least twice
// as far, in either direction, while a sound pack's full charge only drifts
// (Apple Silicon reports it anew on every refresh). While a latch holds, the
// kernel percentage is read again once UPower's own has moved a tenth of a
// point, about one real point at the latch ratios seen. Capacities are Wh,
// percentages fractions; a capacity below zero means no run yet.
function shouldRereadKernel(lastCapacity, capacity, lastPercentage, percentage, latched) {
  if (lastCapacity < 0) return true
  var low = Math.min(lastCapacity, capacity)
  var high = Math.max(lastCapacity, capacity)
  if (high > low * 2) return true
  return !!latched && Math.abs(Number(percentage) - Number(lastPercentage)) >= 0.001
}

function batteryPercentage(device, kernelLevel) {
  if (!device || !device.isPresent) return -1
  if (typeof kernelLevel === "number" && kernelLevel >= 0) return kernelLevel
  return Math.round(Number(device.percentage || 0) * 100)
}

function isDischarging(device, onBattery, dischargingState) {
  return !!(device && device.isPresent && onBattery && device.state === dischargingState)
}

function shouldWarnLowBattery(device, onBattery, dischargingState, threshold, alreadyNotified, kernelLevel) {
  var level = batteryPercentage(device, kernelLevel)
  if (level < 0) return { level: level, notify: false, notifiedLowBattery: false }

  var low = isDischarging(device, onBattery, dischargingState) && level <= threshold
  return {
    level: level,
    notify: low && !alreadyNotified,
    notifiedLowBattery: low
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
    kernelPercentage: kernelPercentage,
    kernelReading: kernelReading,
    shouldRereadKernel: shouldRereadKernel,
    batteryPercentage: batteryPercentage,
    isDischarging: isDischarging,
    shouldWarnLowBattery: shouldWarnLowBattery,
    parseActiveProfile: parseActiveProfile,
    profileAfterRead: profileAfterRead,
    isPowerSaverOnBattery: isPowerSaverOnBattery
  }
}
