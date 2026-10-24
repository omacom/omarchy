#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8')

const serviceQml = read('shell/plugins/lock/Service.qml')
const begin = (serviceQml.match(/function beginLock\(\) \{[\s\S]*?\n  \}\n/) || [''])[0]

assert(begin !== '', 'the lock service has a beginLock function')

// Every new lock begins in beginLock: the key binding, the menu, the idle
// service, and suspend, hibernate and the lid (through omarchy-system-sleep-lock).
assert(
  /Quickshell\.execDetached\(\["omarchy-hook", "lock"\]\)/.test(begin),
  'a new lock runs the lock hook, detached so a slow hook never holds it up'
)

// A refused lock is not a lock: nothing to react to.
const refusal = begin.slice(0, begin.indexOf('return false'))
assert(
  refusal !== '' && !/omarchy-hook/.test(refusal),
  'a lock the shell refuses does not run the lock hook'
)

// After the lock is requested, so the hook never delays the lock itself.
assert(
  /queueSessionLock\(\)[\s\S]*omarchy-hook/.test(begin),
  'the lock hook runs after the lock is requested'
)

// Once per lock: beginLock only runs when the session is not already locked,
// and this is its one call site, so a second call to omarchy-system-lock, or
// one to the sleep lock while locked, does not run the hook again.
assert(
  serviceQml.match(/omarchy-hook/g).length === 1,
  'the lock service runs the lock hook from one place only'
)

for (const script of ['bin/omarchy-system-lock', 'bin/omarchy-system-sleep-lock']) {
  assert(
    !/omarchy-hook/.test(read(script)),
    `${script} leaves the lock hook to the lock service, so it never runs twice`
  )
}

JS
