// Pure helpers for the lock screen's keyboard state badges. Kept free of QML
// so the parsing can be unit tested with node.

// Hyprland reports more than keyboards as keyboards: virtual ones (input
// methods, wlr-virtual-keyboard clients) and the ACPI buttons each carry their
// own xkb state, which nobody types through and no key on the real keyboard
// changes. The same list as the bar's KeyboardLayoutModel.js, which a test
// holds to.
var UNTYPED_KEYBOARDS = /^(hl-virtual-keyboard|power-button|sleep-button|lid-switch|video-bus)/

function isTypedKeyboard(keyboard) {
  return !UNTYPED_KEYBOARDS.test(String(keyboard && keyboard.name ? keyboard.name : ""))
}

// Reduces `hyprctl devices -j` to what changes the meaning of a keystroke:
// Caps Lock on any keyboard, Num Lock off on any keyboard, and the active
// keymap of a keyboard that has moved off its first layout. The first layout
// is the one the lock resets to, so it is never named. Malformed input yields
// the quiet state so a hiccup never shows a stale badge.
function keyboardStateFromDevices(text) {
  var quiet = { capsLockOn: false, numLockOn: true, layoutLabel: "" }
  var devices
  try {
    devices = JSON.parse(String(text || ""))
  } catch (error) {
    return quiet
  }

  var keyboards = devices && Array.isArray(devices.keyboards) ? devices.keyboards : []
  var capsLockOn = false
  var numLockOn = true
  var layoutLabel = ""

  for (var i = 0; i < keyboards.length; i++) {
    var keyboard = keyboards[i]
    if (!keyboard || !isTypedKeyboard(keyboard)) continue
    if (keyboard.capsLock === true) capsLockOn = true
    if (keyboard.numLock === false) numLockOn = false
    if (!layoutLabel && keyboard.active_layout_index > 0) {
      layoutLabel = String(keyboard.active_keymap || "")
    }
  }

  return { capsLockOn: capsLockOn, numLockOn: numLockOn, layoutLabel: layoutLabel }
}

if (typeof module !== "undefined") {
  module.exports = {
    isTypedKeyboard: isTypedKeyboard,
    keyboardStateFromDevices: keyboardStateFromDevices
  }
}
