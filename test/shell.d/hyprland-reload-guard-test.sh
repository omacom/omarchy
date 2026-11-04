#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_root="$test_tmp/run-user"
state_dir="$test_tmp/state"
hyprctl_log="$test_tmp/hyprctl.log"
fake_hyprctl="$test_tmp/hyprctl"
signature="test-signature"
runtime_dir="$run_root/1000"

dead_signature="dead-signature"

mkdir -p "$runtime_dir/hypr/$signature" "$runtime_dir/hypr/$dead_signature"

cat >"$fake_hyprctl" <<'BASH'
#!/bin/bash

printf '%s\t%s\n' "$XDG_RUNTIME_DIR" "$*" >>"$FAKE_HYPRCTL_LOG"

case "$*" in
  *'--instance dead-signature '*)
    printf "Couldn't connect to %s/hypr/dead-signature/.socket.sock. (4)\n" "$XDG_RUNTIME_DIR"
    exit 4
    ;;
  *'getoption misc.disable_autoreload'*)
    printf '{"option":"misc.disable_autoreload","bool":%s,"set":true}\n' "${FAKE_DISABLE_AUTORELOAD:-false}"
    ;;
  *'getoption debug.suppress_errors'*)
    printf '{"option":"debug.suppress_errors","bool":%s,"set":true}\n' "${FAKE_SUPPRESS_ERRORS:-false}"
    ;;
  *)
    printf 'ok\n'
    ;;
esac
BASH
chmod 0755 "$fake_hyprctl"

FAKE_HYPRCTL_LOG="$hyprctl_log" \
  HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause 2>"$test_tmp/pause-stderr"

state_file="$state_dir/$signature"
[[ -f $state_file ]] || fail "reload guard stores Hyprland state on pause"
expected_state=$(printf '%s\tfalse\tfalse' "$runtime_dir")
grep -Fx "$expected_state" "$state_file" >/dev/null || fail "reload guard records previous Hyprland reload settings"
grep -F 'hl.config({ misc = { disable_autoreload = true }, debug = { suppress_errors = true } })' "$hyprctl_log" >/dev/null || fail "reload guard pauses autoreload with hyprctl eval"
pass "reload guard pauses live Hyprland reloads"

[[ ! -e $state_dir/$dead_signature ]] || fail "reload guard skips instances hyprctl cannot reach"
[[ ! -s $test_tmp/pause-stderr ]] || fail "reload guard pauses dead Hyprland instances quietly" "$(cat "$test_tmp/pause-stderr")"
pass "reload guard skips dead Hyprland instances quietly"

: >"$hyprctl_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" resume

[[ ! -e $state_file ]] || fail "reload guard clears Hyprland state after resume"
grep -F -- '--instance test-signature reload' "$hyprctl_log" >/dev/null || fail "reload guard forces one Hyprland reload after package transaction"
grep -F 'hl.config({ misc = { disable_autoreload = false }, debug = { suppress_errors = false } })' "$hyprctl_log" >/dev/null || fail "reload guard restores previous Hyprland reload settings"
pass "reload guard resumes live Hyprland reloads"

# The modeless monitor recovery loop reloads on its own schedule, so it needs to
# ask whether a transaction is in flight.
rm -rf "$state_dir"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "reload guard reports itself unpaused before any transaction"

mkdir -p "$state_dir"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "an empty state directory is not a paused transaction"

touch "$state_dir/some-signature"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused ||
  fail "reload guard reports itself paused during a transaction"
pass "reload guard reports whether a transaction is holding reloads"

# The same transaction that pauses reloads can replace the Hyprland package.
# Reloading the process whose executable was unlinked wedges the session.
rm -rf "$state_dir"
: >"$hyprctl_log"
proc_root="$test_tmp/proc"
mkdir -p "$runtime_dir/hypr/$signature" "$proc_root/4242"
printf '4242\nwayland-1\n' >"$runtime_dir/hypr/$signature/hyprland.lock"
touch "$test_tmp/Hyprland (deleted)"
ln -s "$test_tmp/Hyprland (deleted)" "$proc_root/4242/exe"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause
: >"$hyprctl_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  OMARCHY_HYPRLAND_PROC_ROOT="$proc_root" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" resume
if grep -F -- '--instance test-signature reload' "$hyprctl_log"; then
  fail "reload guard reloaded a Hyprland whose executable was replaced"
fi
grep -F 'hl.config({ misc = { disable_autoreload = false }, debug = { suppress_errors = false } })' "$hyprctl_log" >/dev/null ||
  fail "reload guard still restores settings when it skips the reload"
pass "reload guard does not reload a replaced Hyprland binary"
