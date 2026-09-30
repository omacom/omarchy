#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update
test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"

# script(1) is where the update starts logging, ahead of every step it runs.
for step in script omarchy-update-lock omarchy-update-requires-free-space; do
  rm -f "$stub_bin/$step"
  cat >"$stub_bin/$step" <<'STUB'
#!/bin/bash
printf '%s\n' "${0##*/}" >>"$TEST_LOG"
STUB
  chmod +x "$stub_bin/$step"
done

run_update() {
  : >"$test_tmp/calls"
  TEST_LOG="$test_tmp/calls" PATH="$stub_bin:$PATH" \
    "$@" "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$test_tmp/output" 2>&1
}

# A hardened kernel can disable user namespaces, and with them the only root here.
if unshare --user --map-root-user true 2>/dev/null; then
  for logged in '' 1; do
    if run_update unshare --user --map-root-user env OMARCHY_UPDATE_LOGGED="$logged"; then
      fail "root-run updates fail" "$(cat "$test_tmp/output")"
    fi
    [[ ! -s $test_tmp/calls ]] || fail "root updates never start logging or mutate user state" "$(cat "$test_tmp/calls")"
    grep -q 'without sudo' "$test_tmp/output" || fail "root updates explain the correct invocation" "$(cat "$test_tmp/output")"
  done
  pass "root is rejected before logging, locking, packages and migrations"
else
  skip "no unprivileged user namespace; skipping the root invocation"
fi

run_update env -u OMARCHY_UPDATE_LOGGED || fail "normal desktop users enter the update flow" "$(cat "$test_tmp/output")"
[[ $(<"$test_tmp/calls") == script ]] || fail "normal desktop users enter the update flow" "$(cat "$test_tmp/calls")"
pass "normal users retain the update entry point"
