#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = name => fs.readFileSync(path.join(root, name), 'utf8')
const indicator = read('shell/plugins/bar/indicators/PasswordlessSudo.qml')
const widget = read('shell/plugins/bar/widgets/Indicators.qml')
const manifest = JSON.parse(read('shell/plugins/bar/widgets/Indicators.manifest.json'))
assert(widget.match(/defaultIndicatorEntries: \[ "PasswordlessSudo", "Dictation"/), 'passwordless sudo is included in the default indicator tray')
assert(manifest.barWidget.schema.find(field => field.key === 'items').options.some(option => option.value === 'PasswordlessSudo'), 'passwordless sudo is configurable alongside Night Light')
assert(indicator.includes('useActiveColor: true') && indicator.includes('activeColor: Color.urgent'), 'active passwordless sudo uses the theme danger color')
assertEqual(indicator.match(/activeText: "([^"]+)"/)[1], indicator.match(/inactiveText: "([^"]+)"/)[1], 'sudo keeps the same icon in both states')
assert(!widget.includes('sudoHorizontal') && !widget.includes('sudoVertical'), 'sudo participates in the normal indicator blocks')
assert(!indicator.includes('visible:'), 'sudo uses the shared indicator visibility and hover behavior')
assert(indicator.includes('command: ["omarchy-sudo-passwordless", "--active"]'), 'indicator uses the noninteractive grant probe')
assert(indicator.includes('root.granted = exitCode === 0 && exitStatus === 0'), 'failed or interrupted probes do not claim an active grant')
assert(indicator.includes('interval: 5000') && indicator.includes('onTriggered: root.refresh()'), 'indicator refreshes after activation, revocation, and expiry')
JS
