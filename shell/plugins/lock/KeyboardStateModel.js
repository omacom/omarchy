// Pure helpers for the lock screen's keyboard state badges. Kept free of QML
// so the parsing can be unit tested with node.

// Hyprland's virtual keyboards (input methods, wlr-virtual-keyboard clients)
// carry their own xkb state and would otherwise mask the physical keyboards.
function isVirtualKeyboard(keyboard) {
  return String(keyboard && keyboard.name ? keyboard.name : "").indexOf("hl-virtual-keyboard") === 0
}

// Reduces `hyprctl devices -j` to what changes the meaning of a keystroke:
// Caps Lock on any keyboard, Num Lock off on any keyboard, and the active
// keymap when more than one layout is configured. Malformed input yields the
// quiet state so a hiccup never shows a stale badge.
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
    if (!keyboard || isVirtualKeyboard(keyboard)) continue
    if (keyboard.capsLock === true) capsLockOn = true
    if (keyboard.numLock === false) numLockOn = false
    if (!layoutLabel && String(keyboard.layout || "").indexOf(",") !== -1) {
      layoutLabel = String(keyboard.active_keymap || "")
    }
  }

  return { capsLockOn: capsLockOn, numLockOn: numLockOn, layoutLabel: layoutLabel }
}

if (typeof module !== "undefined") {
  module.exports = {
    isVirtualKeyboard: isVirtualKeyboard,
    keyboardStateFromDevices: keyboardStateFromDevices
  }
}
