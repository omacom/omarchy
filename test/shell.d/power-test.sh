#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
const states = { Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4 }

const rangeReading = 'state\ton\npolicy\trange\nstart\t75\nend\t80\n'
const range = power.parseChargeLimit(rangeReading)
assertDeepEqual(range, { state: 'on', policy: 'range', start: 75, end: 80 }, 'power reads the actual charging range')
assertEqual(power.parseChargeLimit(''), null, 'an empty read is unavailable, not a confirmed unsupported battery')
assertEqual(power.parseChargeLimit('error'), null, 'an invalid charge-limit reading is not reported as off')
assertEqual(power.parseChargeLimit('state\tunsupported\n').state, 'unsupported', 'power recognizes a confirmed unsupported machine')
assertEqual(power.parseChargeLimit('state\toff\npolicy\tend\nend\t100\n').policy, 'unknown', 'power never describes a full-charge threshold as battery protection')
assertEqual(power.parseChargeLimit('state\ton\npolicy\trange\nstart\t90\nend\t80\n').policy, 'unknown', 'power rejects an inverted charging range')

assertEqual(power.chargeLimitDescription(range), 'Starts charging below 75% and stops at 80%.', 'power distinguishes charging start and stop thresholds')
assertEqual(power.chargeLimitDescription({ ...range, state: 'off' }), 'Charges to full. Turn on to start below 75% and stop at 80%.', 'power explains the available policy while protection is off')
assertEqual(power.chargeLimitDescription({ state: 'on', policy: 'end', end: 60 }), 'Stops charging at 60%.', 'power uses the reported limit rather than a fixed percentage')
assertEqual(power.chargeLimitDescription({ state: 'on', policy: 'firmware' }), 'Uses your laptop’s battery protection settings.', 'firmware-controlled protection makes no percentage promise')
assertEqual(power.chargeLimitDescription({ state: 'on', policy: 'different' }), 'Each supported battery uses its own charging limit.', 'power does not apply the first battery limit to every battery')
assert(power.chargeLimitDescription({ state: 'mixed' }).includes('different settings'), 'power explains partially applied battery protection')
assertEqual(power.chargeLimitDescription(range, (key, english) => english, n => '[' + n + ']'), 'Starts charging below [75]% and stops at [80]%.', 'power localizes both charging thresholds')

assertEqual(power.chargeLimitReadResult(null, 1), null, 'power waits for stdout completion when process exit arrives first')
assertEqual(power.chargeLimitReadResult('', null), null, 'power waits for process exit when empty stdout arrives first')
assertDeepEqual(power.chargeLimitReadResult('', 1), { failed: true, info: null }, 'a completed failed read preserves the previous state instead of hiding the control')
assertDeepEqual(power.chargeLimitReadResult(rangeReading, 1), { failed: true, info: null }, 'partial stdout from a failed command is not published as a good reading')
assertDeepEqual(power.chargeLimitReadResult(rangeReading, 0), { failed: false, info: range }, 'a completed successful read can update the panel')

const profiles = ['power-saver', 'balanced', 'performance']
const cursor = { chargeFocused: false, profileIndex: 1 }
assertDeepEqual(power.movePowerCursor(cursor, 0, 1, true, profiles), { chargeFocused: true, profileIndex: 1 }, 'Down reaches battery protection without changing the selected power profile')
assertDeepEqual(power.movePowerCursor({ ...cursor, chargeFocused: true }, 0, -1, true, profiles), cursor, 'Up returns from battery protection to power profiles')
assertDeepEqual(power.movePowerCursor(cursor, 0, 1, false, profiles), { chargeFocused: false, profileIndex: 2 }, 'Down walks profiles when battery protection is unavailable')
assertDeepEqual(power.movePowerCursor({ ...cursor, chargeFocused: true }, 1, 0, false, profiles), { chargeFocused: false, profileIndex: 2 }, 'a vanished or unreadable charge control cannot trap keyboard focus')
assert(power.chargeLimitEvent('PropertiesChanged: ChargeEndThreshold'), 'an external stopping-percentage change refreshes battery protection')
assert(power.chargeLimitEvent('PropertiesChanged: ChargeStartThreshold'), 'an external starting-percentage change refreshes battery protection')
assert(power.chargeLimitEvent('PropertiesChanged: IsPresent'), 'a removable battery becoming absent refreshes the supported battery set')
assert(!power.chargeLimitEvent('PropertiesChanged: EnergyRate'), 'ordinary battery telemetry does not trigger extra charge-limit reads')

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

