#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const fs = require('fs'), vm = require('vm'), ui = {}
vm.runInNewContext(fs.readFileSync(root + '/shell/plugins/agents/LocalAi.js', 'utf8').replace(/^\.pragma library\s*/, ''), ui)
const backend = {version:'5.3.6', __sourceDir:'/home/user/a path/'}
assertEqual(ui.backendCommand(backend), '/home/user/a path/bin/omarchy-local-ai', 'backend paths preserve spaces')
for (const version of ['5.3.5', '4.9.9', '6.0.0', 'invalid'])
  assertEqual(ui.backendCommand({...backend, version}), '', 'unsupported backend ' + version + ' is not launched')
assertEqual(ui.backendCommand(null), '', 'missing backend is not launched')
assert(ui.backendCommand({...backend, version:'5.10.0'}), 'minor versions compare numerically')
const group = {hardwareId:'b70', name:'B70', count:2, keys:['intel:0','intel:1'], vramGb:32}
const recipe = {id:'new', name:'New', hardwareId:'b70', cards:2, onDisk:true, caps:{chat:true}}
const model = {recipeId:'old', name:'Old', state:'ready', keys:group.keys, cards:2, launchable:['pi','opencode','crush'], port:12434}
const other = {...model, recipeId:'other', name:'Other', cards:1, keys:['nvidia:0']}
const snap = {state:'ready', operation:{}, cards:[group], models:[model,other], recipes:[recipe], gpus:[], agents:{default:'pi', directory:'/home/user/Project'}, share:{available:true}}
const context = {snap, view:'card', hw:'b70', count:2, pick:'new', localError:''}
const catalog = ui.build(context)
assert(catalog.rows.some(r => r.label === 'Swap model' && r.action === 'run:new:2'), 'occupied GPUs offer a swap')
assertDeepEqual(ui.loadPlan(snap, recipe, group).replaces.map(m => m.recipeId), ['old'], 'swap preserves models on unrelated GPUs')
assert(catalog.rows.some(r => r.label === 'Will replace' && r.value.includes('Old')), 'swap names the affected model')
assert(ui.build({...context, snap:{...snap, models:[]}}).rows.some(r => r.label === 'Load model'), 'free GPUs offer a load')
const busy = ui.build({...context, browseWhileWorking:true, snap:{...snap, state:'starting'}})
assert(busy.rows.every(r => !r.action.startsWith('run:') || r.disabled), 'deployment actions are disabled while busy')
const home = ui.build({...context, view:'home'})
assert(home.rows.some(r => r.action === 'open-agent:pi:old'), 'home launches the selected agent without expanding settings')
assert(home.rows.some(r => r.action === 'gpu:b70'), 'GPU rows always open their model list')
const details = ui.build({...context, view:'model', slotSel:'old'})
assert(details.path.every(r => r.action), 'every breadcrumb has a destination')
assert(details.rows.some(r => r.devices), 'device meters remain in model details')
assertEqual(ui.meter('Usage', null, 100, '%').fraction, null, 'missing sensors are unknown')
assertEqual(ui.meter('Usage', 150, 100, '%').fraction, 1, 'visual meters clamp over-range readings')
const empty = ui.build({...context, view:'home', snap:{state:'idle', operation:{}, models:[], cards:[], recipes:[]}})
assert(empty.rows.every(r => r.type !== 'usage'), 'empty history does not draw empty usage charts')
JS
