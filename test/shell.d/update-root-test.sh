#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
# Substitute only the identity check, without requiring root or a user namespace.
sed 's/(( EUID == 0 ))/(( TEST_EUID == 0 ))/' "$ROOT/bin/omarchy-update" >"$test_tmp/update"
cat >"$test_tmp/bin/script" <<'STUB'
#!/bin/bash
echo logging >>"$TEST_LOG"
exit 0
STUB
chmod +x "$test_tmp/bin/script"
export PATH="$test_tmp/bin:$PATH" TEST_LOG="$test_tmp/calls"
unset OMARCHY_UPDATE_LOGGED

for logged in '' 1; do
  if TEST_EUID=0 OMARCHY_UPDATE_LOGGED="$logged" bash "$test_tmp/update" -y >"$test_tmp/output" 2>&1; then
    fail "root-run updates fail"
  fi
  [[ ! -e $TEST_LOG ]] || fail "root updates never start logging or mutate user state"
  grep -q 'without sudo' "$test_tmp/output" || fail "root updates explain the correct invocation"
done
pass "root is rejected before logging, locking, packages and migrations"

TEST_EUID=1000 bash "$test_tmp/update" -y
[[ $(<"$TEST_LOG") == logging ]] || fail "normal desktop users enter the update flow"
pass "normal users retain the update entry point"