# The command parses the real busctl JSON format and chooses devices from
# capabilities, not their names, brands or numeric threshold properties.
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export OMARCHY_TEST_CHARGE_DEVICES="$tmp_dir/devices.json"
export OMARCHY_TEST_CHARGE_WRITES="$tmp_dir/writes"
cat >"$tmp_dir/bin/busctl" <<'STUB'
#!/bin/bash
set -euo pipefail
while [[ $1 == --* ]]; do shift; done
[[ $1 == "call" && $2 == "org.freedesktop.UPower" ]] || exit 1
device=$3
case $5 in
  EnumerateDevices)
    [[ ${OMARCHY_TEST_CHARGE_SERVICE_FAIL:-0} == 0 ]] || exit 1
    jq -c '{type: "ao", data: [keys]}' "$OMARCHY_TEST_CHARGE_DEVICES"
    ;;
  GetAll)
    jq -c --arg device "$device" '{type: "a{sv}", data: [.[$device] | with_entries(.value = {type: (if (.value | type) == "boolean" then "b" else "u" end), data: .value})]}' "$OMARCHY_TEST_CHARGE_DEVICES"
    ;;
  EnableChargeThreshold)
    [[ $4 == "org.freedesktop.UPower.Device" && $6 == "b" && ($7 == "true" || $7 == "false") ]] || exit 1
    [[ $device != "${OMARCHY_TEST_CHARGE_DENY:-}" ]] || exit 1
    printf '%s %s\n' "$device" "$7" >>"$OMARCHY_TEST_CHARGE_WRITES"
    [[ ${OMARCHY_TEST_CHARGE_IGNORE_WRITE:-0} == 0 ]] || exit 0
    jq --arg device "$device" --argjson enabled "$7" '.[$device].ChargeThresholdEnabled = $enabled' "$OMARCHY_TEST_CHARGE_DEVICES" >"$OMARCHY_TEST_CHARGE_DEVICES.next"
    mv "$OMARCHY_TEST_CHARGE_DEVICES.next" "$OMARCHY_TEST_CHARGE_DEVICES"
    ;;
  *) exit 1 ;;
esac
STUB
chmod +x "$tmp_dir/bin/busctl"
charge_limit() { PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-battery-charge-limit" "$@"; }
main=/org/freedesktop/UPower/devices/battery_CMB0
other=/org/freedesktop/UPower/devices/battery_auxiliary

printf '{}\n' >"$OMARCHY_TEST_CHARGE_DEVICES"
[[ $(charge_limit) == "unsupported" ]] || fail "no batteries means no charge control"
[[ $(charge_limit --shell) == $'state\tunsupported\npolicy\tunknown\nstart\t0\nend\t0' ]] || fail "unsupported hardware has an explicit status rather than an empty failed reading"
if charge_limit on 2>/dev/null; then fail "an unsupported machine rejects charge-limit changes"; fi
[[ ! -e $OMARCHY_TEST_CHARGE_WRITES ]] || fail "unsupported hardware receives no writes"

jq -n --arg main "$main" '{
  ($main): {Type: 2, PowerSupply: true, IsPresent: true, ChargeThresholdSupported: true, ChargeThresholdEnabled: false},
  "/org/freedesktop/UPower/devices/battery_mouse": {Type: 2, PowerSupply: false, IsPresent: true, ChargeThresholdSupported: true, ChargeThresholdEnabled: true},
  "/org/freedesktop/UPower/devices/ups": {Type: 3, PowerSupply: true, IsPresent: true, ChargeThresholdSupported: true, ChargeThresholdEnabled: true},
  "/org/freedesktop/UPower/devices/battery_absent": {Type: 2, PowerSupply: true, IsPresent: false, ChargeThresholdSupported: true, ChargeThresholdEnabled: true},
  "/org/freedesktop/UPower/devices/battery_unsupported": {Type: 2, PowerSupply: true, IsPresent: true, ChargeThresholdSupported: false, ChargeThresholdEnabled: true}
}' >"$OMARCHY_TEST_CHARGE_DEVICES"
[[ $(charge_limit status) == "off" ]] || fail "only supported present system batteries determine the charge limit"
[[ $(charge_limit on) == "on" ]] || fail "charge limits work without percentage thresholds"
[[ $(cat "$OMARCHY_TEST_CHARGE_WRITES") == "$main true" ]] || fail "only the capable system battery is changed"
charge_limit on >/dev/null
[[ $(wc -l <"$OMARCHY_TEST_CHARGE_WRITES") == 1 ]] || fail "setting the current state is idempotent"
[[ $(charge_limit off) == "off" ]] || fail "a charge limit can be disabled"
pass "charge limits use UPower capabilities and exclude peripherals, absent batteries and unsupported devices"

