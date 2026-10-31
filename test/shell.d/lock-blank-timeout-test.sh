#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const defaultConfig = JSON.parse(fs.readFileSync(path.join(root, 'config/omarchy/shell.json'), 'utf8'))
const lock = requireFromRoot('shell/plugins/lock/LockModel.js')

// The blank after locking used to be a hardcoded five seconds, which blanks the
// unlock prompt again before a slow-waking monitor can show it.
assert(
  !/interval: 5000/.test(serviceQml),
  'the lock screen no longer blanks on a hardcoded five second timer'
)

// Zero disables the blank, so every value that is not a number must fall back
// rather than convert: Number(null), Number(false) and Number("") are all zero,
// and would leave the locked displays lit forever.
assertEqual(lock.blankSeconds(undefined, 5), 5, 'a missing blank delay uses the default')
assertEqual(lock.blankSeconds(null, 5), 5, 'a null blank delay uses the default')
assertEqual(lock.blankSeconds(false, 5), 5, 'a false blank delay uses the default')
assertEqual(lock.blankSeconds(true, 5), 5, 'a true blank delay uses the default')
assertEqual(lock.blankSeconds('', 5), 5, 'an empty blank delay uses the default')
assertEqual(lock.blankSeconds('   ', 5), 5, 'a blank string uses the default')
assertEqual(lock.blankSeconds([], 5), 5, 'an array blank delay uses the default')
assertEqual(lock.blankSeconds({}, 5), 5, 'an object blank delay uses the default')
assertEqual(lock.blankSeconds('nope', 5), 5, 'an unparseable blank delay uses the default')
assertEqual(lock.blankSeconds(-1, 5), 5, 'a negative blank delay uses the default')
assertEqual(lock.blankSeconds(NaN, 5), 5, 'NaN uses the default')
assertEqual(lock.blankSeconds(Infinity, 5), 5, 'infinity uses the default')

assertEqual(lock.blankSeconds(0, 5), 0, 'an explicit zero disables the blank')
assertEqual(lock.blankSeconds('0', 5), 0, 'a zero written as a string disables the blank')
assertEqual(lock.blankSeconds(15, 5), 15, 'a configured blank delay is used')
assertEqual(lock.blankSeconds('15', 5), 15, 'a blank delay written as a string is used')
assertEqual(lock.blankSeconds(15.9, 5), 15, 'a fractional blank delay is floored')

assert(
  /readonly property int blankSeconds: LockModel\.blankSeconds\(idleConfig\.blank, defaultBlankSeconds\)/.test(serviceQml),
  'the lock screen reads the configured delay through the model'
)

assert(
  /readonly property int defaultBlankSeconds: 5/.test(serviceQml),
  'the lock screen keeps five seconds as its default blank delay'
)

assert(
  /readonly property bool blankEnabled: blankSeconds > 0/.test(serviceQml),
  'a zero blank delay reads as disabled rather than an immediate blank'
)

assert(
  /function armBlankTimer\(\) \{\s*if \(!blankEnabled\) \{\s*idleBlankTimer\.stop\(\)\s*return\s*\}\s*idleBlankTimer\.interval = blankSeconds \* 1000\s*\n\s*idleBlankTimer\.armedAt = Date\.now\(\)\s*\n\s*idleBlankTimer\.restart\(\)/.test(serviceQml),
  'arming the blank timer takes its interval from the configured delay'
)

// The idle service arms its timers the same way: the interval is assigned in
// code, so a shell.json change never restarts a pending countdown.
assert(
  !/interval: root\.defaultBlankSeconds/.test(serviceQml),
  'the blank timer is not bound to the configured delay'
)

assert(
  /onBlankEnabledChanged: \{\s*if \(!blankEnabled\) idleBlankTimer\.stop\(\)/.test(serviceQml),
  'turning the blank delay off mid-lock stops an armed timer'
)

// The suspend guard compares wall-clock time against the interval, so it reads
// the configured delay and not a stale literal.
assert(
  /if \(Date\.now\(\) - armedAt > interval \+ 2000\)/.test(serviceQml),
  'the suspend guard still measures against the armed interval'
)

assertEqual(defaultConfig.idle.blank, 5, 'the shipped shell.json carries a five second blank delay')

assert(
  /idle: \{\s*screensaver: 150,\s*lock: 300,\s*blank: 5\s*\}/.test(shellQml),
  'the builtin fallback config matches the shipped defaults'
)

assert(
  /sourceId !== "omarchy.idle" && sourceId !== "omarchy.lock"/.test(shellQml),
  'a cloned lock screen reads the idle block like the idle service does'
)
JS
