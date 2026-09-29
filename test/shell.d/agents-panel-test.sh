#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.selectProvider\(root\.providerIndex \+ 1\)/.test(panelSource), 'agents middle click still advances the subscription')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')
JS

# A limit meter is cut into day segments only for the 7-day window, and that
# window is known by its title. The reset countdown cannot tell it apart: it
# runs under a few hours in the week's last stretch, is missing when the
# collector reports no reset time, and runs weeks long for a monthly window.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const start = source.indexOf('function resetMsFor')
const end = source.indexOf('function formatDuration')
assert(start > 0 && end > start, 'agents panel exposes its reset helper')
assert(source.slice(start, end).includes('function isWeeklyWindow'), 'agents panel exposes its weekly-window helper')
assert(/weekly: root\.isWeeklyWindow\(limitRow\.window\)/.test(source), 'agents limit meter segments by the weekly-window helper')

const isWeeklyWindow = (() => {
  const root = { nowMs: Date.parse('2026-09-25T12:00:00Z') }
  eval(source.slice(start, end))
  root.resetMsFor = resetMsFor
  return isWeeklyWindow
})()

const hoursFromNow = (h) => new Date(Date.parse('2026-09-25T12:00:00Z') + h * 3600000).toISOString()

assertEqual(isWeeklyWindow({ title: 'Weekly', percent: 0.3, resetAt: hoursFromNow(2) }), true,
  'agents panel segments a weekly window in its last hours')
assertEqual(isWeeklyWindow({ title: 'Fable Weekly', percent: 0.3, resetAt: hoursFromNow(90) }), true,
  'agents panel segments a model-scoped weekly window')
assertEqual(isWeeklyWindow({ title: 'weekly', percent: 0.3, resetAt: hoursFromNow(90) }), true,
  'agents panel reads the weekly title without regard to case')
assertEqual(isWeeklyWindow({ title: 'Weekly', percent: 0.3, resetAt: '' }), true,
  'agents panel segments a weekly window that has no reset time')
assertEqual(isWeeklyWindow({ title: 'Session', percent: 0.3, resetAt: hoursFromNow(4) }), false,
  'agents panel leaves a session window whole')
assertEqual(isWeeklyWindow({ title: 'Monthly', percent: 0.3, resetAt: hoursFromNow(20 * 24) }), false,
  'agents panel leaves a monthly window whole')
assertEqual(isWeeklyWindow({ title: '', percent: 0.3, resetAt: hoursFromNow(90) }), false,
  'agents panel leaves an untitled window whole')
assertEqual(isWeeklyWindow(null), false, 'agents panel leaves a missing window whole')
JS
