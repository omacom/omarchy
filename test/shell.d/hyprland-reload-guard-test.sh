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
state_dir="$test_tmp/omarchy/hyprland-reload-guard"
pause_marker="$state_dir.active"
hyprctl_log="$test_tmp/hyprctl.log"
setpriv_log="$test_tmp/setpriv.log"
fake_hyprctl="$test_tmp/hyprctl"
fake_setpriv="$test_tmp/setpriv"
signature="test-signature"
# The uid verify_socket_owner checks against comes from the runtime_dir path
# itself, so it has to be this process's real uid: that's who ends up owning
# the sockets bound below.
own_uid=$(id -u)
own_gid=$(id -g "$own_uid")
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

# Stands in for setpriv so the test can run unprivileged: it records the
# privilege-drop request it was given, then execs straight through to the
# (fake) hyprctl without actually dropping anything. Proving the real
# kernel-enforced connect()-time permission check this fix relies on would
# require genuinely being root; what this test can and does prove is that
# hyprctl_instance asks to drop to the correct uid/gid before every
# connection, which is the half of the fix under this script's own control.
cat >"$fake_setpriv" <<'BASH'
#!/bin/bash

printf '%s\n' "$*" >>"$FAKE_SETPRIV_LOG"
while [[ $# -gt 0 && $1 != "--" ]]; do shift; done
shift
exec "$@"
BASH
chmod 0755 "$fake_setpriv"

FAKE_HYPRCTL_LOG="$hyprctl_log" \
  FAKE_SETPRIV_LOG="$setpriv_log" \
  HYPRCTL="$fake_hyprctl" \
  SETPRIV="$fake_setpriv" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_EFFECTIVE_UID=0 \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause 2>"$test_tmp/pause-stderr"

state_file="$state_dir/$signature"
[[ -f $state_file ]] || fail "reload guard stores Hyprland state on pause"
expected_state=$(printf '%s\tfalse\tfalse' "$runtime_dir")
grep -Fx "$expected_state" "$state_file" >/dev/null || fail "reload guard records previous Hyprland reload settings"
grep -F 'hl.config({ misc = { disable_autoreload = true }, debug = { suppress_errors = true } })' "$hyprctl_log" >/dev/null || fail "reload guard pauses autoreload with hyprctl eval"
pass "reload guard pauses live Hyprland reloads"

grep -F -- "--reuid=$own_uid --regid=$own_gid --clear-groups --no-new-privs -- $fake_hyprctl --instance $signature" "$setpriv_log" >/dev/null ||
  fail "reload guard drops root to the socket owner's uid/gid before connecting" "$(cat "$setpriv_log")"
pass "reload guard runs hyprctl as the claimed socket owner, not as root"

[[ ! -e $state_dir/$dead_signature ]] || fail "reload guard skips instances hyprctl cannot reach"
[[ ! -s $test_tmp/pause-stderr ]] || fail "reload guard pauses dead Hyprland instances quietly" "$(cat "$test_tmp/pause-stderr")"
pass "reload guard skips dead Hyprland instances quietly"

: >"$hyprctl_log"
: >"$setpriv_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  FAKE_SETPRIV_LOG="$setpriv_log" \
  HYPRCTL="$fake_hyprctl" \
  SETPRIV="$fake_setpriv" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_EFFECTIVE_UID=0 \
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
#
# This runs under its own run_root/state_dir, separate from runtime_dir
# above: that tree's own signature socket is still live (its python process
# merely exited after bind -- the socket node itself persists), so reusing
# it here would make resume's "must not touch anything" assertions below
# race against that instance's own, perfectly legitimate, resume activity.
toctou_run_root="$test_tmp/run-user-toctou"
toctou_state_dir="$test_tmp/state-toctou"
toctou_runtime_dir="$toctou_run_root/$own_uid"
toctou_signature="toctou-signature"
victim_socket="$test_tmp/victim.socket.sock"
mkdir -p "$toctou_runtime_dir/hypr/$toctou_signature"
bind_socket "$toctou_runtime_dir/hypr/$toctou_signature/.socket.sock"
bind_socket "$victim_socket"

: >"$hyprctl_log"
: >"$setpriv_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  FAKE_SETPRIV_LOG="$setpriv_log" \
  HYPRCTL="$fake_hyprctl" \
  SETPRIV="$fake_setpriv" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_EFFECTIVE_UID=0 \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$toctou_run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$toctou_state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause

toctou_state_file="$toctou_state_dir/$toctou_signature"
[[ -f $toctou_state_file ]] || fail "reload guard stores state for the instance before it is swapped"
grep -F -- "--instance $toctou_signature" "$hyprctl_log" >/dev/null ||
  fail "reload guard pauses the instance before it is swapped"

# The swap: the path pause trusted is no longer a real socket.
rm -f "$toctou_runtime_dir/hypr/$toctou_signature/.socket.sock"
ln -s "$victim_socket" "$toctou_runtime_dir/hypr/$toctou_signature/.socket.sock"

: >"$hyprctl_log"
: >"$setpriv_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  FAKE_SETPRIV_LOG="$setpriv_log" \
  HYPRCTL="$fake_hyprctl" \
  SETPRIV="$fake_setpriv" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_EFFECTIVE_UID=0 \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$toctou_run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$toctou_state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" resume 2>"$test_tmp/resume-stderr"

[[ ! -s $hyprctl_log ]] || fail "reload guard must not connect through a socket path swapped after pause" "$(cat "$hyprctl_log")"
[[ ! -s $setpriv_log ]] || fail "reload guard must not even attempt a privilege drop for a swapped socket path" "$(cat "$setpriv_log")"
[[ ! -e $toctou_state_file ]] || fail "reload guard clears state even for a rejected swap"
[[ ! -s $test_tmp/resume-stderr ]] || fail "reload guard rejects a swapped socket quietly" "$(cat "$test_tmp/resume-stderr")"
pass "reload guard refuses to connect through a socket path swapped after pause"

# --- pause marker: state_dir being root-only must not hide "is paused" too ---
# omarchy-hyprland-monitor-watch runs as the session user and gates its own
# reload recovery on `paused`, so that check has to work even though
# state_dir (which carries other users' runtime_dir paths and settings) is
# root-only. Regression coverage for mkdir -p -m 0700 having applied that
# mode to state_dir's *parent* too, which silently broke the old
# compgen-based check for anyone but root.
parent_dir="${state_dir%/*}"

OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "reload guard reports itself unpaused before any transaction"

: >"$hyprctl_log"
: >"$setpriv_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  FAKE_SETPRIV_LOG="$setpriv_log" \
  HYPRCTL="$fake_hyprctl" \
  SETPRIV="$fake_setpriv" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_EFFECTIVE_UID=0 \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause

[[ -e $pause_marker ]] || fail "reload guard creates a pause marker on pause"
marker_mode=$(stat -c '%a' -- "$pause_marker")
[[ $marker_mode == "644" ]] || fail "pause marker must be world-readable" "mode $marker_mode"
state_dir_mode=$(stat -c '%a' -- "$state_dir")
[[ $state_dir_mode == "700" ]] || fail "state_dir itself must stay root-only" "mode $state_dir_mode"
parent_mode=$(stat -c '%a' -- "$parent_dir")
[[ $parent_mode != "700" ]] || fail "state_dir's parent must stay traversable by other users" "mode $parent_mode"

OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused ||
  fail "reload guard reports itself paused once the marker exists"
pass "reload guard exposes a world-readable pause marker without widening state_dir"

: >"$hyprctl_log"
: >"$setpriv_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  FAKE_SETPRIV_LOG="$setpriv_log" \
  HYPRCTL="$fake_hyprctl" \
  SETPRIV="$fake_setpriv" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_EFFECTIVE_UID=0 \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" resume

[[ ! -e $pause_marker ]] || fail "reload guard clears the pause marker on resume"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "reload guard reports itself unpaused once resume completes"
pass "reload guard clears the pause marker once resume completes"

# A pacman transaction can run with zero live Hyprland sessions to pause; the
# marker still has to flip on for its duration, and resume still has to clear
# it even though state_dir itself is never created in that case.
empty_run_root="$test_tmp/run-user-empty"
empty_state_dir="$test_tmp/empty/hyprland-reload-guard"
empty_pause_marker="$empty_state_dir.active"

OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$empty_run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$empty_state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause

[[ -e $empty_pause_marker ]] || fail "reload guard marks a transaction in flight even with no live instances"
[[ ! -e $empty_state_dir ]] || fail "reload guard must not create state_dir when there is nothing to pause"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$empty_state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused ||
  fail "reload guard reports itself paused during a transaction with no live instances"

OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$empty_state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" resume

[[ ! -e $empty_pause_marker ]] || fail "reload guard clears the pause marker even when state_dir never existed"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$empty_state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "reload guard reports itself unpaused after a no-instance transaction resumes"
pass "reload guard tracks a transaction in flight even when nothing is paused"
