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
