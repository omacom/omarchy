#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/power/BAT0" "$tmp_dir/power/AC"
export OMARCHY_POWER_SUPPLY_PATH="$tmp_dir/power"
export OMARCHY_BATTERY_GUARD_STATE_DIR="$tmp_dir/state"
export OMARCHY_BATTERY_GUARD_CLOCK_PATH="$tmp_dir/clock"
export OMARCHY_BATTERY_GUARD_MAX_ONESHOT_CYCLES=70
export OMARCHY_BATTERY_GUARD_DRY_RUN=false
export EVENTS="$tmp_dir/events" SCENARIO=""
export PATH="$tmp_dir/bin:$PATH"
unset OMARCHY_BATTERY_GUARD_THRESHOLD_PERCENT OMARCHY_BATTERY_GUARD_COUNTDOWN_SECONDS

cat >"$tmp_dir/bin/sleep" <<'SH'
#!/bin/bash
read -r now _ <"$OMARCHY_BATTERY_GUARD_CLOCK_PATH"
printf '%s 0\n' "$((now + 1))" >"$OMARCHY_BATTERY_GUARD_CLOCK_PATH"
if [[ $SCENARIO == "plug" && $now == "46" ]]; then
  printf '1\n' >"$OMARCHY_POWER_SUPPLY_PATH/AC/online"
  printf 'Charging\n' >"$OMARCHY_POWER_SUPPLY_PATH/BAT0/status"
fi
if [[ $SCENARIO == "collapse" && $now == "5" ]]; then
  printf '20\n' >"$OMARCHY_POWER_SUPPLY_PATH/BAT0/time_to_empty_now"
fi
if [[ $SCENARIO == missing-* || $SCENARIO == "invalid-capacity" || $SCENARIO == "removed-battery" ]]; then
  if (( now == 5 )); then
    case $SCENARIO in
      invalid-capacity) printf 'unavailable\n' >"$OMARCHY_POWER_SUPPLY_PATH/BAT0/capacity" ;;
      removed-battery) rm -rf "$OMARCHY_POWER_SUPPLY_PATH/BAT0" ;;
      *) rm -f "$OMARCHY_POWER_SUPPLY_PATH/BAT0/capacity" ;;
    esac
  fi
  if [[ $SCENARIO == "missing-plug" ]] && (( now == 10 )); then
    printf '1\n' >"$OMARCHY_POWER_SUPPLY_PATH/AC/online"
    printf 'Charging\n' >"$OMARCHY_POWER_SUPPLY_PATH/BAT0/status"
  fi
fi
if [[ $SCENARIO == "unknown" && $now == "5" ]]; then
  printf 'Unknown\n' >"$OMARCHY_POWER_SUPPLY_PATH/BAT0/status"
  printf '1\n' >"$OMARCHY_POWER_SUPPLY_PATH/AC/online"
fi
SH
cat >"$tmp_dir/bin/timeout" <<'SH'
#!/bin/bash
[[ $1 != --kill-after=* ]] || shift
shift
if [[ $1 == "/bin/bash" && $2 == "/usr/share/omarchy/default/battery-guard/close-windows" ]]; then
  shift
  if [[ $3 == "--snapshot" ]]; then
    printf 'snapshot\n' >>"$EVENTS"
    if [[ $SCENARIO != "empty-snapshot" ]]; then
      printf 'fixture 123 wayland-1 0xabc\n'
      if [[ $SCENARIO == "close-partial" || $SCENARIO == "crash" ]]; then
        printf 'fixture 123 wayland-1 0xdef\n'
      fi
    fi
    exit 0
  fi
  [[ $3 == "--close-one" ]] || exit 1
  printf 'close %s\n' "$(cat "$OMARCHY_BATTERY_GUARD_CLOCK_PATH")" >>"$EVENTS"
  printf 'dispatch %s\n' "$7" >>"$EVENTS"
  # Assert write-ahead state at the exact entry to a dispatch invocation.
  grep -Eq '^snapshot:[0-9]+=1$' "$OMARCHY_BATTERY_GUARD_STATE_DIR/state" || exit 99
  grep -Eq "^done:[0-9]+=fixture $7$" "$OMARCHY_BATTERY_GUARD_STATE_DIR/state" || exit 99
  printf 'persisted-before-dispatch\n' >>"$EVENTS"
  if [[ $SCENARIO == "reject-once" && ! -e $EVENTS.rejected ]]; then
    touch "$EVENTS.rejected"
    exit 2
  fi
  if [[ $SCENARIO == "crash" && $7 == "0xabc" ]]; then
    kill -KILL "$GUARD_PID"
    exit 124
  fi
  if [[ $SCENARIO == "close-partial" && $7 == "0xabc" ]]; then exit 124; fi
  if [[ $SCENARIO == "close-plug" ]]; then
    printf '1\n' >"$OMARCHY_POWER_SUPPLY_PATH/AC/online"
    printf 'Charging\n' >"$OMARCHY_POWER_SUPPLY_PATH/BAT0/status"
  fi
