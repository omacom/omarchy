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

// The cue is emitted after pam_u2f finds a matching attached key. Never probe
// the device from the UI: a concurrent FIDO client can disrupt authentication.
function securityKeyCuesFromPamConfig(raw) {
  var cues = []
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim()
    var match = line.match(/^auth\s+sufficient\s+pam_u2f\.so(?:\s+(.*))?$/)
    if (!match) continue
    var options = (match[1] || "").match(/\[[^\]]*\]|\S+/g) || []
    if (options.indexOf("cue") === -1 || options.indexOf("nodetect") !== -1) continue
    var cue = "Please touch the FIDO authenticator."
    for (var j = 0; j < options.length; j++) {
      var custom = options[j].match(/^\[?cue_prompt=(.*?)\]?$/)
      if (custom) cue = custom[1]
    }
    cues.push({ message: cue, biometric: options.indexOf("userverification=1") !== -1 })
  }
  return cues
}

function securityKeyCue(message, cues) {
  for (var i = 0; i < cues.length; i++) {
    if (message !== cues[i].message) continue
    // Counts are opt-in, explicitly supplied by the PAM administrator. They
    // describe prompt attempts, never the authenticator's hardware lockout.
    var count = message.match(/\(([1-9][0-9]*) prompt tr(?:y|ies) left\)$/)
    return { biometric: cues[i].biometric, remaining: count ? Number(count[1]) : 0 }
  }
  return null
}

function securityKeyProgress(previous, cue) {
  return {
    active: true,
    biometric: cue.biometric,
    remaining: cue.remaining,
    failed: previous.active && previous.remaining > 0 && cue.remaining > 0 && cue.remaining < previous.remaining
  }
}

function authorizationLabel(message) {
  var text = String(message || "")
  var match = text.match(/^Authentication is (?:needed|required) to run [`']([^`']+)[`'] as /i)
  return match ? "Authorize running '" + match[1] + "'" : text
}

if (typeof module !== "undefined") {
  module.exports = {
    promptLooksFingerprint: promptLooksFingerprint,
    fingerprintConfiguredFromPamConfig: fingerprintConfiguredFromPamConfig,
    securityKeyCuesFromPamConfig: securityKeyCuesFromPamConfig,
    securityKeyCue: securityKeyCue,
    securityKeyProgress: securityKeyProgress,
    authorizationLabel: authorizationLabel
  }
}
