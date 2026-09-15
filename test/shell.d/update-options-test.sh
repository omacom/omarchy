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
exit 0
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
printf 'script %s\n' "$*" >>"$STEP_LOG"
exit 99
STUB
chmod +x "$stub_bin/script"

run_valid() {
  : >"$test_tmp/steps"
  : >"$test_tmp/out"
  : >"$test_tmp/err"
  STEP_LOG="$test_tmp/steps" \
    OMARCHY_UPDATE_LOGGED=1 \
    OMARCHY_PATH="$ROOT" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    env -u OMARCHY_UPDATE_RUN_REEXEC \
    bash "$ROOT/bin/omarchy-update" "$@" >"$test_tmp/out" 2>"$test_tmp/err"
}

run_invalid() {
  : >"$test_tmp/steps"
  : >"$test_tmp/out"
  : >"$test_tmp/err"
  rm -f /tmp/omarchy-update.log
  set +e
  STEP_LOG="$test_tmp/steps" \
    OMARCHY_PATH="$ROOT" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    env -u OMARCHY_UPDATE_LOGGED -u OMARCHY_UPDATE_RUN_REEXEC \
    bash "$ROOT/bin/omarchy-update" "$@" >"$test_tmp/out" 2>"$test_tmp/err"
  status=$?
  set -e
  printf '%s' "$status" >"$test_tmp/status"
}

expect_invalid() {
  local desc="$1"
  shift
  run_invalid "$@"
  status=$(<"$test_tmp/status")
  (( status == 2 )) || fail "$desc exits 2" "got $status out=$(cat "$test_tmp/out") err=$(cat "$test_tmp/err")"
  [[ ! -s $test_tmp/steps ]] || fail "$desc runs no step/lock/sudo/script mocks" "$(cat "$test_tmp/steps")"
  [[ ! -e /tmp/omarchy-update.log ]] || fail "$desc creates no transcript" "log exists"
  pass "$desc"
}

check_env() {
  local desc="$1"
  local expected="$2"
  grep -q "^omarchy-update-requires-free-space $expected" "$test_tmp/steps" ||
    fail "$desc forwards env before early steps" "$(cat "$test_tmp/steps")"
  grep -q "^omarchy-update-system-pkgs $expected" "$test_tmp/steps" ||
    fail "$desc forwards env to pipeline" "$(cat "$test_tmp/steps")"
  pass "$desc"
}

run_valid || fail "interactive defaults succeed"
check_env "interactive defaults" "unattended= strict= hooks=run aur=run mise=run orphans=ask reboot=ask restarts=run"
[[ ! -s $test_tmp/out ]] || fail "interactive prints no unattended summary" "$(cat "$test_tmp/out")"
pass "interactive defaults with no summary"

run_valid -y || fail "-y defaults succeed"
check_env "-y defaults" "unattended=1 strict= hooks=run aur=run mise=run orphans=keep reboot=never restarts=run"
grep -q "Unattended update (full)" "$test_tmp/out" || fail "-y prints full summary" "$(cat "$test_tmp/out")"
pass "-y defaults"

run_valid --yes || fail "--yes defaults succeed"
check_env "--yes defaults" "unattended=1 strict= hooks=run aur=run mise=run orphans=keep reboot=never restarts=run"
pass "--yes defaults match -y"

run_valid --non-interactive || fail "strict defaults succeed"
check_env "strict defaults" "unattended=1 strict=1 hooks=skip aur=skip mise=skip orphans=keep reboot=never restarts=run"
grep -q "Unattended update (strict)" "$test_tmp/out" || fail "strict prints strict summary" "$(cat "$test_tmp/out")"
grep -q "Skipping post-update hooks (--hooks=skip)" "$test_tmp/out" || fail "strict reports hook skip" "$(cat "$test_tmp/out")"
grep -q "Skipping AUR package updates (--aur=skip)" "$test_tmp/out" || fail "strict reports aur skip" "$(cat "$test_tmp/out")"
grep -q "Skipping mise updates (--mise=skip)" "$test_tmp/out" || fail "strict reports mise skip" "$(cat "$test_tmp/out")"
[[ $test_tmp/err != *"Warning:"* ]] || fail "strict defaults warn without opt-in" "$(cat "$test_tmp/err")"
pass "strict defaults skip externals"

