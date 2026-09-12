#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Every step omarchy-update runs, recorded in order with the unattended flag it
# was handed. One of them can be told to fail.
steps=(
  omarchy-update-lock
  omarchy-update-requires-free-space
  omarchy-update-confirm
  omarchy-update-pkg-prune
  omarchy-snapshot
  omarchy-update-stay-awake
  omarchy-update-dev
  omarchy-update-keyring
  omarchy-update-system-pkgs
  omarchy-migrate
  omarchy-hook
  omarchy-update-aur-pkgs
  omarchy-update-mise
  omarchy-update-orphan-pkgs
  omarchy-update-analyze-logs
  omarchy-update-status
  omarchy-update-restart
)

for step in "${steps[@]}"; do
  cat >"$stub_bin/$step" <<'STUB'
#!/bin/bash
printf '%s unattended=%s\n' "${0##*/}" "${OMARCHY_UPDATE_UNATTENDED:-}" >>"$STEP_LOG"
[[ ${FAILING_STEP:-} != "${0##*/}" ]] || exit 1
STUB
  chmod +x "$stub_bin/$step"
done

# With Snapper gone the real omarchy-snapshot is the deliberate 127 the update
# tolerates, so the stub can stand in for both sides of that arrangement.
cat >"$stub_bin/omarchy-snapshot" <<'STUB'
#!/bin/bash
printf '%s unattended=%s\n' "${0##*/}" "${OMARCHY_UPDATE_UNATTENDED:-}" >>"$STEP_LOG"
[[ ${FAILING_STEP:-} != "${0##*/}" ]] || exit 1
[[ -z ${SNAPPER_MISSING:-} ]] || exit 127
STUB

# Snapper is present unless the test says otherwise. Exit 1 means nothing is
# missing, matching omarchy-cmd-missing.
cat >"$stub_bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
for cmd in "$@"; do
  if [[ $cmd == snapper && -n ${SNAPPER_MISSING:-} ]]; then
    exit 0
  fi
done
exit 1
STUB

# gum only has to answer confirm: yes by default, overridable per run. Every
# ask is logged so the tests can tell prompting from silence.
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
if [[ ${1:-} == confirm ]]; then
  printf '%s\n' "$*" >>"$GUM_LOG"
  [[ ${GUM_CONFIRM_ANSWER:-yes} == yes ]]
fi
STUB
chmod +x "$stub_bin/gum" "$stub_bin/omarchy-snapshot" "$stub_bin/omarchy-cmd-missing"

# OMARCHY_UPDATE_LOGGED stands in for the script(1) wrapper the update re-execs
# itself under; the stubbed lock reports itself already held.
run_update() {
  : >"$test_tmp/steps"
  : >"$test_tmp/gum"
  STEP_LOG="$test_tmp/steps" \
    GUM_LOG="$test_tmp/gum" \
    FAILING_STEP="${FAILING_STEP:-}" \
    SNAPPER_MISSING="${SNAPPER_MISSING:-}" \
    GUM_CONFIRM_ANSWER="${GUM_CONFIRM_ANSWER:-}" \
    OMARCHY_UPDATE_LOGGED=1 \
    PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/omarchy-update" "$@" >"$test_tmp/out" 2>"$test_tmp/err"
}

steps_run() {
  cut -d' ' -f1 "$test_tmp/steps"
}

# Every step of a whole update, in order. $1 asks for the confirm a person
# gives, $2 for the snapshot step. Stay Awake bookends the work, so it is here
# twice.
expected_steps() {
  printf '%s\n' \
    omarchy-update-lock \
    omarchy-update-requires-free-space \
    ${1:+omarchy-update-confirm} \
    omarchy-update-pkg-prune \
    ${2:+omarchy-snapshot} \
    omarchy-update-stay-awake \
    omarchy-update-dev \
    omarchy-update-keyring \
    omarchy-update-system-pkgs \
    omarchy-migrate \
    omarchy-hook \
    omarchy-update-aur-pkgs \
    omarchy-update-mise \
    omarchy-update-orphan-pkgs \
    omarchy-update-analyze-logs \
    omarchy-update-status \
    omarchy-update-stay-awake \
    omarchy-update-restart
}

no_asked_questions() {
  if [[ -s "$test_tmp/gum" ]]; then
    fail "the update asked something it should not have" "$(cat "$test_tmp/gum")"
  fi
}

# -y promised not to ask anything, so it snapshots without a prompt.
run_update -y || fail "an unattended update where everything works reports a failure"
no_asked_questions
diff <(expected_steps "" snapshot) <(steps_run) >"$test_tmp/order" ||
  fail "an unattended update does not run every step in order" "$(cat "$test_tmp/order")"
grep -q '^omarchy-update-system-pkgs unattended=1$' "$test_tmp/steps" ||
  fail "-y does not mark the update unattended"
pass "-y keeps the snapshot default and asks nothing"

# A missing Snapper is the deliberate 127 the update tolerates, and there is
# nothing to ask about either.
SNAPPER_MISSING=1 run_update </dev/null ||
  fail "an update without Snapper reports a failure"
no_asked_questions
diff <(expected_steps confirmed snapshot) <(steps_run) >"$test_tmp/order" ||
  fail "an update without Snapper runs a different set of steps" "$(cat "$test_tmp/order")"
if grep -q 'without a snapshot' "$test_tmp/err"; then
  fail "a tolerated Snapper absence announces a missing snapshot"
fi
pass "without Snapper the update never asks and carries on without a snapshot"

# A person who confirms the update gets asked about the snapshot, and taking
# the recommended answer changes nothing about the step order.
run_update </dev/null || fail "a confirmed update reports a failure"
diff <(expected_steps confirmed snapshot) <(steps_run) >"$test_tmp/order" ||
  fail "a confirmed update runs a different set of steps" "$(cat "$test_tmp/order")"
grep -q '^omarchy-update-system-pkgs unattended=$' "$test_tmp/steps" ||
  fail "an update a person confirmed is treated as unattended"
[[ $(wc -l <"$test_tmp/gum") == 1 ]] ||
  fail "a confirmed update does not ask exactly one question" "$(cat "$test_tmp/gum")"
pass "a confirmed update asks once and snapshots on the recommended answer"

# Declining the snapshot skips exactly that step and nothing else.
GUM_CONFIRM_ANSWER=no run_update </dev/null ||
  fail "an update without the snapshot the user declined reports a failure"
diff <(expected_steps confirmed) <(steps_run) >"$test_tmp/order" ||
  fail "a declined snapshot changes more than the snapshot step" "$(cat "$test_tmp/order")"
grep -q 'Skipping the snapshot' "$test_tmp/err" ||
  fail "a declined snapshot passes without saying so"
pass "declining the snapshot skips it and the update goes on"

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