update_devices() {
  jq --arg main "$main" --arg other "$other" "$1" "$OMARCHY_TEST_CHARGE_DEVICES" >"$tmp_dir/next"
  mv "$tmp_dir/next" "$OMARCHY_TEST_CHARGE_DEVICES"
}
update_devices '.[$main] += {ChargeThresholdSettingsSupported: 4, ChargeStartThreshold: 75, ChargeEndThreshold: 80}'
[[ $(charge_limit --shell) == $'state\toff\npolicy\tfirmware\nstart\t0\nend\t0' ]] || fail "firmware mode does not expose stale percentage properties as its policy"
update_devices '.[$main].ChargeThresholdSettingsSupported = 3'
[[ $(charge_limit status --shell) == $'state\toff\npolicy\trange\nstart\t75\nend\t80' ]] || fail "the supported start and stop thresholds are reported separately"
update_devices '.[$main] += {ChargeThresholdSettingsSupported: 2, ChargeEndThreshold: 60}'
[[ $(charge_limit --shell) == $'state\toff\npolicy\tend\nstart\t0\nend\t60' ]] || fail "an end-only limit does not invent a restart threshold"
update_devices '.[$main].ChargeEndThreshold = 4294967295'
[[ $(charge_limit --shell) == $'state\toff\npolicy\tunknown\nstart\t0\nend\t0' ]] || fail "an unavailable threshold sentinel is never displayed as a percentage"
pass "charge-limit policy follows the supported settings and validates numeric limits"

update_devices '.[$main] += {ChargeThresholdSettingsSupported: 3, ChargeStartThreshold: 75, ChargeEndThreshold: 80} | .[$other] = .[$main] | .[$other].ChargeThresholdEnabled = true'
[[ $(charge_limit) == "mixed" ]] || fail "differing system battery settings are not reported as off"
[[ $(charge_limit toggle) == "on" ]] || fail "toggling a mixed setting protects every capable battery"
[[ $(charge_limit toggle) == "off" ]] || fail "toggling an enabled limit disables it on every capable battery"
grep -Fx "$other false" "$OMARCHY_TEST_CHARGE_WRITES" >/dev/null || fail "the second battery receives an explicit off request"
update_devices '.[$other] += {ChargeStartThreshold: 40, ChargeEndThreshold: 60}'
[[ $(charge_limit --shell) == $'state\toff\npolicy\tdifferent\nstart\t0\nend\t0' ]] || fail "different battery limits do not borrow the first battery percentage"
pass "charge limits handle percentage thresholds and multiple system batteries"

if OMARCHY_TEST_CHARGE_DENY="$main" charge_limit on 2>/dev/null; then fail "a refused change fails"; fi
[[ $(charge_limit) == "off" ]] || fail "a refused change preserves the actual state"
if OMARCHY_TEST_CHARGE_IGNORE_WRITE=1 charge_limit on 2>/dev/null; then fail "an ignored write is not reported as success"; fi
if OMARCHY_TEST_CHARGE_DENY="$other" charge_limit on 2>/dev/null; then fail "a failure on the second battery fails the command"; fi
[[ $(charge_limit) == "mixed" ]] || fail "a partial failure is reflected in the actual state"
if charge_limit invalid 2>/dev/null; then fail "invalid charge-limit actions are rejected"; fi
if charge_limit on extra 2>/dev/null; then fail "extra charge-limit arguments are rejected"; fi
if charge_limit on off 2>/dev/null; then fail "multiple charge-limit actions are rejected"; fi
jq --arg main "$main" '.[$main].ChargeThresholdEnabled = "unknown"' "$OMARCHY_TEST_CHARGE_DEVICES" >"$tmp_dir/next"
mv "$tmp_dir/next" "$OMARCHY_TEST_CHARGE_DEVICES"
if charge_limit status 2>/dev/null; then fail "an invalid reading is not reported as off"; fi
if OMARCHY_TEST_CHARGE_SERVICE_FAIL=1 charge_limit status 2>/dev/null; then fail "a failed UPower query is not reported as unsupported"; fi
pass "charge limits verify readback and report refusals, partial failures and invalid readings"
