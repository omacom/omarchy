#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = name => fs.readFileSync(path.join(root, name), 'utf8')
const indicator = read('shell/plugins/bar/indicators/PasswordlessSudo.qml')
const collector = read('shell/Commons/PasswordlessSudoStatus.qml')
const widget = read('shell/plugins/bar/widgets/Indicators.qml')
const manifest = JSON.parse(read('shell/plugins/bar/widgets/Indicators.manifest.json'))
assert(widget.match(/defaultIndicatorEntries: \[ "PasswordlessSudo", "ScreenRecording"/), 'passwordless sudo is included in the default indicator tray')
assert(manifest.barWidget.schema.find(field => field.key === 'items').options.some(option => option.value === 'PasswordlessSudo'), 'passwordless sudo is configurable alongside Night Light')
assert(indicator.includes('useActiveColor: true') && indicator.includes('activeColor: Commons.Color.urgent'), 'active passwordless sudo uses the theme danger color')
assertEqual(indicator.match(/activeText: "([^"]+)"/)[1], indicator.match(/inactiveText: "([^"]+)"/)[1], 'sudo keeps the same icon in both states')
assert(!widget.includes('sudoHorizontal') && !widget.includes('sudoVertical'), 'sudo participates in the normal indicator blocks')
assert(!indicator.includes('visible:'), 'sudo uses the shared indicator visibility and hover behavior')
assert(collector.startsWith('pragma Singleton') && read('shell/Commons/qmldir').includes('singleton PasswordlessSudoStatus 1.0 PasswordlessSudoStatus.qml'), 'grant status is collected once per QML engine')
assert(indicator.includes('readonly property bool granted: PasswordlessSudoStatus.granted') && !indicator.includes('Timer {') && !indicator.includes('"--active"'), 'every monitor and indicator view reads the shared probe instead of starting another')
assert(collector.includes('command: ["omarchy-sudo-passwordless", "--active"]'), 'shared collector uses the noninteractive grant probe')
assert(collector.includes('interval: 5000') && collector.includes('onTriggered: root.refresh()'), 'shared collector preserves activation, revocation, and expiry polling')
assert(!collector.includes('"--disable"') && !collector.includes('"--enable"') && !collector.includes('PAM'), 'shared state carries no grant-changing or authentication API')
assert(indicator.includes('command: ["omarchy-sudo-passwordless", "--disable"]'), 'active indicator revokes access through a background process')
assert(indicator.includes('if (root.granted) disableProc.running = true'), 'active click bypasses the terminal launcher')
assert(indicator.includes('root.indicatorHost.refresh()'), 'disabling access refreshes all indicator instances immediately')
const press = new Function('root', 'disableProc', indicator.match(/onPressed: function\(\) \{([\s\S]*?)\n  \}/)[1])
const launched = []
const button = { granted: true, bar: { run: command => launched.push(command) } }
const revoke = { running: false }
press(button, revoke)
assert(revoke.running && launched.length === 0, 'clicking active sudo starts background revocation without a terminal')
button.granted = false
press(button, revoke)
assert(launched.length === 0, 'repeat clicks during revocation cannot open the enable flow')
revoke.running = false
press(button, revoke)
assertDeepEqual(launched, ['omarchy-launch-floating-terminal-with-presentation omarchy-sudo-passwordless'], 'inactive click still opens interactive setup')

JS
