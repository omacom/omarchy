// The keypad keys Qt reports as navigation when a surface's locked-modifier state disagrees with the
// compositor's. The polkit overlay is a layer surface with exclusive keyboard focus, and its keypad
// arrives as Home/End/arrows carrying KeypadModifier with empty text while the compositor reports
// NumLock on — so keypad digits type nothing until NumLock is toggled twice (#15424).
//
// A hidden password field has no use for navigation, so each of these types its digit instead.
// The codes are Qt's own, read from qt6 QtCore/qnamespace.h (6.12.0):
//   Key_Insert 0x01000006, Key_Delete 0x01000007, Key_Clear 0x0100000b, Key_Home 0x01000010,
//   Key_End 0x01000011, Key_Left 0x01000012, Key_Up 0x01000013, Key_Right 0x01000014,
//   Key_Down 0x01000015, Key_PageUp 0x01000016, Key_PageDown 0x01000017, KeypadModifier 0x20000000.
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

// The digit this key event should type, or null when it is not this case. A field that is not
// editable, a key without the keypad modifier, and a key that carries text of its own are all left
// to Qt.
function digitFor(key, modifiers, text, readOnly) {
  if (readOnly) return null
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
