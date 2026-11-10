#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const vm = require('vm')
const { spawnSync } = require('child_process')
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')
const serviceSource = fs.readFileSync(root + '/shell/plugins/services/idle/Service.qml', 'utf8')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')
assertEqual(idle.optionalSecondsFromConfig('42.9'), 42, 'idle floors an optional timeout')
assertEqual(idle.optionalSecondsFromConfig(undefined), -1, 'idle disables an omitted optional timeout')
assertEqual(idle.optionalSecondsFromConfig(true), -1, 'idle rejects a boolean optional timeout')
assertEqual(idle.optionalSecondsFromConfig([900]), -1, 'idle rejects an array optional timeout')
assertEqual(idle.optionalSecondsFromConfig('999999999'), idle.MAX_TIMEOUT_SECONDS, 'idle clamps an optional timeout at the safe timer ceiling')
assertEqual(idle.MAX_TIMEOUT_SECONDS, 2147483, 'idle derives the safe timer ceiling in seconds')
assertEqual(idle.secondsFromConfig(0, 300), 0, 'idle keeps an explicit zero timeout')
assertEqual(idle.firstIdleTimeout(150, 300), 150, 'idle uses the sooner of screensaver and lock')
assertEqual(idle.firstIdleTimeout(0, 300), 300, 'idle ignores a disabled screensaver when computing first idle')
assertEqual(idle.firstIdleTimeout(150, 0), 150, 'idle ignores a disabled lock when computing first idle')
assertEqual(idle.firstIdleTimeout(0, 0), 0, 'idle has no first-idle timeout when both actions are disabled')
assertEqual(idle.firstIdleTimeout(150, 300, 120), 120, 'idle includes suspend when choosing the first idle deadline')
assertEqual(idle.delayAfterFirstIdle(300, 150), 150, 'idle delays lock until its own timeout')
assertEqual(idle.delayAfterFirstIdle(150, 150), 0, 'idle fires an action immediately when it is the first timeout')
assertEqual(idle.delayAfterFirstIdle(0, 150), 0, 'idle does not schedule a disabled action')

assert(
  serviceSource.includes('IdleModel.firstIdleTimeout(screensaverTimeoutSeconds, lockTimeoutSeconds, suspendTimeoutSeconds)'),
  'idle shares the first user-idle deadline with suspend'
)
assert(
  /id: suspendTimer[\s\S]*?onTriggered: root\.attemptSuspend\(\)/.test(serviceSource),
  'idle uses a timer rather than an IdleMonitor as the suspend clock'
)
assert(
  /id: suspendInhibitorMonitor[\s\S]*?respectInhibitors: true/.test(serviceSource),
  'idle keeps an inhibitor-aware gate for suspend'
)
assert(
  /id: suspendRetryTimer[\s\S]*?interval: 60000/.test(serviceSource),
  'idle retries after a temporary inhibitor'
)
assert(
  /onSuspendTimeoutSecondsChanged: root\.rearmIdleMonitor\(\)/.test(serviceSource),
  'idle re-arms after a suspend timeout change'
)

// Run the service's event handlers with fake timers and processes. No test
// case can launch the real lock or suspend commands.
function timer() {
  return {
    running: false,
    interval: 0,
    stop() { this.running = false },
    restart() { this.running = true }
  }
}

const later = []
const state = vm.createContext({
  Qt: { callLater: callback => later.push(callback) },
  logEvent() {},
  runProcess() {},
  screensaverTimer: timer(),
  lockTimer: timer(),
  screensaverLaunchGraceTimer: timer(),
  suspendTimer: timer(),
  suspendRetryTimer: timer(),
  idleMonitor: { isIdle: false },
  suspendInhibitorMonitor: { isIdle: true },
  suspendInhibitorCheck: { running: false },
  suspendProcess: { running: false },
  wakeProcess: { running: false },
  idleEnabled: true,
  idleTimersEnabled: true,
  idleTimeoutsReady: true,
  idleMonitorArmed: true,
  suspendEnabled: true,
  suspendDelaySeconds: 600,
  suspendGeneration: 0
})
state.root = state
vm.runInContext(serviceSource.match(/^  function .*?^  }/gms).join('\n'), state)

state.startIdleCycle()
state.handleSleepEvent('/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (true,)')
assert(!state.suspendTimer.running && !state.idleMonitorArmed, 'sleep cancels the old countdown')
state.handleSleepEvent('/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (false,)')
assert(!state.suspendTimer.running && !state.idleMonitorArmed, 'resume waits for fresh idle detection')
later.shift()()
state.idleMonitor.isIdle = true
state.handleIdleChanged()
assert(state.suspendTimer.running && state.suspendTimer.interval === 600000, 'unattended wake can start a fresh idle cycle')
state.idledThisCycle = false
state.idleMonitor.isIdle = false
state.handleIdleChanged()
assert(!state.suspendTimer.running && !state.suspendPending, 'activity cancels suspend after the lock timer finishes')

state.handleSleepEvent('The name org.freedesktop.login1 is owned by :1.6')
state.startIdleCycle()
state.attemptSuspend()
const staleGeneration = state.suspendInhibitorCheck.generation
assert(state.suspendInhibitorCheck.running, 'suspend first starts the inhibitor check')
state.handleSessionUnlocked()
later.shift()()
state.startIdleCycle()
state.handleInhibitorCheck(staleGeneration, 0, 0)
assert(!state.suspendProcess.running && !state.suspendRetryTimer.running, 'an old check cannot suspend after unlock, even during a new idle cycle')
state.handleInhibitorCheck(state.suspendGeneration, 1, 0)
assert(state.suspendRetryTimer.running && !state.suspendProcess.running, 'an unsuccessful inhibitor check defers suspend')
state.handleInhibitorCheck(state.suspendGeneration, 0, 0)
assert(state.suspendProcess.running, 'a clear inhibitor check permits the current suspend')

const query = JSON.parse(serviceSource.match(/command: (\["bash", "-o", "pipefail".*\])/)[1])
const fixture = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-idle-inhibitors-'))
try {
  fs.writeFileSync(path.join(fixture, 'systemd-inhibit'), '#!/bin/bash\nprintf "%s" "$INHIBITORS"\nexit "$INHIBITOR_STATUS"\n', { mode: 0o700 })
  function probe(inhibitors, status = '0') {
    return spawnSync(query[0], query.slice(1), {
      env: { ...process.env, PATH: fixture + ':' + process.env.PATH, INHIBITORS: inhibitors, INHIBITOR_STATUS: status }
    }).status
  }
  assertEqual(probe('[]'), 0, 'a successful empty logind list allows suspend')
  assert(probe('[{"what":"sleep:idle","mode":"block"}]') > 0, 'logind blocks with an idle component defer suspend')
  assertEqual(probe('[{"what":"idle","mode":"delay"}]'), 0, 'non-blocking inhibitors do not defer suspend')
  assert(probe('{"what":"idle"}') > 0 && probe('[{}]') > 0, 'malformed logind data defers suspend')
  assert(probe('[]', '2') > 0, 'a failed logind query defers suspend even with valid stdout')
} finally {
  fs.rmSync(fixture, { recursive: true })
}
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
