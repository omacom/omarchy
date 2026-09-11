#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

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
printf '%s unattended=%s strict=%s hooks=%s aur=%s mise=%s orphans=%s reboot=%s restarts=%s args=%s\n' "${0##*/}" "${OMARCHY_UPDATE_UNATTENDED:-}" "${OMARCHY_UPDATE_STRICT:-}" "${OMARCHY_UPDATE_HOOKS:-}" "${OMARCHY_UPDATE_AUR:-}" "${OMARCHY_UPDATE_MISE:-}" "${OMARCHY_UPDATE_ORPHANS:-}" "${OMARCHY_UPDATE_REBOOT:-}" "${OMARCHY_UPDATE_RESTARTS:-}" "$*" >>"$STEP_LOG"
[[ ${FAILING_STEP:-} != "${0##*/}" ]] || exit 1
STUB
  chmod +x "$stub_bin/$step"
done

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$STEP_LOG"
args=()
for a in "$@"; do
  if [[ $a == "-n" ]]; then
    continue
  fi
  if [[ $a == "--" ]]; then
    continue
  fi
  args+=("$a")
done
if (( ${#args[@]} == 0 )); then
  exit 0
fi
exec "${args[@]}"
STUB
chmod +x "$stub_bin/sudo"

cat >"$stub_bin/script" <<'STUB'
#!/bin/bash
echo "script should not run when LOGGED=1" >>"$STEP_LOG"
exit 99
STUB
chmod +x "$stub_bin/script"

run_update() {
  : >"$test_tmp/steps"
  : >"$test_tmp/out"
  : >"$test_tmp/err"
  STEP_LOG="$test_tmp/steps" \
    FAILING_STEP="${FAILING_STEP:-}" \
    OMARCHY_UPDATE_LOGGED=1 \
    OMARCHY_PATH="$ROOT" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-update" "$@" >"$test_tmp/out" 2>"$test_tmp/err"
}

steps_run() {
  cut -d' ' -f1 "$test_tmp/steps"
}

expected_full() {
  printf '%s\n' \
    omarchy-update-lock \
    omarchy-update-requires-free-space \
    omarchy-update-pkg-prune \
    omarchy-snapshot \
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

expected_interactive() {
  printf '%s\n' \
    omarchy-update-lock \
    omarchy-update-requires-free-space \
    omarchy-update-confirm \
    omarchy-update-pkg-prune \
    omarchy-snapshot \
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

expected_strict() {
  printf '%s\n' \
    omarchy-update-lock \
    omarchy-update-requires-free-space \
    omarchy-update-pkg-prune \
    omarchy-snapshot \
    omarchy-update-stay-awake \
    omarchy-update-dev \
    omarchy-update-keyring \
    omarchy-update-system-pkgs \
    omarchy-migrate \
    omarchy-update-orphan-pkgs \
    omarchy-update-analyze-logs \
    omarchy-update-status \
    omarchy-update-stay-awake \
    omarchy-update-restart
}

run_update -y || fail "an update where everything works reports a failure"
diff <(expected_full) <(steps_run) >"$test_tmp/order" ||
  fail "an update where everything works does not run every step in order" "$(cat "$test_tmp/order")"
pass "an update where every step works runs all of them, in order"

grep -q '^omarchy-update-system-pkgs unattended=1 strict= hooks=run aur=run mise=run orphans=keep reboot=never restarts=run ' "$test_tmp/steps" ||
  fail "-y normalizes to full unattended env" "$(cat "$test_tmp/steps")"
grep -q "Unattended update (full)" "$test_tmp/out" ||
  fail "-y prints full unattended summary" "$(cat "$test_tmp/out")"
pass "-y normalizes full pipeline env with summary"

run_update --yes || fail "--yes reports failure"
diff <(expected_full) <(steps_run) >"$test_tmp/order" ||
  fail "--yes runs different steps than -y" "$(cat "$test_tmp/order")"
grep -q '^omarchy-update-system-pkgs unattended=1 strict= hooks=run ' "$test_tmp/steps" ||
  fail "--yes does not match -y env" "$(cat "$test_tmp/steps")"
pass "-y alias matches --yes"

run_update </dev/null || fail "a confirmed update reports a failure"
diff <(expected_interactive) <(steps_run) >"$test_tmp/order" ||
  fail "a confirmed update runs a different set of steps" "$(cat "$test_tmp/order")"
grep -q '^omarchy-update-system-pkgs unattended= strict= hooks=run aur=run mise=run orphans=ask reboot=ask restarts=run ' "$test_tmp/steps" ||
  fail "an update a person confirmed is treated as unattended" "$(cat "$test_tmp/steps")"
pass "-y is what marks an update unattended, not the update itself"

run_update --non-interactive || fail "strict update reports failure"
diff <(expected_strict) <(steps_run) >"$test_tmp/order" ||
  fail "strict update does not skip hook/aur/mise in order" "$(cat "$test_tmp/order")"
grep -q '^omarchy-update-system-pkgs unattended=1 strict=1 hooks=skip aur=skip mise=skip orphans=keep reboot=never restarts=run ' "$test_tmp/steps" ||
  fail "strict does not normalize to skip env" "$(cat "$test_tmp/steps")"
grep -q "Unattended update (strict)" "$test_tmp/out" ||
  fail "strict prints strict summary" "$(cat "$test_tmp/out")"
grep -q "Skipping post-update hooks (--hooks=skip)" "$test_tmp/out" ||
  fail "strict reports hook skip" "$(cat "$test_tmp/out")"
grep -q "Skipping AUR package updates (--aur=skip)" "$test_tmp/out" ||
  fail "strict reports aur skip" "$(cat "$test_tmp/out")"
grep -q "Skipping mise updates (--mise=skip)" "$test_tmp/out" ||
  fail "strict reports mise skip" "$(cat "$test_tmp/out")"
pass "strict defaults skip external steps with reports"

run_update --non-interactive --hooks=run --aur=run --mise=run || fail "strict opt-in reports failure"
diff <(expected_full) <(steps_run) >"$test_tmp/order" ||
  fail "strict opt-in does not run external steps" "$(cat "$test_tmp/order")"
grep -q "Warning: --hooks=run in strict mode" "$test_tmp/err" ||
  fail "strict hooks opt-in does not warn" "$(cat "$test_tmp/err")"
grep -q "Warning: --aur=run in strict mode" "$test_tmp/err" ||
  fail "strict aur opt-in does not warn" "$(cat "$test_tmp/err")"
grep -q "Warning: --mise=run in strict mode" "$test_tmp/err" ||
  fail "strict mise opt-in does not warn" "$(cat "$test_tmp/err")"
pass "strict opt-in runs externals with warnings"

if FAILING_STEP=omarchy-update-system-pkgs run_update -y; then
  fail "an update whose packages did not upgrade passes for a whole one"
fi
for step in omarchy-migrate omarchy-hook omarchy-update-aur-pkgs omarchy-update-restart; do
  if grep -q "^$step " "$test_tmp/steps"; then
    fail "a blocked package upgrade still runs $step"
  fi
done
grep -q "^omarchy-update-stay-awake .*args=stop" "$test_tmp/steps" ||
  fail "a blocked package upgrade does not release the inhibitor" "$(cat "$test_tmp/steps")"
pass "a blocked package upgrade stops the update before it migrates"
