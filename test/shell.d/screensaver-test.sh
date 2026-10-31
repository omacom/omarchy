#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The Amiga fixtures exercise process-lifecycle code (signals, pidfds, sandbox
# launches) and refuse to run in the desktop's namespaces. Re-enter this file
# in a private bubblewrap sandbox with the checkout read-only, home and runtime
# sockets masked, and the environment cleared.
if [[ -z ${OMARCHY_TEST_HOST_pid:-} ]]; then
  if ! command -v bwrap >/dev/null || ! bwrap --unshare-all --die-with-parent --ro-bind / / true 2>/dev/null; then
    skip "unprivileged bubblewrap namespaces unavailable; skipping Amiga screensaver fixtures"
    exit 0
  fi
  sandbox=(--unshare-all --die-with-parent --new-session --ro-bind / / --proc /proc --dev /dev
    --tmpfs /tmp --tmpfs /run --tmpfs /home --ro-bind "$ROOT" /tmp/work --chdir /tmp/work
    --dir /tmp/tools --clearenv --setenv PATH /tmp/tools:/usr/bin:/bin --setenv HOME /tmp
    --setenv LANG C.UTF-8 --setenv PYTHONDONTWRITEBYTECODE 1 --setenv ROOT /tmp/work --setenv OMARCHY_PATH /tmp/work)
  if node=$(command -v node); then
    sandbox+=(--ro-bind "$(readlink -f "$node")" /tmp/tools/node)
  fi
  for namespace in pid user mnt net; do
    sandbox+=(--setenv "OMARCHY_TEST_HOST_$namespace" "$(readlink "/proc/self/ns/$namespace")")
  done
  exec bwrap "${sandbox[@]}" bash /tmp/work/test/shell.d/screensaver-test.sh
fi

python3 "$ROOT/test/shell.d/fixtures/screensaver_test.py"
python3 "$ROOT/test/shell.d/fixtures/amiga_native_test.py"
python3 "$ROOT/test/shell.d/fixtures/amiga_renderer_test.py"
python3 "$ROOT/test/shell.d/fixtures/amiga_top_pack_test.py"
run_node_test <<'JS'
const fs = require('fs')
const guard = fs.readFileSync(path.join(root, 'packages/amiga-runtime/guard/Guard.qml'), 'utf8')
const vm = require('vm')
const state = {
  token: '', monitorName: '', appId: '', reason: '', dismissed: false, hintOn: 'on', hintOff: 'off',
  requestedMuted: true, audioMuted: true, audioRevision: 0, frameReady: false,
  presentationGeneration: 0, titlePendingGeneration: 0, titlePending: false, pendingAppId: '', captureFailed: false, directPresented: false,
  source: {},
  get active() { return this.token !== '' },
  motion: { ready: true }, lease: { restart() {}, stop() {} },
  captureDeadline: { restart() {}, stop() {} },
  titleHint: { restart() {}, stop() {}, running: true }, demoTitle: "",
  hint: { restart() {}, stop() {}, running: true }, opened() {}, closed() {},
}
vm.createContext(state)
// Extract top-level QML methods, including single-line methods.
for (const match of guard.matchAll(/^  function .*?(?:\n[\s\S]*?^  })?$/gm)) {
  if (match[0].includes('{') && match[0].includes('}')) vm.runInContext(match[0], state)
}
const owner = 'a'.repeat(32)
assertEqual(state.begin('invalid', 'TEST'), 'busy', 'invalid owner rejected')
assertEqual(state.begin(owner, 'TEST'), 'ok', 'owned guard opens')
assertEqual(state.begin('b'.repeat(32), 'TEST'), 'busy', 'second owner rejected')
assertEqual(state.present(owner, 'TEST', 'org.omarchy.amiga-screensaver.' + owner), 'ok', 'token matched presentation')
assert(!state.frameReady, 'staging keeps the black transition shield until capture is ready')
assert(state.appId === '' && state.pendingAppId.endsWith(owner), 'staging cannot replace the black shield before capture commit')
assertEqual(state.commit(owner), 'ok', 'owner binds the opaque capture over the black shield')
assert(state.pendingAppId === '' && state.appId.endsWith(owner), 'commit binds capture to the exact staged source')
assert(!state.frameReady && state.titlePending, 'presentation waits for owned ScreencopyView content')
assertEqual(state.direct(owner), 'closed', 'direct presentation needs a capture failure')
state.captureStopped()
assert(state.captureFailed && !state.frameReady, 'capture failure keeps the black shield up')
assert(JSON.parse(state.poll(owner)).captureFailed, 'capture failure is reported to the controller')
state.frameArrived(state.presentationGeneration)
assert(!state.frameReady, 'late capture content cannot reveal after a capture failure')
assertEqual(state.direct('b'.repeat(32)), 'closed', 'only the owner confirms direct presentation')
assertEqual(state.direct(owner), 'ok', 'owner confirms the fullscreen client')
assert(state.directPresented && state.frameReady, 'direct presentation reveals the fullscreen client')
state.captureFailed = false; state.directPresented = false; state.frameReady = false; state.titlePending = true
state.frameArrived(state.presentationGeneration)
assert(state.frameReady && !state.titlePending, 'owned capture content marks the presentation ready')
state.requestNavigation('next')
assertEqual(JSON.parse(state.poll(owner)).navigationRevision, 1, 'Right requests one navigation revision')
assertEqual(JSON.parse(state.poll(owner)).navigationDirection, 'next', 'Right requests forward history')
state.requestAudioToggle()
assertEqual(state.audioRevision, 1, 'M requests one audio revision')
assertEqual(state.audioApplied(owner, 0, false), 'stale', 'stale audio acknowledgement rejected')
assertEqual(state.audioApplied(owner, 1, false), 'ok', 'confirmed audio state accepted')
assertEqual(state.cover(owner), 'ok', 'transition covers outputs before child cleanup')
assert(!state.requestedMuted && state.audioRevision === 1 && state.appId === '', 'transition preserves session audio and clears old capture')
state.dismiss('motion')
assertEqual(JSON.parse(state.poll(owner)).state, 'dismissed', 'classified activity dismisses')
assertEqual(state.end(owner), 'ok', 'owner releases guard')
const wrapper = fs.readFileSync(path.join(root, 'shell/plugins/services/idle/AmigaScreensaver.qml'), 'utf8')
const loads = []
const lazyState = { Loader: { Error: 3 }, guard: { item: null, status: 3, set active(value) { loads.push(value) } } }
vm.createContext(lazyState)
vm.runInContext(wrapper.match(/^  function begin[\s\S]*?^  }/m)[0], lazyState)
assertEqual(lazyState.begin(owner, 'TEST'), 'preparing', 'lazy dependency remains optional')
assertEqual(JSON.stringify(loads), '[false,true]', 'a previously missing native package can be retried without restarting the shell')
const service = fs.readFileSync(path.join(root, 'shell/plugins/services/idle/Service.qml'), 'utf8')
let clock = 10000
let dismissals = 0
const lockState = {
  Date: { now: () => clock },
  lockActive: true, lockCheckedAt: 0, lockProbeStartedAt: 0, lockStatusMaxAge: 1000,
  amigaWatching: false, amigaTouchedAt: 0, amigaWatchGrace: 5000,
  lockStatusProbe: { running: false },
  amigaScreensaver: {
    open: false,
    dismiss() { dismissals++ }, begin() { return 'ok' }, poll() { return 'active' }, present() { return 'ok' }
  }
}
lockState.root = lockState
vm.createContext(lockState)
for (const match of service.matchAll(/^  function [\s\S]*?^  }/gm)) vm.runInContext(match[0], lockState)
for (const match of service.matchAll(/^    function amiga(?:Begin|Poll|Present)\([\s\S]*?^    }/gm))
  vm.runInContext(match[0].replace(/: string/g, ''), lockState)
