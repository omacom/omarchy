// A security key blinks while pam_u2f waits for a touch, so a retry loop would
// leave it flashing and tapping the USB bus for as long as the lock is up.
// Attempts are bounded, and one that never reached the touch prompt (no key
// plugged in, wrong key) backs off instead of retrying at once.

// Bounds one attempt; the key gives up on its own earlier, this is the backstop.
var ATTEMPT_TIMEOUT_MS = 30000
// An attempt that waited at least this long for a touch was a real chance to
// touch; a shorter one failed before the user could have reacted.
var TOUCH_WINDOW_MS = 5000
var RETRY_MS = 1000
var ERROR_RETRY_BASE_MS = 2000
var ERROR_RETRY_CAP_MS = 30000
// After a wake or a nudge: long enough for an aborted attempt to release the key.
var WAKE_DELAY_MS = 300
// At most one nudge per cooldown, however many keys are pressed.
var NUDGE_COOLDOWN_MS = 2000

// A missed touch window retries at the normal interval; failures back off.
function retryDelayMs(streak) {
  if (streak <= 0) return RETRY_MS
  return Math.min(ERROR_RETRY_BASE_MS * Math.pow(2, streak - 1), ERROR_RETRY_CAP_MS)
}

// Only an attempt that prompted for a touch and was then given the window
// resets the streak.
function nextStreak(streak, prompted, elapsedMs) {
  if (prompted && elapsedMs >= TOUCH_WINDOW_MS) return 0
  return streak + 1
}

if (typeof module !== "undefined") {
  module.exports = {
    ATTEMPT_TIMEOUT_MS: ATTEMPT_TIMEOUT_MS,
    TOUCH_WINDOW_MS: TOUCH_WINDOW_MS,
    RETRY_MS: RETRY_MS,
    ERROR_RETRY_BASE_MS: ERROR_RETRY_BASE_MS,
    ERROR_RETRY_CAP_MS: ERROR_RETRY_CAP_MS,
    WAKE_DELAY_MS: WAKE_DELAY_MS,
    NUDGE_COOLDOWN_MS: NUDGE_COOLDOWN_MS,
    retryDelayMs: retryDelayMs,
    nextStreak: nextStreak
  }
}
