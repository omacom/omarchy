#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')

const hotspot = { name: 'Phone Hotspot', known: false, signalStrength: 0.4 }
const nearby = [{ name: 'Cafe', known: true, signalStrength: 0.8 }, hotspot, null]
const keyBeforeProfile = network.knownWifiKey(nearby)
hotspot.signalStrength = 0.7
assertEqual(network.knownWifiKey(nearby), keyBeforeProfile, 'known-wifi key ignores signal churn')
hotspot.known = true
assert(network.knownWifiKey(nearby) !== keyBeforeProfile, 'known-wifi key changes when a listed network gains its saved profile')
assertEqual(network.knownWifiKey(nearby.slice().reverse()), network.knownWifiKey(nearby), 'known-wifi key ignores list order')
hotspot.known = false
assertEqual(network.knownWifiKey(nearby), keyBeforeProfile, 'known-wifi key changes back when the profile goes away')

// The runtime half below skips without a compositor; keep the wiring pinned.
assert(
  /knownWifiKey: Model\.knownWifiKey\(wifiNetworkObjects\)/.test(panelSource) &&
    /onKnownWifiKeyChanged: Qt\.callLater\(syncWifiNetworks\)/.test(panelSource),
  'network resyncs wifi rows when a listed network gains or loses its saved profile'
)
assert(
  /cursorSsid = selected \? selected\.ssid : ""\s*wifiNetworks = /.test(panelSource) &&
    /selectedIndex = wifiIndexForSsid\(cursorSsid\)/.test(panelSource),
  'network keeps the cursor on its network when a rebuild re-sorts the rows'
)
JS

require_compositor "network known-resync runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/network-known-resync"
mkdir -p "$stage/network" "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp -r "$fixture/mocks" "$stage/mocks"
cp "$fixture/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/network/Model.js" "$stage/network/Model.js"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Only the singleton is replaced, and only in the disposable copy.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
printf '#!/bin/bash\nexit 0\n' > "$stage/bin/noop"
chmod +x "$stage/bin/noop"
for command in omarchy-dns omarchy-network-band omarchy-network-status; do
  ln -s noop "$stage/bin/$command"
done

# All networking is mocked and every panel probe is a no-op stub, so the host
# connection is never read or touched.
output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network known-resync fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "network known-resync runtime assertions pass" "$output"
# Binding loops are left out: showing "Connecting…" trips the row status
# line's existing height loop (#11099), which this fixture does not cover.
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign' <<< "$output"; then
  fail "network known-resync fixture has no QML errors" "$output"
fi
pass "a saved profile attaching to a listed network moves its row and the cursor into known networks and connects without a password prompt"