else
  exec "$@"
fi
SH
cat >"$tmp_dir/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'toast %s\n' "$*" >>"$EVENTS"
if [[ $SCENARIO == "final-plug" && $* == *"Shutting down…"* ]]; then
  printf '1\n' >"$OMARCHY_POWER_SUPPLY_PATH/AC/online"
  printf 'Charging\n' >"$OMARCHY_POWER_SUPPLY_PATH/BAT0/status"
fi
printf '77\n'
SH
cat >"$tmp_dir/bin/systemctl" <<'SH'
#!/bin/bash
printf 'power %s %s\n' "$(cat "$OMARCHY_BATTERY_GUARD_CLOCK_PATH")" "$*" >>"$EVENTS"
[[ $SCENARIO != "power-fail" ]]
SH
chmod +x "$tmp_dir/bin/"*

reset_fixture() {
  rm -rf "$tmp_dir/state" "$tmp_dir/power/AAA" "$tmp_dir/power/BAT0" "$tmp_dir/power/BAT1"
  mkdir -p "$tmp_dir/power/BAT0"
  rm -f "$EVENTS.rejected"
  printf '0 0\n' >"$tmp_dir/clock"
  : >"$EVENTS"
  printf 'Battery\n' >"$tmp_dir/power/BAT0/type"
  printf 'Discharging\n' >"$tmp_dir/power/BAT0/status"
  printf '5\n' >"$tmp_dir/power/BAT0/capacity"
  printf '600\n' >"$tmp_dir/power/BAT0/time_to_empty_now"
  printf 'Mains\n' >"$tmp_dir/power/AC/type"
  printf '0\n' >"$tmp_dir/power/AC/online"
}
run_guard() { bash -c 'export GUARD_PID=$$; exec "$ROOT/bin/omarchy-battery-guard" --oneshot'; }

reset_fixture
printf '6\n' >"$tmp_dir/power/BAT0/capacity"
run_guard
[[ ! -s $EVENTS ]] || fail "raw 6 percent must not start countdown"

reset_fixture
run_guard
grep -Fx 'close 45 0' "$EVENTS" >/dev/null || fail "normal close gets last 15 seconds"
grep -Fx 'power 60 0 poweroff --no-wall' "$EVENTS" >/dev/null || fail "default save window lasts 60 seconds"
[[ $(grep -c '^toast ' "$EVENTS") == 4 ]] || fail "only initial, 30, 10, final notices"
[[ $(grep -c -- '-p -r 0 -t 0' "$EVENTS") == 1 ]] || fail "first toast creates ID"
[[ $(grep -c -- '-p -r 77 -t 0' "$EVENTS") == 3 ]] || fail "remaining notices replace same ID"

reset_fixture
SCENARIO=plug run_guard
! grep '^power ' "$EVENTS" >/dev/null || fail "AC during save window aborts shutdown"
grep -F -- '-r 77 -t 5000' "$EVENTS" >/dev/null || fail "cancel replaces toast and expires"

reset_fixture
SCENARIO=close-plug run_guard
! grep '^power ' "$EVENTS" >/dev/null || fail "AC during close aborts shutdown"
reset_fixture
SCENARIO=final-plug run_guard
! grep '^power ' "$EVENTS" >/dev/null || fail "AC during final notification aborts shutdown"

# Capacity loss cannot suspend an established save deadline or mask recovery.
for scenario in missing-capacity invalid-capacity removed-battery; do
  reset_fixture
  SCENARIO=$scenario run_guard
  grep -Fx 'power 60 0 poweroff --no-wall' "$EVENTS" >/dev/null || fail "$scenario preserves the active deadline"
