#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')
const helper = source.match(/function handleConnectionFailure\([^]*?\n  \}/)
assert(helper, 'connection failures are handled outside the disposable delegate')
var actionKind = 'connect', actionSsid = 'Test WiFi'
var prompted = null, failed = false
function shouldRepromptPassphrase(reason, secured) { return reason === 'auth' && secured }
function networkForSsid(ssid) { return { name: ssid } }
function failNetworkAction() { failed = true; actionKind = ''; actionSsid = '' }
function openPasswordPrompt(ssid) { prompted = ssid }
eval(helper[0])
handleConnectionFailure('Test WiFi', 'auth', true)
assert(failed && prompted === 'Test WiFi', 'auth failure preserves the SSID after refresh clears action state')
prompted = null
handleConnectionFailure('Other WiFi', 'auth', true)
assert(prompted === null, 'background connection failures do not open the password prompt')
actionKind = 'connect'; actionSsid = 'Test WiFi'
handleConnectionFailure('Test WiFi', 'timeout', true)
assert(prompted === null, 'timeouts do not ask for a replacement password')
JS
