// Back off missing prompts and fast device errors; ordinary mismatches
// and a full scan window without a finger keep the normal swipe interval.
var MATCH_RETRY_MS = 250
var FAST_ERROR_MS = 2000
var NUDGE_COOLDOWN_MS = 2000
var IDLE_CLEAR_MS = 32000
var ERROR_RETRY_BASE_MS = 1000
// Leave enough idle time for fprintd to exit and clear a wedged claim.
var FPRINTD_IDLE_EXIT_MS = 30000
var ERROR_RETRY_CAP_MS = 40000
var UNAVAILABLE_AFTER = 3
// Abort before the D-Bus claim timeout, while allowing slow device opens.
var REACH_TIMEOUT_MS = 20000
// Monotonic timers pause across suspend; a wall-clock gap detects resume.
var SLEEP_GAP_MS = 2000
// Ignore transient misses while the asynchronous resume restart lands.
var RESUME_GRACE_MS = 5000

function retryDelayMs(streak) {
  if (streak <= 0) return MATCH_RETRY_MS
  var delay = ERROR_RETRY_BASE_MS * Math.pow(2, streak - 1)
  return Math.min(delay, ERROR_RETRY_CAP_MS)
}

// Preserve the daemon idle window even under continuous user activity.
function shouldNudge(nowMs, lastNudgeMs, lastSettleMs, currentIntervalMs) {
  if (currentIntervalMs <= MATCH_RETRY_MS) return false
  var sinceNudge = nowMs - lastNudgeMs
  var sinceSettle = nowMs - lastSettleMs
  // A backward clock step cannot count as a completed idle window.
  if (sinceNudge >= 0 && sinceNudge < Math.max(NUDGE_COOLDOWN_MS, currentIntervalMs)) return false
  if (sinceSettle < 0) sinceSettle = 0
  if (currentIntervalMs >= ERROR_RETRY_CAP_MS && sinceSettle < IDLE_CLEAR_MS) return false
  return true
}


// A failed probe is unknown, so it cannot disable authentication for the lock.
function classifyProbe(text) {
  var s = String(text || "").trim()
  if (/^[ \t]*-[ \t]*#[0-9]+:/m.test(s)) return "yes"
  if (s === "no") return "no"
  if (/has no fingers enrolled/i.test(s)) return "no"
  return "unknown"
}

// Resume-time misses stay at the first tier while fprintd restarts.
function nextStreak(streak, usableAttempt, inResumeGrace) {
  if (usableAttempt) return 0
  if (inResumeGrace) return 1
  return streak + 1
}

// Event-loop stalls may also open the grace window; retries remain paced.
function spannedSleep(elapsedMs, expectedMs) {
  return elapsedMs > expectedMs + SLEEP_GAP_MS
}

function inResumeGrace(nowMs, resumedAtMs) {
  if (resumedAtMs <= 0) return false
  var elapsed = nowMs - resumedAtMs
  return elapsed >= 0 && elapsed < RESUME_GRACE_MS
}

// A few consecutive misses avoid reporting a single claim conflict.
function isUnavailable(streak) {
  return streak >= UNAVAILABLE_AFTER
}

if (typeof module !== "undefined") {
  module.exports = {
    MATCH_RETRY_MS: MATCH_RETRY_MS,
    FAST_ERROR_MS: FAST_ERROR_MS,
    NUDGE_COOLDOWN_MS: NUDGE_COOLDOWN_MS,
    IDLE_CLEAR_MS: IDLE_CLEAR_MS,
    shouldNudge: shouldNudge,
    ERROR_RETRY_BASE_MS: ERROR_RETRY_BASE_MS,
    ERROR_RETRY_CAP_MS: ERROR_RETRY_CAP_MS,
    FPRINTD_IDLE_EXIT_MS: FPRINTD_IDLE_EXIT_MS,
    UNAVAILABLE_AFTER: UNAVAILABLE_AFTER,
    REACH_TIMEOUT_MS: REACH_TIMEOUT_MS,
    SLEEP_GAP_MS: SLEEP_GAP_MS,
    RESUME_GRACE_MS: RESUME_GRACE_MS,
    spannedSleep: spannedSleep,
    classifyProbe: classifyProbe,
    inResumeGrace: inResumeGrace,
    retryDelayMs: retryDelayMs,
    nextStreak: nextStreak,
    isUnavailable: isUnavailable
  }
}
