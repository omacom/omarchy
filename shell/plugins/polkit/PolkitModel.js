function promptLooksFingerprint(text) {
  var s = String(text || "").toLowerCase()
  return s.indexOf("finger") !== -1 || s.indexOf("fprint") !== -1 || s.indexOf("swipe") !== -1
}

function fingerprintConfiguredFromPamConfig(raw) {
  // Fingerprint is available whenever pam_fprintd appears anywhere in the auth
  // stack — it need not be the first module. A clamshell gate (pam_exec) may
  // legitimately precede it to skip fingerprint while the lid is closed.
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].replace(/^\s+|\s+$/g, "")
    if (!line || line.charAt(0) === "#") continue
    if (!line.match(/^auth\s+/)) continue
    if (line.indexOf("pam_fprintd.so") !== -1) return true
  }
  return false
}

function authorizationLabel(message) {
  var text = String(message || "")
  var match = text.match(/^Authentication is (?:needed|required) to run [`']([^`']+)[`'] as /i)
  return match ? "Authorize running '" + match[1] + "'" : text
}

// Qt never reads system NumLock at startup (QTBUG-32687), so keypad digits
// arrive as navigation keys. Values are Qt::Key_* from qnamespace.h.
function keypadDigit(k) {
  switch (k) {
    case 0x01000006: return "0" // Key_Insert
    case 0x01000011: return "1" // Key_End
    case 0x01000015: return "2" // Key_Down
    case 0x01000017: return "3" // Key_PageDown
    case 0x01000012: return "4" // Key_Left
    case 0x0100000b: return "5" // Key_Clear
    case 0x00000035: return "5" // Key_5 (some layouts)
    case 0x01000014: return "6" // Key_Right
    case 0x01000010: return "7" // Key_Home
    case 0x01000013: return "8" // Key_Up
    case 0x01000016: return "9" // Key_PageUp
    case 0x01000007: return "." // Key_Delete
  }
  return ""
}

if (typeof module !== "undefined") {
  module.exports = {
    promptLooksFingerprint: promptLooksFingerprint,
    fingerprintConfiguredFromPamConfig: fingerprintConfiguredFromPamConfig,
    authorizationLabel: authorizationLabel,
    keypadDigit: keypadDigit
  }
}
