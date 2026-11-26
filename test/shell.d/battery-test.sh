#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const battery = requireFromRoot('shell/plugins/services/battery/BatteryModel.js')
const discharging = 1
const charging = 2

assertEqual(battery.batteryPercentage({ isPresent: true, percentage: 0.126 }), 13, 'battery rounds display percentage')
assertEqual(battery.batteryPercentage({ isPresent: false, percentage: 0.5 }), -1, 'battery reports missing battery')
assert(battery.isDischarging({ isPresent: true, state: discharging }, discharging), 'battery detects discharging state, plugged in or not')
assert(!battery.isDischarging({ isPresent: true, state: charging }, discharging), 'battery ignores non-discharging state')
assert(!battery.isDischarging({ isPresent: false, state: discharging }, discharging), 'battery requires a present battery')

assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, discharging, 10, false),
  { level: 8, notify: true, notifiedLowBattery: true },
  'battery warns once under threshold, plugged in or not'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: charging }, discharging, 10, false),
  { level: 8, notify: false, notifiedLowBattery: false },
  'battery does not warn while charging'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, discharging, 10, true),
  { level: 8, notify: false, notifiedLowBattery: true },
  'battery keeps low-battery notified state'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, discharging, 10, true),
  { level: 40, notify: false, notifiedLowBattery: false },
  'battery clears notified state after recovery'
)

let warned = false
let warnings = 0
for (const state of [discharging, charging, discharging, charging, discharging]) {
  const result = battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state }, discharging, 10, warned)
  warned = result.notifiedLowBattery
  warnings += Number(result.notify)
}
assertEqual(warnings, 1, 'battery warns only once across AC flaps while low')
assertEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.1, state: charging }, discharging, 10, true).notifiedLowBattery,
  true,
  'charging at the warning threshold does not re-arm the latch'
)
assertEqual(
  battery.shouldWarnLowBattery(null, discharging, 10, true).notifiedLowBattery,
  true,
  'a missing reading does not re-arm the low-battery warning'
)
const recovered = battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.11, state: charging }, discharging, 10, true)
assertEqual(recovered.notifiedLowBattery, false, 'battery re-arms after recovering above the threshold')
assertEqual(
  battery.shouldDismissLowBatteryWarning({ isPresent: true, percentage: 0.08, state: charging }, discharging, true, 20),
  true,
  'battery dismisses its visible warning after charging starts'
)
assertEqual(
  battery.shouldDismissLowBatteryWarning({ isPresent: true, percentage: 0.21, state: discharging }, discharging, true, 20),
  true,
  'battery dismisses its visible warning after recovering above the threshold'
)
assertEqual(
  battery.shouldDismissLowBatteryWarning({ isPresent: true, percentage: 0.08, state: discharging }, discharging, true, 20),
  false,
  'battery keeps its warning while it is still low and discharging'
)
assertEqual(
  battery.shouldDismissLowBatteryWarning(null, discharging, true, false),
  false,
  'a missing battery reading does not dismiss the warning'
)
assertEqual(
  battery.shouldRearmLowBatteryWarning({ isPresent: true, state: charging }, discharging),
  true,
  'charging after automatic dismissal re-arms the low-battery warning'
)
assertEqual(
  battery.shouldRearmLowBatteryWarning({ isPresent: true, state: discharging }, discharging),
  false,
  'continued discharging does not re-arm a dismissed warning'
)
assertEqual(
  battery.shouldRearmLowBatteryWarning(null, discharging),
  false,
  'a missing battery reading does not re-arm the warning'
)

const reply = profile => JSON.stringify({ type: 's', data: profile })
assertEqual(battery.parseActiveProfile(reply('power-saver')), 'power-saver', 'battery parses the busctl profile reply')
assertEqual(battery.parseActiveProfile(''), '', 'battery reads a missing daemon as no profile')

assertEqual(battery.profileAfterRead('', reply('balanced'), 0, 0), 'balanced', 'battery takes its startup read')

// A read that sampled balanced before a power-saver signal must not undo it.
const signalsAtStart = 3
assertEqual(
  battery.profileAfterRead('power-saver', reply('balanced'), signalsAtStart, signalsAtStart + 1),
  'power-saver',
  'battery drops a read made stale by a change signal'
)
assertEqual(
  battery.profileAfterRead('balanced', reply('power-saver'), signalsAtStart, signalsAtStart),
  'power-saver',
  'battery takes a read no signal overtook'
)
JS

# The low-battery command must insist until noticed and still pass the level to hooks.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_NOTIFICATION_ARGS"
SH
cat >"$tmpdir/bin/omarchy-hook" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_HOOK_ARGS"
SH
chmod +x "$tmpdir/bin/omarchy-notification-send" "$tmpdir/bin/omarchy-hook"
OMARCHY_TEST_NOTIFICATION_ARGS="$tmpdir/notification-args" \
OMARCHY_TEST_HOOK_ARGS="$tmpdir/hook-args" \
PATH="$tmpdir/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-battery-low" 7

declare -a notification_args hook_args
mapfile -d '' -t notification_args <"$tmpdir/notification-args"
mapfile -d '' -t hook_args <"$tmpdir/hook-args"
urgency_index=-1
for ((i = 0; i < ${#notification_args[@]}; i++)); do
  if [[ ${notification_args[i]} == "-u" ]]; then urgency_index=$((i + 1)); break; fi
done
(( urgency_index >= 0 )) || fail "low-battery warning sets an urgency"
[[ ${notification_args[urgency_index]} == "critical" ]] || fail "low-battery warning persists until noticed" "${notification_args[*]}"
[[ ${notification_args[*]} != *"-t 30000"* ]] || fail "low-battery warning does not set a misleading transient timeout"
[[ ${hook_args[*]} == "battery-low 7" ]] || fail "low-battery warning still calls hooks with the percentage" "${hook_args[*]}"
pass "low-battery command sends a persistent warning and runs its hook"

cat >"$tmpdir/bin/omarchy-notification-dismiss" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_DISMISS_ARGS"
SH
cat >"$tmpdir/bin/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s\n' 'Localized low battery'
SH
chmod +x "$tmpdir/bin/omarchy-notification-dismiss" "$tmpdir/bin/omarchy-i18n"
OMARCHY_TEST_DISMISS_ARGS="$tmpdir/dismiss-args" \
PATH="$tmpdir/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-battery-low-dismiss"
declare -a dismiss_args
mapfile -d '' -t dismiss_args <"$tmpdir/dismiss-args"
[[ ${dismiss_args[*]} == "Localized low battery" ]] || fail "battery dismissal uses the localized notification summary" "${dismiss_args[*]}"
pass "low-battery dismissal uses the localized notification summary"
