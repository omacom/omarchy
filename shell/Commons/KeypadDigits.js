// Keypad keys Qt reports as navigation when a surface's locked-modifier state
// disagrees with the compositor's (QTBUG-32687 / Hyprland keymap order). With
// NumLock on system-wide, digits still arrive as Home/End/arrows carrying
// KeypadModifier and empty text until NumLock is toggled twice.
//
// Search fields map those keys back to digits only while the compositor reports
// NumLock on — the same key shape is genuine navigation when NumLock is off.
// Leave a key alone when it already carries text (synced NumLock), lacks
// KeypadModifier, or is an Alt/Ctrl/Super chord. Codes from qt6 qnamespace.h:
//   Key_Insert 0x01000006, Key_Delete 0x01000007, Key_Clear 0x0100000b,
//   Key_Home 0x01000010, Key_End 0x01000011, Key_Left 0x01000012,
//   Key_Up 0x01000013, Key_Right 0x01000014, Key_Down 0x01000015,
//   Key_PageUp 0x01000016, Key_PageDown 0x01000017,
//   ControlModifier 0x04000000, AltModifier 0x08000000, MetaModifier 0x10000000,
//   KeypadModifier 0x20000000.
var CONTROL_MODIFIER = 0x04000000
var ALT_MODIFIER = 0x08000000
var META_MODIFIER = 0x10000000
var KEYPAD_MODIFIER = 0x20000000
var SHORTCUT_MODIFIERS = CONTROL_MODIFIER | ALT_MODIFIER | META_MODIFIER

var NAVIGATION_TO_DIGIT = {
  0x01000006: "0", // Insert
  0x01000011: "1", // End
  0x01000015: "2", // Down
  0x01000017: "3", // PageDown
  0x01000012: "4", // Left
  0x0100000b: "5", // Clear
  0x01000014: "6", // Right
  0x01000010: "7", // Home
  0x01000013: "8", // Up
  0x01000016: "9", // PageUp
  0x01000007: "."  // Delete
}

// The digit this key event should type, or null when it is not this case.
// numLockOn is the compositor's NumLock (hyprctl devices); false means genuine
// keypad navigation and must not be remapped.
function digitFor(key, modifiers, text, numLockOn) {
  if (numLockOn === false) return null
  modifiers = modifiers || 0
  if ((modifiers & SHORTCUT_MODIFIERS) !== 0) return null
  if ((modifiers & KEYPAD_MODIFIER) === 0) return null
  if (String(text === undefined || text === null ? "" : text) !== "") return null
  var digit = NAVIGATION_TO_DIGIT[key]
  return digit === undefined ? null : digit
}

// Compositor NumLock from `hyprctl -j devices` JSON (object or string). Prefers
// the main keyboard; defaults to true when the seat cannot be read, matching
// Omarchy's numlock_by_default.
function numLockFromDevices(devices) {
  var parsed = devices
  if (typeof devices === "string") {
    try { parsed = JSON.parse(devices || "{}") } catch (e) { return true }
  }
  if (!parsed || typeof parsed !== "object") return true
  var keyboards = parsed.keyboards
  if (!Array.isArray(keyboards) || keyboards.length === 0) return true
  var main = null
  for (var i = 0; i < keyboards.length; i++) {
    if (keyboards[i] && keyboards[i].main) { main = keyboards[i]; break }
  }
  var kb = main || keyboards[0]
  return kb.numLock !== false
}

if (typeof module !== "undefined") {
  module.exports = {
    digitFor: digitFor,
    numLockFromDevices: numLockFromDevices,
    KEYPAD_MODIFIER: KEYPAD_MODIFIER,
    SHORTCUT_MODIFIERS: SHORTCUT_MODIFIERS,
    NAVIGATION_TO_DIGIT: NAVIGATION_TO_DIGIT
  }
}
