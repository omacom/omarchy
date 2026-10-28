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

// What the password field asks for. polkit names the identity it is
// authenticating: on a child install its admin rule names root, whose
// password is the parent password, so say that; another account's password
// is named outright; the session user's own stays the plain prompt. An
// unknown identity (a Quickshell without selectedIdentity) keeps the plain
// prompt too. tr(key, english) translates, defaulting to the English text.
function passwordPlaceholder(identityName, sessionUser, childInstall, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var identity = String(identityName || "")
  if (!identity) return t("polkit.enterPassword", "Enter password")
  if (childInstall && identity === "root") return t("polkit.parentPassword", "Parent password")
  if (identity !== String(sessionUser || "")) return t("polkit.passwordFor", "Password for %1").replace("%1", identity)
  return t("polkit.enterPassword", "Enter password")
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
    passwordPlaceholder: passwordPlaceholder,
    authorizationLabel: authorizationLabel
  }
}
