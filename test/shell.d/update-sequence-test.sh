#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update
test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"

# Every step omarchy-update runs, recorded in order with the unattended flag it
# was handed. One of them can be told to fail. omarchy-update-available is here
# so a recheck after the update would show up as an unexpected step.
steps=(
  omarchy-update-lock
  omarchy-update-requires-free-space
  omarchy-update-confirm
  omarchy-update-pkg-prune
  omarchy-snapshot
  omarchy-update-stay-awake
  omarchy-update-dev
  omarchy-update-boot
  omarchy-update-keyring
  omarchy-update-system-pkgs
  omarchy-migrate
  omarchy-hook
  omarchy-update-aur-pkgs
  omarchy-update-mise
  omarchy-update-orphan-pkgs
  omarchy-update-analyze-logs
  omarchy-shell
  omarchy-update-available
  omarchy-update-health
  omarchy-update-restart
)

for step in "${steps[@]}"; do
  rm -f "$stub_bin/$step"
  cat >"$stub_bin/$step" <<'STUB'
#!/bin/bash
printf '%s unattended=%s\n' "${0##*/}" "${OMARCHY_UPDATE_UNATTENDED:-}" >>"$STEP_LOG"
if [[ ${0##*/} == "omarchy-update-orphan-pkgs" ]]; then
  printf '%s\n' "$@" >"$STEP_LOG.orphan-args"
fi
if [[ ${0##*/} == "omarchy-shell" ]]; then
  printf '%s\n' "$*" >"$STEP_LOG.shell-args"
fi
if [[ ${0##*/} == "omarchy-update-health" ]]; then
  baseline=${OMARCHY_UPDATE_HEALTH_BASELINE:-}
  [[ -n $baseline && -d $baseline ]] || baseline=missing
  printf 'snapshot=%s baseline=%s\n' "${OMARCHY_UPDATE_HEALTH_SNAPSHOT:-}" "$baseline" >"$STEP_LOG.health"
fi
[[ ${FAILING_STEP:-} != "${0##*/}" ]] || exit 1
STUB
  chmod +x "$stub_bin/$step"
done

# OMARCHY_UPDATE_LOGGED stands in for the script(1) wrapper the update re-execs
# itself under; the stubbed lock reports itself already held.
run_update() {
  : >"$test_tmp/steps"
  STEP_LOG="$test_tmp/steps" \
    FAILING_STEP="${FAILING_STEP:-}" \
    OMARCHY_UPDATE_LOGGED=1 \
    PATH="$stub_bin:$PATH" \
    "$SUDO_TEST_ROOT/bin/omarchy-update" "$@" >"$test_tmp/out" 2>"$test_tmp/err"
}

steps_run() {
  cut -d' ' -f1 "$test_tmp/steps"
}

# Every step of a whole update, in order. $1 asks for the one a person confirms.
# Stay Awake bookends the work, so it is here twice.
expected_steps() {
  printf '%s\n' \
    omarchy-update-lock \
    omarchy-update-requires-free-space \
    ${1:+omarchy-update-confirm} \
    omarchy-update-pkg-prune \
    omarchy-snapshot \
    omarchy-update-stay-awake \
    omarchy-update-dev \
    omarchy-update-keyring \
    omarchy-update-system-pkgs \
    omarchy-migrate \
    omarchy-update-orphan-pkgs \
    omarchy-update-analyze-logs \
    omarchy-shell \
    omarchy-update-restart \
    omarchy-hook \
    omarchy-update-mise \
    omarchy-update-aur-pkgs \
    omarchy-update-boot \
    omarchy-update-stay-awake \
    omarchy-update-health \
    omarchy-update-restart
}

run_update -y || fail "an update where everything works reports a failure"
diff <(expected_steps) <(steps_run) >"$test_tmp/order" ||
  fail "an update where everything works does not run every step in order" "$(cat "$test_tmp/order")"
pass "an update where every step works runs all of them, in order"
[[ $(cat "$test_tmp/steps.orphan-args") == "-y" ]] || fail "an unattended update approves orphan removal"
pass "an unattended update approves orphan removal"
[[ $(cat "$test_tmp/steps.shell-args") == "-q omarchy.system-update clear" ]] ||
  fail "a finished update clears the shell update indicator" "$(cat "$test_tmp/steps.shell-args")"
pass "a finished update clears the shell update indicator without rechecking"

# The health report hears which units had failed before the update, from a
# list the update removes again, and that a snapshot was taken.
read -r health_snapshot health_baseline <"$test_tmp/steps.health"
[[ $health_snapshot == "snapshot=1" ]] || fail "the health report hears the update took a snapshot" "$health_snapshot"
[[ $health_baseline == baseline=/* ]] || fail "the health report gets the units that had failed before" "$health_baseline"
[[ ! -e ${health_baseline#baseline=} ]] || fail "the update removes its list of units that had failed before"
pass "the health report hears what failed before the update and that a snapshot was taken"

FAILING_STEP=omarchy-snapshot run_update -y || fail "an update without a snapshot reports a failure"
grep -qx 'snapshot=0 .*' "$test_tmp/steps.health" ||
  fail "the health report hears the update took no snapshot" "$(cat "$test_tmp/steps.health")"
pass "the health report hears when the update took no snapshot"

# With the boot files unverified the update says not to reboot, so the report
# must not be told there is a snapshot to reboot into.
FAILING_STEP=omarchy-update-boot run_update -y && fail "an update whose boot files failed verification reports success"
grep -qx 'snapshot=0 .*' "$test_tmp/steps.health" ||
  fail "the health report hears no snapshot when the boot files failed verification" "$(cat "$test_tmp/steps.health")"
pass "the health report hears no snapshot when the boot files failed verification"

grep -q '^omarchy-update-system-pkgs unattended=1$' "$test_tmp/steps" ||
  fail "-y does not mark the update unattended"
run_update </dev/null || fail "a confirmed update reports a failure"
diff <(expected_steps confirmed) <(steps_run) >"$test_tmp/order" ||
  fail "a confirmed update runs a different set of steps" "$(cat "$test_tmp/order")"
grep -q '^omarchy-update-system-pkgs unattended=$' "$test_tmp/steps" ||
  fail "an update a person confirmed is treated as unattended"
pass "-y is what marks an update unattended, not the update itself"
[[ $(cat "$test_tmp/steps.orphan-args") == "-y" ]] || fail "a confirmed update approves orphan removal"
pass "a confirmed update approves orphan removal"

# Migrations ship with the packages the upgrade installs and are written against
# them. Running them against what is still on disk is the failure this ordering
# exists to prevent, so the update stops where the packages did.
if FAILING_STEP=omarchy-update-system-pkgs run_update -y; then
  fail "an update whose packages did not upgrade passes for a whole one"
fi
for step in omarchy-migrate omarchy-hook omarchy-update-aur-pkgs omarchy-update-restart; do
  if grep -q "^$step " "$test_tmp/steps"; then
    fail "a blocked package upgrade still runs $step"
  fi
done
pass "a blocked package upgrade stops the update before it migrates"

# The health report is information only. Whatever it finds, or however it
# fails, the update still finishes and still offers the reboot.
FAILING_STEP=omarchy-update-health run_update -y ||
  fail "a failing health report fails the update" "$(cat "$test_tmp/err")"
diff <(expected_steps) <(steps_run) >"$test_tmp/order" ||
  fail "a failing health report changes the steps an update runs" "$(cat "$test_tmp/order")"
! grep -q 'Something went wrong during the update' "$test_tmp/out" "$test_tmp/err" ||
  fail "a failing health report is reported as a failed update"
pass "a failing health report still lets the update finish and offer the reboot"
