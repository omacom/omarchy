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

// pkexec joins the command line without escaping it, so its arguments (and the
// target user's name) can carry line breaks that push the rest of the command
// out of view, or bidi controls that reorder it on screen. Show those
// characters as escapes rather than letting them shape what the prompt shows.
function visibleText(text) {
  return String(text).replace(/[\u0000-\u001f\u007f-\u009f\u061c\u200b-\u200f\u2028-\u202e\u2060-\u2069\ufeff]/g, function(c) {
    if (c === "\n") return "\\n"
    if (c === "\t") return "\\t"
    if (c === "\r") return "\\r"
    return "\\u" + ("000" + c.charCodeAt(0).toString(16)).slice(-4)
  })
}

function authorizationRequest(message) {
  var text = String(message || "")
  // pkexec's message: "Authentication is needed to run `CMD' as the super user"
  // (or "... as user NAME"). CMD is pkexec's cmdline_short, which keeps any
  // quotes the command itself contains, so anchor on the fixed tail instead of
  // stopping at the next quote.
  var match = text.match(/^Authentication is (?:needed|required) to run [`']([\s\S]+)[`'] as (?:(the super user)|user ([\s\S]+))$/i)
  if (!match) return { title: text, program: "", args: "", command: "" }

  var command = match[1].replace(/^\s+|\s+$/g, "").match(/^(\S+)\s*([\s\S]*)$/)
  if (!command) return { title: text, program: "", args: "", command: "" }

  // command keeps the message's text exactly, unescaped and with empty and
  // space-padded arguments, for matching against the waiting pkexec.
  return {
    title: match[2] ? "Run as root" : "Run as " + visibleText(match[3]),
    program: visibleText(command[1]),
    args: visibleText(command[2]),
    command: match[1]
  }
}

// omarchy-polkit-caller's JSON: who started pkexec, and the full command it was
// given, shell-quoted and already capped.
function callerFromOutput(exitCode, output) {
  var info = null
  if (exitCode === 0) {
    try {
      info = JSON.parse(String(output || ""))
    } catch (e) {}
  }
  info = info || {}
  return {
    requestedBy: typeof info.requestedBy === "string" ? info.requestedBy : "",
    command: typeof info.command === "string" ? info.command : "",
    shortened: info.shortened === true
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    promptLooksFingerprint: promptLooksFingerprint,
    fingerprintConfiguredFromPamConfig: fingerprintConfiguredFromPamConfig,
    authorizationRequest: authorizationRequest,
    callerFromOutput: callerFromOutput
  }
}
