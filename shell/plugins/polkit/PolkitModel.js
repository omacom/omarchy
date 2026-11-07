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

function messageLooksSecurityKey(text, cues) {
  // pam_u2f's default cue is "Please touch the device."; cue_prompt= can
  // change it. A configured cue is matched exactly, before the usual words
  // for a FIDO key.
  var trimmed = String(text || "").replace(/^\s+|\s+$/g, "").toLowerCase()
  var configured = cues || []
  for (var i = 0; trimmed && i < configured.length; i++) {
    if (String(configured[i]).replace(/^\s+|\s+$/g, "").toLowerCase() === trimmed) return true
  }
  if (promptLooksFingerprint(text)) return false
  var s = String(text || "").toLowerCase()
  return s.indexOf("touch") !== -1 || s.indexOf("security key") !== -1
    || s.indexOf("u2f") !== -1 || s.indexOf("fido") !== -1
}

function passiveAuthModules(raw) {
  // The auth modules that wait on hardware instead of asking for a response,
  // in stack order: "fingerprint" (pam_fprintd) and "security-key" (pam_u2f).
  var out = []
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].replace(/^\s+|\s+$/g, "")
    if (!line || line.charAt(0) === "#") continue
    if (!line.match(/^auth\s+/)) continue
    var kind = line.indexOf("pam_fprintd.so") !== -1 ? "fingerprint"
      : line.indexOf("pam_u2f.so") !== -1 ? "security-key" : ""
    if (kind && out.indexOf(kind) === -1) out.push(kind)
  }
  return out
}

function securityKeyConfiguredFromPamConfig(raw) {
  return passiveAuthModules(raw).indexOf("security-key") !== -1
}

function pamTokens(line) {
  // Split a pam.d line as Linux-PAM does: "[...]" is one token with only \]
  // escaped, only space, tab and newline separate, and '#' ends the line.
  var s = String(line || "").split("#")[0]
  var out = []
  var i = 0
  while (i < s.length) {
    while (i < s.length && /[ \t\n]/.test(s.charAt(i))) i++
    if (i >= s.length) break
    var token = ""
    if (s.charAt(i) === "[") {
      for (i++; i < s.length && s.charAt(i) !== "]"; i++) {
        if (s.charAt(i) === "\\" && s.charAt(i + 1) === "]") i++
        token += s.charAt(i)
      }
      i++
    } else {
      for (; i < s.length && !/[ \t\n]/.test(s.charAt(i)); i++) token += s.charAt(i)
    }
    out.push(token)
  }
  return out
}

function securityKeyCuesFromPamConfig(raw) {
  // The cue_prompt= arguments of pam_u2f, bare (cue_prompt=Tap) or in
  // brackets ([cue_prompt=Tap the token]).
  var out = []
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var tokens = pamTokens(lines[i])
    if (tokens[0] !== "auth" || !/(^|\/)pam_u2f\.so$/.test(tokens[2] || "")) continue
    for (var j = 3; j < tokens.length; j++) {
      if (tokens[j].indexOf("cue_prompt=") !== 0) continue
      var cue = tokens[j].slice("cue_prompt=".length)
      if (cue && out.indexOf(cue) === -1) out.push(cue)
    }
  }
  return out
}

// Which method owns the dialog while PAM waits on hardware. These live here
// rather than in QML bindings so polkit-test.sh can check the property that matters:
// a password prompt from PAM (`responseRequired`) is never hidden. `s` holds
// the dialog's state: dialogVisible, responseRequired, submitted, errorFlash,
// supplementary (PAM's info message), securityKeyConfigured, securityKeyFirst,
// securityKeyCues (pam_u2f's cue_prompt values), fingerprintConfigured and
// laptopClosed.
function waitingOnHardware(s) {
  return !!s.dialogVisible && !s.responseRequired && !s.submitted && !s.errorFlash
}

// pam_u2f blocks until the key is touched and asks for nothing — at most an
// info message ("Please touch the device." with `cue`). A cue tells us for
// sure; without one, go by the PAM stack (u2f first, or the fingerprint
// reader out of the way).
function securityKeyMode(s) {
  if (!waitingOnHardware(s)) return false
  if (messageLooksSecurityKey(s.supplementary, s.securityKeyCues)) return true
  if (!s.securityKeyConfigured || promptLooksFingerprint(s.supplementary)) return false
  // pam_u2f's cue is never translated but pam_fprintd's messages are, so any
  // other message while the reader is reachable is the reader's.
  if (s.fingerprintConfigured && !s.laptopClosed) return !!s.securityKeyFirst && !s.supplementary
  return true
}

// Whether an answer is still being checked after PAM's flow changed. `s`
// holds submitted, responseRequired, supplementary, securityKeyCues and
// messageChanged (PAM sent a new info message). PAM asking again ends the check; so does a new
// touch cue, since PAM then took the answer (pam_u2f's PIN with
// `pinverification`) and waits on the key instead.
function stillSubmitted(s) {
  if (!s.submitted || s.responseRequired) return false
  return !(s.messageChanged && messageLooksSecurityKey(s.supplementary, s.securityKeyCues))
}

// Fingerprint owns the dialog while PAM waits on the reader (lid open, sensor
// enrolled), unless it's the security key being waited on.
function fingerprintMode(s) {
  return !!s.fingerprintConfigured && !s.laptopClosed && waitingOnHardware(s) && !securityKeyMode(s)
}

function passwordPlaceholder(prompt, tr) {
  // PAM's own prompt when it asks for a PIN instead of the password
  // (pam_u2f with pinverification asks "Please enter the PIN:").
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var text = String(prompt || "").replace(/^\s+|[\s:]+$/g, "")
  return /\bPIN\b/.test(text) ? text : t("polkit.enterPassword", "Enter password")
}

function authorizationLabel(message, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var text = String(message || "")
  var match = text.match(/^Authentication is (?:needed|required) to run [`']([^`']+)[`'] as /i)
  return match ? t("polkit.authorizeRunning", "Authorize running '%1'").replace("%1", match[1]) : text
}

if (typeof module !== "undefined") {
  module.exports = {
    promptLooksFingerprint: promptLooksFingerprint,
    fingerprintConfiguredFromPamConfig: fingerprintConfiguredFromPamConfig,
    messageLooksSecurityKey: messageLooksSecurityKey,
    waitingOnHardware: waitingOnHardware,
    securityKeyMode: securityKeyMode,
    stillSubmitted: stillSubmitted,
    fingerprintMode: fingerprintMode,
    passiveAuthModules: passiveAuthModules,
    securityKeyConfiguredFromPamConfig: securityKeyConfiguredFromPamConfig,
    securityKeyCuesFromPamConfig: securityKeyCuesFromPamConfig,
    passwordPlaceholder: passwordPlaceholder,
    authorizationLabel: authorizationLabel
  }
}
