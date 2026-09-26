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

function lidClosedPolicy(value) {
  return value === "skip" ? "skip" : "try"
}

if (typeof module !== "undefined") {
  module.exports = {
    INITIAL_MS: INITIAL_MS,
    CAP_MS: CAP_MS,
    delayForAttempt: delayForAttempt,
    isIdleTimeout: isIdleTimeout,
    lidClosedPolicy: lidClosedPolicy
  }
}
