#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')
assertEqual(idle.secondsFromConfig(0, 300), 0, 'idle keeps an explicit zero timeout')
assertEqual(idle.firstIdleTimeout(150, 300), 150, 'idle uses the sooner of screensaver and lock')
assertEqual(idle.firstIdleTimeout(0, 300), 300, 'idle ignores a disabled screensaver when computing first idle')
assertEqual(idle.firstIdleTimeout(150, 0), 150, 'idle ignores a disabled lock when computing first idle')
assertEqual(idle.firstIdleTimeout(0, 0), 0, 'idle has no first-idle timeout when both actions are disabled')
assertEqual(idle.delayAfterFirstIdle(300, 150), 150, 'idle delays lock until its own timeout')
assertEqual(idle.delayAfterFirstIdle(150, 150), 0, 'idle fires an action immediately when it is the first timeout')
assertEqual(idle.delayAfterFirstIdle(0, 150), 0, 'idle does not schedule a disabled action')

// State machine transitions
const { States, Events, Actions, transition } = idle

// 1. Idle start from active schedules timers
let res = transition(States.ACTIVE, Events.IDLE_START, {
  screensaverEnabled: true,
  lockEnabled: true,
  screensaverDelaySeconds: 0,
  lockDelaySeconds: 150,
  isMonitorIdle: true
})
assertEqual(res.nextState, States.SCREENSAVER_GRACE, 'immediate screensaver transitions to grace state')
assert(res.actions.includes(Actions.LAUNCH_SCREENSAVER), 'screensaver is launched')
assert(res.actions.includes(Actions.START_GRACE_TIMER), 'grace timer is armed')

// 2. Idle start with delayed screensaver
res = transition(States.ACTIVE, Events.IDLE_START, {
  screensaverEnabled: true,
  lockEnabled: true,
  screensaverDelaySeconds: 60,
  lockDelaySeconds: 150,
  isMonitorIdle: true
})
assertEqual(res.nextState, States.IDLE_COUNTDOWN, 'delayed action stays in countdown')
assert(res.actions.includes(Actions.START_SCREENSAVER_TIMER), 'screensaver timer is armed')
assert(res.actions.includes(Actions.START_LOCK_TIMER), 'lock timer is armed')

// 3. User activity while unlocked wakes system
res = transition(States.IDLE_COUNTDOWN, Events.USER_ACTIVITY, {
  isSessionLocked: false
})
assertEqual(res.nextState, States.ACTIVE, 'user activity returns to active')
assert(res.actions.includes(Actions.WAKE_SYSTEM), 'wakes system when unlocked')
assert(res.actions.includes(Actions.STOP_TIMERS), 'stops pending timers')

// 4. Regression test for #11133: Activity or cancel while locked NEVER emits WAKE_SYSTEM
res = transition(States.IDLE_COUNTDOWN, Events.USER_ACTIVITY, {
  isSessionLocked: true
})
assertEqual(res.nextState, States.LOCKED, 'locked session clamps state to locked')
assert(!res.actions.includes(Actions.WAKE_SYSTEM), 'never wakes system while session is locked (#11133)')

// 5. Activity while locked stays locked and does not wake compositor
res = transition(States.LOCKED, Events.USER_ACTIVITY, {
  isSessionLocked: true
})
assertEqual(res.nextState, States.LOCKED, 'locked state absorbs user activity without waking')
assert(!res.actions.includes(Actions.WAKE_SYSTEM), 'no wake emitted in locked state')

// 6. Grace period ignores spurious input, then returns when grace expires if user present
res = transition(States.SCREENSAVER_GRACE, Events.USER_ACTIVITY, {
  isMonitorIdle: false
})
assertEqual(res.nextState, States.SCREENSAVER_GRACE, 'grace absorbs activity during screensaver spawn')

res = transition(States.SCREENSAVER_GRACE, Events.GRACE_EXPIRED, {
  isMonitorIdle: false,
  isSessionLocked: false
})
assertEqual(res.nextState, States.ACTIVE, 'grace expiry with active user stops screensaver')
assert(res.actions.includes(Actions.STOP_SCREENSAVER), 'screensaver is stopped')
assert(res.actions.includes(Actions.WAKE_SYSTEM), 'system is awakened')

