#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

field() {
  awk -F '\t' -v name="$1" '$1 == name { print $2; exit }' <<<"$2"
}

duration_seconds() {
  local text=$1

  if [[ $text =~ ^([0-9]+)h[[:space:]]([0-9]+)m$ ]]; then
    echo $((BASH_REMATCH[1] * 3600 + BASH_REMATCH[2] * 60))
  elif [[ $text =~ ^([0-9]+)h$ ]]; then
    echo $((BASH_REMATCH[1] * 3600))
  elif [[ $text =~ ^([0-9]+)m$ ]]; then
    echo $((BASH_REMATCH[1] * 60))
  else
    echo -1
  fi
}

require_field() {
  local actual

  actual=$(field "$3" "$2")
  [[ $actual == "$4" ]] || fail "$1" "expected ${3}=${4}, got ${3}=${actual:-<empty>}"
}

reset_supply() {
  rm -rf "$tmp_dir/power"
  mkdir -p "$tmp_dir/power/BAT0"
  printf '900000\n' >"$tmp_dir/power/BAT0/current_now"
  printf '12000000\n' >"$tmp_dir/power/BAT0/voltage_now"
}

set_charge() {
  if [[ -n $1 ]]; then
    printf '%s\n' "$1" >"$tmp_dir/power/BAT0/charge_now"
  else
    rm -f "$tmp_dir/power/BAT0/charge_now"
  fi
}

write_upower() {
  local state=$1
  local time_line=${2:-}
  local extra=${3:-}

  {
    printf '  native-path:          BAT0\n'
    printf '  state:                %s\n' "$state"
    printf '  energy:               28.3 Wh\n'
    printf '  energy-full:          56.7 Wh\n'
    printf '  energy-rate:          7.3 W\n'
    [[ -n $time_line ]] && printf '  %s\n' "$time_line"
    printf '  percentage:           51%%\n'
    [[ -n $extra ]] && printf '%s\n' "$extra"
  } >"$tmp_dir/upower-info"

  cat >"$tmp_dir/bin/upower" <<STUB
#!/bin/bash

if [[ \$1 == "-e" ]]; then
  echo "/org/freedesktop/UPower/devices/battery_BAT0"
  exit 0
fi

if [[ \$1 == "-i" ]]; then
  cat "$tmp_dir/upower-info"
  exit 0
fi

exit 1
STUB
  chmod +x "$tmp_dir/bin/upower"
}

