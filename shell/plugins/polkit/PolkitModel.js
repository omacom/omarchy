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

// A label a command asked for its next prompt (omarchy.polkit expect), when
// this prompt is that one: pkexec running the program it named, before the
// label went stale. Empty otherwise.
function expectedLabel(message, expected, nowMs) {
  if (!expected || !expected.label || nowMs > expected.until) return ""
  var program = promptProgram(message)
  return program !== "" && (program === expected.program || program === promptLine(expected.program)) ? String(expected.label) : ""
}

// The mark requester.sh named, as a file name in the agents plugin's assets;
// empty for anything else.
function agentMark(text) {
  var name = String(text || "").trim()
  return /^[a-z0-9-]+$/.test(name) ? name : ""
}

// Relative luminance of a Qt color, to pick a mark drawn for light surfaces.
function luminance(color) {
  function channel(value) {
    var c = Number(value)
    if (!isFinite(c)) return 0
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4)
  }
  if (!color) return 0
  return 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b)
}

// What the prompt calls an agent requester.sh named, by its mark.
var agentNames = { claude: "Claude", codex: "Codex", grok: "Grok", opencode: "OpenCode", cursor: "Cursor", copilot: "Copilot" }

function agentName(mark) {
  return Object.prototype.hasOwnProperty.call(agentNames, mark) ? agentNames[mark] : ""
}

// A pkexec prompt names the agent it comes from, when that's known. The parts
// go in through functions, so a $ in a command line stays as it is.
function authorizationLabel(message, tr, agent) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var text = String(message || "")
  var match = text.match(pkexecPrompt)
  if (!match) return text
  var name = agentName(agent)
  if (name !== "")
    return t("polkit.authorizeAgentRunning", "Authorize %1 to run '%2'").replace("%1", function() { return name }).replace("%2", function() { return match[1] })
  return t("polkit.authorizeRunning", "Authorize running '%1'").replace("%1", function() { return match[1] })
}

if (typeof module !== "undefined") {
  module.exports = {
    promptLooksFingerprint: promptLooksFingerprint,
    fingerprintConfiguredFromPamConfig: fingerprintConfiguredFromPamConfig,
    authorizationLabel: authorizationLabel,
    promptProgram: promptProgram,
    expectedLabel: expectedLabel,
    agentMark: agentMark,
    agentName: agentName,
    luminance: luminance
  }
}
