function secondsFromConfig(value, fallback) {
  var n = Number(value)
  if (!isFinite(n) || n < 0) return fallback
  return Math.floor(n)
}

// 0 means the action is disabled, not "fire immediately". min(0, 300) would
// otherwise make IdleMonitor report idle as soon as an inhibitor is released.
function firstIdleTimeout(screensaverSeconds, lockSeconds) {
  var times = []
  if (screensaverSeconds > 0) times.push(screensaverSeconds)
  if (lockSeconds > 0) times.push(lockSeconds)
  if (times.length === 0) return 0
  var min = times[0]
  for (var i = 1; i < times.length; i++) {
    if (times[i] < min) min = times[i]
  }
  return min
}

function delayAfterFirstIdle(timeoutSeconds, firstIdleSeconds) {
  if (!(timeoutSeconds > 0)) return 0
  var delay = timeoutSeconds - firstIdleSeconds
  return delay > 0 ? delay : 0
}

var States = {
  DISABLED: "disabled",
  ACTIVE: "active",
  IDLE_COUNTDOWN: "idle-countdown",
  SCREENSAVER: "screensaver",
  SCREENSAVER_GRACE: "screensaver-grace",
  LOCKED: "locked"
}

var Events = {
  IDLE_START: "idle-start",
  USER_ACTIVITY: "user-activity",
  SCREENSAVER_TIMEOUT: "screensaver-timeout",
  LOCK_TIMEOUT: "lock-timeout",
  GRACE_EXPIRED: "grace-expired",
  SCREENSAVER_DISMISSED: "screensaver-dismissed",
  LOCK_REQUESTED: "lock-requested",
  SESSION_LOCKED: "session-locked",
  SESSION_UNLOCKED: "session-unlocked",
  STAY_AWAKE_ENABLED: "stay-awake-enabled",
  STAY_AWAKE_DISABLED: "stay-awake-disabled",
  TIMERS_DISABLED: "timers-disabled",
  TIMERS_ENABLED: "timers-enabled"
}

var Actions = {
  START_SCREENSAVER_TIMER: "START_SCREENSAVER_TIMER",
  START_LOCK_TIMER: "START_LOCK_TIMER",
  LAUNCH_SCREENSAVER: "LAUNCH_SCREENSAVER",
  STOP_SCREENSAVER: "STOP_SCREENSAVER",
  LOCK_SYSTEM: "LOCK_SYSTEM",
  WAKE_SYSTEM: "WAKE_SYSTEM",
  START_GRACE_TIMER: "START_GRACE_TIMER",
  STOP_TIMERS: "STOP_TIMERS"
}

