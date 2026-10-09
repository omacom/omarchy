#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
POWER_SUPPLY_PATH="$tmp_dir/power"
mkdir -p "$POWER_SUPPLY_PATH/BAT0" "$POWER_SUPPLY_PATH/AC"

# Load only the real telemetry/recovery functions, never daemon startup or actions.
sed -n '/^find_battery_supply() {$/,/^# Notification IDs/{ /^# Notification IDs/!p; }' "$ROOT/bin/omarchy-battery-guard" >"$tmp_dir/readers.sh"
sed -n '/^power_recovered() {$/,/^}$/p' "$ROOT/bin/omarchy-battery-guard" >>"$tmp_dir/readers.sh"
source "$tmp_dir/readers.sh"
battery_path="$POWER_SUPPLY_PATH/BAT0"
printf 'Battery\n' >"$battery_path/type"
printf 'Charging\n' >"$battery_path/status"
printf '1\n' >"$POWER_SUPPLY_PATH/AC/online"
for type in Mains USB USB_C USB_PD USB_PD_DRP USB_DCP USB_CDP USB_ACA Wireless; do
  printf '%s\n' "$type" >"$POWER_SUPPLY_PATH/AC/type"
  power_recovered || fail "confirmed charging cancels on $type"
done
printf 'Discharging\n' >"$battery_path/status"
if power_recovered; then fail "online weak adapter must not cancel discharge"; fi
printf 'Unknown\n' >"$battery_path/status"
if power_recovered; then fail "unknown status is not charging confirmation"; fi
pass "USB charging types recover while weak or unknown supplies stay protected"

printf 'Discharging\n' >"$battery_path/status"
printf '50\n' >"$battery_path/time_to_empty_now"
read_battery_state "$battery_path" || fail "missing percentage must not discard independent telemetry"
[[ $percent == "-1" && $discharging == "true" && $seconds_to_empty == "50" ]] || fail "runtime and state survive missing percentage"
printf 'invalid\n' >"$battery_path/capacity"
read_battery_state "$battery_path"
[[ $percent == "-1" && $seconds_to_empty == "50" ]] || fail "invalid percentage does not become zero or hide critical runtime"
pass "runtime is independent of missing or invalid capacity"

mkdir -p "$POWER_SUPPLY_PATH/BAT1"
printf 'Battery\n' >"$POWER_SUPPLY_PATH/BAT1/type"
printf 'Full\n' >"$POWER_SUPPLY_PATH/BAT1/status"
printf '5\n' >"$battery_path/capacity"
printf '100\n' >"$POWER_SUPPLY_PATH/BAT1/capacity"
printf '2000000\n' >"$battery_path/energy_full"
printf '2000000\n' >"$POWER_SUPPLY_PATH/BAT1/energy_full"
printf '100000\n' >"$battery_path/energy_now"
printf '2000000\n' >"$POWER_SUPPLY_PATH/BAT1/energy_now"
printf '100000\n' >"$battery_path/power_now"
read_system_battery_state
awk -v p="$percent" 'BEGIN { exit !(p == 52.5) }' || fail "equal packs use combined charge"
(( seconds_to_empty > 90 )) || fail "short first-pack runtime must not hide the second pack's energy"
[[ $discharging == "true" ]] || fail "a discharging pack keeps net recovery conservative"
if power_recovered; then fail "a full second pack does not prove AC recovery while another discharges"; fi
pass "multi-pack capacity and runtime use total energy"

# charge_* is microamp-hours, not energy: convert through the pack voltage.
rm "$battery_path/energy_full" "$battery_path/energy_now"
printf '1000000\n' >"$battery_path/charge_full"
printf '50000\n' >"$battery_path/charge_now"
printf '2000000\n' >"$battery_path/voltage_min_design"
read_system_battery_state
awk -v p="$percent" 'BEGIN { exit !(p == 52.5) }' || fail "mixed energy/charge packs retain comparable weights"
pass "charge packs are weighted in the same energy units"