for mode in "" "-y" "--non-interactive"; do
  for val in run skip; do
    if [[ -z $mode ]]; then
      label="interactive --hooks=$val"
    else
      label="$mode --hooks=$val"
    fi
    # shellcheck disable=SC2086
    run_valid $mode --hooks=$val || fail "$label succeeds"
    grep -q "hooks=$val " "$test_tmp/steps" || fail "$label forwards hooks" "$(cat "$test_tmp/steps")"
  done
  for val in run skip; do
    # shellcheck disable=SC2086
    run_valid $mode --aur=$val || fail "$mode --aur=$val succeeds"
    grep -q "aur=$val " "$test_tmp/steps" || fail "$mode --aur=$val forwards" "$(cat "$test_tmp/steps")"
  done
  for val in run skip; do
    # shellcheck disable=SC2086
    run_valid $mode --mise=$val || fail "$mode --mise=$val succeeds"
    grep -q "mise=$val " "$test_tmp/steps" || fail "$mode --mise=$val forwards" "$(cat "$test_tmp/steps")"
  done
  for val in run skip; do
    # shellcheck disable=SC2086
    run_valid $mode --restarts=$val || fail "$mode --restarts=$val succeeds"
    grep -q "restarts=$val " "$test_tmp/steps" || fail "$mode --restarts=$val forwards" "$(cat "$test_tmp/steps")"
  done
done
pass "every hooks/aur/mise/restarts value works across modes"

run_valid --orphans=ask || fail "interactive --orphans=ask succeeds"
grep -q "orphans=ask " "$test_tmp/steps" || fail "interactive ask forwards" "$(cat "$test_tmp/steps")"
run_valid --orphans=keep || fail "interactive --orphans=keep succeeds"
run_valid --orphans=remove || fail "interactive --orphans=remove succeeds"
run_valid -y --orphans=keep || fail "-y --orphans=keep succeeds"
run_valid -y --orphans=remove || fail "-y --orphans=remove succeeds"
run_valid --non-interactive --orphans=keep || fail "strict --orphans=keep succeeds"
run_valid --non-interactive --orphans=remove || fail "strict --orphans=remove succeeds"
run_valid --reboot=ask || fail "interactive --reboot=ask succeeds"
run_valid --reboot=never || fail "interactive --reboot=never succeeds"
run_valid --reboot=if-needed || fail "interactive --reboot=if-needed succeeds"
run_valid -y --reboot=never || fail "-y --reboot=never succeeds"
run_valid -y --reboot=if-needed || fail "-y --reboot=if-needed succeeds"
run_valid --non-interactive --reboot=never || fail "strict --reboot=never succeeds"
run_valid --non-interactive --reboot=if-needed || fail "strict --reboot=if-needed succeeds"
pass "every orphans/reboot value works where allowed"

run_valid --non-interactive --aur=run --hooks=skip --mise=skip || fail "order case 1 succeeds"
env1=$(grep "^omarchy-update-system-pkgs " "$test_tmp/steps")
run_valid --non-interactive --mise=skip --hooks=skip --aur=run || fail "order case 2 succeeds"
env2=$(grep "^omarchy-update-system-pkgs " "$test_tmp/steps")
[[ $env1 == "$env2" ]] || fail "explicit policies are order-independent" "$env1 vs $env2"
pass "explicit policies are order-independent"

run_valid -y --hooks=run --hooks=run || fail "identical duplicate hooks succeeds"
run_valid --non-interactive --mise=skip --mise=skip || fail "identical duplicate mise succeeds"
pass "identical duplicates are allowed"

run_valid -y --yes || fail "-y --yes succeeds"
grep -q "unattended=1 strict= hooks=run " "$test_tmp/steps" || fail "-y --yes stays full" "$(cat "$test_tmp/steps")"
run_valid -y --non-interactive || fail "-y + strict succeeds"
grep -q "unattended=1 strict=1 hooks=skip " "$test_tmp/steps" || fail "-y + strict prefers strict" "$(cat "$test_tmp/steps")"
run_valid --non-interactive -y || fail "strict + -y order succeeds"
grep -q "unattended=1 strict=1 hooks=skip " "$test_tmp/steps" || fail "strict wins regardless of order" "$(cat "$test_tmp/steps")"
run_valid --yes --non-interactive --hooks=run || fail "strict opt-in priority succeeds"
grep -q "hooks=run " "$test_tmp/steps" || fail "strict opt-in keeps explicit run" "$(cat "$test_tmp/steps")"
grep -q "Warning: --hooks=run in strict mode" "$test_tmp/err" || fail "strict opt-in warns" "$(cat "$test_tmp/err")"
pass "strict mode priority with redundant modes"

