#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = name => fs.readFileSync(path.join(root, name), 'utf8')
const indicator = read('shell/plugins/bar/indicators/AgentAwake.qml')
const widget = read('shell/plugins/bar/widgets/Indicators.qml')
const manifest = JSON.parse(read('shell/plugins/bar/widgets/Indicators.manifest.json'))
const menu = read('default/omarchy/omarchy-menu.jsonc')

assert(widget.match(/defaultIndicatorEntries: \[[^\]]*"StayAwake", "AgentAwake" \]/), 'Agent Awake follows Stay Awake in the default indicator tray')
assert(manifest.barWidget.schema.find(field => field.key === 'items').options.some(option => option.value === 'AgentAwake'), 'Agent Awake can be picked for a custom indicator list')

assert(indicator.includes('command: ["omarchy-hw-laptop"]') && indicator.includes('inactiveText: hasLid ? "󰈈" : ""') && indicator.includes('keepSpace: hasLid'), 'a machine without a lid gets no indicator and no gap')
assert(indicator.includes('omarchy-agent-awake status'), 'the indicator reads the command rather than its state files')
assert(indicator.includes('root.awake = data.active === true'), 'only an explicit active answer lights the indicator')
assert(indicator.includes('if (exitCode !== 0) root.awake = false'), 'a failed status read never claims a session')
assert(indicator.includes('watchChanges: true') && indicator.includes('interval: 30000'), 'the indicator follows the state directory and polls for a holder that was killed')
assert(indicator.includes('"omarchy-menu", "summon", "trigger.toggle.agent-awake"'), 'clicking opens the Agent Awake menu')

const entries = {}
for (const line of menu.split('\n')) {
  const match = line.match(/^\s*"(trigger\.toggle\.agent-awake[^"]*)":\s*(\{.*\}),?\s*$/)
  if (match) entries[match[1]] = JSON.parse(match[2])
}
assertEqual(entries['trigger.toggle.agent-awake'].when, 'omarchy-hw-laptop', 'the menu entry is only offered on a laptop')
for (const id of ['add', 'stop']) {
  assertEqual(entries[`trigger.toggle.agent-awake.${id}`].when, 'omarchy-agent-awake active', `${id} is only offered while a session runs`)
}
for (const id of ['agents', '1h', '2h', '4h', '8h']) {
  assert(entries[`trigger.toggle.agent-awake.${id}`].action.startsWith('omarchy-agent-awake '), `${id} starts a session`)
}
JS
