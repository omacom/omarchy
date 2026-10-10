#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/services/idle/Service.qml'), 'utf8')
const functions = [...source.matchAll(/^  function (\w+)\([^)]*\) \{[\s\S]*?^  \}/gm)]
const monitor = source.match(/IdleMonitor \{\s*id: screensaverActivityMonitor([\s\S]*?)\n  \}/)
assert(Boolean(monitor), 'idle service watches input after screensaver launch')
const enabled = monitor[1].match(/enabled:\s*([\s\S]*?)\n\s*timeout:/)[1].trim()
const changed = monitor[1].match(/onIsIdleChanged:\s*([^\n]+)/)[1]
assert(/timeout: 0\b/.test(monitor[1]), 'screensaver input monitor rearms immediately')
assert(/respectInhibitors: false\b/.test(monitor[1]), 'screensaver dismissal observes input rather than inhibitor changes')

function timer() {
  return {
    running: false,
    restart() { this.running = true },
    stop() { this.running = false },
  }
}

function scenario() {
  const state = {
    idleEnabled: true,
    idledThisCycle: false,
    screensaverStartedThisCycle: false,
    screensaverWindows: {},
    screensaverWindowCount: 0,
    screensaverTimeoutSeconds: 150,
    lockTimeoutSeconds: 300,
    screensaverDelaySeconds: 0,
    lockDelaySeconds: 150,
  }
  const context = vm.createContext({
    root: state,
    console: { log() {} },
    IdleModel: requireFromRoot('shell/plugins/services/idle/IdleModel.js'),
    idleMonitor: { isIdle: true },
    screensaverProcess: { running: false },
    wakeProcess: { running: false },
    screensaverDismissProcess: { running: false },
    lockProcess: { running: false },
    screensaverTimer: timer(),
    lockTimer: timer(),
    screensaverLaunchGraceTimer: timer(),
  })
  // Execute the service's actual methods and monitor binding/callback, with
  // only process, compositor notification, and timer objects substituted.
  vm.runInContext(functions.map(match => match[0] + '\nroot.' + match[1] + ' = ' + match[1]).join('\n'), context)
  return {
    state, context,
    inputMonitorEnabled() { return vm.runInContext(enabled, context) },
    notify(isIdle) {
      vm.runInContext('(function(enabled, isIdle) { ' + changed + ' })(' + this.inputMonitorEnabled() + ', ' + isIdle + ')', context)
    },
    launch() {
      state.handleIdleChanged()
      state.handleScreensaverWindowOpened('unfocused-window')
    },
  }
}

let s = scenario()
s.launch()
s.context.idleMonitor.isIdle = false
s.state.handleIdleChanged()
s.notify(false)
assert(s.state.idledThisCycle && s.context.lockTimer.running && !s.context.wakeProcess.running,
  'terminal mapping activity preserves the pending lock during launch')
assert(!s.inputMonitorEnabled(), 'input dismissal waits until the launcher restores monitor focus')

s.context.screensaverProcess.running = false
assert(s.inputMonitorEnabled(), 'input dismissal is armed with an existing unfocused screensaver')
s.notify(true)
assert(s.context.lockTimer.running, 'arming the input monitor does not dismiss the screensaver')
s.notify(false)
assert(!s.state.idledThisCycle && !s.context.lockTimer.running && !s.context.screensaverTimer.running,
  'input cancels the pending lock without a focused screensaver or another long-idle transition')
assertEqual(s.context.screensaverDismissProcess.command[2], "pkill -f '[o]rg.omarchy.screensaver' 2>/dev/null || true",
  'input terminates screensaver terminals through their normal signal cleanup')
assertEqual(s.context.wakeProcess.command[2], 'omarchy-system-wake', 'input wakes the desktop')
assertEqual(s.state.screensaverWindowCount, 0, 'activity clears screensaver tracking')
assert(!s.inputMonitorEnabled(), 'activity disarms the screensaver input monitor')

s = scenario()
s.launch()
s.context.screensaverProcess.running = false
s.notify(true)
s.state.lockSystem('lock-timeout')
s.notify(false)
assertEqual(s.context.lockProcess.command[2], 'omarchy-system-lock', 'inactivity still reaches the lock deadline')
assert(!s.context.wakeProcess.running, 'a disabled input monitor cannot cancel an already-triggered lock')

s = scenario()
s.state.handleScreensaverWindowOpened('manual-window')
s.notify(false)
assert(!s.inputMonitorEnabled() && !s.context.wakeProcess.running, 'manual screensavers do not create an idle dismissal cycle')

s = scenario()
s.state.handleIdleChanged()
s.context.screensaverProcess.running = false
s.notify(false)
assert(s.context.lockTimer.running && !s.inputMonitorEnabled(), 'a missing screensaver leaves the normal lock timer armed')

s = scenario()
s.launch()
s.context.screensaverProcess.running = false
s.state.handleScreensaverWindowClosed('unfocused-window')
assert(!s.state.idledThisCycle && !s.context.lockTimer.running, 'ordinary screensaver dismissal still cancels the lock')
JS
