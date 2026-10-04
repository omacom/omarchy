#!/bin/bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

failing_script="$work_dir/fail.sh"
log_file="$work_dir/install.log"
cat >"$failing_script" <<'SCRIPT'
echo "about to fail"
false
SCRIPT

set +e
(
  set -euo pipefail
  export OMARCHY_INSTALL_LOG_FILE="$log_file"
  source "$ROOT/install/helpers/logging.sh"
  run_logged "$failing_script"
  echo "unreachable"
)
status=$?
set -e

(( status != 0 )) || fail "run_logged returns failing script status"
grep -q "Starting: $failing_script" "$log_file" || fail "run_logged logs script start"
grep -q "about to fail" "$log_file" || fail "run_logged captures script output"
grep -q "Failed: $failing_script (exit code: 1)" "$log_file" || fail "run_logged logs failed script before errexit exits"

stdout_log="$work_dir/stdout.log"
set +e
(
  set -euo pipefail
  export OMARCHY_INSTALL_LOG_FILE="$work_dir/iso-owned.log"
  export OMARCHY_LOG_TO_STDOUT=1
  source "$ROOT/install/helpers/logging.sh"
  run_logged "$failing_script"
) >"$stdout_log" 2>&1
stdout_status=$?
set -e

(( stdout_status != 0 )) || fail "stdout run_logged returns failing script status"
[[ ! -e $work_dir/iso-owned.log ]] || fail "stdout logging mode does not write directly to install log"
grep -q "Starting: $failing_script" "$stdout_log" || fail "stdout logging mode emits script start"
grep -q "about to fail" "$stdout_log" || fail "stdout logging mode emits script output"
grep -q "Failed: $failing_script (exit code: 1)" "$stdout_log" || fail "stdout logging mode emits failure marker"

pass "run_logged records failures under errexit"

mode_log="$work_dir/mode.log"
OMARCHY_INSTALL_LOG_FILE="$mode_log" \
  bash -c 'source "$1"; start_install_log >/dev/null' bash "$ROOT/install/helpers/logging.sh" \
  >/dev/null 2>&1

mode=$(stat -c '%a' "$mode_log")
[[ $mode == 644 ]] || fail "start_install_log leaves the install log 0644" "got 0$mode"

# The log is uploaded by omarchy-upload-log, which runs unprivileged, so it must
# stay world-readable. It must not be world-writable: only root writes it, and
# omarchy-upload-log publishes its contents to logs.omarchy.org for the user to
# share, so a local append would forge a shared artifact.
[[ $mode != 666 && $mode != 664 && $mode != 622 ]] ||
  fail "install log is not group- or world-writable" "got 0$mode"

pass "start_install_log keeps the install log readable but not writable by others"
