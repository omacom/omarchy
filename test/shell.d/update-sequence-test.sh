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
  omarchy-restart-shell
  omarchy-hook
  omarchy-update-aur-pkgs
  omarchy-update-mise
  omarchy-update-orphan-pkgs
  omarchy-update-analyze-logs
  omarchy-shell
  omarchy-update-available
  omarchy-update-restart
  omarchy-toggle-enabled
  omarchy-plugin-update
)

for step in "${steps[@]}"; do
  rm -f "$stub_bin/$step"
  cat >"$stub_bin/$step" <<'STUB'
#!/bin/bash
step=${0##*/}
# The pending check is a step of its own, so the order around the restart shows.
if [[ $step == "omarchy-migrate" && ${1:-} == "--pending" ]]; then
  step+=":--pending"
fi
printf '%s unattended=%s\n' "$step" "${OMARCHY_UPDATE_UNATTENDED:-}" >>"$STEP_LOG"
[[ $step != "omarchy-migrate:--pending" || ${NO_PENDING:-} != 1 ]] || exit 1
if [[ ${0##*/} == "omarchy-update-orphan-pkgs" ]]; then
  printf '%s\n' "$@" >"$STEP_LOG.orphan-args"
fi
if [[ ${0##*/} == "omarchy-shell" ]]; then
  printf '%s\n' "$*" >"$STEP_LOG.shell-args"
fi
if [[ ${0##*/} == "omarchy-toggle-enabled" ]]; then
  printf '%s\n' "$*" >"$STEP_LOG.toggle-args"
  [[ ${PLUGIN_UPDATES:-} == 1 ]] || exit 1
fi
if [[ ${0##*/} == "omarchy-plugin-update" ]]; then
  printf '%s\n' "$*" >"$STEP_LOG.plugin-args"
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

# Every step of a whole update, in order. $1 asks for the one a person confirms;
# an empty $2 leaves out the shell restart, for an update with nothing to migrate;
# $3 asks for the plugin update a person opted into.
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
    omarchy-migrate:--pending \
    ${2-omarchy-restart-shell} \
    omarchy-migrate \
    omarchy-update-orphan-pkgs \
    omarchy-update-analyze-logs \
    omarchy-shell \
    omarchy-toggle-enabled \
    ${3:+omarchy-plugin-update} \
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

NO_PENDING=1 run_update -y || fail "an update with nothing to migrate reports a failure"
diff <(expected_steps "" "") <(steps_run) >"$test_tmp/order" ||
  fail "an update with nothing to migrate restarts the shell anyway" "$(cat "$test_tmp/order")"
pass "an update restarts the shell before migrating only when migrations are pending"

# Migrations ship with the packages the upgrade installs and are written against
# them. Running them against what is still on disk is the failure this ordering
# exists to prevent, so the update stops where the packages did.
if FAILING_STEP=omarchy-update-system-pkgs run_update -y; then
  fail "an update whose packages did not upgrade passes for a whole one"
fi
for step in omarchy-migrate omarchy-restart-shell omarchy-hook omarchy-update-aur-pkgs omarchy-update-restart; do
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
pass "a mise failure still finishes the update, offers a reboot and explains how to retry"

# Plugins are third-party code, so the update leaves them alone unless the
# person opted in. When they did, plugins update before the shell restart so the
# restart loads the new code, and a plugin failure never fails the system update.
run_update -y || fail "an update without plugin updates reports a failure"
[[ $(cat "$test_tmp/steps.toggle-args") == "update-plugins" ]] ||
  fail "the update checks the wrong toggle for plugin updates" "$(cat "$test_tmp/steps.toggle-args")"
if grep -q '^omarchy-plugin-update ' "$test_tmp/steps"; then
  fail "an update updates plugins nobody opted into"
fi
pass "an update leaves plugins alone unless the person opted in"

PLUGIN_UPDATES=1 run_update -y || fail "an opted-in unattended update reports a failure"
diff <(expected_steps "" omarchy-restart-shell plugins) <(steps_run) >"$test_tmp/order" ||
  fail "an opted-in update does not update plugins before the shell restart" "$(cat "$test_tmp/order")"
[[ $(cat "$test_tmp/steps.plugin-args") == "--yes" ]] ||
  fail "an unattended update still asks to review plugin changes" "$(cat "$test_tmp/steps.plugin-args")"
pass "an opted-in unattended update approves plugin updates before the shell restart"

PLUGIN_UPDATES=1 run_update </dev/null || fail "an opted-in confirmed update reports a failure"
diff <(expected_steps confirmed omarchy-restart-shell plugins) <(steps_run) >"$test_tmp/order" ||
  fail "an opted-in confirmed update runs a different set of steps" "$(cat "$test_tmp/order")"
[[ -z $(cat "$test_tmp/steps.plugin-args") ]] ||
  fail "a confirmed update skips the plugin change review" "$(cat "$test_tmp/steps.plugin-args")"
pass "an opted-in confirmed update lets the person review each plugin change"

PLUGIN_UPDATES=1 FAILING_STEP=omarchy-plugin-update run_update -y ||
  fail "a failed plugin update fails the system update"
diff <(expected_steps "" omarchy-restart-shell plugins) <(steps_run) >"$test_tmp/order" ||
  fail "a failed plugin update skips later update steps" "$(cat "$test_tmp/order")"
grep -q "omarchy plugin update" "$test_tmp/err" || fail "the plugin update failure has no retry guidance"
pass "a plugin failure still finishes the update and explains how to retry"
