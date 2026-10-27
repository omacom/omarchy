#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/panels/monitor/Model.js')
const tr = key => key === 'monitor.builtInDisplay' ? 'Built-in Display' : key
for (const name of ['eDP-1', 'LVDS-1', 'DSI-1']) {
  assertEqual(model.displayName({name, make: 'Apple Computer Inc', model: 'Retina Panel', description: 'Apple Computer Inc Retina Panel'}, tr), 'Built-in Display', 'internal connector uses the localized label: ' + name)
}
assertEqual(model.displayName({name: 'eDP-1'}, () => 'Écran intégré'), 'Écran intégré', 'internal label follows the translator')
const dell = {name: 'DP-1', make: 'Dell Inc.', model: 'DELL S2725QS', description: 'Dell Inc. DELL S2725QS 7X1KT84'}
assertEqual(model.displayName(dell, tr), 'Dell S2725QS', 'external name omits corporate suffix, repeated brand and serial')
assertEqual(dell.name, 'DP-1', 'formatting preserves action identity')
assertEqual(model.displayName({...dell, name: 'DP-2'}, tr), 'Dell S2725QS', 'identical monitors share labels and retain distinct connectors')
assertEqual(model.displayName({name: 'HDMI-A-1', make: 'Acme', model: 'Wide Panel'}, tr), 'Acme Wide Panel', 'external make and model are preserved')
assertEqual(model.displayName({name: 'DP-3', model: 'Panel'}, tr), 'Panel', 'model-only identity is usable')
assertEqual(model.displayName({name: 'DP-4', description: 'Opaque Panel SERIAL'}, tr), 'DP-4', 'opaque descriptions do not leak unknown serials')
assertEqual(model.displayName({name: 'DP-5', make: null, model: null, description: null}, tr), 'DP-5', 'missing metadata falls back to connector')
const fs = require('fs')
const panel = fs.readFileSync(root + '/shell/plugins/panels/monitor/Panel.qml', 'utf8')
assertEqual(panel.includes('root.toggleDisplay(monitorRow.display.name, monitorRow.display.enabled)'), true, 'toggle still uses connector')
assertEqual(panel.includes('text: monitorRow.display.name'), true, 'connector remains in secondary text')
JS
