#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home"

cat >"$mock_bin/omarchy-done" <<'SH'
#!/bin/bash
[[ $1 == "check" && $2 == "first-run-user" ]]
SH
cat >"$mock_bin/omarchy-provision-user" <<'SH'
#!/bin/bash
touch "$OMARCHY_TEST_FINALIZE_CALLED"
SH
chmod +x "$mock_bin/omarchy-done" "$mock_bin/omarchy-provision-user"

finalize_called="$test_tmp/finalize-called"
HOME="$test_tmp/home" PATH="$mock_bin:$PATH" OMARCHY_TEST_FINALIZE_CALLED="$finalize_called" \
  bash "$ROOT/bin/omarchy-provision-first-run" >"$test_tmp/output"

[[ ! -e $finalize_called ]] || fail "completed first-run exits before any setup step"
grep -F 'First-run already complete' "$test_tmp/output" >/dev/null || fail "completed first-run reports its lifecycle gate"

if grep -F 'user-migration-notify-watch-enabled' "$ROOT/bin/omarchy-provision-first-run" >/dev/null; then
  fail "first-run does not track the migration watcher separately"
fi
if grep -F 'skip-first-run-update-notification' "$ROOT/install/user/first-run/wifi.sh" >/dev/null; then
  fail "first-run does not track update notifications separately"
fi

pass "first-run uses one lifecycle completion marker"

# Finalization is a first-run step like any other: a failure has to leave the
# marker unwritten so the next login retries, rather than being swallowed into
# a completed first-run the user can never get back to.
run_bin="$test_tmp/run-bin"
run_omarchy="$test_tmp/run-omarchy/install/user/first-run"
mkdir -p "$run_bin" "$run_omarchy"

for hook in setup-fingerprint setup-agent; do
  touch "$run_omarchy/$hook.hook"
done
for step in enable-user-units gnome-theme gtk-primary-paste audio-tuning welcome wifi; do
  printf '#!/bin/bash\n' >"$run_omarchy/$step.sh"
done

cat >"$run_bin/omarchy-done" <<'SH'
#!/bin/bash
[[ $1 != "check" ]] || exit 1
[[ $1 != "mark" ]] || printf '%s\n' "$2" >>"$OMARCHY_TEST_MARKED"
SH
printf '#!/bin/bash\n' >"$run_bin/omarchy-hook-install"
printf '#!/bin/bash\n' >"$run_bin/omarchy-notification-wait"
printf '#!/bin/bash\n' >"$run_bin/omarchy-lifecycle-dispatch"
chmod +x "$run_bin"/*

first_run() {
  local finalize_exit="$1" home="$2"
  printf '#!/bin/bash\nexit %s\n' "$finalize_exit" >"$run_bin/omarchy-provision-user"
  chmod +x "$run_bin/omarchy-provision-user"
  rm -rf "$home"
  mkdir -p "$home"
  HOME="$home" PATH="$run_bin:$PATH" OMARCHY_PATH="$test_tmp/run-omarchy" \
    OMARCHY_TEST_MARKED="$home/marked" \
    bash "$ROOT/bin/omarchy-provision-first-run" >/dev/null 2>&1
}

failed_home="$test_tmp/home-finalize-failed"
first_run 1 "$failed_home"
if grep -Fx 'first-run-user' "$failed_home/marked" >/dev/null 2>&1; then
  fail "a failed finalization leaves first-run unmarked" "$(cat "$failed_home/.local/state/omarchy/first-run.log")"
fi
grep -F 'Failed: finalize user setup' "$failed_home/.local/state/omarchy/first-run.log" >/dev/null ||
  fail "a failed finalization is recorded in the first-run log"
pass "a failed finalization keeps first-run retryable"

passed_home="$test_tmp/home-finalize-passed"
first_run 0 "$passed_home"
grep -Fx 'first-run-user' "$passed_home/marked" >/dev/null ||
  fail "a successful run still marks first-run complete"
pass "a successful finalization completes first-run"

# systemctl enables none of a list when one unit in it is unknown, so a unit
# missing from a build must cost first-run only that unit.
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
[[ $* != *"$OMARCHY_TEST_MISSING_UNIT"* ]] || exit 1
printf '%s\n' "$*" >>"$OMARCHY_TEST_CALLS"
SH
cat >"$mock_bin/omarchy-hook-install" <<'SH'
#!/bin/bash
echo "hook $*" >>"$OMARCHY_TEST_CALLS"
SH
chmod +x "$mock_bin/systemctl" "$mock_bin/omarchy-hook-install"

enable_user_units() {
  rm -f "$test_tmp/calls"
  PATH="$mock_bin:$PATH" OMARCHY_TEST_CALLS="$test_tmp/calls" OMARCHY_TEST_MISSING_UNIT="$1" \
    bash "$ROOT/install/user/first-run/enable-user-units.sh"
}

enable_user_units no-such-unit || fail "first-run enables its user units"
clean_run=$(<"$test_tmp/calls")
grep -Fq 'hook theme-set' <<<"$clean_run" || fail "first-run installs the theme hook"
mapfile -t units < <(sed -n 's/^--user enable --now //p' <<<"$clean_run")

for unit in "${units[@]}"; do
  [[ $unit != *" "* ]] || fail "first-run enables each unit on its own" "$unit"
  if enable_user_units "$unit"; then
    fail "first-run reports a unit it could not enable" "$unit"
  fi
  [[ $(<"$test_tmp/calls") == "$(grep -Fvx -- "--user enable --now $unit" <<<"$clean_run")" ]] ||
    fail "a unit missing from the build costs first-run only that unit" "$unit"
done
(( ${#units[@]} > 1 )) || fail "first-run enables each unit on its own"
pass "a unit missing from the build costs first-run only that unit"
