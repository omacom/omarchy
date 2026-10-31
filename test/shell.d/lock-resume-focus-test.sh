#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// A suspend between the lock's focus request and the compositor's keyboard
// grab leaves the password field unfocused with nothing after the resume to
// bring focus back: the surface stays shown, so neither completion nor
// inputEnabled re-runs. The lock already notices a resume as the wall clock
// jumping under a repeating timer (the fingerprint sleep watch does); the
// same watch has to hand the field its focus back.
assert(
  /Timer\s*\{\s*id: passwordFocusSleepWatch[\s\S]*?spannedSleep\(now - lastTickMs, interval\)[\s\S]*?lockView\.forcePasswordFocus\(\)/.test(serviceQml),
  'a sleep watch refocuses the password field after a resume'
)

// The watch only runs while the lock holds the session, so the shell keeps
// no timer ticking when the session is open.
assert(
  /id: passwordFocusSleepWatch[\s\S]*?running: root\.lockRequested/.test(serviceQml),
  'the focus watch runs only while the lock is up'
)

// A field that cannot take input, or a password check in flight (the field
// then already has focus, and refocusing it would race the conversation),
// is left alone.
assert(
  /spannedSleep\(now - lastTickMs, interval\)[\s\S]*?lockView\.inputEnabled && !root\.authenticatingPassword\) lockView\.forcePasswordFocus\(\)/.test(serviceQml),
  'the focus watch refocuses only an enabled field outside a password check'
)

// The watch lives inside the lock surface, so it dies with it instead of
// ticking for a surface that no longer exists.
const surface = serviceQml.slice(serviceQml.indexOf('WlSessionLockSurface'), serviceQml.indexOf('PanelWindow'))
assert(
  /id: passwordFocusSleepWatch/.test(surface),
  'the focus watch is owned by the lock surface'
)
JS