done
for supply_type in USB_C USB_PD USB_PD_DRP; do
  reset_fixture
  printf '%s\n' "$supply_type" >"$tmp_dir/power/AC/type"
  SCENARIO=missing-plug run_guard
  ! grep '^power ' "$EVENTS" >/dev/null || fail "$supply_type charging cancels even with missing capacity"
  grep -F 'Shutdown cancelled.' "$EVENTS" >/dev/null || fail "$supply_type recovery is reported"
done
reset_fixture
rm "$tmp_dir/power/BAT0/capacity"
printf '50\n' >"$tmp_dir/power/BAT0/time_to_empty_now"
run_guard
grep -Fx 'power 20 0 poweroff --no-wall' "$EVENTS" >/dev/null || fail "valid critical runtime starts protection without capacity"
reset_fixture
rm "$tmp_dir/power/BAT0/capacity"
run_guard
[[ ! -s $EVENTS ]] || fail "missing capacity with ample runtime must not start protection"

reset_fixture
OMARCHY_BATTERY_GUARD_MAX_ONESHOT_CYCLES=46 run_guard
rm "$tmp_dir/power/BAT0/capacity"
run_guard
grep -Fx 'power 60 0 poweroff --no-wall' "$EVENTS" >/dev/null || fail "restart with missing capacity preserves the persisted deadline"

# A depleted first pack must not mask the remaining system charge.
reset_fixture
mkdir -p "$tmp_dir/power/BAT1"
printf 'Battery\n' >"$tmp_dir/power/BAT1/type"
printf 'Discharging\n' >"$tmp_dir/power/BAT1/status"
printf '100\n' >"$tmp_dir/power/BAT1/capacity"
for pack in BAT0 BAT1; do
  printf '2000000\n' >"$tmp_dir/power/$pack/energy_full"
  printf '1000000\n' >"$tmp_dir/power/$pack/power_now"
done
printf '100000\n' >"$tmp_dir/power/BAT0/energy_now"
printf '2000000\n' >"$tmp_dir/power/BAT1/energy_now"
printf '50\n' >"$tmp_dir/power/BAT0/time_to_empty_now"
run_guard
[[ ! -s $EVENTS ]] || fail "combined energy and runtime protect against a depleted first pack"
printf '100000\n' >"$tmp_dir/power/BAT1/energy_now"
run_guard
grep '^power ' "$EVENTS" >/dev/null || fail "combined charge at threshold starts protection"

reset_fixture
printf '1\n' >"$tmp_dir/power/AC/online"
run_guard
grep '^power ' "$EVENTS" >/dev/null || fail "weak adapter must not cancel protection"

reset_fixture
printf '50\n' >"$tmp_dir/power/BAT0/time_to_empty_now"
run_guard
grep -Fx 'power 20 0 poweroff --no-wall' "$EVENTS" >/dev/null || fail "short runtime reserves 30 seconds"
reset_fixture
SCENARIO=collapse run_guard
grep -Fx 'power 6 0 poweroff --no-wall' "$EVENTS" >/dev/null || fail "deteriorating runtime triggers emergency override"
! grep '^close ' "$EVENTS" >/dev/null || fail "no close delay when reserve is exhausted"

reset_fixture
SCENARIO=close-partial run_guard
[[ $(grep -c '^close ' "$EVENTS") == 2 ]] || fail "unfinished helper requests retry once with acknowledged windows excluded"
grep -Fx 'power 60 0 poweroff --no-wall' "$EVENTS" >/dev/null || fail "close retries cannot extend save deadline"

reset_fixture
OMARCHY_BATTERY_GUARD_MAX_ONESHOT_CYCLES=46 SCENARIO=close-partial run_guard
grep -Fx 'done:1000=fixture 0xabc' "$tmp_dir/state/state" >/dev/null ||
  grep -E '^done:[0-9]+=fixture 0xabc$' "$tmp_dir/state/state" >/dev/null || fail "partial close progress is persisted"
SCENARIO=close-partial run_guard
[[ $(grep -c '^close ' "$EVENTS") == 2 ]] || fail "restart retries unfinished snapshot without re-prompting completed windows"

