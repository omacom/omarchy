#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const lock = requireFromRoot('shell/plugins/lock/LockModel.js')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const defaultConfig = JSON.parse(fs.readFileSync(path.join(root, 'config/omarchy/shell.json'), 'utf8'))

assertEqual(defaultConfig.idle.blankDisplay, true, 'lock display blanking defaults to enabled')
assertEqual(lock.blankDisplayEnabled({}), true, 'missing display blank setting preserves the default')
assertEqual(lock.blankDisplayEnabled({ blankDisplay: true }), true, 'display blanking accepts an explicit enable')
assertEqual(lock.blankDisplayEnabled({ blankDisplay: false }), false, 'display blanking accepts an explicit disable')
assertEqual(lock.shouldBlankDisplay(true, true, false), true, 'an idle locked display can blank')
assertEqual(lock.shouldBlankDisplay(false, true, false), false, 'disabled display blanking blocks DPMS-off')
assertEqual(lock.shouldBlankDisplay(true, false, false), false, 'an unlocked display never blanks')
assertEqual(lock.shouldBlankDisplay(true, true, true), false, 'password authentication holds the display awake')
assert(
  /idle: \{\s*screensaver: 150,\s*lock: 300,\s*blankDisplay: true\s*\}/.test(shellQml),
  'the bundled fallback also enables lock display blanking'
)
assert(
  /readonly property bool blankDisplayEnabled: LockModel\.blankDisplayEnabled\(idleConfig\)/.test(serviceQml),
  'lock display blanking reads the idle config through the tested model'
)
assert(
  /function armBlankTimer\(\) \{\s*if \(!blankDisplayEnabled\) \{\s*idleBlankTimer\.stop\(\)\s*return\s*\}/.test(serviceQml),
  'disabled display blanking never arms the blank timer'
)
assert(
  /if \(LockModel\.shouldBlankDisplay\(root\.blankDisplayEnabled, root\.lockRequested, root\.authenticatingPassword\)\) root\.runBlank\(\)/.test(serviceQml),
  'a running timer uses the tested decision before switching off the display'
)
assert(
  /onBlankDisplayEnabledChanged: \{[\s\S]*?idleBlankTimer\.stop\(\)[\s\S]*?if \(displaysBlank\) runWake\(\)[\s\S]*?else if \(lockRequested && !authenticatingPassword\) armBlankTimer\(\)/.test(serviceQml),
  'live config changes stop or re-arm blanking and wake an already blank display'
)

// The fingerprint PAM stays armed for the whole lock waiting for a finger, so
// `authenticating` is true from lock until unlock on every machine with a
// reader enrolled. Gating the blank on it leaves the panel lit all night.
assert(
  !/idleBlankTimer[\s\S]*?!root\.authenticating\)/.test(serviceQml),
  'the blank timer never gates on the combined authenticating state'
)

assert(
  /onAuthenticatingPasswordChanged: \{\s*if \(!lockRequested\) return\s*if \(authenticatingPassword\) idleBlankTimer\.stop\(\)\s*else armBlankTimer\(\)/.test(serviceQml),
  'the blank timer is held off by password entry and re-armed when it finishes'
)

assert(
  !/onAuthenticatingChanged:/.test(serviceQml),
  'the combined authenticating state no longer drives the blank timer'
)
JS
