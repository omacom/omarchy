#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const polkit = requireFromRoot('shell/plugins/polkit/PolkitModel.js')
const fs = require('fs')
const vm = require('vm')

assert(polkit.promptLooksFingerprint('Swipe your finger'), 'polkit detects fingerprint prompts')
assert(polkit.promptLooksFingerprint('fprintd verification'), 'polkit detects fprint prompts')
assert(!polkit.promptLooksFingerprint('Password:'), 'polkit ignores password prompts')

assertEqual(
  polkit.authorizationLabel("Authentication is needed to run `/usr/bin/true' as the super user"),
  "Authorize running '/usr/bin/true'",
  'polkit shortens the standard pkexec message'
)
assertEqual(
  polkit.authorizationLabel('Authentication is required to change system settings'),
  'Authentication is required to change system settings',
  'polkit preserves custom authorization messages'
)

assert(
  polkit.fingerprintConfiguredFromPamConfig(`
# comment
auth sufficient pam_fprintd.so
auth include system-auth
`),
  'polkit detects fingerprint in a PAM config'
)
assert(
  polkit.fingerprintConfiguredFromPamConfig(`
auth [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth sufficient pam_fprintd.so
auth required pam_unix.so
`),
  'polkit detects fingerprint even behind a clamshell gate'
)
assert(
  !polkit.fingerprintConfiguredFromPamConfig(`
account include system-auth
auth include system-auth
auth required pam_unix.so
`),
  'polkit reports no fingerprint when pam_fprintd is absent'
)

// Exercise the production private store with observable lock-state producers.
// A clone id must work too; this boundary cannot depend on the built-in id.
const store = vm.createContext({})
vm.runInContext(fs.readFileSync(path.join(root, 'shell/services/AuthServiceStore.js'), 'utf8'), store)
function lockSource(blocked) {
  const listeners = new Set()
  const signal = { connect(fn) { listeners.add(fn) }, disconnect(fn) { listeners.delete(fn) } }
  return {
    lockRequested: false,
    strandedLock: false,
    strandedLockResolved: !blocked,
    currentlyLocked() { return this.lockRequested },
    lockRequestedChanged: signal,
    lockedChanged: signal,
    strandedLockChanged: signal,
    strandedLockResolvedChanged: signal,
    setBlocked(value) {
      this.strandedLockResolved = true
      this.lockRequested = value
      for (const fn of listeners) fn()
    },
    destroy() {}
  }
}
const agent = { authenticationBlocked: true, destroy() {} }
const lock = lockSource(true)
store.put('custom.polkit', agent)
assert(agent.authenticationBlocked, 'Polkit fails closed before a lock service is available')
store.put('custom.lock', lock)
assert(agent.authenticationBlocked, 'Polkit stays blocked while startup lock discovery is unresolved')
lock.setBlocked(false)
assert(!agent.authenticationBlocked, 'Polkit opens after lock discovery confirms an unlocked session')
lock.setBlocked(true)
assert(agent.authenticationBlocked, 'locking immediately blocks an existing Polkit agent')
const queuedAgent = { authenticationBlocked: true, destroy() {} }
store.put('other.polkit', queuedAgent)
assert(queuedAgent.authenticationBlocked, 'an agent loaded during locking starts blocked')
lock.setBlocked(false)
assert(!agent.authenticationBlocked && !queuedAgent.authenticationBlocked, 'unlock reopens all retained agents')
const otherLock = lockSource(true)
store.put('other.lock', otherLock)
assert(agent.authenticationBlocked, 'any retained locked service keeps authorization blocked')
store.destroy('other.lock')
assert(!agent.authenticationBlocked, 'removing a second lock preserves the remaining unlocked state')
store.destroy('custom.lock')
assert(agent.authenticationBlocked && queuedAgent.authenticationBlocked, 'losing the lock service fails closed')
lock.setBlocked(false)
assert(agent.authenticationBlocked, 'a removed lock cannot reopen authorization through a stale signal')
const replacement = lockSource(true)
store.put('custom.lock', replacement)
store.put('custom.lock', lockSource(false))
replacement.setBlocked(true)
assert(!agent.authenticationBlocked, 'replacing a lock disconnects the old state producer')
JS

require_quickshell "Polkit cancellation lifecycle"
run_qml_fixture polkit-authentication-gate "Polkit gate cancels active and newly arriving locked requests"