reset_fixture
if SCENARIO=crash run_guard; then fail "fixture must interrupt the guard at dispatch entry"; fi
grep -Fx 'persisted-before-dispatch' "$EVENTS" >/dev/null || fail "attempt is on disk before dispatch starts"
SCENARIO=crash run_guard
[[ $(grep -c '^snapshot$' "$EVENTS") == 1 ]] || fail "restart must not resnapshot save dialogs"
[[ $(grep -c '^dispatch 0xabc$' "$EVENTS") == 1 ]] || fail "uncertain attempt must never be resent after crash"
[[ $(grep -c '^dispatch 0xdef$' "$EVENTS") == 1 ]] || fail "restart still closes untouched original windows"

reset_fixture
OMARCHY_BATTERY_GUARD_MAX_ONESHOT_CYCLES=46 SCENARIO=empty-snapshot run_guard
SCENARIO=empty-snapshot run_guard
[[ $(grep -c '^snapshot$' "$EVENTS") == 1 ]] || fail "empty snapshot sentinel survives restart"
! grep '^close ' "$EVENTS" >/dev/null || fail "empty snapshot never dispatches"

reset_fixture
SCENARIO=reject-once run_guard
[[ $(grep -c '^dispatch 0xabc$' "$EVENTS") == 2 ]] || fail "explicit rejection unmarks the attempt for one successful retry"
[[ $(grep -c '^snapshot$' "$EVENTS") == 1 ]] || fail "explicit rejection reuses the original snapshot"

reset_fixture
SCENARIO=unknown run_guard
grep -Fx 'power 60 0 poweroff --no-wall' "$EVENTS" >/dev/null || fail "Unknown with online adapter preserves active deadline"

reset_fixture
mkdir -p "$tmp_dir/power/AAA"
printf 'Battery\n' >"$tmp_dir/power/AAA/type"
printf 'Device\n' >"$tmp_dir/power/AAA/scope"
printf '95\n' >"$tmp_dir/power/AAA/capacity"
run_guard
grep '^power ' "$EVENTS" >/dev/null || fail "peripheral must not mask system battery"

reset_fixture
OMARCHY_BATTERY_GUARD_DRY_RUN=true run_guard
! grep -E '^(close|power) ' "$EVENTS" >/dev/null || fail "dry run never closes apps or powers off"
grep -Fx 'mode=dry-run' "$tmp_dir/state/state" >/dev/null || fail "dry run records outcome"

reset_fixture
if SCENARIO=power-fail run_guard; then fail "poweroff failure must propagate for systemd retry"; fi

reset_fixture
mkdir -p "$tmp_dir/state"
printf 'mode=$(touch %s)\n' "$tmp_dir/injected" >"$tmp_dir/state/state"
printf '6\n' >"$tmp_dir/power/BAT0/capacity"
run_guard
[[ ! -e $tmp_dir/injected ]] || fail "persisted state is data"

# Exercise the notification function with two session recipients. It must keep
# independent IDs in its caller, including the cancellation update.
sed -n '/^notify_critical() {$/,/^}$/p' "$ROOT/bin/omarchy-battery-guard" >"$tmp_dir/notify.sh"
(
  declare -A notification_ids=()
  source "$tmp_dir/notify.sh"
  session_users() { printf '1000 alice\n1001 bob\n'; }
  as_session_user() {
    printf 'user %s %s\n' "$1" "$*" >>"$tmp_dir/recipients"
    printf '%s\n' "$(($1 + 100))"
  }
  notify_critical initial
  notify_critical update
  notify_critical cancelled 5000
)
grep -E 'user 1000 .* -r 1100 -t 5000' "$tmp_dir/recipients" >/dev/null || fail "Alice retains her own replacement ID"
grep -E 'user 1001 .* -r 1101 -t 5000' "$tmp_dir/recipients" >/dev/null || fail "Bob retains his own replacement ID"

! rg 'systemctl hibernate|--force|killall|pkill' "$ROOT/bin/omarchy-battery-guard" "$ROOT/default/battery-guard/close-windows" | rg -v '^.*#' >/dev/null || fail "no forced process kills or hibernation"
pass "battery guard thresholds, toast replacement, save window and emergency actions"
