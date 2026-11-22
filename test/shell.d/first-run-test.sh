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

pass "completed first-run exits at its lifecycle gate"

# systemctl enables none of a list when one unit in it is unknown, so a unit
# missing from a build must cost first-run only that unit.
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
if [[ $2 == "show" ]]; then
  [[ $3 != ${OMARCHY_TEST_QUERY_FAILURE:-} ]] || exit 1
  if [[ $3 == ${OMARCHY_TEST_MASKED_UNIT:-} ]]; then
    echo masked
  elif [[ $3 == $OMARCHY_TEST_MISSING_UNIT ]]; then
    echo not-found
  else
    echo loaded
  fi
  exit 0
fi
[[ $* != *"$OMARCHY_TEST_MISSING_UNIT"* ]] || exit 1
printf '%s\n' "$*" >>"$OMARCHY_TEST_CALLS"
[[ $2 != "enable" || $4 != ${OMARCHY_TEST_MASKED_UNIT:-} ]]
SH
cat >"$mock_bin/omarchy-hook-install" <<'SH'
#!/bin/bash
echo "hook $*" >>"$OMARCHY_TEST_CALLS"
SH
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-input-method"
chmod +x "$mock_bin/systemctl" "$mock_bin/omarchy-hook-install" "$mock_bin/omarchy-input-method"

enable_user_units() {
  rm -f "$test_tmp/calls"
  PATH="$mock_bin:$PATH" OMARCHY_TEST_CALLS="$test_tmp/calls" OMARCHY_TEST_MISSING_UNIT="$1" \
    bash "$ROOT/install/user/first-run/enable-user-units.sh"
}

enable_user_units no-such-unit || fail "first-run enables its user units"
clean_run=$(<"$test_tmp/calls")
grep -Fq 'hook theme-set' <<<"$clean_run" || fail "first-run installs the theme hook"
(( $(grep -Fxc -- "--user daemon-reload" <<<"$clean_run") == 1 )) || fail "first-run reloads systemd user manager once"
mapfile -t units < <(sed -n '1,/^--user daemon-reload$/s/^--user enable --no-reload //p' <<<"$clean_run")
mapfile -t started < <(sed -n '/^--user daemon-reload$/,$s/^--user start //p' <<<"$clean_run")
[[ ${started[*]} == "${units[*]}" ]] || fail "first-run starts every enabled unit after reloading"

for unit in "${units[@]}"; do
  [[ $unit != *" "* ]] || fail "first-run enables each unit on its own" "$unit"
  if enable_user_units "$unit"; then
    fail "first-run reports a unit it could not enable" "$unit"
  fi
  expected=$(grep -Fvx -e "--user enable --no-reload $unit" -e "--user start $unit" <<<"$clean_run")
  [[ $(<"$test_tmp/calls") == "$expected" ]] ||
    fail "a unit missing from the build costs first-run only that unit" "$unit"
done
(( ${#units[@]} > 1 )) || fail "first-run enables each unit on its own"
pass "a unit missing from the build costs first-run only that unit"

masked=${units[0]}
remaining=$(grep -Fvx -e "--user enable --no-reload $masked" -e "--user start $masked" <<<"$clean_run")
OMARCHY_TEST_MASKED_UNIT="$masked" enable_user_units no-such-unit ||
  fail "first-run succeeds with an explicitly masked unit"
diff -u <(printf '%s\n' "$remaining") "$test_tmp/calls" ||
  fail "first-run preserves the mask and starts the other units"
if OMARCHY_TEST_QUERY_FAILURE="$masked" enable_user_units no-such-unit; then
  fail "first-run reports a failed unit state query"
fi
diff -u <(printf '%s\n' "$remaining") "$test_tmp/calls" ||
  fail "a failed query costs first-run only that unit"
pass "first-run preserves explicit masks and reports query failures"

cat >"$mock_bin/nm-online" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_CALLS"
SH
cat >"$mock_bin/omarchy-i18n" <<'SH'
#!/bin/bash
echo "$1"
SH
chmod +x "$mock_bin/nm-online" "$mock_bin/omarchy-notification-send" "$mock_bin/omarchy-i18n"

run_first_run_network() {
  : >"$test_tmp/calls"
  OMARCHY_PATH="$ROOT" PATH="$mock_bin:$PATH" OMARCHY_TEST_CALLS="$test_tmp/calls" \
    bash -c 'source "$1"; wait' _ "$ROOT/install/user/first-run/wifi.sh"
}

# Choosing an agent installs it, so the invitation waits for a connection.
cat >"$mock_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
SH
cat >"$mock_bin/omarchy-done" <<'SH'
#!/bin/bash
[[ $1 == "ensure" ]]
SH
chmod +x "$mock_bin/omarchy-default-agent" "$mock_bin/omarchy-done"
run_first_run_network
grep -Fq -- '--exec omarchy menu summon agent.harness' "$test_tmp/calls" ||
  fail "first run invites a default agent once there is a connection"
pass "first run invites a default agent once there is a connection"

