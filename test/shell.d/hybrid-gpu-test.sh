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


# The products bound supergfxctl queries at 1s/3s (plus a 1s kill-after);
# shorten those bounds here instead of waiting them out against the
# blocked stubs. Other durations pass through untouched.
cat >"$fake_bin/timeout" <<'STUB'
#!/bin/bash
args=()
for arg in "$@"; do
  case $arg in
    --kill-after=1s) arg="--kill-after=0.2s" ;;
    1s | 3s) arg="0.2s" ;;
  esac
  args+=("$arg")
done
exec /usr/bin/timeout "${args[@]}"
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
case $1 in
  /usr/bin/mktemp) printf '%s\n' "${@: -1}" | sed 's/XXXXXX$/abc123/' ;;
  sed) [[ -z ${SUDO_SED_FAILS:-} ]] ;;
esac
STUB

cat >"$fake_bin/omarchy-system" <<'STUB'
#!/bin/bash
[[ $1 == "reboot" ]] || exit 2
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

# The installed hook is the copy that stranded the machine in Vfio, so the
# recovery replaces it before the saved mode arms it again.
hook_line=$(grep -n -m1 'mv -Tf -- .* /usr/lib/systemd/system-sleep/force-igpu$' "$test_tmp/sudo-calls" | cut -d: -f1)
mode_line=$(grep -n -m1 '"mode": "Integrated"' "$test_tmp/sudo-calls" | cut -d: -f1)
[[ -n $hook_line ]] || fail "hybrid GPU toggle replaces the force-igpu hook when leaving Vfio" "$(<"$test_tmp/sudo-calls")"
(( hook_line < mode_line )) || fail "hybrid GPU toggle replaces the hook before restoring Integrated"
pass "hybrid GPU toggle replaces the sleep hook that left the machine in Vfio"

rm -f "$test_tmp/sudo-calls" "$test_tmp/rebooted"

set +e
output=$(TEST_TMP="$test_tmp" SUDO_SED_FAILS=1 PATH="$fake_bin:$PATH" bash "$ROOT/bin/omarchy-toggle-hybrid-gpu" 2>&1)
status=$?
set -e

((status != 0)) || fail "hybrid GPU toggle reports a failed Vfio recovery"
[[ ! -e $test_tmp/rebooted ]] || fail "hybrid GPU toggle does not reboot when it cannot restore Integrated"
pass "hybrid GPU toggle stops before rebooting when the Vfio recovery write fails"

marker="$test_tmp/marker"

# The hook calls root-owned absolute paths and keeps its marker under /run.
# Neither is writable from a test, so run a copy with the /usr/bin prefix
# dropped and the marker moved. Both edits are textual; the case blocks, the
# set -e behavior and the switch_mode order are the shipped ones.
hook="$test_tmp/force-igpu"
sed -e "s#/usr/bin/supergfxctl#$fake_bin/supergfxctl#g" \
  -e 's#/usr/bin/##g' \
  -e "s#^restore_marker=.*#restore_marker=$marker#" \
  "$ROOT/default/systemd/system-sleep/force-igpu" >"$hook"
chmod +x "$hook"

# Request every mode successfully, but never report Vfio back. That is the
# failure in the journal on #11808: "Could not confirm the GPU transition to
# Vfio mode".
cat >"$fake_bin/supergfxctl" <<'STUB'
#!/bin/bash
case "$1" in
  -m)
    printf '%s\n' "$2" >>"$TEST_TMP/requested"
    ;;
  -g)
    echo Hybrid
    ;;
esac
STUB

chmod +x "$fake_bin"/*

: >"$marker"
rm -f "$test_tmp/requested"

set +e
output=$(TEST_TMP="$test_tmp" PATH="$fake_bin:$PATH" "$hook" post suspend 2>&1)
set -e

grep -qxF 'Vfio' "$test_tmp/requested" ||
  fail "resume hook detaches the dGPU through Vfio first" "$output"
grep -qxF 'Integrated' "$test_tmp/requested" ||
  fail "resume hook restores Integrated after an unconfirmed Vfio switch" "$(<"$test_tmp/requested")"
pass "resume hook restores Integrated even when the Vfio switch is not confirmed"

# The restore itself did not confirm either, so the marker has to survive for
# the next resume to retry.
[[ -f $marker ]] || fail "resume hook keeps its marker when the restore fails"
pass "resume hook keeps its marker for the next attempt"