run_valid -y --orphans=remove --reboot=if-needed || fail "destructive summary succeeds"
grep -q "Unattended update (full)" "$test_tmp/out" || fail "destructive prints summary" "$(cat "$test_tmp/out")"
grep -q "Orphan policy: remove" "$test_tmp/out" || fail "destructive reports orphans=remove" "$(cat "$test_tmp/out")"
grep -q "Reboot policy: if-needed" "$test_tmp/out" || fail "destructive reports reboot=if-needed" "$(cat "$test_tmp/out")"
pass "unattended summary includes destructive selections"

run_valid --non-interactive --hooks=run || fail "strict hooks opt-in succeeds"
grep -q "Warning: --hooks=run in strict mode" "$test_tmp/err" || fail "strict hooks warn" "$(cat "$test_tmp/err")"
[[ $test_tmp/out != *"Skipping post-update hooks"* ]] || fail "strict hooks opt-in must not skip" "$(cat "$test_tmp/out")"
run_valid --non-interactive --aur=run || fail "strict aur opt-in succeeds"
grep -q "Warning: --aur=run in strict mode" "$test_tmp/err" || fail "strict aur warn" "$(cat "$test_tmp/err")"
run_valid --non-interactive --mise=run || fail "strict mise opt-in succeeds"
grep -q "Warning: --mise=run in strict mode" "$test_tmp/err" || fail "strict mise warn" "$(cat "$test_tmp/err")"
run_valid -y --hooks=skip || fail "full explicit skip succeeds"
grep -q "Skipping post-update hooks (--hooks=skip)" "$test_tmp/out" || fail "full skip reports" "$(cat "$test_tmp/out")"
[[ $test_tmp/err != *"Warning:"* ]] || fail "full skip must not warn" "$(cat "$test_tmp/err")"
pass "external skip and warn reports"

set +e
STEP_LOG="$test_tmp/steps" OMARCHY_UPDATE_LOGGED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_UPDATE_STRICT=1 OMARCHY_UPDATE_HOOKS=skip OMARCHY_UPDATE_AUR=skip OMARCHY_UPDATE_MISE=skip OMARCHY_UPDATE_ORPHANS=remove OMARCHY_UPDATE_REBOOT=if-needed OMARCHY_UPDATE_RESTARTS=skip \
  bash "$ROOT/bin/omarchy-update" >"$test_tmp/out" 2>"$test_tmp/err"
set -e
grep -q "^omarchy-update-requires-free-space unattended= strict= hooks=run aur=run mise=run orphans=ask reboot=ask restarts=run " "$test_tmp/steps" ||
  fail "stale inherited policy does not leak into interactive" "$(cat "$test_tmp/steps")"
pass "stale inherited values are ignored for interactive"

set +e
STEP_LOG="$test_tmp/steps" OMARCHY_UPDATE_LOGGED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env OMARCHY_UPDATE_HOOKS=skip OMARCHY_UPDATE_AUR=skip OMARCHY_UPDATE_ORPHANS=ask \
  bash "$ROOT/bin/omarchy-update" -y >"$test_tmp/out" 2>"$test_tmp/err"
set -e
grep -q "^omarchy-update-system-pkgs unattended=1 strict= hooks=run aur=run mise=run orphans=keep reboot=never restarts=run " "$test_tmp/steps" ||
  fail "public args are authoritative over stale env" "$(cat "$test_tmp/steps")"
pass "public args are authoritative not inherited policy env"

set +e
STEP_LOG="$test_tmp/steps" OMARCHY_UPDATE_LOGGED=1 OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env OMARCHY_UPDATE_UNATTENDED=1 OMARCHY_UPDATE_ENV_READY=1 OMARCHY_UPDATE_REAL_SUDO=/nonexistent \
  bash "$ROOT/bin/omarchy-update" >"$test_tmp/out" 2>"$test_tmp/err"
