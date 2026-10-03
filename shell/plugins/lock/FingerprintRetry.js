var INITIAL_MS = 250
var CAP_MS = 30000

function delayForAttempt(attempt) {
  var n = Number(attempt)
  if (!isFinite(n) || n < 0) n = 0
  return Math.min(CAP_MS, INITIAL_MS * Math.pow(2, n))
}

function isIdleTimeout(message) {
  return /timed out/i.test(String(message || ""))
}

// A place-your-finger info message, not an error and not an idle timeout.
// pam_fprintd sends one of these before every rejected scan, so it is not
// itself evidence that a dead reader recovered.
function isRecoveryPrompt(message, isError) {
  if (isError) return false
  var text = String(message || "")
  if (!text || isIdleTimeout(text)) return false
  return true
}

function applyPamMessage(attempt, readerDown, promptSeen, message, isError) {
  var nextAttempt = attempt
  var down = !!readerDown
  var seen = !!promptSeen

  if (isRecoveryPrompt(message, isError)) {
    seen = true
    if (down) {
      nextAttempt = 0
      down = false
    }
  }

  return {
    retryAttempt: nextAttempt,
    readerDown: down,
    promptSeen: seen,
    lastMessage: String(message || "")
  }
}

function applyConversationEnd(attempt, readerDown, promptSeen, idleTimeout) {
  var down = !!readerDown
  if (promptSeen) down = false
  else if (!idleTimeout) down = true

  return {
    retryAttempt: attempt,
    readerDown: down,
    promptSeen: false
  }
}

function lidClosedPolicy(value) {
  return value === "skip" ? "skip" : "try"
}

if (typeof module !== "undefined") {
  module.exports = {
    INITIAL_MS: INITIAL_MS,
    CAP_MS: CAP_MS,
    delayForAttempt: delayForAttempt,
    isIdleTimeout: isIdleTimeout,
    isRecoveryPrompt: isRecoveryPrompt,
    applyPamMessage: applyPamMessage,
    applyConversationEnd: applyConversationEnd,
    lidClosedPolicy: lidClosedPolicy
  }
}
