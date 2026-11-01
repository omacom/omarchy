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

# First run offers an update only when there is one. A fresh install from
# current media is already current, and a critical toast that leads to
# "nothing to do" teaches people to dismiss the next one.
cat >"$mock_bin/nm-online" <<'SH'
#!/bin/bash
exit 0
SH
# Like the real one, it looks for Omarchy's package with checkupdates.
cat >"$mock_bin/omarchy-update-available" <<'SH'
#!/bin/bash
checkupdates >/dev/null
exit "$OMARCHY_TEST_OMARCHY_UPDATE"
SH
cat >"$mock_bin/checkupdates" <<'SH'
#!/bin/bash
echo checkupdates >>"$OMARCHY_TEST_CALLS"
exit "$OMARCHY_TEST_CHECKUPDATES"
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_CALLS"
SH
cat >"$mock_bin/omarchy-i18n" <<'SH'
#!/bin/bash
echo "$1"
SH
chmod +x "$mock_bin/nm-online" "$mock_bin/omarchy-update-available" \
  "$mock_bin/checkupdates" "$mock_bin/omarchy-notification-send" "$mock_bin/omarchy-i18n"

# Arguments: OMARCHY_PATH, omarchy-update-available's exit status, then
# checkupdates'.
offers_update() {
  : >"$test_tmp/calls"
  OMARCHY_PATH="$1" PATH="$mock_bin:$PATH" OMARCHY_TEST_CALLS="$test_tmp/calls" \
    OMARCHY_TEST_OMARCHY_UPDATE="$2" OMARCHY_TEST_CHECKUPDATES="$3" \
    bash -c 'source "$1"; wait' _ "$ROOT/install/user/first-run/wifi.sh"
  grep -Fq -- '--exec omarchy-launch-floating-terminal-with-presentation omarchy-update' "$test_tmp/calls"
}

installed=/usr/share/omarchy
checkout="$test_tmp/omarchy-checkout"

if offers_update "$installed" 1 2; then
  fail "first run offers no update when nothing is pending"
fi
[[ $(grep -c '^checkupdates$' "$test_tmp/calls") == 1 ]] ||
  fail "first run syncs the package databases once"
offers_update "$installed" 1 0 || fail "first run offers an update when packages are pending"
offers_update "$installed" 1 1 || fail "first run offers an update when it cannot tell whether one is pending"
offers_update "$checkout" 0 2 || fail "first run offers an update when a development checkout is behind"
if offers_update "$checkout" 1 2; then
  fail "first run offers no update when a current checkout has nothing pending"
fi
pass "first run offers an update only when there is one"

# Arguments: the git name and email already configured, empty for unset.
offers_git_setup() {
  : >"$test_tmp/calls"
  local home="$test_tmp/git-home"
  rm -rf "$home" && mkdir -p "$home"
  [[ -z $1 ]] || HOME="$home" git config --global user.name "$1"
  [[ -z $2 ]] || HOME="$home" git config --global user.email "$2"
  HOME="$home" PATH="$mock_bin:$PATH" OMARCHY_TEST_CALLS="$test_tmp/calls" \
    bash "$ROOT/install/user/first-run/git.sh"
  grep -Fq 'omarchy-setup-git' "$test_tmp/calls"
}

offers_git_setup "" "" || fail "first run offers git setup on a fresh account"
offers_git_setup "Jane" "" || fail "first run offers git setup when the email is missing"
if offers_git_setup "Jane" "jane@example.com"; then
  fail "first run offers no git setup when the install already set an identity"
fi
pass "first run offers git setup only when the identity is missing"
