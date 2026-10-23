#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "power icon reactivity test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/power-reactivity"
mkdir -p "$stage/power" "$stage/mocks" "$stage/home" "$stage/bin"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$fixture/shell.qml" "$stage/shell.qml"
cp "$fixture/mocks/"* "$stage/mocks/"
cp "$ROOT/shell/plugins/panels/power/Model.js" "$stage/power/Model.js"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/power/Panel.qml`, 'utf8')
source = source.replace('import Quickshell.Services.UPower', 'import "../mocks" as Mock')
source = source.replace(/\bUPowerDeviceState\b/g, '__MOCK_DEVICE_STATE__')
source = source.replace(/\bUPower\b/g, 'Mock.UPower')
source = source.replace(/__MOCK_DEVICE_STATE__/g, 'Mock.UPowerDeviceState')
source = source.replace('  id: root', '  id: root\n  property alias testBatteryIcon: button.text\n  property alias testBatteryIconComponent: button.iconComponent')
fs.writeFileSync(`${stage}/power/Panel.qml`, source)
JS
cat >"$stage/bin/noop" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stage/bin/noop"
for command in omarchy-battery-status omarchy-powerprofiles-list omarchy-system-stats omarchy-powerprofiles-set omarchy-shell; do
  ln -s noop "$stage/bin/$command"
done

output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  timeout 20 quickshell -p "$stage" --no-color 2>&1) || fail "power icon QML fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "power icon binding reacts to plug and unplug signals" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "power icon fixture has no QML errors" "$output"
fi
pass "power icon binding reacts to mocked UPower onBattery changes during charge hold and stale full state"