function transition(state, event, context) {
  var ctx = context || {}
  var isLocked = !!ctx.isSessionLocked
  var screensaverEnabled = !!ctx.screensaverEnabled
  var lockEnabled = !!ctx.lockEnabled
  var screensaverDelay = Number(ctx.screensaverDelaySeconds) || 0
  var lockDelay = Number(ctx.lockDelaySeconds) || 0
  var isIdle = !!ctx.isMonitorIdle
  var stayAwake = !!ctx.stayAwake

  var nextState = state || States.ACTIVE
  var actions = []

  function addAction(act) {
    if (actions.indexOf(act) < 0) actions.push(act)
  }

  if (isLocked && nextState !== States.LOCKED && event !== Events.SESSION_UNLOCKED) {
    nextState = States.LOCKED
  }

  switch (nextState) {
    case States.DISABLED:
      if (event === Events.SESSION_LOCKED || event === Events.LOCK_REQUESTED) {
        nextState = States.LOCKED
        addAction(Actions.STOP_TIMERS)
        if (event === Events.LOCK_REQUESTED) addAction(Actions.LOCK_SYSTEM)
      } else if ((event === Events.STAY_AWAKE_DISABLED || event === Events.TIMERS_ENABLED) && !stayAwake) {
        if (screensaverEnabled || lockEnabled) {
          if (isIdle) {
            nextState = States.IDLE_COUNTDOWN
            if (screensaverEnabled) {
              if (screensaverDelay === 0) {
                nextState = States.SCREENSAVER_GRACE
                addAction(Actions.LAUNCH_SCREENSAVER)
                addAction(Actions.START_GRACE_TIMER)
              } else {
                addAction(Actions.START_SCREENSAVER_TIMER)
              }
            }
            if (lockEnabled) {
              if (lockDelay === 0) {
                nextState = States.LOCKED
                addAction(Actions.LOCK_SYSTEM)
              } else {
                addAction(Actions.START_LOCK_TIMER)
              }
            }
          } else {
            nextState = States.ACTIVE
          }
        } else {
          nextState = States.ACTIVE
        }
      }
      break

    case States.ACTIVE:
      if (event === Events.STAY_AWAKE_ENABLED || event === Events.TIMERS_DISABLED) {
        nextState = States.DISABLED
        addAction(Actions.STOP_TIMERS)
      } else if (event === Events.LOCK_REQUESTED || event === Events.SESSION_LOCKED) {
        nextState = States.LOCKED
        addAction(Actions.STOP_TIMERS)
        if (event === Events.LOCK_REQUESTED) addAction(Actions.LOCK_SYSTEM)
      } else if (event === Events.IDLE_START) {
        if (screensaverEnabled || lockEnabled) {
          nextState = States.IDLE_COUNTDOWN
          if (screensaverEnabled) {
            if (screensaverDelay === 0) {
              nextState = States.SCREENSAVER_GRACE
              addAction(Actions.LAUNCH_SCREENSAVER)
              addAction(Actions.START_GRACE_TIMER)
            } else {
              addAction(Actions.START_SCREENSAVER_TIMER)
            }
          }
          if (lockEnabled) {
            if (lockDelay === 0) {
              nextState = States.LOCKED
              addAction(Actions.LOCK_SYSTEM)
            } else {
              addAction(Actions.START_LOCK_TIMER)
            }
          }
        }
      }
      break

    case States.IDLE_COUNTDOWN:
      if (event === Events.STAY_AWAKE_ENABLED || event === Events.TIMERS_DISABLED) {
        nextState = States.DISABLED
        addAction(Actions.STOP_TIMERS)
        if (!isLocked) addAction(Actions.WAKE_SYSTEM)
      } else if (event === Events.USER_ACTIVITY) {
        nextState = States.ACTIVE
        addAction(Actions.STOP_TIMERS)
        if (!isLocked) addAction(Actions.WAKE_SYSTEM)
      } else if (event === Events.LOCK_REQUESTED || event === Events.SESSION_LOCKED) {
        nextState = States.LOCKED
        addAction(Actions.STOP_TIMERS)
        if (event === Events.LOCK_REQUESTED) addAction(Actions.LOCK_SYSTEM)
      } else if (event === Events.SCREENSAVER_TIMEOUT) {
        if (screensaverEnabled) {
          nextState = States.SCREENSAVER_GRACE
          addAction(Actions.LAUNCH_SCREENSAVER)
          addAction(Actions.START_GRACE_TIMER)
        }
      } else if (event === Events.LOCK_TIMEOUT) {
        if (lockEnabled) {
          nextState = States.LOCKED
          addAction(Actions.LOCK_SYSTEM)
          addAction(Actions.STOP_TIMERS)
        }
      }
      break

    case States.SCREENSAVER:
      if (event === Events.USER_ACTIVITY || event === Events.SCREENSAVER_DISMISSED) {
        nextState = States.ACTIVE
        addAction(Actions.STOP_SCREENSAVER)
        addAction(Actions.STOP_TIMERS)
        if (!isLocked) addAction(Actions.WAKE_SYSTEM)
      } else if (event === Events.LOCK_TIMEOUT) {
        if (!isIdle) {
          nextState = States.ACTIVE
          addAction(Actions.STOP_SCREENSAVER)
          addAction(Actions.STOP_TIMERS)
          if (!isLocked) addAction(Actions.WAKE_SYSTEM)
        } else {
          nextState = States.LOCKED
          addAction(Actions.STOP_SCREENSAVER)
          addAction(Actions.STOP_TIMERS)
          addAction(Actions.LOCK_SYSTEM)
        }
      } else if (event === Events.LOCK_REQUESTED || event === Events.SESSION_LOCKED) {
        nextState = States.LOCKED
        addAction(Actions.STOP_SCREENSAVER)
        addAction(Actions.STOP_TIMERS)
        if (event !== Events.SESSION_LOCKED) addAction(Actions.LOCK_SYSTEM)
      } else if (event === Events.STAY_AWAKE_ENABLED || event === Events.TIMERS_DISABLED) {
        nextState = States.DISABLED
        addAction(Actions.STOP_SCREENSAVER)
        addAction(Actions.STOP_TIMERS)
        if (!isLocked) addAction(Actions.WAKE_SYSTEM)
      }
      break

    case States.SCREENSAVER_GRACE:
      if (event === Events.USER_ACTIVITY) {
        // Activity while screensaver starts is ignored until grace expires
      } else if (event === Events.GRACE_EXPIRED) {
        if (!isIdle) {
          nextState = States.ACTIVE
          addAction(Actions.STOP_SCREENSAVER)
          addAction(Actions.STOP_TIMERS)
          if (!isLocked) addAction(Actions.WAKE_SYSTEM)
        } else {
          nextState = States.SCREENSAVER
        }
      } else if (event === Events.SCREENSAVER_DISMISSED) {
        nextState = States.ACTIVE
        addAction(Actions.STOP_TIMERS)
        if (!isLocked) addAction(Actions.WAKE_SYSTEM)
      } else if (event === Events.LOCK_TIMEOUT) {
        if (!isIdle) {
          nextState = States.ACTIVE
          addAction(Actions.STOP_SCREENSAVER)
          addAction(Actions.STOP_TIMERS)
          if (!isLocked) addAction(Actions.WAKE_SYSTEM)
        } else {
          nextState = States.LOCKED
          addAction(Actions.STOP_SCREENSAVER)
          addAction(Actions.STOP_TIMERS)
          addAction(Actions.LOCK_SYSTEM)
        }
      } else if (event === Events.LOCK_REQUESTED || event === Events.SESSION_LOCKED) {
        nextState = States.LOCKED
        addAction(Actions.STOP_SCREENSAVER)
        addAction(Actions.STOP_TIMERS)
        if (event !== Events.SESSION_LOCKED) addAction(Actions.LOCK_SYSTEM)
      } else if (event === Events.STAY_AWAKE_ENABLED || event === Events.TIMERS_DISABLED) {
        nextState = States.DISABLED
        addAction(Actions.STOP_SCREENSAVER)
        addAction(Actions.STOP_TIMERS)
        if (!isLocked) addAction(Actions.WAKE_SYSTEM)
      }
      break

    case States.LOCKED:
      if (event === Events.SESSION_UNLOCKED) {
        if (stayAwake) {
          nextState = States.DISABLED
        } else if (isIdle && (screensaverEnabled || lockEnabled)) {
          nextState = States.IDLE_COUNTDOWN
          if (screensaverEnabled) addAction(Actions.START_SCREENSAVER_TIMER)
          if (lockEnabled) addAction(Actions.START_LOCK_TIMER)
        } else {
          nextState = States.ACTIVE
        }
        addAction(Actions.WAKE_SYSTEM)
      }
      break
  }

  return {
    nextState: nextState,
    actions: actions
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    secondsFromConfig: secondsFromConfig,
    firstIdleTimeout: firstIdleTimeout,
    delayAfterFirstIdle: delayAfterFirstIdle,
    States: States,
    Events: Events,
    Actions: Actions,
    transition: transition
  }
}