status=$?
set -e
grep -q "^omarchy-update-requires-free-space unattended= strict= " "$test_tmp/steps" ||
  fail "interactive is not turned unattended by inherited env" "$(cat "$test_tmp/steps") err=$(cat "$test_tmp/err") status=$status"
pass "interactive must not be turned unattended by inherited policy env"

expect_invalid "contradictory duplicate hooks" --hooks=run --hooks=skip
expect_invalid "contradictory duplicate orphans" -y --orphans=keep --orphans=remove
expect_invalid "unknown flag" --frobnicate
expect_invalid "unknown hooks spelling" --hook=run
expect_invalid "missing hooks value" --hooks
expect_invalid "empty hooks value" --hooks=
expect_invalid "invalid hooks value" --hooks=maybe
expect_invalid "invalid hooks case" --hooks=Run
expect_invalid "missing aur value" --aur=
expect_invalid "invalid orphans value" --orphans=never
expect_invalid "invalid reboot value" --reboot=run
expect_invalid "invalid restarts value" --restarts=ask
expect_invalid "space-separated policy" --hooks run
expect_invalid "positional arg" foo
expect_invalid "positional after -y" -y foo
expect_invalid "single-dash unknown" -n
expect_invalid "combined -yy" -yy
expect_invalid "mode with value" --yes=true
expect_invalid "strict with value" --non-interactive=true
expect_invalid "ask orphans with -y" -y --orphans=ask
expect_invalid "ask orphans before -y" --orphans=ask -y
expect_invalid "ask reboot with -y" -y --reboot=ask
expect_invalid "ask reboot with strict" --non-interactive --reboot=ask
expect_invalid "ask reboot before strict" --reboot=ask --non-interactive
expect_invalid "ask orphans with strict" --non-interactive --orphans=ask

: >"$test_tmp/steps"
rm -f /tmp/omarchy-update.log
set +e
STEP_LOG="$test_tmp/steps" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env -u OMARCHY_UPDATE_LOGGED bash "$ROOT/bin/omarchy-update" -h >"$test_tmp/out" 2>"$test_tmp/err"
h_status=$?
set -e
(( h_status == 0 )) || fail "-h exits 0" "got $h_status"
grep -q "^Usage: omarchy update" "$test_tmp/out" || fail "-h prints usage" "$(cat "$test_tmp/out")"
[[ ! -s $test_tmp/steps ]] || fail "-h runs no mocks" "$(cat "$test_tmp/steps")"
[[ ! -e /tmp/omarchy-update.log ]] || fail "-h creates no transcript"
pass "-h prints usage with no actions"

: >"$test_tmp/steps"
rm -f /tmp/omarchy-update.log
set +e
STEP_LOG="$test_tmp/steps" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env -u OMARCHY_UPDATE_LOGGED bash "$ROOT/bin/omarchy-update" --help >"$test_tmp/out" 2>"$test_tmp/err"
help_status=$?
set -e
(( help_status == 0 )) || fail "--help exits 0" "got $help_status"
grep -q "^Usage: omarchy update" "$test_tmp/out" || fail "--help prints usage" "$(cat "$test_tmp/out")"
grep -q "orphans=ask" "$test_tmp/out" || fail "--help is detailed" "$(cat "$test_tmp/out")"
[[ ! -s $test_tmp/steps ]] || fail "--help runs no mocks" "$(cat "$test_tmp/steps")"
[[ ! -e /tmp/omarchy-update.log ]] || fail "--help creates no transcript"
pass "--help prints detailed usage with no actions"

: >"$test_tmp/steps"
rm -f /tmp/omarchy-update.log
set +e
STEP_LOG="$test_tmp/steps" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  env -u OMARCHY_UPDATE_LOGGED bash "$ROOT/bin/omarchy-update" --bogus --help >"$test_tmp/out" 2>"$test_tmp/err"
mixed_status=$?
set -e
(( mixed_status == 0 )) || fail "help wins over invalid flags exits 0" "got $mixed_status"
grep -q "^Usage: omarchy update" "$test_tmp/out" || fail "help wins prints usage" "$(cat "$test_tmp/out")"
[[ ! -s $test_tmp/steps ]] || fail "help wins runs no mocks" "$(cat "$test_tmp/steps")"
[[ ! -e /tmp/omarchy-update.log ]] || fail "help wins creates no transcript"
pass "help takes precedence over invalid flags deterministically"
