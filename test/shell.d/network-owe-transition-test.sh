#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "network OWE transition runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/network-owe-transition"
mkdir -p "$stage/network" "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp -r "$SHELL_TEST_DIR/fixtures/network-captive-portal/mocks" "$stage/mocks"
cp "$fixture/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/network/Model.js" "$stage/network/Model.js"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Replace only the singleton and expose the private poll in the disposable copy.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
source = source.replace('  id: root', '  id: root\n  property alias testApPoll: activeApSignalPoll')
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
printf '#!/bin/bash\nexit 0\n' > "$stage/bin/noop"
chmod +x "$stage/bin/noop"
for command in omarchy-dns omarchy-network-band omarchy-network-status; do
  ln -s noop "$stage/bin/$command"
done
# Answers in call order: 57, then a slow stale 11, then 33. Never touches the
# host's NetworkManager.
cat > "$stage/bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$NETWORK_TEST_NMCLI_LOG"
count=$(wc -l < "$NETWORK_TEST_NMCLI_LOG")
case $count in
  1) printf ' :82\n*:57\n' ;;
  2) sleep 0.5; printf '*:11\n' ;;
  *) printf ' :40\n*:33\n' ;;
esac
SH
chmod +x "$stage/bin/nmcli"

output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  NETWORK_TEST_NMCLI_LOG="$stage/nmcli.log" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "network OWE fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "network OWE runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "network OWE fixture has no QML errors" "$output"
fi
while IFS= read -r args; do
  [[ $args == "-t -f IN-USE,SIGNAL device wifi list ifname test-wifi --rescan no" ]] || fail "in-use access point read never rescans" "$args"
done < "$stage/nmcli.log"
pass "network keeps Wi-Fi through OWE transition scan churn, reads the in-use access point, and discards stale reads"
