#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

PYTHONDONTWRITEBYTECODE=1 python3 "$ROOT/test/shell.d/fixtures/screensaver_test.py"
PYTHONDONTWRITEBYTECODE=1 python3 "$ROOT/test/shell.d/fixtures/amiga_native_test.py"
PYTHONDONTWRITEBYTECODE=1 python3 "$ROOT/test/shell.d/fixtures/amiga_renderer_test.py"
PYTHONDONTWRITEBYTECODE=1 python3 "$ROOT/test/shell.d/fixtures/amiga_top_pack_test.py"
run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const entries = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const amiga = entries.find(e => e.id === 'style.screensaver.amiga')
assert(amiga && amiga.label === 'Amiga', 'native Amiga menu entry has exact label')
assert(entries.some(e => e.id === 'style.screensaver.omarchy' && e.label === 'Default'), 'upstream screensaver has exact Default label')
assert(amiga.action === 'omarchy-setup-screensaver amiga', 'ready selection preflights without spawning a terminal')
assert(entries.some(e => e.id === 'style.screensaver.omarchy' && e.checked === 'omarchy-setup-screensaver --is-default'), 'default text choice remains selectable')
assert(entries.some(e => e.id === 'style.screensaver.text' && e.action === 'omarchy-branding-screensaver text'), 'text branding remains available')
const guard = fs.readFileSync(path.join(root, 'packages/amiga-runtime/guard/Guard.qml'), 'utf8')
for (const input of ['Keys.onPressed', 'onPressed', 'onWheel', 'onMotion'])
  assert(guard.includes(input), `input guard handles ${input}`)
assert(!guard.includes('onPositionChanged'), 'absolute compositor warps do not dismiss')
assert(guard.includes('Qt.BlankCursor') && guard.includes('WlrKeyboardFocus.Exclusive'), 'surface-local cursor and exclusive keys')
assert(guard.includes('interval: 10000'), 'owned guard lease expires')
assert(guard.includes('color: "black"') && guard.includes('ScreencopyView'), 'opaque owned-toplevel export')
const vm = require('vm')
const state = {
  token: '', monitorName: '', appId: '', reason: '', dismissed: false, hintOn: 'on', hintOff: 'off',
  requestedMuted: true, audioMuted: true, audioRevision: 0, frameReady: false,
  get active() { return this.token !== '' },
  motion: { ready: true }, lease: { restart() {}, stop() {} },
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
assertEqual(lazyState.begin(owner, 'TEST', 'on', 'off'), 'preparing', 'lazy dependency remains optional')
assertEqual(JSON.stringify(loads), '[false,true]', 'a previously missing native package can be retried without restarting the shell')
const service = fs.readFileSync(path.join(root, 'shell/plugins/services/idle/Service.qml'), 'utf8')
const launcher = fs.readFileSync(path.join(root, 'bin/omarchy-launch-screensaver'), 'utf8')
assert(launcher.includes('omarchy-amiga-screensaver.lock') && launcher.includes('flock -n'), 'Default preview refuses overlap with an active Amiga controller')
assert(service.includes('AmigaScreensaver {'), 'input guard lives inside the native shell, not a background plugin')
for (const method of ['amigaBegin', 'amigaPoll', 'amigaPresent', 'amigaEnd'])
  assert(service.includes(`function ${method}(`), `idle IPC provides ${method}`)
// Exercise the actual QML lock guard functions without a compositor or live IPC.
assert(!service.includes('firstPartyServiceFor("omarchy.lock")'), 'idle does not expose or look up authentication services')
assert(service.includes('function amigaRuntime(userPrefix: bool)') && service.includes('omarchy-amiga-runtime/guard/Guard.qml'), 'idle loads only the integrity-checked runtime guard')
assert(service.includes('root.omarchyPath + "/bin/omarchy-shell", "lock", "isLocked"'), 'lock observation uses the canonical read-only IPC')
assert(service.includes('"timeout", "--kill-after=0.2s", "0.8s"'), 'lock IPC has a bounded process-group timeout')
assert(service.includes('interval: 250') && service.includes('interval: 100'), 'lock polling and independent expiry remain armed')
assert(service.includes('if (outputReady && exitReady)'), 'lock response waits for both output and exit status')
let clock = 10000
let dismissals = 0
const lockState = {
  Date: { now: () => clock },
  lockActive: true, lockCheckedAt: 0, lockProbeStartedAt: 0, lockStatusMaxAge: 1000,
  lockStatusProbe: { running: false },
  amigaScreensaver: {
    dismiss() { dismissals++ }, begin() { return 'ok' }, poll() { return 'active' }, present() { return 'ok' }
  }
}
lockState.root = lockState
vm.createContext(lockState)
for (const match of service.matchAll(/^  function [\s\S]*?^  }/gm)) vm.runInContext(match[0], lockState)
for (const match of service.matchAll(/^    function amiga(?:Begin|Poll|Present)\([\s\S]*?^    }/gm))
  vm.runInContext(match[0].replace(/: string/g, ''), lockState)
assertEqual(lockState.amigaBegin(owner, 'TEST'), 'locked', 'unknown startup lock state fails closed')
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
assert(!service.slice(service.indexOf('function invalidateLockStatus'), service.indexOf('function acceptLockStatus')).includes('stayAwake ='), 'lock observation does not modify Stay Awake')
JS

pass "screensaver selection and owned FS-UAE runtime"
