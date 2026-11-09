#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
const states = { Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4 }

assertEqual(power.selectProfileIndex(0, 1, ['balanced', 'performance']), 1, 'power advances profile selection')
assertEqual(power.selectProfileIndex(1, 1, ['balanced', 'performance']), 1, 'power clamps profile selection')

assertDeepEqual(power.parseKeyValue('time\t2:00\nenergy\t42\n'), { time: '2:00', energy: '42' }, 'power parses key-value output')
assertDeepEqual(
  power.parseProfiles('power-saver\t0\nbalanced\t1\nperformance\t0\n', 5),
  { profiles: ['power-saver', 'balanced', 'performance'], activeProfile: 'balanced', profileIndex: 2 },
  'power parses profile output and clamps selection'
)

assert(power.profileIcon('performance').length > 0, 'power maps profile icons')
assertEqual(power.batteryFraction({ isPresent: true, percentage: 1.5 }), 1, 'power clamps battery fraction')

assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states), 'power detects threshold by pending charge state')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0.1, timeToFull: 120 }, false, states), 'power detects threshold by stalled charging')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states), 'power does not flag active charging as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states), 'Fully charged', 'power labels full battery')
assertEqual(power.localizeReading('13.1W'), '13.1W', 'power keeps battery readings in English digits by default')
assertEqual(power.localizeReading('75-80%', function(v, d) { return '<' + v + '>' }), '<75>-<80>%', 'power localizes every number in a battery reading')
assertEqual(power.localizeReading('13.10W', function(v, d) { return v.toFixed(d).replace('.', ',') }), '13,10W', 'power keeps a reading\'s decimals when localizing')
assertEqual(power.localizeReading(undefined), '', 'power reads a missing battery field as empty')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, true, states), 'On battery', 'power labels battery mode')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'Charging', 'power treats external power as newer than stale discharging state')
assert(power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, false, states).length > 0, 'power maps battery icons')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, false, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states),
  'power shows charging icon when external power is present before battery state refreshes'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, true, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states),
  'power shows battery icon when unplugged before battery state refreshes'
)
JS

# Exercise the real conservation command against a sysfs fixture. Rewrite
# only its fixed /sys paths; the production writer accepts no path override.
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/sys/class/power_supply/BAT0/extensions" "$tmp_dir/sys/bus/platform/drivers/ideapad_acpi/VPC2004:01"
sed "s|/sys/|$tmp_dir/sys/|g" "$ROOT/bin/omarchy-battery-conservation" >"$tmp_dir/conservation"
chmod +x "$tmp_dir/conservation"
export CONSERVATION_TEST_LOG="$tmp_dir/writes"
cat >"$tmp_dir/bin/pkexec" <<'STUB'
#!/bin/bash
[[ $1 == "/usr/bin/tee" && $# == 2 ]] || exit 1
[[ ${CONSERVATION_TEST_DENY:-0} == 0 ]] || exit 126
read -r value
[[ ${CONSERVATION_TEST_IGNORE_WRITE:-0} == 0 ]] || exit 0
printf '%s %s\n' "$2" "$value" >>"$CONSERVATION_TEST_LOG"
if [[ $2 == */charge_types ]]; then
  # sysfs echoes the available modes, bracketing the mode just selected.
  case $value in
    Long_Life) printf 'Fast Standard [Long_Life]\n' >"$2" ;;
    Standard) printf 'Fast [Standard] Long_Life\n' >"$2" ;;
    *) exit 1 ;;
  esac
else
  printf '%s\n' "$value" >"$2"
fi
STUB
chmod +x "$tmp_dir/bin/pkexec"
export PATH="$tmp_dir/bin:$PATH"
conservation() { "$tmp_dir/conservation" "$@" </dev/null; }
[[ $(conservation status) == "unsupported" ]] || fail "conservation is hidden without supported hardware"
if conservation on 2>/dev/null; then fail "unsupported hardware rejects writes"; fi
[[ ! -e $CONSERVATION_TEST_LOG ]] || fail "unsupported hardware never requests authentication"

legacy="$tmp_dir/sys/bus/platform/drivers/ideapad_acpi/VPC2004:01/conservation_mode"
printf '1\n' >"$legacy"
[[ $(conservation) == "on" ]] || fail "legacy conservation is detected without a hard-coded device ID"
conservation off
[[ $(cat "$legacy") == 0 && $(conservation) == off ]] || fail "legacy conservation can be disabled"
CONSERVATION_TEST_DENY=1 conservation on 2>/dev/null && fail "cancelled authentication fails the change"
[[ $(cat "$legacy") == 0 ]] || fail "cancelled authentication leaves the setting unchanged"
conservation on
[[ $(cat "$legacy") == 1 ]] || fail "legacy conservation can be enabled"
printf 'invalid\n' >"$legacy"
[[ $(conservation) == unsupported ]] || fail "invalid readings are not reported as off"

modern="$tmp_dir/sys/class/power_supply/BAT0/charge_types"
printf 'Fast [Standard] Long_Life\n' >"$modern"
[[ $(conservation) == unsupported ]] || fail "a non-Lenovo charge_types control is not exposed"
mkdir "$tmp_dir/sys/class/power_supply/BAT0/extensions/ideapad_laptop"
[[ $(conservation) == off ]] || fail "Lenovo charge_types is detected"
if CONSERVATION_TEST_IGNORE_WRITE=1 conservation on; then fail "a successful writer with unchanged hardware is not success"; fi
conservation on
[[ $(conservation) == on ]] || fail "modern conservation selects Long_Life"
conservation off
[[ $(conservation) == off && $(cat "$modern") == 'Fast [Standard] Long_Life' ]] || fail "modern conservation restores Standard"
[[ $(cat "$legacy") == invalid ]] || fail "modern controls take precedence over deprecated controls"
printf '[Fast] Standard Long_Life\n' >"$modern"
conservation off
[[ $(cat "$modern") == '[Fast] Standard Long_Life' ]] || fail "an already disabled limit preserves rapid charging"
if conservation invalid 2>/dev/null; then fail "invalid conservation actions are rejected"; fi
if conservation on extra 2>/dev/null; then fail "extra conservation arguments are rejected"; fi
pass "Lenovo conservation detects both interfaces, verifies writes, and handles cancellation"