// 7. Session unlock transitions out of locked
res = transition(States.LOCKED, Events.SESSION_UNLOCKED, {
  isSessionLocked: false,
  isMonitorIdle: false
})
assertEqual(res.nextState, States.ACTIVE, 'unlock restores active state')
assert(res.actions.includes(Actions.WAKE_SYSTEM), 'unlock wakes displays')

// 8. Returning user during grace is not locked by lock timeout (#17252)
res = transition(States.SCREENSAVER_GRACE, Events.LOCK_TIMEOUT, {
  isMonitorIdle: false,
  isSessionLocked: false
})
assertEqual(res.nextState, States.ACTIVE, 'lock timeout does not lock returning active user during grace')
assert(res.actions.includes(Actions.STOP_SCREENSAVER), 'screensaver stopped for returning user')
assert(!res.actions.includes(Actions.LOCK_SYSTEM), 'lock is not engaged for active user')

// 9. Disabling timers or enabling stay awake cancels grace immediately
res = transition(States.SCREENSAVER_GRACE, Events.STAY_AWAKE_ENABLED, {
  isSessionLocked: false
})
assertEqual(res.nextState, States.DISABLED, 'stay awake cancels grace immediately')
assert(res.actions.includes(Actions.STOP_SCREENSAVER), 'screensaver stopped on stay awake')
assert(res.actions.includes(Actions.STOP_TIMERS), 'timers stopped on stay awake')

// 10. Complete lock -> unlock -> idle countdown -> lock cycle survives
let cycleState = States.ACTIVE
const cycleCtx = {
  screensaverEnabled: false,
  lockEnabled: true,
  lockDelaySeconds: 5,
  isMonitorIdle: true,
  isSessionLocked: false
}
// Start idle
let stepRes = transition(cycleState, Events.IDLE_START, cycleCtx)
assertEqual(stepRes.nextState, States.IDLE_COUNTDOWN, 'cycle step 1: enters countdown')

// Lock timeout locks session
cycleCtx.isSessionLocked = false
stepRes = transition(stepRes.nextState, Events.LOCK_TIMEOUT, cycleCtx)
assertEqual(stepRes.nextState, States.LOCKED, 'cycle step 2: locks session')
assert(stepRes.actions.includes(Actions.LOCK_SYSTEM), 'cycle step 2: executes lock')

// User unlocks
cycleCtx.isSessionLocked = false
cycleCtx.isMonitorIdle = false
stepRes = transition(stepRes.nextState, Events.SESSION_UNLOCKED, cycleCtx)
assertEqual(stepRes.nextState, States.ACTIVE, 'cycle step 3: unlock returns to active')

// Subsequent idle starts new cycle successfully
cycleCtx.isMonitorIdle = true
stepRes = transition(stepRes.nextState, Events.IDLE_START, cycleCtx)
assertEqual(stepRes.nextState, States.IDLE_COUNTDOWN, 'cycle step 4: subsequent idle schedules countdown after unlock')

// 11. Restoring nonzero timeouts leaves disabled state (#17252)
res = transition(States.DISABLED, Events.TIMERS_ENABLED, {
  stayAwake: false,
  isMonitorIdle: false,
  screensaverEnabled: true,
  lockEnabled: true
})
assertEqual(res.nextState, States.ACTIVE, 'restoring timers leaves disabled state for active user')

res = transition(States.DISABLED, Events.TIMERS_ENABLED, {
  stayAwake: false,
  isMonitorIdle: true,
  screensaverEnabled: true,
  lockEnabled: true,
  screensaverDelaySeconds: 10,
  lockDelaySeconds: 20
})
assertEqual(res.nextState, States.IDLE_COUNTDOWN, 'restoring timers while idle resumes countdown')
JS

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists enabled state"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists disabled state"

pass "Stay Awake toggle persists state"