assertEqual(lockState.amigaBegin(owner, 'TEST'), 'locked', 'unknown startup lock state fails closed')
assert(lockState.amigaWatching, 'an Amiga request starts lock polling')
assert(lockState.lockStatusProbe.running, 'denied begin requests a fresh lock probe')
lockState.acceptLockStatus('false\n', 0, 0)
assertEqual(lockState.amigaBegin(owner, 'TEST'), 'ok', 'recent exact unlocked success permits begin')
const originalStart = lockState.lockProbeStartedAt
clock += 100
lockState.refreshLockStatus()
assertEqual(lockState.lockProbeStartedAt, originalStart, 'busy probe is never overlapped or re-aged')
for (const [output, code, status] of [['true', 0, 0], ['', 0, 0], ['false', 1, 0], ['false', 0, 1], ['false', 124, 0], ['false', 137, 1], ['Function not found.', 0, 0], ['false\ntrue', 0, 0], ['{"locked":false}', 0, 0]]) {
  lockState.lockProbeStartedAt = clock
  lockState.acceptLockStatus(output, code, status)
  assertEqual(lockState.amigaBegin(owner, 'TEST'), 'locked', `unsafe lock reply fails closed: ${JSON.stringify([output, code, status])}`)
  assertEqual(lockState.amigaPoll(owner), 'closed', 'unsafe lock state tells runtime to stop')
  assertEqual(lockState.amigaPresent(owner, 'TEST'), 'closed', 'unsafe lock state cannot present emulator')
}
lockState.lockProbeStartedAt = clock
lockState.acceptLockStatus('false', 0, 0)
const beforeExpiry = dismissals
clock += 1000
assert(!lockState.lockStatusAllowsAmiga(), 'stale unlocked status expires without a new IPC response')
assert(dismissals > beforeExpiry, 'expiry dismisses an existing guard')
lockState.acceptLockStatus('false', 0, 0)
assert(lockState.lockActive, 'late successful reply cannot renew stale authorization')
lockState.lockProbeStartedAt = clock + 1
lockState.acceptLockStatus('false', 0, 0)
assert(lockState.lockActive, 'clock rollback fails closed')
lockState.lockProbeStartedAt = clock
lockState.acceptLockStatus('false', 0, 0)
const beforeLock = dismissals
lockState.acceptLockStatus('true', 0, 0)
assert(dismissals > beforeLock && lockState.lockActive, 'observed lock immediately dismisses guard')
lockState.lockProbeStartedAt = clock
lockState.acceptLockStatus('false', 0, 0)
lockState.amigaScreensaver.open = true
clock += 10000
lockState.settleAmigaWatch()
assert(lockState.amigaWatching, 'an open guard keeps lock polling armed')
lockState.amigaScreensaver.open = false
lockState.watchAmiga()
clock += 4000
lockState.settleAmigaWatch()
assert(lockState.amigaWatching, 'a starting Amiga session keeps lock polling armed')
clock += 1000
lockState.settleAmigaWatch()
assert(!lockState.amigaWatching && lockState.lockActive, 'polling stops and authorization fails closed once Amiga goes quiet')
JS

pass "screensaver selection and owned FS-UAE runtime"
