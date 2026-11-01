#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# verify_socket_owner (the fix for the TOCTOU socket-swap finding) stats a
# real .socket.sock node, so the fixture needs one bound for real rather than
# faked at the hyprctl-binary level like the rest of this test.
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_root="$test_tmp/run-user"
state_dir="$test_tmp/state"
hyprctl_log="$test_tmp/hyprctl.log"
fake_hyprctl="$test_tmp/hyprctl"
signature="test-signature"
# The uid verify_socket_owner checks against comes from the runtime_dir path
# itself, so it has to be this process's real uid: that's who ends up owning
# the sockets bound below.
own_uid=$(id -u)
runtime_dir="$run_root/$own_uid"

dead_signature="dead-signature"

mkdir -p "$runtime_dir/hypr/$signature" "$runtime_dir/hypr/$dead_signature"

bind_socket() {
  python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' "$1"
}
bind_socket "$runtime_dir/hypr/$signature/.socket.sock"
bind_socket "$runtime_dir/hypr/$dead_signature/.socket.sock"

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

# --- TOCTOU socket-swap: verify_socket_owner must block the attack ---
# Simulates the finding this fix closes: pause discovers a real, self-owned
# socket and records state for it; before resume runs, that same path is
# replaced with a symlink into a different socket. The real exploit swaps in
# another user's live socket so root's resume-time connection -- which
# bypasses the target socket's permissions -- carries the paused eval payload
# into that other session. A symlink to any other socket proves the same gap:
# verify_socket_owner has to reject the swapped path on its own stat, not on
# whose socket it ends up pointing to.
toctou_signature="toctou-signature"
victim_socket="$test_tmp/victim.socket.sock"
mkdir -p "$runtime_dir/hypr/$toctou_signature"
bind_socket "$runtime_dir/hypr/$toctou_signature/.socket.sock"
bind_socket "$victim_socket"

: >"$hyprctl_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause

toctou_state_file="$state_dir/$toctou_signature"
[[ -f $toctou_state_file ]] || fail "reload guard stores state for the instance before it is swapped"
grep -F -- "--instance $toctou_signature" "$hyprctl_log" >/dev/null ||
  fail "reload guard pauses the instance before it is swapped"

# The swap: the path pause trusted is no longer a real socket.
rm -f "$runtime_dir/hypr/$toctou_signature/.socket.sock"
ln -s "$victim_socket" "$runtime_dir/hypr/$toctou_signature/.socket.sock"

: >"$hyprctl_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" resume 2>"$test_tmp/resume-stderr"

[[ ! -s $hyprctl_log ]] || fail "reload guard must not connect through a socket path swapped after pause" "$(cat "$hyprctl_log")"
[[ ! -e $toctou_state_file ]] || fail "reload guard clears state even for a rejected swap"
[[ ! -s $test_tmp/resume-stderr ]] || fail "reload guard rejects a swapped socket quietly" "$(cat "$test_tmp/resume-stderr")"
pass "reload guard refuses to connect through a socket path swapped after pause"

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
