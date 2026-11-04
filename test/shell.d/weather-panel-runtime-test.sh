#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "weather panel runtime test"
require_command quickshell

scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
fixtures="$SHELL_TEST_DIR/fixtures/weather-panel"

# A disposable shell that loads the real weather Panel.qml and Model.js against
# a NetworkMock singleton. curl is a stub that fails until WEATHER_TEST_ONLINE
# exists, then answers from canned JSON; nothing touches the real network.
stage="$scratch/network-recovery"
mkdir -p "$stage/weather" "$stage/bin" "$stage/home"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp -r "$fixtures/mocks" "$stage/mocks"
cp "$fixtures/network-recovery.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/weather/Model.js" "$stage/weather/Model.js"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/weather/Panel.qml`, 'utf8')
// Keep the installed NetworkConnectivity enum; only swap the singleton and
// shorten the retry timers in the disposable copy.
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
source = source.replace('target: Networking\n', 'target: NetworkMock\n')
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/interval: 2500/g, 'interval: 100')
fs.writeFileSync(`${stage}/weather/Panel.qml`, source)
JS
cat >"$stage/bin/curl" <<'SH'
#!/bin/bash
[[ -f $WEATHER_TEST_ONLINE ]] || exit 7
case ${*: -1} in
  *geo.omarchy.org*) printf '{"name":"Testville","latitude":46.05,"longitude":14.5}' ;;
  *open-meteo.com*) printf '{"current":{"temperature_2m":12.3,"apparent_temperature":11,"relative_humidity_2m":50,"wind_speed_10m":5,"weather_code":0,"is_day":1},"daily":{"time":[],"weather_code":[],"temperature_2m_max":[],"temperature_2m_min":[]}}' ;;
  *wttr.in*) printf '{"current_condition":[{"temp_C":"12","weatherCode":"113"}],"nearest_area":[{"latitude":"46.05","longitude":"14.5"}],"weather":[]}' ;;
  *) exit 7 ;;
esac
SH
chmod +x "$stage/bin/curl"

output=$(HOME="$stage/home" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  WEATHER_TEST_ONLINE="$stage/online" timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "weather fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "weather runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "weather fixture has no QML errors" "$output"
fi
pass "weather panel fetches again once the network comes up after a failed startup fetch"
