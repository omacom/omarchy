#!/bin/bash
#
# omarchy-sudo-keepalive exists so a long pacman/yay install does not re-prompt
# mid-run. It must still be time-bounded: an abandoned or SIGKILLed install must
# not keep refreshing the cached credential, and a clean exit must revoke it.

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

script="$ROOT/bin/omarchy-sudo-keepalive"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
sleeps="$test_tmp/sleeps"
mkdir -p "$mock_bin"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash

# Drop a leading -A from askpass wrappers so assertions stay stable.
[[ ${1:-} == -A ]] && shift
printf '%s\n' "$*" >>"$TEST_CALLS"

case ${1:-} in
-v)
  exit 0
  ;;
-n)
  [[ ${2:-} == "true" || ${2:-} == "/usr/bin/true" ]]
  ;;
-k)
  exit 0
  ;;
*)
  echo "unexpected sudo command: $*" >&2
  exit 90
  ;;
esac
SH

cat >"$mock_bin/sleep" <<'SH'
#!/bin/bash

printf 'sleep %s\n' "$*" >>"$TEST_SLEEPS"
# Tiny real delay so the background loop can schedule without spinning the CPU.
exec /bin/sleep 0.01
SH

chmod +x "$mock_bin/sudo" "$mock_bin/sleep"

run_keepalive() {
  local max_refreshes=$1
  local hold_seconds=$2

  : >"$calls"
  : >"$sleeps"

  PATH="$mock_bin:$PATH" \
    TEST_CALLS="$calls" \
    TEST_SLEEPS="$sleeps" \
    OMARCHY_SUDO_KEEPALIVE_INTERVAL=0.01 \
    OMARCHY_SUDO_KEEPALIVE_MAX_REFRESHES="$max_refreshes" \
    bash -c '
      source "$1"
      /bin/sleep "$2"
    ' bash "$script" "$hold_seconds"
}

# Bound: with a max of three refreshes, the loop must stop even while the
# sourcing shell is still alive. An unbounded while-true would keep going.
run_keepalive 3 0.2
mapfile -t sudo_calls <"$calls"
[[ ${sudo_calls[0]:-} == "-v" ]] || fail "keepalive prompts once up front" "$(cat "$calls")"

refresh_count=0
for call in "${sudo_calls[@]}"; do
  [[ $call == "-n true" || $call == "-n /usr/bin/true" ]] && ((refresh_count++)) || true
done
(( refresh_count == 3 )) ||
  fail "keepalive stops after OMARCHY_SUDO_KEEPALIVE_MAX_REFRESHES" \
    "expected 3 refreshes, got $refresh_count"$'\n'"$(cat "$calls")"

sleep_count=$(wc -l <"$sleeps")
(( sleep_count == 3 )) ||
  fail "each refresh is paced by one sleep" "sleeps=$sleep_count"$'\n'"$(cat "$sleeps")"
pass "keepalive stops after its refresh ceiling"

# Clean exit must revoke the cached credential, not leave it for timestamp_timeout.
run_keepalive 5 0.05
grep -qx -- '-k' "$calls" ||
  fail "clean exit revokes the sudo timestamp with sudo -k" "$(cat "$calls")"
pass "clean exit revokes the sudo timestamp"

# SIGKILL skips EXIT traps. The loop must notice the parent is gone and stop
# refreshing instead of extending the credential until timestamp_timeout.
: >"$calls"
: >"$sleeps"
loop_pid_file="$test_tmp/loop_pid"

PATH="$mock_bin:$PATH" \
  TEST_CALLS="$calls" \
  TEST_SLEEPS="$sleeps" \
  OMARCHY_SUDO_KEEPALIVE_INTERVAL=0.02 \
  OMARCHY_SUDO_KEEPALIVE_MAX_REFRESHES=100 \
  bash -c '
    source "$1"
    printf "%s\n" "$SUDO_KEEPALIVE_PID" >"$2"
    # Replace this shell so SIGKILL cannot leave an orphaned sleeper behind.
    exec /bin/sleep 10
  ' bash "$script" "$loop_pid_file" &
parent_pid=$!

for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ -s $loop_pid_file ]] && break
  /bin/sleep 0.01
done
[[ -s $loop_pid_file ]] || fail "keepalive publishes its background pid"
loop_pid=$(cat "$loop_pid_file")

/bin/sleep 0.05
kill -9 "$parent_pid" 2>/dev/null || true
wait "$parent_pid" 2>/dev/null || true

# Give the loop one interval to observe the dead parent and exit.
/bin/sleep 0.08
if kill -0 "$loop_pid" 2>/dev/null; then
  kill "$loop_pid" 2>/dev/null || true
  wait "$loop_pid" 2>/dev/null || true
  fail "keepalive stops after its parent is gone" "$(cat "$calls")"
fi

refreshes_after_kill=0
mapfile -t sudo_calls <"$calls"
for call in "${sudo_calls[@]}"; do
  [[ $call == "-n true" || $call == "-n /usr/bin/true" ]] && ((refreshes_after_kill++)) || true
done
# A few refreshes before the kill are fine; a runaway loop would still be in
# the hundreds under this interval. Keep the bound tight enough to catch that.
(( refreshes_after_kill < 10 )) ||
  fail "keepalive does not keep refreshing after the parent dies" \
    "refreshes=$refreshes_after_kill"$'\n'"$(cat "$calls")"
pass "keepalive stops when its parent is gone"