run_status() {
  local now=${1:-}
  local supply=${2:-$tmp_dir/power}
  local state_dir=${3:-$tmp_dir/state}
  local shell_flag="--shell"
  local -a command=(
    "$ROOT/bin/omarchy-battery-status"
  )

  if (($# >= 4)); then
    shell_flag=$4
  fi

  [[ -n $shell_flag ]] && command+=("$shell_flag")

  if [[ -n $now ]]; then
    OMARCHY_BATTERY_NOW=$now \
      OMARCHY_POWER_SUPPLY_PATH=$supply \
      OMARCHY_BATTERY_STATE_DIR=$state_dir \
      PATH="$tmp_dir/bin:$PATH" \
      "${command[@]}"
  else
    env -u OMARCHY_BATTERY_NOW \
      OMARCHY_POWER_SUPPLY_PATH=$supply \
      OMARCHY_BATTERY_STATE_DIR=$state_dir \
      PATH="$tmp_dir/bin:$PATH" \
      "${command[@]}"
  fi
}

fresh_state() {
  local name=$1

  rm -rf "$tmp_dir/states/$name"
  mkdir -p "$tmp_dir/states/$name"
  printf '%s\n' "$tmp_dir/states/$name"
}

# The single-shot fixture has no charge counter and no remembered samples.
reset_supply
write_upower discharging "time to empty:        2.5 hours"
single_state=$(fresh_state single)
single_output=$(run_status "" "$tmp_dir/power" "$single_state")

require_field "battery status reports percentage" "$single_output" percentage "51%"
require_field "battery status reports state" "$single_output" state "discharging"
require_field "battery status reports live sysfs power rate" "$single_output" rate "10.8W"
require_field "battery status reports full capacity" "$single_output" size "56Wh"
require_field "battery status reports remaining time" "$single_output" time "2h 30m"

# A second look a few seconds later keeps the first hour when UPower jumps.
reset_supply
write_upower discharging "time to empty:        11 hours"
hold_state=$(fresh_state hold)
hold_output=$(run_status 1000 "$tmp_dir/power" "$hold_state")
require_field "battery status prints the first UPower hour" "$hold_output" time "11h"
require_field "battery status keeps sysfs watts on the first look" "$hold_output" rate "10.8W"

write_upower discharging "time to empty:        3 hours"
hold_output=$(run_status 1005 "$tmp_dir/power" "$hold_state")
require_field "battery status keeps the 11 hour across a short gap" "$hold_output" time "11h"
require_field "battery status keeps sysfs watts when UPower time jumps" "$hold_output" rate "10.8W"

reset_supply
write_upower discharging "time to empty:        45 minutes"
minutes_state=$(fresh_state minutes)
minutes_output=$(run_status 2000 "$tmp_dir/power" "$minutes_state")
require_field "battery status prints a minute-only UPower time" "$minutes_output" time "45m"

reset_supply
write_upower discharging ""
empty_time_state=$(fresh_state empty-time)
empty_time_output=$(run_status 3000 "$tmp_dir/power" "$empty_time_state")
grep -Fx $'time\t' <<<"$empty_time_output" >/dev/null || fail "battery status leaves a missing UPower time empty" "$empty_time_output"

# A different supply's memory cannot change this fixture's first reading.
reset_supply
mkdir -p "$tmp_dir/other/BAT0"
printf '900000\n' >"$tmp_dir/other/BAT0/current_now"
printf '12000000\n' >"$tmp_dir/other/BAT0/voltage_now"
write_upower discharging "time to empty:        11 hours"
isolated_state=$(fresh_state isolated)
run_status 4000 "$tmp_dir/other" "$isolated_state" >/dev/null
write_upower discharging "time to empty:        2.5 hours"
isolated_output=$(run_status 4005 "$tmp_dir/power" "$isolated_state")
require_field "battery status ignores another supply's memory" "$isolated_output" time "2h 30m"

# No runtime directory means nothing is remembered.
reset_supply
write_upower discharging "time to empty:        11 hours"
env -u XDG_RUNTIME_DIR -u OMARCHY_BATTERY_STATE_DIR \
  OMARCHY_BATTERY_NOW=5000 \
  OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" \
  PATH="$tmp_dir/bin:$PATH" \
  "$ROOT/bin/omarchy-battery-status" --shell >/dev/null
write_upower discharging "time to empty:        3 hours"
unset_output=$(
  env -u XDG_RUNTIME_DIR -u OMARCHY_BATTERY_STATE_DIR \
    OMARCHY_BATTERY_NOW=5005 \
    OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power" \
    PATH="$tmp_dir/bin:$PATH" \
    "$ROOT/bin/omarchy-battery-status" --shell
)
require_field "battery status does not remember time without a runtime dir" "$unset_output" time "3h"

# Corrupt memory is an empty memory.
reset_supply
write_upower discharging "time to empty:        11 hours"
corrupt_state=$(fresh_state corrupt)
run_status 6000 "$tmp_dir/power" "$corrupt_state" >/dev/null
mapfile -t corrupt_files < <(find "$corrupt_state" -type f -print)
(( ${#corrupt_files[@]} > 0 )) || fail "battery status writes a memory file"
for corrupt_file in "${corrupt_files[@]}"; do
  printf 'garbage\n' >"$corrupt_file"
done
write_upower discharging "time to empty:        2.5 hours"
corrupt_output=$(run_status 6005 "$tmp_dir/power" "$corrupt_state")
require_field "battery status treats corrupt memory as empty" "$corrupt_output" time "2h 30m"

# A charge counter that keeps falling toward a 3 hour drain walks the hour
# over a few minutes, and one refresh does not leap there.
reset_supply
walk_charge=6000000
set_charge "$walk_charge"
write_upower discharging "time to empty:        11 hours"
walk_state=$(fresh_state walk)
walk_output=$(run_status 100000 "$tmp_dir/power" "$walk_state")
require_field "battery status starts a counter walk from the UPower hour" "$walk_output" time "11h"
require_field "battery status keeps sysfs watts during a counter walk" "$walk_output" rate "10.8W"

walk_now=100000
walk_prev_secs=39600
walk_prev_charge=$walk_charge
for _step in $(seq 1 48); do
  walk_now=$((walk_now + 5))
  walk_charge=$((walk_charge - 2778))
  set_charge "$walk_charge"
  write_upower discharging "time to empty:        3 hours"
  walk_output=$(run_status "$walk_now" "$tmp_dir/power" "$walk_state")
  require_field "battery status keeps sysfs watts while the counter walks" "$walk_output" rate "10.8W"
  walk_secs=$(duration_seconds "$(field time "$walk_output")")
  (( walk_secs >= 0 )) || fail "battery status prints a duration during the walk" "$walk_output"
  walk_used=$((walk_prev_secs - walk_prev_secs * walk_charge / walk_prev_charge))
  walk_drop=$((walk_prev_secs - walk_secs))
  if (( walk_drop > walk_used + 3600 )); then
    fail "battery status leaped more than an hour past the charge used" "drop=${walk_drop}s used=${walk_used}s time=$(field time "$walk_output")"
  fi
  walk_prev_secs=$walk_secs
  walk_prev_charge=$walk_charge
done

walk_time=$(field time "$walk_output")
walk_hour=${walk_time%%h*}
[[ $walk_hour != "11" ]] || fail "battery status moves off an 11 hour reading over a few minutes" "$walk_time"
walk_secs=$(duration_seconds "$walk_time")
if (( walk_secs <= 3 * 3600 )); then
  fail "battery status stays above the 3 hour drain after a few minutes" "$walk_time"
fi

# The same charge a few seconds later does not adopt UPower's new hour.
reset_supply
set_charge 6000000
write_upower discharging "time to empty:        11 hours"
same_charge_state=$(fresh_state same-charge)
run_status 200000 "$tmp_dir/power" "$same_charge_state" >/dev/null
write_upower discharging "time to empty:        3 hours"
same_charge_output=$(run_status 200005 "$tmp_dir/power" "$same_charge_state")
require_field "battery status keeps the hour when charge does not move" "$same_charge_output" time "11h"
require_field "battery status keeps sysfs watts when charge does not move" "$same_charge_output" rate "10.8W"

# Hours of wall clock with an unchanged counter are not drain.
reset_supply
set_charge 6000000
write_upower discharging "time to empty:        11 hours"
sleep_state=$(fresh_state sleep)
run_status 300000 "$tmp_dir/power" "$sleep_state" >/dev/null
write_upower discharging "time to empty:        3 hours"
sleep_output=$(run_status 320000 "$tmp_dir/power" "$sleep_state")
require_field "battery status keeps the hour across sleep" "$sleep_output" time "11h"

# A long gap that uses only a few charge steps adjusts by that use.
# A few seconds of a faster drain keep that hour. A minute of it starts the walk.
reset_supply
set_charge 6000000
write_upower discharging "time to empty:        11 hours"
quanta_state=$(fresh_state quanta)
run_status 400000 "$tmp_dir/power" "$quanta_state" >/dev/null
set_charge 5997000
write_upower discharging "time to empty:        30 minutes"
quanta_output=$(run_status 420000 "$tmp_dir/power" "$quanta_state")
require_field "battery status follows a few charge steps across a long gap" "$quanta_output" time "10h 59m"

quanta_charge=5997000
quanta_now=420000
for _step in 1 2 3; do
  quanta_now=$((quanta_now + 5))
  quanta_charge=$((quanta_charge - 2778))
  set_charge "$quanta_charge"
  write_upower discharging "time to empty:        3 hours"
  quanta_output=$(run_status "$quanta_now" "$tmp_dir/power" "$quanta_state")
done
quanta_time=$(field time "$quanta_output")
quanta_secs=$(duration_seconds "$quanta_time")
if (( quanta_secs < 10 * 3600 + 50 * 60 )); then
  fail "battery status keeps the hour during a few seconds of faster drain" "$quanta_time"
fi

for _step in $(seq 1 12); do
  quanta_now=$((quanta_now + 5))
  quanta_charge=$((quanta_charge - 2778))
  set_charge "$quanta_charge"
  write_upower discharging "time to empty:        3 hours"
  quanta_output=$(run_status "$quanta_now" "$tmp_dir/power" "$quanta_state")
done
quanta_after=$(duration_seconds "$(field time "$quanta_output")")
if (( quanta_after >= quanta_secs || quanta_after <= 4 * 3600 )); then
  fail "battery status starts toward a faster drain after about a minute" "$(field time "$quanta_output")"
fi

# Half the pack used across a long gap follows that energy, not UPower.
reset_supply
set_charge 6000000
write_upower discharging "time to empty:        11 hours"
half_state=$(fresh_state half)
run_status 500000 "$tmp_dir/power" "$half_state" >/dev/null
set_charge 3000000
write_upower discharging "time to empty:        20 minutes"
half_output=$(run_status 520000 "$tmp_dir/power" "$half_state")
require_field "battery status follows a large charge drop across a long gap" "$half_output" time "5h 30m"

# With no counter, a UPower blend walks toward the new time and one run does not arrive.
reset_supply
write_upower discharging "time to empty:        11 hours"
blend_state=$(fresh_state blend)
run_status 600000 "$tmp_dir/power" "$blend_state" >/dev/null
write_upower discharging "time to empty:        3 hours"
blend_output=$(run_status 600060 "$tmp_dir/power" "$blend_state")
blend_time=$(field time "$blend_output")
blend_secs=$(duration_seconds "$blend_time")
[[ $blend_time != "3h" && $blend_time != "3h 0m" ]] || fail "battery status does not adopt a blended UPower time in one run" "$blend_time"
if (( blend_secs >= 11 * 3600 || blend_secs <= 3 * 3600 )); then
  fail "battery status moves toward a blended UPower time" "$blend_time"
fi
blend_output=$(run_status 600180 "$tmp_dir/power" "$blend_state")
blend_later=$(duration_seconds "$(field time "$blend_output")")
if (( blend_later >= blend_secs || blend_later <= 3 * 3600 )); then
  fail "battery status keeps moving toward a blended UPower time" "$(field time "$blend_output")"
fi

# No counter, and UPower stops giving a time. Those looks are not 0s samples.
reset_supply
write_upower discharging "time to empty:        2 hours"
missing_state=$(fresh_state missing-estimate)
run_status 1100000 "$tmp_dir/power" "$missing_state" >/dev/null
write_upower discharging ""
missing_now=1100000
for _step in $(seq 1 60); do
  missing_now=$((missing_now + 5))
  missing_output=$(run_status "$missing_now" "$tmp_dir/power" "$missing_state")
  require_field "battery status keeps 2h while later UPower times are missing" "$missing_output" time "2h"
done

# A gap longer than the blend, and no counter, prints the current UPower time.
reset_supply
write_upower discharging "time to empty:        11 hours"
snap_state=$(fresh_state snap)
run_status 700000 "$tmp_dir/power" "$snap_state" >/dev/null
write_upower discharging "time to empty:        3 hours"
snap_output=$(run_status 700181 "$tmp_dir/power" "$snap_state")
require_field "battery status starts over when a UPower blend expires" "$snap_output" time "3h"

# Plugging in shows the charge time on both outputs.
reset_supply
write_upower discharging "time to empty:        11 hours"
charge_state=$(fresh_state charge)
run_status 800000 "$tmp_dir/power" "$charge_state" >/dev/null
write_upower charging "time to full:         2 hours"
charge_output=$(run_status 800010 "$tmp_dir/power" "$charge_state")
require_field "battery status prints charge time after plugging in" "$charge_output" time "2h"
require_field "battery status reports charging after plugging in" "$charge_output" state "charging"
charge_human=$(run_status 800010 "$tmp_dir/power" "$charge_state" "")
[[ $charge_human == *"2h"* && $charge_human == *"to full"* ]] || fail "battery status human line shows the charge time" "$charge_human"

# Holding leaves the discharge memory in place.
reset_supply
set_charge 6000000
write_upower discharging "time to empty:        11 hours"
hold_memory_state=$(fresh_state hold-memory)
run_status 900000 "$tmp_dir/power" "$hold_memory_state" >/dev/null
mkdir -p "$tmp_dir/power/AC"
printf 'Mains\n' >"$tmp_dir/power/AC/type"
printf '1\n' >"$tmp_dir/power/AC/online"
write_upower pending-charge "time to full:         3 hours" $'  charge-start-threshold: 50%\n  charge-end-threshold:   80%'
holding_output=$(run_status 900010 "$tmp_dir/power" "$hold_memory_state")
require_field "battery status reports holding" "$holding_output" state "holding"
require_field "battery status keeps the raw UPower time while holding" "$holding_output" time "3h"
holding_human=$(run_status 900010 "$tmp_dir/power" "$hold_memory_state" "")
[[ $holding_human == "Battery 51%  ·  Holding at 50-80%  ·  10.8W / 56Wh" ]] || fail "battery status holding line stays the threshold line" "$holding_human"
rm -rf "$tmp_dir/power/AC"
write_upower discharging "time to empty:        3 hours"
held_output=$(run_status 900020 "$tmp_dir/power" "$hold_memory_state")
require_field "battery status resumes the discharge hour after holding" "$held_output" time "11h"

# A full battery clears the old countdown.
reset_supply
write_upower discharging "time to empty:        11 hours"
full_state=$(fresh_state full)
run_status 910000 "$tmp_dir/power" "$full_state" >/dev/null
write_upower fully-charged ""
full_output=$(run_status 910010 "$tmp_dir/power" "$full_state")
grep -Fx $'time\t' <<<"$full_output" >/dev/null || fail "battery status leaves time empty when full" "$full_output"
write_upower discharging "time to empty:        4 hours"
full_output=$(run_status 910020 "$tmp_dir/power" "$full_state")
require_field "battery status starts a new discharge after a full battery" "$full_output" time "4h"

# No battery exits quietly and leaves memory alone.
reset_supply
write_upower discharging "time to empty:        2.5 hours"
quiet_state=$(fresh_state quiet)
run_status 920000 "$tmp_dir/power" "$quiet_state" >/dev/null
cp -a "$quiet_state" "$tmp_dir/quiet-copy"
cat >"$tmp_dir/bin/upower" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$tmp_dir/bin/upower"
quiet_output=$(run_status 920005 "$tmp_dir/power" "$quiet_state")
[[ -z $quiet_output ]] || fail "battery status prints nothing when upower lists no battery" "$quiet_output"
diff -r "$quiet_state" "$tmp_dir/quiet-copy" >/dev/null || fail "battery status leaves memory unchanged when no battery is listed"

# Overlapping runs both print a time.
reset_supply
write_upower discharging "time to empty:        2.5 hours"
overlap_state=$(fresh_state overlap)
overlap_a=$tmp_dir/overlap-a
overlap_b=$tmp_dir/overlap-b
run_status 930000 "$tmp_dir/power" "$overlap_state" >"$overlap_a" &
run_status 930000 "$tmp_dir/power" "$overlap_state" >"$overlap_b" &
wait
grep -q $'^time\t' "$overlap_a" || fail "battery status prints a time when another run holds the lock" "$(<"$overlap_a")"
grep -q $'^time\t' "$overlap_b" || fail "battery status prints a time from the overlapping run" "$(<"$overlap_b")"

# The human duration is the shell time.
reset_supply
write_upower discharging "time to empty:        2.5 hours"
shared_state=$(fresh_state shared)
shared_shell=$(run_status 940000 "$tmp_dir/power" "$shared_state")
shared_human=$(run_status 940000 "$tmp_dir/power" "$shared_state" "")
shared_time=$(field time "$shared_shell")
[[ $shared_human == *"$shared_time"* ]] || fail "battery status human line uses the shell time" "$shared_human"

if matches=$(rg -n 'omarchy-battery-(capacity|remaining|remaining-time)' "$ROOT/bin" "$ROOT/test" "$ROOT/shell" "$ROOT/docs"); then
  fail "battery status owns capacity and remaining calculations" "$matches"
fi

pass "battery status keeps a steady time left"
