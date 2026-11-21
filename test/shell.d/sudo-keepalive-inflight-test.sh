#!/bin/bash
#
# A refresh that is still running when the caller exits must finish before the
# EXIT trap's sudo -k. Otherwise that refresh can write the timestamp record
# back after it was revoked.

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

script="$ROOT/bin/omarchy-sudo-keepalive"
test_tmp=$(mktemp -d)
mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
exit_now="$test_tmp/exit_now"
release="$test_tmp/release"
caller_pid=""

# Release both waits and reap children before deleting the temp dir, so a
# failed assertion cannot leave the background caller holding the suite pipe.
cleanup() {
  touch "$exit_now" "$release" 2>/dev/null || true
  if [[ -n $caller_pid ]]; then
    kill "$caller_pid" 2>/dev/null || true
    wait "$caller_pid" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$mock_bin"

# The refresh blocks until the harness releases it, so cleanup can begin while
# it is still in flight instead of racing a fixed sleep.
cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash

case ${1:-} in
-v | -k)
  printf '%s\n' "$1" >>"$TEST_CALLS"
  ;;
-n)
  printf 'refresh-start\n' >>"$TEST_CALLS"
  while [[ ! -f $TEST_RELEASE ]]; do
    /bin/sleep 0.01
  done
  printf 'refresh-done\n' >>"$TEST_CALLS"
  ;;
*)
  echo "unexpected sudo command: $*" >&2
  exit 90
  ;;
esac
SH
chmod +x "$mock_bin/sudo"

PATH="$mock_bin:$PATH" \
  TEST_CALLS="$calls" \
  TEST_RELEASE="$release" \
  OMARCHY_SUDO_KEEPALIVE_INTERVAL=0.05 \
  OMARCHY_SUDO_KEEPALIVE_MAX_REFRESHES=5 \
  bash -c '
    source "$1"
    while [[ ! -f $2 ]]; do
      /bin/sleep 0.01
    done
  ' bash "$script" "$exit_now" &
caller_pid=$!

for _ in $(seq 200); do
  grep -qx refresh-start "$calls" 2>/dev/null && break
  /bin/sleep 0.01
done
grep -qx refresh-start "$calls" ||
  fail "refresh starts before the caller exits" "$(cat "$calls" 2>/dev/null || true)"

# Caller exits into the EXIT trap while the refresh is still blocked.
touch "$exit_now"

# Let kill be delivered and wait begin on the in-flight refresh. The caller
# must still be alive here: it is blocked in wait until we release the mock.
/bin/sleep 0.05
kill -0 "$caller_pid" 2>/dev/null ||
  fail "caller exited before the refresh was released" "$(cat "$calls")"

touch "$release"
wait "$caller_pid"
caller_pid=""

grep -qx refresh-done "$calls" ||
  fail "in-flight refresh completes before revoke" "$(cat "$calls")"

done_line=$(grep -nx 'refresh-done' "$calls" | head -n 1 | cut -d: -f1)
revoke_line=$(grep -nx -- '-k' "$calls" | head -n 1 | cut -d: -f1)
[[ -n $done_line && -n $revoke_line ]] && (( done_line < revoke_line )) ||
  fail "refresh-done precedes sudo -k" "$(cat "$calls")"
pass "sudo -k runs after any in-flight refresh"
