// Qt never reads the compositor's NumLock state at startup (QTBUG-32687), so
// keypad digits reach the password field as cursor keys carrying no text.
// The decimal key is left alone: it arrives as Delete on every layout but
// types "." on some and "," on others (KP_Separator), which the event alone
// cannot tell apart.
// Values are Qt::Key_* from qnamespace.h; QML enums are not visible here.
function keypadDigit(key) {
  switch (key) {
    case 0x01000006: return "0" // Key_Insert
    case 0x01000011: return "1" // Key_End
    case 0x01000015: return "2" // Key_Down
    case 0x01000017: return "3" // Key_PageDown
    case 0x01000012: return "4" // Key_Left
    case 0x0100000b: return "5" // Key_Clear
    case 0x01000014: return "6" // Key_Right
    case 0x01000010: return "7" // Key_Home
    case 0x01000013: return "8" // Key_Up
    case 0x01000016: return "9" // Key_PageUp
  }
  return ""
}

if (typeof module !== "undefined") {
  module.exports = {
    keypadDigit: keypadDigit
  }
}
