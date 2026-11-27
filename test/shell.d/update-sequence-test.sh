#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update
test_tmp="$boundary_tmp"
sed -i "s#/tmp/omarchy-update\.log#$test_tmp/update.log#" "$SUDO_TEST_ROOT/bin/omarchy-update"
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
  omarchy-done
  omarchy-shell
  omarchy-update-available
  omarchy-update-restart
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
if [[ ${0##*/} == "omarchy-update-analyze-logs" ]]; then
  printf '%s\n' "$*" >"$STEP_LOG.analyze-args"
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
# an empty $2 leaves out the shell restart, for an update with nothing to migrate.
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
    omarchy-done \
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

# A channel switch logs its own package transactions first; the log check reads
# only what came after them.
printf 'channel switch output\n' >"$test_tmp/update.log"
run_update -y || fail "an update after a channel switch reports a failure"
[[ $(cat "$test_tmp/steps.analyze-args") == "$(stat -c %s "$test_tmp/update.log")" ]] ||
  fail "the log check starts where the update's own output does" "$(cat "$test_tmp/steps.analyze-args")"
rm "$test_tmp/update.log"
run_update -y || fail "an update without a log reports a failure"
[[ $(cat "$test_tmp/steps.analyze-args") == "0" ]] || fail "without a log the check reads from the start"
pass "the update hands the log check the offset its own output starts at"

analyzer_bin="$test_tmp/analyzer-bin"
mkdir -p "$analyzer_bin"
sed "s#/tmp/omarchy-update\.log#$test_tmp/analyze.log#" "$ROOT/bin/omarchy-update-analyze-logs" >"$analyzer_bin/omarchy-update-analyze-logs"
grep -qF "$test_tmp/analyze.log" "$analyzer_bin/omarchy-update-analyze-logs" && ! grep -qF /tmp/omarchy-update.log "$analyzer_bin/omarchy-update-analyze-logs" ||
  fail "the log check under test reads the test's log"
printf '#!/bin/bash\nexit 1\n' >"$analyzer_bin/omarchy-hw-aarch64-apple"
chmod +x "$analyzer_bin/"*
analyze() { PATH="$analyzer_bin:$PATH" omarchy-update-analyze-logs "$@"; }
build="(4/9) Updating linux initcpios..."
printf '%s\n' "$build" "==> Initcpio image generation successful" >"$test_tmp/analyze.log"
switch_end=$(stat -c %s "$test_tmp/analyze.log")
printf '%s\n' "$build" "==> ERROR: module not found" >>"$test_tmp/analyze.log"
[[ $(analyze "$switch_end") == *"may have failed"* ]] || fail "a channel switch's successful build hides the update's failed one"
printf '%s\n' "$build" "==> ERROR: module not found" >"$test_tmp/analyze.log"
for start in "" 999999 "a[0]"; do
  [[ $(analyze "$start") == *"may have failed"* ]] || fail "an unusable offset (${start:-none}) does not read the whole log"
done
pass "the log check reads only the update's own output, or all of it without a usable offset"

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

# Multiple Hyprland PIDs must not break the deleted-executable reboot check.
restart_bin="$test_tmp/restart-bin"
restart_home="$test_tmp/restart-home"
mkdir -p "$restart_bin" "$restart_home" "$test_tmp/modules/6.14.0-test"
: >"$test_tmp/modules/6.14.0-test/modules.builtin"

cat >"$restart_bin/uname" <<'SH'
#!/bin/bash
printf '6.14.0-test\n'
SH
cat >"$restart_bin/pacman" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$restart_bin/pgrep" <<'SH'
#!/bin/bash
printf '101\n202\n'
SH
cat >"$restart_bin/readlink" <<'SH'
#!/bin/bash
case "$*" in
  /proc/101/exe) printf '/usr/bin/Hyprland\n' ;;
  /proc/202/exe) printf '/usr/bin/Hyprland (deleted)\n' ;;
  *) exit 1 ;;
esac
SH
cat >"$restart_bin/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s\n' "$1"
SH
cat >"$restart_bin/gum" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$RESTART_PROMPTS"
exit 1
SH
chmod +x "$restart_bin"/*

: >"$test_tmp/restart-prompts"
HOME="$restart_home" \
  OMARCHY_KERNEL_MODULES_PATH="$test_tmp/modules" \
  RESTART_PROMPTS="$test_tmp/restart-prompts" \
  PATH="$restart_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-update-restart" --reboot-only >/dev/null
grep -q "update.hyprlandReboot" "$test_tmp/restart-prompts" ||
  fail "omarchy-update-restart offers a reboot when a later Hyprland PID runs a deleted binary" "$(cat "$test_tmp/restart-prompts")"
pass "omarchy-update-restart checks every Hyprland PID for a deleted executable"
