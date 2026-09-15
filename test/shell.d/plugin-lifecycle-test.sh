#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/services/SandboxedPlugins.qml'), 'utf8')
let closed = 0
const scope = vm.createContext({ dismissAll() { closed++ } })
vm.runInContext(source.match(/  function handleHostEvent\(event\) \{[\s\S]*?\n  \}/)[0], scope)
for (const event of [null, {}, {name: 'closewindow'}, {name: 'openwindow', data: '1,2,terminal,title'}])
  scope.handleHostEvent(event)
assertEqual(closed, 0, 'unrelated or malformed host events preserve panels')
scope.handleHostEvent({name: 'openwindow', parse(count) { assertEqual(count, 4, 'parse bounded host fields'); return ['1','2','org.omarchy.screensaver','title'] }})
scope.handleHostEvent({name: 'openwindow', data: '1,2,org.omarchy.screensaver,title'})
scope.handleHostEvent({name: 'openwindow', parse() { throw new Error('unavailable') }, data: '1,2,org.omarchy.screensaver,title'})
assertEqual(closed, 3, 'host screensaver events dismiss panels without worker event access')
assert(source.includes('function onRawEvent(event) { root.handleHostEvent(event) }'), 'host subscribes to compositor lifecycle')
JS
