#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# first-run must not abort the whole unit list when one unit is missing
# (issue #10484). systemctl enable with multiple names validates the full list
# first; a single missing name enables nothing.

script="$ROOT/install/user/first-run/enable-user-units.sh"
[[ -f $script ]] || fail "enable-user-units.sh exists"

grep -F 'for unit in' "$script" >/dev/null ||
  fail "enable-user-units enables units one at a time"
grep -F 'could not enable' "$script" >/dev/null ||
  fail "enable-user-units warns when a unit fails"
# Must not keep the multi-arg enable that aborts the whole list under set -e.
if grep -E 'enable --now[[:space:]]+\\$' "$script" >/dev/null; then
  fail "enable-user-units must not multi-arg enable under one set -e line"
fi
pass "enable-user-units enables units one at a time"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
log="$test_tmp/systemctl.log"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_SYSTEMCTL_LOG"
# daemon-reload always succeeds.
[[ $1 == "--user" && $2 == "daemon-reload" ]] && exit 0
# is-enabled: treat any previously successful enable --now as enabled.
if [[ $1 == "--user" && $2 == "is-enabled" ]]; then
  unit=${4:-$3}
  [[ $unit == --quiet ]] && unit=$4
  if grep -Fq "enable --now $unit" "$OMARCHY_TEST_SYSTEMCTL_LOG" 2>/dev/null; then
    exit 0
  fi
  exit 1
fi
# enable --now: fail only the injected missing unit.
if [[ $1 == "--user" && $2 == "enable" && $3 == "--now" ]]; then
  unit=$4
  if [[ $unit == "${OMARCHY_TEST_MISSING_UNIT:-}" ]]; then
    echo "Failed to enable unit: Unit $unit does not exist" >&2
    exit 1
  fi
  exit 0
fi
exit 0
SH
chmod +x "$mock_bin/systemctl"

# Missing unit in the middle must not stop later units.
: >"$log"
export OMARCHY_TEST_SYSTEMCTL_LOG="$log"
export OMARCHY_TEST_MISSING_UNIT="omarchy-sleep-lock.service"
PATH="$mock_bin:/usr/bin:/bin" bash "$script" >"$test_tmp/out" 2>"$test_tmp/err" || status=$?
status=${status:-0}
(( status == 0 )) || fail "enable-user-units exits 0 when some units still enable" "status=$status err=$(cat "$test_tmp/err")"

grep -F 'enable --now bt-agent.service' "$log" >/dev/null ||
  fail "enable-user-units still tries bt-agent" "$(cat "$log")"
grep -F 'enable --now omarchy-sleep-lock.service' "$log" >/dev/null ||
  fail "enable-user-units still tries the missing unit" "$(cat "$log")"
grep -F 'enable --now omarchy-crash-watch.service' "$log" >/dev/null ||
  fail "enable-user-units continues after a missing unit" "$(cat "$log")"
grep -F 'could not enable omarchy-sleep-lock.service' "$test_tmp/err" >/dev/null ||
  fail "enable-user-units warns about the missing unit" "$(cat "$test_tmp/err")"
pass "enable-user-units continues after a missing unit"

# Prove the old multi-arg failure mode for contrast (documentation of the bug).
: >"$log"
cat >"$mock_bin/systemctl-atomic" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_SYSTEMCTL_LOG"
if [[ $* == *enable* && $* == *does-not-exist* ]]; then
  echo "Failed to enable unit: Unit does-not-exist.service does not exist" >&2
  exit 1
fi
exit 0
SH
chmod +x "$mock_bin/systemctl-atomic"
if PATH="$mock_bin:$PATH" systemctl-atomic --user enable --now bt-agent.service does-not-exist.service 2>/dev/null; then
  fail "multi-arg enable should fail when one unit is missing"
fi
# No partial enables recorded as separate lines for the good unit alone — the
# atomic call is one line that failed entirely.
lines=$(grep -c 'enable --now' "$log" || true)
(( lines == 1 )) || fail "atomic multi-arg enable is a single failed call" "$(cat "$log")"
pass "multi-arg enable fails the whole list when one unit is missing"

# All units present → clean success, no warnings.
: >"$log"
: >"$test_tmp/err"
unset OMARCHY_TEST_MISSING_UNIT
PATH="$mock_bin:/usr/bin:/bin" bash "$script" >"$test_tmp/out" 2>"$test_tmp/err"
[[ ! -s $test_tmp/err ]] || fail "enable-user-units is quiet when every unit enables" "$(cat "$test_tmp/err")"
for unit in bt-agent.service omarchy-recover-internal-monitor.service omarchy-sleep-lock.service \
  omarchy-migrate-notify.service omarchy-fcitx5.service omarchy-crash-watch.service; do
  grep -F "enable --now $unit" "$log" >/dev/null ||
    fail "enable-user-units enables $unit" "$(cat "$log")"
done
pass "enable-user-units enables every shipped unit when all exist"
