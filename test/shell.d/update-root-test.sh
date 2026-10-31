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
  # Plain sudo resets the environment, so root usually arrives without OMARCHY_PATH.
  for root_env in 'OMARCHY_UPDATE_LOGGED=' 'OMARCHY_UPDATE_LOGGED=1' '-u OMARCHY_PATH'; do
    read -ra env_args <<<"$root_env"
    if run_update unshare --user --map-root-user env "${env_args[@]}"; then
      fail "root-run updates fail" "$(cat "$test_tmp/output")"
    fi
    [[ ! -s $test_tmp/calls ]] || fail "root updates never start logging or mutate user state" "$(cat "$test_tmp/calls")"
    [[ ! -s $SUDO_TEST_LOG ]] || fail "root updates are refused before touching sudo" "$(cat "$SUDO_TEST_LOG")"
    grep -q 'without sudo' "$test_tmp/output" || fail "root updates explain the correct invocation" "$(cat "$test_tmp/output")"
  done
  pass "root is rejected before logging, locking, packages and migrations"
else
  skip "no unprivileged user namespace; skipping the root invocation"
fi

if (( EUID == 0 )); then
  skip "running as root; skipping the normal-user invocation"
else
  run_update env -u OMARCHY_UPDATE_LOGGED || fail "normal desktop users enter the update flow" "$(cat "$test_tmp/output")"
  [[ $(<"$test_tmp/calls") == "script" ]] || fail "normal desktop users enter the update flow" "$(cat "$test_tmp/calls")"
  pass "normal users retain the update entry point"
fi
