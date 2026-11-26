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

// pkexec's prompt, with its command line between a backtick and a quote. The
// line can hold quotes of its own, so it runs to the last one before " as".
var pkexecPrompt = /^Authentication is (?:needed|required) to run [`']([\s\S]+)[`'] as (?:the super user|user )/i

// The program a pkexec prompt asks to run, as its message names it; empty for
// any other prompt.
function promptProgram(message) {
  var match = String(message || "").match(pkexecPrompt)
  return match ? match[1] : ""
}

// pkexec's prompt cuts a command line longer than 80 bytes to its first 38
// and last 37, so one expected whole is cut the same way to match it. This
// counts characters, which are bytes for an ASCII command line.
function promptLine(line) {
  var text = String(line || "")
  return text.length > 80 ? text.slice(0, 38) + " ... " + text.slice(-37) : text
}

function matchesProgram(shown, want) {
  if (!shown || !want) return false
  if (want.charAt(0) === "/") return shown === want || shown === promptLine(want)
  var clean = want.replace(/^\.\//, "")
  var bare = "/" + clean
  if (shown.slice(-bare.length) === bare && shown.slice(0, shown.length - bare.length).indexOf(" ") === -1) return true
  var wantExe = "/" + clean.split(" ")[0]
  var shownExe = shown.split(" ")[0]
  return shown.length === 80 && shown.indexOf(" ... ") === 38 && shownExe.slice(-wantExe.length) === wantExe && shown.slice(-37) === bare.slice(-37)
}

// A label a command asked for its next prompt (omarchy.polkit expect), when
// this prompt is that one: pkexec running the program it named, before the
// label went stale. Empty otherwise.
function expectedLabel(message, expected, nowMs) {
  if (!expected || !expected.label || nowMs > expected.until) return ""
  return matchesProgram(promptProgram(message), String(expected.program || "")) ? String(expected.label) : ""
}

// Parse requester.py output ("<mark>\t<display name>\t<0|1>"); null otherwise.
function parseRequester(text) {
  var parts = String(text || "").trim().split("\t")
  if (parts.length < 2) return null
  var mark = parts[0]
  var name = parts[1].trim()
  if (!/^[a-z0-9-]+$/.test(mark) || name === "") return null
  return { mark: mark, name: name, light: parts[2] === "1" }
}

// Collapse line breaks and runs of whitespace so a multi-line command or
// message always fits on a single line in the pill above the password card.
function singleLine(text) {
  return String(text || "").replace(/\s+/g, " ").trim()
}

// A pkexec prompt names the agent it comes from, when that's known. The parts
// go in through functions, so a $ in a command line stays as it is.
function authorizationLabel(message, tr, agentName) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var text = String(message || "")
  var match = text.match(pkexecPrompt)
  if (match) {
    var program = singleLine(match[1])
    var name = singleLine(agentName)
    if (name !== "")
      return t("polkit.authorizeAgentRunning", "Authorize %1 to run '%2'").replace("%1", function() { return name }).replace("%2", function() { return program })
    return t("polkit.authorizeRunning", "Authorize running '%1'").replace("%1", function() { return program })
  }
  var clean = singleLine(text)
  // udisks formatting a drive, named as udisks names it.
  match = clean.match(/^Authentication is required to format (.+)$/i)
  if (match) return t("polkit.authorizeFormatting", "Authorize formatting of %1").replace("%1", function() { return match[1] })
  return clean
}

if (typeof module !== "undefined") {
  module.exports = {
    promptLooksFingerprint: promptLooksFingerprint,
    fingerprintConfiguredFromPamConfig: fingerprintConfiguredFromPamConfig,
    singleLine: singleLine,
    authorizationLabel: authorizationLabel,
    promptProgram: promptProgram,
    expectedLabel: expectedLabel,
    parseRequester: parseRequester
  }
}
