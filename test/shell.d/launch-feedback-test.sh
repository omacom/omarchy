#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const qml = fs.readFileSync(path.join(root, 'shell/services/AppLibrary.qml'), 'utf8')
const calls = []
const state = { launchSerial: 1, launchOsdOpen: false, launchToplevelCount: 0, launchActiveToplevel: null, launchOsdMessage: 'Launching test', toplevelCount: () => 0, shellHost: { callIfLoaded: (...args) => { calls.push(args); return 'ok' } } }
const context = vm.createContext({ root: state, ToplevelManager: { activeToplevel: null }, launchDelay: { stop() {} }, launchTimeout: { stop() {} } })
for (const name of ['showLaunchFeedback', 'closeLaunchFeedback']) {
  const match = qml.match(new RegExp('function ' + name + '\\(([^)]*)\\) \\{([\\s\\S]*?)\\n  \\}'))
  assert(match, name + ' exists')
  state[name] = vm.runInContext('(function(' + match[1] + ') {' + match[2] + '})', context)
}
state.closeLaunchFeedback(1)
assertEqual(calls.length, 0, 'fast launches do not close unrelated OSDs')
state.showLaunchFeedback()
assertEqual(state.launchOsdOpen, true, 'successful direct open records ownership')
assertEqual(JSON.parse(calls[0][2]).duration, 13000, 'launch feedback alone has a finite lifetime')
state.closeLaunchFeedback(0)
assertEqual(calls.length, 1, 'stale launch completion does not close current feedback')
state.closeLaunchFeedback(1)
assertDeepEqual(calls.map(call => call.slice(0, 2)), [['omarchy.osd', 'open'], ['omarchy.osd', 'close']], 'open and close execute in order without detached processes')
state.shellHost.callIfLoaded = () => 'unknown'
state.showLaunchFeedback()
assertEqual(state.launchOsdOpen, false, 'unloaded OSD does not acquire ownership or queue a later open')
state.shellHost = null
state.showLaunchFeedback()
assertEqual(state.launchOsdOpen, false, 'missing host is harmless')
assert(qml.includes('onTriggered: root.showLaunchFeedback()'), 'delay timer invokes tested show behavior')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
assert(shellQml.includes('AppLibrary { shellHost: shell }'), 'shell injects the direct host')
JS
