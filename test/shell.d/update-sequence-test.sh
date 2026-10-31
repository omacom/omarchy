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
  omarchy-apply-sssd-hook
  omarchy-apply-sssd
  omarchy-migrate
  omarchy-hook
  omarchy-update-aur-pkgs
  omarchy-update-mise
  omarchy-update-orphan-pkgs
  omarchy-update-analyze-logs
  omarchy-shell
  omarchy-update-available
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
    omarchy-apply-sssd-hook \
    omarchy-update-system-pkgs \
    omarchy-apply-sssd \
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
for step in omarchy-apply-sssd omarchy-migrate omarchy-hook omarchy-update-aur-pkgs omarchy-update-restart; do
  if grep -q "^$step " "$test_tmp/steps"; then
    fail "a blocked package upgrade still runs $step"
  fi
done
pass "a blocked package upgrade stops the update before it migrates"

# Optional tools may fail after system packages have already changed. Finish
# AUR work, verify boot files and release Stay Awake before offering a reboot.
FAILING_STEP=omarchy-update-mise run_update -y || fail "a failed mise update prevents system update completion"
diff <(expected_steps) <(steps_run) >"$test_tmp/order" ||
  fail "a failed mise update skips later update steps" "$(cat "$test_tmp/order")"
grep -q "omarchy update mise" "$test_tmp/err" || fail "the tool update failure has no retry guidance"
assert_boundary_cold "update after mise failure"
pass "a mise failure still finishes the update, offers a reboot and explains how to retry"

# Re-applying SSSD guards directory accounts, not the update itself: when it
# can't finish, the update reports that and carries on with the migrations.
FAILING_STEP=omarchy-apply-sssd run_update -y ||
  fail "an update still finishes when the SSSD re-apply fails" "$(cat "$test_tmp/err")"
grep -q '^omarchy-migrate ' "$test_tmp/steps" || fail "a failed SSSD re-apply still lets the migrations run"
grep -F 'Run omarchy-apply-sssd to retry' "$test_tmp/err" >/dev/null ||
  fail "a failed SSSD re-apply tells the user how to retry" "$(cat "$test_tmp/err")"
pass "a failed SSSD re-apply is reported and does not stop the update"

# The hook has to be in place before the packages are upgraded: that upgrade is
# what takes sss out of nsswitch.conf, after which sudo can no longer look a
# directory account up. A hook that could not be installed is reported, and
# does not stop the update.
run_update -y || fail "an update where everything works reports a failure"
hook_line=$(grep -n '^omarchy-apply-sssd-hook ' "$test_tmp/steps" | cut -d: -f1)
packages_line=$(grep -n '^omarchy-update-system-pkgs ' "$test_tmp/steps" | cut -d: -f1)
(( hook_line < packages_line )) || fail "the SSSD hook is installed before the packages are upgraded"
pass "the SSSD hook is installed before the packages are upgraded"

FAILING_STEP=omarchy-apply-sssd-hook run_update -y ||
  fail "an update still finishes when the SSSD hook can't be installed" "$(cat "$test_tmp/err")"
grep -q '^omarchy-update-system-pkgs ' "$test_tmp/steps" || fail "a failed SSSD hook install still lets the packages upgrade"
grep -F 'Run omarchy-apply-sssd-hook to retry' "$test_tmp/err" >/dev/null ||
  fail "a failed SSSD hook install tells the user how to retry" "$(cat "$test_tmp/err")"
pass "a failed SSSD hook install is reported and does not stop the update"
