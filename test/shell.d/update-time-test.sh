#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
mkdir -p "$stub_bin"
: >"$call_log"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
exit "${SUDO_STATUS:-0}"
SH
chmod +x "$stub_bin/sudo"

run_update_time() {
  : >"$call_log"
  PATH="$stub_bin:$PATH" \
    CALL_LOG="$call_log" \
    SUDO_STATUS="${1:-0}" \
    bash "$ROOT/bin/omarchy-update-time" >"$test_tmp/out" 2>&1
}

run_update_time 0 || fail "restarting time synchronization reports a failure"
grep -q 'Updating time...' "$test_tmp/out" ||
  fail "restarting time synchronization announces itself"
grep -qxF 'sudo systemctl restart systemd-timesyncd' "$call_log" ||
  fail "time synchronization restarts systemd-timesyncd"
pass "time synchronization restarts systemd-timesyncd"

if run_update_time 1; then
  fail "a failed restart still reports success"
fi
pass "a failed restart reports the failure"
