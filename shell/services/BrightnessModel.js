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
    brightnessKeyTarget: brightnessKeyTarget
  }
}
