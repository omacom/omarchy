#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/test/shell.d"
cp "$ROOT/test/"{shell,all} "$test_dir/test/"
cp "$SHELL_TEST_DIR/base-test.sh" "$test_dir/test/shell.d/"

# Run the real runners in a tiny fixture tree, without recursing into this test.
run_suite() {
  status=0
  output=$(bash "$test_dir/test/${1:-shell}" 2>&1) || status=$?
}

run_suite
(( status == 1 )) && [[ $output == *"No shell tests found"* ]] ||
  fail "an empty suite fails instead of counting the helper as a test" "$output"
pass "an empty suite fails instead of counting the helper as a test"

cat >"$test_dir/test/shell.d/a-pass-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
captured=$(skip "captured fixture output is not a skipped check")
pass "the command skips an optional action"
SH
run_suite
(( status == 0 )) && [[ $output == *"All 1 test files passed."* ]] ||
  fail "passing assertions and captured skip output do not mark a file skipped" "$output"
pass "passing assertions and captured skip output do not mark a file skipped"

cat >"$test_dir/test/shell.d/b-partial-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "static check"
skip "first unavailable runtime check"
skip "second unavailable runtime check"
pass "check after skips"
SH
cat >"$test_dir/test/shell.d/c-skipped-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
unset WAYLAND_DISPLAY
require_compositor "runtime fixture"
fail "unreachable after compositor skip"
SH
cat >"$test_dir/test/shell.d/z-last-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
pass "last file ran"
SH
run_suite
(( status == 0 )) && [[ $output == *"4 test files completed without failures; 2 had skipped checks."* ]] ||
  fail "whole and partial skips are counted once per file and remain successful" "$output"
[[ $output == *"ok - check after skips"* && $output == *"ok - last file ran"* ]] ||
  fail "skip returns normally and later files still run" "$output"
[[ $output == *$'Skipped checks in 2 of 4 test files:\n  test/shell.d/b-partial-test.sh\n  test/shell.d/c-skipped-test.sh\n'* ]] ||
  fail "the summary identifies only files with skipped checks" "$output"
pass "whole and partial skips are visible without failing or stopping the suite"

cat >"$test_dir/test/shell.d/d-failed-test.sh" <<'SH'
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
skip "unavailable check before failure"
echo "failure detail" >&2
false
pass "unreachable after failure"
SH
run_suite
(( status == 1 )) && [[ $output == *$'1 of 5 test files failed:\n  test/shell.d/d-failed-test.sh'* ]] ||
  fail "a failure after a skip still fails the suite through the output pipe" "$output"
[[ $output == *"Skipped checks in 3 of 5 test files:"* && $output == *"failure detail"* && $output == *"ok - last file ran"* && $output != *"ok - unreachable after failure"* ]] ||
  fail "failures preserve skip reporting, diagnostics, errexit, and later tests" "$output"
pass "failures remain fatal while skips and later test results stay visible"

printf '#!/bin/bash\necho "CLI fixture passed"\n' >"$test_dir/test/cli"
chmod +x "$test_dir/test/cli"
run_suite all
(( status == 1 )) && [[ $output == *"CLI fixture passed"* && $output == *"Skipped checks in 3 of 5 test files:"* && $output == *$'1 of 2 suites failed:\n  test/shell'* ]] ||
  fail "the aggregate runner preserves shell failures and skip reporting" "$output"
pass "the aggregate runner preserves shell failures and skip reporting"

# Run the actual graphical runner without a graphical session. Only hyprctl is
# faked; the harmless acceptance fixture records which session it inherited.
acceptance_root="$test_dir/acceptance"
acceptance_runtime="$acceptance_root/runtime"
acceptance_artifacts="$acceptance_root/artifacts"
mkdir -p "$acceptance_root/test/acceptance.d" "$acceptance_root/product/bin" "$acceptance_root/home"
cp "$ROOT/test/acceptance" "$acceptance_root/test/"
cat >"$acceptance_root/test/acceptance.d/selected-session-test.sh" <<'SH'
set -euo pipefail
printf '%s\n' "$HYPRLAND_INSTANCE_SIGNATURE" >"$OMARCHY_ACCEPTANCE_DIR/selected-session"
SH
cat >"$acceptance_root/product/bin/hyprctl" <<'SH'
#!/bin/bash
set -euo pipefail
signature=${HYPRLAND_INSTANCE_SIGNATURE:-}
if [[ ${1:-} == -i ]]; then
  signature=$2
  shift 2
