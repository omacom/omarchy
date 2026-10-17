#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "network password scan runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/network" "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp -r "$SHELL_TEST_DIR/fixtures/network-captive-portal/mocks" "$stage/mocks"
cp "$SHELL_TEST_DIR/fixtures/network-password-scan/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/network/Model.js" "$stage/network/Model.js"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Replace only the singleton and expose the network list in the disposable copy.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
source = source.replace('  id: root', '  id: root\n  property alias testNetworkList: networkList')
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
printf '#!/bin/bash\nexit 0\n' > "$stage/bin/noop"
chmod +x "$stage/bin/noop"
for command in nmcli omarchy-dns omarchy-network-band omarchy-network-status; do
  ln -s noop "$stage/bin/$command"
done

output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network password scan fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "network password scan runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "network password scan fixture has no QML errors" "$output"
fi
pass "network scans leave the passphrase prompt's row in place until it closes"
