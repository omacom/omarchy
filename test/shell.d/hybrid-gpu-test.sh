#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
exit 1
STUB

cat >"$fake_bin/sleep" <<'STUB'
#!/bin/bash
:
STUB

cat >"$fake_bin/gum" <<'STUB'
#!/bin/bash
exit 1
STUB

cat >"$fake_bin/supergfxctl" <<'STUB'
#!/bin/bash
attempts_file="$TEST_TMP/attempts"
attempts=0
[[ -f $attempts_file ]] && attempts=$(<"$attempts_file")
attempts=$((attempts + 1))
printf '%s\n' "$attempts" >"$attempts_file"

if (( attempts < ${SUCCEED_ON_ATTEMPT:-999} )); then
  exit 1
fi

echo Hybrid
STUB

chmod +x "$fake_bin"/*

TEST_TMP="$test_tmp" SUCCEED_ON_ATTEMPT=3 \
  PATH="$fake_bin:$PATH" bash "$ROOT/bin/omarchy-toggle-hybrid-gpu" >/dev/null

[[ $(<"$test_tmp/attempts") == "3" ]] || fail "hybrid GPU mode query retries transient failures"
pass "hybrid GPU mode query recovers from a transient supergfxd failure"

rm -f "$test_tmp/attempts"

set +e
error=$(
  TEST_TMP="$test_tmp" \
    PATH="$fake_bin:$PATH" bash "$ROOT/bin/omarchy-toggle-hybrid-gpu" 2>&1 >/dev/null
)
status=$?
set -e

(( status != 0 )) || fail "hybrid GPU mode query fails when supergfxd stays unavailable"
[[ $(<"$test_tmp/attempts") == "3" ]] || fail "hybrid GPU mode query stops after three attempts"
grep -qF 'supergfxd is not responding' <<<"$error" ||
  fail "hybrid GPU mode query explains how to diagnose supergfxd" "$error"
pass "hybrid GPU mode query fails clearly instead of hanging"

cat >"$fake_bin/supergfxctl" <<'STUB'
#!/bin/bash
trap '' TERM
/usr/bin/sleep 30
STUB
chmod +x "$fake_bin/supergfxctl"

set +e
output=$(TEST_TMP="$test_tmp" PATH="$fake_bin:$PATH" timeout 25s bash "$ROOT/bin/omarchy-toggle-hybrid-gpu" 2>&1)
status=$?
set -e

(( status != 124 )) || fail "hybrid GPU mode query terminates a blocked client"
(( status != 0 )) || fail "hybrid GPU mode query reports a blocked client as unavailable"
grep -qF 'supergfxd is not responding' <<<"$output" ||
  fail "hybrid GPU mode query diagnoses a blocked client" "$output"
pass "hybrid GPU mode query kills a client that ignores the timeout signal"

# supergfxd persists the sleep hook's transient Vfio request. The toggle used
# to have no case for that mode and exited with "unknown mode", so the machine
# had no supported way back to either end of the cycle. Reported in #11808.
cat >"$fake_bin/supergfxctl" <<'STUB'
#!/bin/bash
echo Vfio
STUB

cat >"$fake_bin/gum" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$fake_bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_TMP/sudo-calls"
STUB

cat >"$fake_bin/omarchy-system-reboot" <<'STUB'
#!/bin/bash
printf 'rebooted\n' >"$TEST_TMP/rebooted"
STUB

chmod +x "$fake_bin"/*
rm -f "$test_tmp/sudo-calls" "$test_tmp/rebooted"

set +e
output=$(TEST_TMP="$test_tmp" PATH="$fake_bin:$PATH" bash "$ROOT/bin/omarchy-toggle-hybrid-gpu" 2>&1)
status=$?
set -e

((status == 0)) || fail "hybrid GPU toggle accepts a saved Vfio mode" "$output"
grep -qF 'unknown mode' <<<"$output" &&
  fail "hybrid GPU toggle no longer rejects a saved Vfio mode" "$output"
grep -qF '"mode": "Integrated"' "$test_tmp/sudo-calls" ||
  fail "hybrid GPU toggle restores the Integrated mode from Vfio" "$(<"$test_tmp/sudo-calls")"
[[ -f $test_tmp/rebooted ]] || fail "hybrid GPU toggle reboots after leaving Vfio"
pass "hybrid GPU toggle recovers a machine left in Vfio mode"
