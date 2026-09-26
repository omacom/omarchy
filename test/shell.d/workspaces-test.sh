#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/bar/widgets/WorkspacesModel.js')

// Trimmed from hyprctl monitors -j and hyprctl workspacerules -j on a two
// monitor setup binding 1-5 to the left monitor and 6-10 to the right one.
const monitors = [
  { name: 'HDMI-A-1', description: 'Lenovo Group Limited E24-30 VNABHKG4' },
  { name: 'DP-3', description: 'Dell Inc. DELL P2417H CW6Y76AG24RL' }
]

const rules = [1, 2, 3, 4, 5].map(id => ({ workspaceString: String(id), monitor: 'desc:Lenovo Group Limited E24-30 VNABHKG4' }))
  .concat([6, 7, 8, 9, 10].map(id => ({ workspaceString: String(id), monitor: 'DP-3' })))
  .concat([
    { workspaceString: 'special:scratch', monitor: 'DP-3' },
    { workspaceString: 'name:web', monitor: 'DP-3' },
    { workspaceString: '11', monitor: 'DP-3' },
    { workspaceString: '3', layout: 'scrolling' },
    { workspaceString: '4', monitor: 'eDP-1' }
  ])

const byMonitor = model.monitorRuleIds(rules, monitors)

assertDeepEqual(byMonitor['HDMI-A-1'], [1, 2, 3, 4, 5], 'a desc: rule binds workspaces to its monitor')
assertDeepEqual(byMonitor['DP-3'], [6, 7, 8, 9, 10], 'a connector rule binds workspaces to its monitor')
assertEqual(byMonitor['eDP-1'], undefined, 'a rule for a disconnected monitor is ignored')
assertDeepEqual(model.monitorRuleIds([{ workspaceString: '1', monitor: 'desc:Dell Inc.' }], monitors), { 'DP-3': [1] }, 'a desc: rule matches a description prefix')
assertDeepEqual(model.monitorRuleIds(rules, []), {}, 'no monitors binds nothing')

const live = [
  { id: 1, monitor: 'HDMI-A-1' },
  { id: 6, monitor: 'DP-3' },
  { id: 7, monitor: 'DP-3' }
]

assertDeepEqual(model.workspaceIds(byMonitor, 'HDMI-A-1', live), [1, 2, 3, 4, 5], 'the left bar shows its bound workspaces')
assertDeepEqual(model.workspaceIds(byMonitor, 'DP-3', live), [6, 7, 8, 9, 10], 'the right bar shows its bound workspaces')

const moved = [
  { id: 1, monitor: 'HDMI-A-1' },
  { id: 2, monitor: 'DP-3' },
  { id: 6, monitor: 'DP-3' }
]

assertDeepEqual(model.workspaceIds(byMonitor, 'HDMI-A-1', moved), [1, 3, 4, 5], 'a workspace moved away leaves its bound bar')
assertDeepEqual(model.workspaceIds(byMonitor, 'DP-3', moved), [2, 6, 7, 8, 9, 10], 'a workspace moved in joins the bar of its monitor')

const unbound = [
  { id: 1, monitor: 'HDMI-A-1' },
  { id: 7, monitor: 'DP-3' },
  { id: 12, monitor: 'DP-3' }
]

assertDeepEqual(model.workspaceIds({}, 'HDMI-A-1', unbound), [1, 2, 3, 4, 5, 7], 'without rules every bar shows 1-5 and other workspaces up to 10')
assertDeepEqual(model.workspaceIds(byMonitor, '', unbound), [1, 2, 3, 4, 5, 7], 'an unknown monitor falls back to 1-5')
assertDeepEqual(model.workspaceIds(byMonitor, 'eDP-1', [{ id: 3, monitor: 'eDP-1' }]), [3], 'a monitor without rules shows the workspaces living on it')
JS
