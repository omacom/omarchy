#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/services/PluginSecurityFeedback.qml'), 'utf8')
const functions = [...source.matchAll(/^  function \w+\([^\n]*\) \{[\s\S]*?^  \}/gm)].map(match => match[0]).join('\n')
const feedback = vm.createContext({windowStarted:0, delivered:0, lastEvent:null, delivery:{running:false}, Date:{now:()=>1000}})
vm.runInContext(functions, feedback)
assertEqual(feedback.report('test.hostile', 5), true, 'known broker denial creates host feedback')
assertDeepEqual(feedback.delivery.command.slice(-2), ['Ward blocked a request', 'test.hostile tried to run a command outside its approved permissions.'], 'notice uses host-owned text and bound identity, not plugin prose')
assertEqual(feedback.report('test.hostile', 999), false, 'unknown action codes do not create notifications')
assertEqual(feedback.report('spoof\nSystem', 5), false, 'invalid identity cannot spoof notification text')
feedback.delivery.running = false
assertEqual(feedback.report('test.other', 5), true, 'second bounded notification is allowed')
feedback.delivery.running = false
assertEqual(feedback.report('test.third', 5), false, 'desktop-wide feedback is rate limited across plugins')
JS
