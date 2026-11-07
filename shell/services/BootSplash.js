// What Omarchy's Plymouth theme (default/plymouth/omarchy.script) draws, so the
// login cover can carry on from its last frame.

// The theme's fake_progress_limit and fake_progress_duration: after the disk
// password, the bar eases out towards 70% over 15 s.
var progressLimit = 0.7
var progressDuration = 15

function progressAt(elapsed) {
  var ratio = Math.min(Math.max(Number(elapsed) || 0, 0) / progressDuration, 1)
  return progressLimit * (1 - (1 - ratio) * (1 - ratio))
}

// Plymouth's device scale for a display with a native driver: 2 above 1.625
// times the target density, as Mutter decides, and 1 when the panel's size is
// unknown or is really an aspect ratio.
function deviceScale(width, height, widthMm, heightMm) {
  if ((widthMm === 160 && (heightMm === 90 || heightMm === 100)) || (widthMm === 16 && (heightMm === 9 || heightMm === 10)))
    return 1
  if (!(widthMm > 0) || !(heightMm > 0)) return 1
  var inches = Math.sqrt(widthMm * widthMm + heightMm * heightMm) / 25.4
  var dpi = Math.sqrt(width * width + height * height) / inches
  return dpi / (inches >= 20 ? 110 : 135) > 1.625 ? 2 : 1
}

// How many of the shell's logical pixels one of Plymouth's image pixels covers
// on a Hyprland monitor, from its `hyprctl monitors` entry; 0 while unknown.
function pixelUnit(monitor) {
  if (!monitor || !(monitor.width > 0) || !(monitor.height > 0) || !(monitor.scale > 0)) return 0
  return deviceScale(monitor.width, monitor.height, monitor.physicalWidth, monitor.physicalHeight) / monitor.scale
}

if (typeof module !== "undefined") {
  module.exports = {
    progressLimit: progressLimit,
    progressDuration: progressDuration,
    progressAt: progressAt,
    deviceScale: deviceScale,
    pixelUnit: pixelUnit
  }
}
