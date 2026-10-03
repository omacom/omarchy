#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const battery = requireFromRoot('shell/plugins/services/battery/BatteryModel.js')
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
let previous = 0
let matches = true
for (let step = 0; step <= 10000; step++) {
  const raw = step / 100
  const device = {isPresent: true, percentage: raw / 100}
  const expected = raw > 0 ? Math.max(1, Math.floor((raw - 4) * 100 / 96 + 0.5 + 1e-9)) : 0
  const actual = battery.batteryPercentage(device)
  if (actual !== expected || Math.round(power.batteryFraction(device) * 100) !== actual || actual < previous) {
    matches = false
    throw new Error(`usable scale mismatch at ${raw}`)
  }
  previous = actual
}
assert(matches, '10001 samples agree across usable display models and remain monotonic')
assertEqual(battery.batteryPercentage({isPresent:true, percentage:0.05}), 1, 'shutdown reserve displays one percent')
assert(battery.shouldWarnLowBattery({isPresent:true, percentage:0.05, state:1}, true, 1, 10, false).notify, 'first critical observation delivers battery-low hook')
assert(!battery.shouldWarnLowBattery({isPresent:true, percentage:0.05, state:1}, true, 1, 10, true).notify, 'critical hook is delivered once')
assert(!battery.shouldWarnLowBattery({isPresent:true, percentage:0.12, state:1}, true, 1, 10, false).notify, 'mapped low percent does not change raw early warning threshold')
const states = {Charging:1, FullyCharged:2}
assert(!power.chargeThresholdActive({isPresent:true, percentage:0.99, state:1, changeRate:0}, false, states), 'charge hold uses raw 99 percent')
assertEqual(power.modeLabel({isPresent:true, percentage:0.999, state:1}, false, states), 'Charging', 'rounded displayed full remains charging')
const source = require('fs').readFileSync(path.join(root, 'shell/plugins/services/battery/Service.qml'), 'utf8')
const body = source.match(/function sendLowBatteryWarning\(level, displayLevel\) \{([\s\S]*?)\n  \}/)[1]
const warning = {running:false, command:[]}
const device = {isPresent:true, percentage:0.094, state:1}
const state = battery.shouldWarnLowBattery(device, true, 1, 10, false)
new Function('warningProcess', 'level', 'displayLevel', body)(warning, state.level, battery.batteryPercentage(device))
assertDeepEqual(warning.command, ['omarchy-battery-low', '9', '--display-percentage', '6'], 'service keeps raw hook level and exact displayed percentage separate')

JS

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/power"
export EVENTS="$tmp_dir/events"
cat >"$tmp_dir/bin/upower" <<'SH'
#!/bin/bash
if [[ $1 == "-e" ]]; then
  echo /org/freedesktop/UPower/devices/battery_BAT0
else
  printf 'native-path: BAT0\npower supply: yes\nstate: discharging\npercentage: %s%%\n' "$RAW"
fi
SH
cat >"$tmp_dir/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$EVENTS"
SH
cat >"$tmp_dir/bin/omarchy-hook" <<'SH'
#!/bin/bash
printf 'hook %s\n' "$*" >>"$EVENTS"
SH
chmod +x "$tmp_dir/bin/"*
for pair in 0:0 1:1 5:1 7.36:4 9.4:6 10:6 15.04:12 52.48:51 60.16:59 51:49 79.5:79 99.9:100 100:100; do
  raw=${pair%:*}
  expected=${pair#*:}
  result=$(RAW="$raw" PATH="$tmp_dir/bin:$PATH" OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" "$ROOT/bin/omarchy-battery-status" --shell)
  grep -Fx $'percentage\t'"$expected%" <<<"$result" >/dev/null || fail "CLI mapping agrees at $raw"
done
PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-low" 10
grep -F 'Battery is down to 6%' "$EVENTS" >/dev/null || fail "early warning uses usable display"
grep -Fx 'hook battery-low 10' "$EVENTS" >/dev/null || fail "battery-low hook retains raw percentage"
: >"$EVENTS"
PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-low" 5 --quiet
[[ $(cat "$EVENTS") == "hook battery-low 5" ]] || fail "quiet critical delivery runs raw hook without a toast"
: >"$EVENTS"
PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-low" 9 --display-percentage 6
grep -F 'Battery is down to 6%' "$EVENTS" >/dev/null || fail "toast preserves the displayed percentage for raw 9.4 percent"
grep -Fx 'hook battery-low 9' "$EVENTS" >/dev/null || fail "display override leaves rounded raw hook argument unchanged"
: >"$EVENTS"
PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-low" 5 --display-percentage 1 --quiet
[[ $(cat "$EVENTS") == "hook battery-low 5" ]] || fail "quiet works with a display override"
for invalid in -1 101 6.5 bad; do
  : >"$EVENTS"
  if PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-low" 9 --display-percentage "$invalid" 2>/dev/null; then
    fail "invalid displayed percentage must fail: $invalid"
  fi
  [[ ! -s $EVENTS ]] || fail "invalid display input causes no notification or hook"
done
rg -F 'sendLowBatteryWarning(state.level, batteryPercentage())' "$ROOT/shell/plugins/services/battery/Service.qml" >/dev/null || fail "service passes its exact displayed percentage"

pass "usable percentage is consistent while protection and hooks retain raw values"
