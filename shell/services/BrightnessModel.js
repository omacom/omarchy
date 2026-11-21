// A sysfs backlight directory name. Refused unless it is one path segment, so
// it can be joined onto /sys/class/backlight without leaving that directory.
function backlightDeviceName(name) {
  var device = String(name == null ? "" : name).trim()
  if (!/^[A-Za-z0-9_.-]+$/.test(device)) return ""
  if (device === "." || device === "..") return ""
  return device
}

function backlightSysfsPath(device) {
  var name = backlightDeviceName(device)
  if (!name) return ""
  return "/sys/class/backlight/" + name
}

// The integer in a sysfs brightness file. Empty text is a failed read, not
// zero: Number("") is 0, and a step would then treat the panel as off.
function backlightReading(text) {
  var trimmed = String(text == null ? "" : text).trim()
  if (!/^[0-9]+$/.test(trimmed)) return NaN
  return parseInt(trimmed, 10)
}

// omarchy-brightness-display's steps for the brightness keys: 1% at or below
// 5%, otherwise 5%, kept between 1% and 100%.
function brightnessKeyTarget(action, current) {
  if (action === "raise") return Math.min(current < 5 ? current + 1 : current + 5, 100)
  return Math.max(current <= 5 ? current - 1 : current - 5, 1)
}

if (typeof module !== "undefined") {
  module.exports = {
    backlightDeviceName: backlightDeviceName,
    backlightSysfsPath: backlightSysfsPath,
    backlightReading: backlightReading,
    brightnessKeyTarget: brightnessKeyTarget
  }
}
