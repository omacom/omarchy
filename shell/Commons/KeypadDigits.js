// Keypad keys Qt reports as navigation when a surface's locked-modifier state
// disagrees with the compositor's (QTBUG-32687 / Hyprland keymap order). With
// NumLock on system-wide, digits still arrive as Home/End/arrows carrying
// KeypadModifier and empty text until NumLock is toggled twice.
//
// Search and password fields map those keys back to digits. Leave a key alone
// when it already carries text (synced NumLock) or lacks KeypadModifier
// (genuine navigation). Codes from qt6 QtCore/qnamespace.h:
//   Key_Insert 0x01000006, Key_Delete 0x01000007, Key_Clear 0x0100000b,
//   Key_Home 0x01000010, Key_End 0x01000011, Key_Left 0x01000012,
//   Key_Up 0x01000013, Key_Right 0x01000014, Key_Down 0x01000015,
//   Key_PageUp 0x01000016, Key_PageDown 0x01000017, KeypadModifier 0x20000000.
var KEYPAD_MODIFIER = 0x20000000

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
function digitFor(key, modifiers, text) {
  if (((modifiers || 0) & KEYPAD_MODIFIER) === 0) return null
  if (String(text === undefined || text === null ? "" : text) !== "") return null
  var digit = NAVIGATION_TO_DIGIT[key]
  return digit === undefined ? null : digit
}

if (typeof module !== "undefined") {
  module.exports = {
    digitFor: digitFor,
    KEYPAD_MODIFIER: KEYPAD_MODIFIER,
    NAVIGATION_TO_DIGIT: NAVIGATION_TO_DIGIT
  }
}
