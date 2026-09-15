var INITIAL_MS = 250
var CAP_MS = 30000
var MAX_ATTEMPTS = 8

function delayForAttempt(attempt) {
  var n = Number(attempt)
  if (!isFinite(n) || n < 0) n = 0
  return Math.min(CAP_MS, INITIAL_MS * Math.pow(2, n))
}

function shouldRetry(attempt) {
  var n = Number(attempt)
  if (!isFinite(n) || n < 0) n = 0
  return n < MAX_ATTEMPTS
}

function lidClosedPolicy(value) {
  return value === "skip" ? "skip" : "try"
}

if (typeof module !== "undefined") {
  module.exports = {
    INITIAL_MS: INITIAL_MS,
    CAP_MS: CAP_MS,
    MAX_ATTEMPTS: MAX_ATTEMPTS,
    delayForAttempt: delayForAttempt,
    shouldRetry: shouldRetry,
    lidClosedPolicy: lidClosedPolicy
  }
}