rm "$battery_path/charge_full" "$battery_path/charge_now" "$battery_path/voltage_min_design"
rm "$POWER_SUPPLY_PATH/BAT1/energy_full" "$POWER_SUPPLY_PATH/BAT1/energy_now"
read_system_battery_state
(( percent == 100 && seconds_to_empty == 0 )) || fail "unknown weights cannot trigger on only the first depleted pack"
rm "$POWER_SUPPLY_PATH/BAT1/capacity"
read_system_battery_state
[[ $percent == "-1" ]] || fail "missing second-pack charge is not silently discarded"
printf 'Device\n' >"$POWER_SUPPLY_PATH/BAT1/scope"
read_system_battery_state
(( percent == 5 && seconds_to_empty == 50 )) || fail "peripheral battery is excluded from system protection"
pass "incomplete telemetry stays conservative and peripherals are excluded"

# Full capacity and voltage have no direction. Malformed negative weights
# must not turn a charged pack into evidence that the whole system is low.
rm "$POWER_SUPPLY_PATH/BAT1/scope"
printf 'Discharging\n' >"$POWER_SUPPLY_PATH/BAT1/status"
printf '100\n' >"$battery_path/capacity"
printf '5\n' >"$POWER_SUPPLY_PATH/BAT1/capacity"
for pack in BAT0 BAT1; do
  printf '100000\n' >"$POWER_SUPPLY_PATH/$pack/energy_now"
  printf '100000\n' >"$POWER_SUPPLY_PATH/$pack/power_now"
done
printf '%s\n' '-2000000' >"$battery_path/energy_full"
printf '2000000\n' >"$POWER_SUPPLY_PATH/BAT1/energy_full"
read_system_battery_state
(( percent == 100 && seconds_to_empty == 0 )) || fail "negative pack weight cannot start a false low-charge countdown"
rm "$battery_path/energy_full" "$battery_path/energy_now"
printf '1000000\n' >"$battery_path/charge_full"
printf '50000\n' >"$battery_path/charge_now"
printf '%s\n' '-2000000' >"$battery_path/voltage_min_design"
read_system_battery_state
(( percent == 100 && seconds_to_empty == 0 )) || fail "negative voltage cannot establish a pack energy weight"
rm "$battery_path/charge_full" "$battery_path/charge_now" "$battery_path/voltage_min_design"
printf '%s\n' '-50' >"$battery_path/time_to_empty_now"
read_battery_state "$battery_path"
(( seconds_to_empty == 0 )) || fail "negative runtime is invalid rather than an emergency estimate"
printf '008\n' >"$battery_path/capacity"
read_battery_state "$battery_path"
(( percent == 8 )) || fail "capacity is read as decimal regardless of leading zeroes"
pass "malformed weights, voltage and runtime do not become valid telemetry"
printf 'Device\n' >"$POWER_SUPPLY_PATH/BAT1/scope"

# The user helper independently rechecks charging immediately before dispatch.
# Exercise that real function without requiring a compositor socket.
sed -n '/^power_recovered() {$/,/^}$/p' "$ROOT/default/battery-guard/close-windows" >"$tmp_dir/helper-recovery.sh"
source "$tmp_dir/helper-recovery.sh"
printf 'Charging\n' >"$battery_path/status"
for type in Mains USB USB_C USB_PD USB_PD_DRP USB_DCP USB_CDP USB_ACA Wireless; do
  printf '%s\n' "$type" >"$POWER_SUPPLY_PATH/AC/type"
  power_recovered || fail "helper confirms charging on $type"
done
printf 'Battery\n' >"$POWER_SUPPLY_PATH/AC/type"
if power_recovered; then fail "online peripheral supply cannot cancel app-close protection"; fi
printf 'USB_PD\n' >"$POWER_SUPPLY_PATH/AC/type"
rm "$POWER_SUPPLY_PATH/BAT1/scope"
printf 'Discharging\n' >"$POWER_SUPPLY_PATH/BAT1/status"
if power_recovered; then fail "helper does not cancel while a second system pack discharges"; fi
printf 'Not charging\n' >"$POWER_SUPPLY_PATH/BAT1/status"
power_recovered || fail "helper permits confirmed charging with an idle second pack"
printf 'Unknown\n' >"$POWER_SUPPLY_PATH/BAT1/status"
if power_recovered; then fail "helper requires status confirmation from every pack"; fi
pass "helper independently confirms charging across all system batteries"
