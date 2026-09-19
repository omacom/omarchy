#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')

assert(
  !/height:\s*visible\s*\?\s*implicitHeight\s*:\s*0/.test(panelSource),
  'network Panel.qml has no height/implicitHeight binding loop'
)
assertEqual(
  network.shouldActivateWifiConnection({ opened: true, layoutBusy: true, alreadyConnected: false }),
  false,
  'layout thrash cannot activate a wifi connection'
)
JS

require_compositor "network layout runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/network-layout"
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
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
printf '#!/bin/bash\nexit 0\n' > "$stage/bin/noop"
chmod +x "$stage/bin/noop"
printf '#!/bin/bash\nprintf "%%s\\n" "$@" >> "$NETWORK_TEST_BAND_LOG"\n' > "$stage/bin/omarchy-network-band"
chmod +x "$stage/bin/omarchy-network-band"
ln -s noop "$stage/bin/omarchy-dns"
printf '#!/bin/bash\nprintf "type\\twifi\\niface\\ttest-wifi\\nssid\\tGuest Wi-Fi\\nip\\t192.0.2.10\\ngateway\\t192.0.2.1\\n"\n' > "$stage/bin/omarchy-network-status"
chmod +x "$stage/bin/omarchy-network-status"

output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  NETWORK_TEST_BAND_LOG="$stage/band.log" \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network layout fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "network layout runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "network layout fixture has no QML errors or height binding loops" "$output"
fi
if [[ -f $stage/band.log ]] && rg -q '^(2\.4|5|6|auto)$' "$stage/band.log"; then
  fail "network layout fixture does not pin a band during closed or settling activates" "$(<"$stage/band.log")"
fi
pass "network list layout settle refuses connection-activate and has no height binding loop"
