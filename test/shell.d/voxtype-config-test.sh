#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_bin=$(mktemp -d)
log_file=$(mktemp)

cleanup() {
  rm -rf "$test_bin"
  rm -f "$log_file"
}
trap cleanup EXIT

# Stub the presence check so the branch is decided by the test, not by whether
# this machine happens to have Voxtype installed.
cat >"$test_bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
[[ -z $TEST_VOXTYPE_PRESENT ]]
STUB

cat >"$test_bin/omarchy-launch-floating-terminal-with-presentation" <<'STUB'
#!/bin/bash
echo "present:$*" >>"$TEST_LOG"
STUB

cat >"$test_bin/omarchy-restart-shell" <<'STUB'
#!/bin/bash
echo "restart-shell" >>"$TEST_LOG"
STUB

chmod +x "$test_bin"/*

run_config() {
  : >"$log_file"
  TEST_VOXTYPE_PRESENT="$1" TEST_LOG="$log_file" PATH="$test_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-voxtype-config"
}

run_config ""

grep -qx 'present:omarchy-voxtype-install' "$log_file" ||
  fail "missing Voxtype routes the config command to the installer" "$(cat "$log_file")"
grep -q 'voxtype configure' "$log_file" &&
  fail "missing Voxtype does not run voxtype configure"
grep -qx 'restart-shell' "$log_file" &&
  fail "missing Voxtype does not restart the shell"

run_config 1

grep -qx 'present:voxtype configure' "$log_file" ||
  fail "installed Voxtype opens its configuration" "$(cat "$log_file")"
grep -qx 'restart-shell' "$log_file" ||
  fail "installed Voxtype restarts the shell to pick up the new config"
grep -q 'omarchy-voxtype-install' "$log_file" &&
  fail "installed Voxtype does not re-run the installer"

pass "Voxtype config guards against a missing Voxtype"
