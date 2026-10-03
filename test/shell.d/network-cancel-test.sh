#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A mocked backend whose guards mirror the real Quickshell frontend guards: the
# profile-level disconnect is refused unless the profile is Connected, and the
# device-level one is refused only while the device is Disconnected or
# Disconnecting. Source-text assertions cannot see that difference, so the
# panel's behaviour is driven here instead.
require_compositor "network cancel/forget lane runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/network-cancel"
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
// Keep the panel's real logic and UI bindings; only swap the singleton. No
// private ids are needed by this fixture, so nothing is exposed in it.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
printf '#!/bin/bash\nexit 0\n' >"$stage/bin/noop"
chmod +x "$stage/bin/noop"
for command in omarchy-dns omarchy-network-band; do
  ln -s noop "$stage/bin/$command"
done
# Synthetic details only; the host's SSID and addresses are never involved.
printf '#!/bin/bash\nprintf "type\\twifi\\niface\\ttest-wifi\\nssid\\tCafe WiFi\\nip\\t192.0.2.10\\ngateway\\t192.0.2.1\\n"\n' >"$stage/bin/omarchy-network-status"
chmod +x "$stage/bin/omarchy-network-status"

# Every networking action is mocked, so the host network is never touched and
# the fixture only writes to its scratch HOME.
output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network cancel fixture exits cleanly" "$output"
echo "$output" | grep -E '^ DEBUG qml: (PASS|FAIL) ' | sed 's/^ DEBUG qml: //'

if grep -q '^ DEBUG qml: FAIL ' <<<"$output"; then
  fail "every network cancel/forget lane assertion holds" "$(grep '^ DEBUG qml: FAIL ' <<<"$output")"
fi
[[ $output == *"RESULT pass cancel-and-forget-lanes"* ]] ||
  fail "network cancel fixture reports success" "$output"
if rg -q 'ReferenceError|TypeError|Unable to assign' <<<"$output"; then
  fail "network cancel fixture has no QML errors" "$output"
fi
# "Binding loop ... height" on a row's status line is pre-existing: starting a
# connect triggers it on the base Panel.qml as well, so it is not this change's
# to fix here.
pass "cancelling a connect reaches NetworkManager, and forget runs on its own lane"