fi
[[ $# == 2 && $1 == -j && $2 == monitors && -n $signature ]] || exit 1
printf '%s\n' "$signature" >>"$OMARCHY_ACCEPTANCE_DIR/probed-sessions"
[[ -f $XDG_RUNTIME_DIR/hypr/$signature/reachable ]]
SH
chmod +x "$acceptance_root/product/bin/hyprctl"

reset_acceptance_sessions() {
  rm -rf "$acceptance_runtime/hypr" "$acceptance_artifacts"
  mkdir -p "$acceptance_runtime/hypr/older-live" "$acceptance_runtime/hypr/newer-live" "$acceptance_runtime/hypr/newest-dead"
  touch "$acceptance_runtime/hypr/older-live/reachable" "$acceptance_runtime/hypr/newer-live/reachable"
  touch -d '2000-01-01 00:00:00' "$acceptance_runtime/hypr/older-live"
  touch -d '2000-01-02 00:00:00' "$acceptance_runtime/hypr/newer-live"
  touch -d '2000-01-03 00:00:00' "$acceptance_runtime/hypr/newest-dead"
}

run_acceptance_fixture() {
  local signature=${1:-}
  local -a environment=(env -u HYPRLAND_INSTANCE_SIGNATURE
    HOME="$acceptance_root/home" OMARCHY_PATH="$acceptance_root/product"
    XDG_RUNTIME_DIR="$acceptance_runtime" DBUS_SESSION_BUS_ADDRESS="unix:path=$acceptance_runtime/bus"
    OMARCHY_ACCEPTANCE_DIR="$acceptance_artifacts" OMARCHY_ACCEPTANCE_BOOT_TIMEOUT=0
    DISPLAY=:fixture LANG=C.UTF-8 WAYLAND_DISPLAY=fixture)
  [[ -z $signature ]] || environment+=("HYPRLAND_INSTANCE_SIGNATURE=$signature")
  acceptance_status=0
  acceptance_output=$(timeout 5 "${environment[@]}" bash "$acceptance_root/test/acceptance" 2>&1) || acceptance_status=$?
}

assert_acceptance_session() {
  local expected=$1 description=$2
  (( acceptance_status == 0 )) && [[ -f $acceptance_artifacts/selected-session && $(cat "$acceptance_artifacts/selected-session") == "$expected" ]] ||
    fail "$description" "$acceptance_output"
  pass "$description"
}

reset_acceptance_sessions
run_acceptance_fixture older-live
assert_acceptance_session older-live "acceptance preserves a reachable exported session despite newer live and dead directories"

reset_acceptance_sessions
run_acceptance_fixture
assert_acceptance_session newer-live "acceptance discovers the newest reachable session when no signature is exported"

reset_acceptance_sessions
run_acceptance_fixture missing-export
assert_acceptance_session newer-live "acceptance replaces an unreachable exported session with the newest reachable one"

reset_acceptance_sessions
touch "$acceptance_runtime/hypr/newest-file"
touch -d '2000-01-04 00:00:00' "$acceptance_runtime/hypr/newest-file"
run_acceptance_fixture
if grep -Fxq newest-file "$acceptance_artifacts/probed-sessions"; then
  fail "acceptance does not probe an ordinary runtime file as a compositor" "$acceptance_output"
fi
assert_acceptance_session newer-live "acceptance ignores a newer ordinary runtime file while discovering a live session"

reset_acceptance_sessions
rm "$acceptance_runtime/hypr/older-live/reachable" "$acceptance_runtime/hypr/newer-live/reachable"
run_acceptance_fixture
(( acceptance_status == 1 )) && [[ ! -e $acceptance_artifacts/selected-session && $acceptance_output == *"Hyprland session never came up"* ]] ||
  fail "acceptance fails at the boot deadline without running fixtures when no session is reachable" "$acceptance_output"
pass "acceptance fails at the boot deadline without running fixtures when no session is reachable"
