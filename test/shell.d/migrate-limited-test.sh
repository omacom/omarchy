#!/bin/bash
#
# A limited account's migrations apply only its own part: sudo and pkexec run
# nothing and report success, since an administrator's run of the same
# migration does the machine-wide steps. An administrator's run uses them.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# An Omarchy root with the runner's stand-ins and three migrations: one that
# pipes into sudo, one that asks pkexec, one that fails for another reason.
test_root="$test_tmp/omarchy"
mkdir -p "$test_root/migrations" "$test_root/default/omarchy"
cp -a "$ROOT/default/omarchy/migrate-limited" "$test_root/default/omarchy/"
cat >"$test_root/migrations/100-machine-and-user.sh" <<'SH'
printf 'setting\n' | sudo tee "$TEST_TMP/machine-setting" >/dev/null
sudo systemctl reload systemd-logind
echo "user step 100" >>"$TEST_CALLS"
SH
cat >"$test_root/migrations/200-pkexec.sh" <<'SH'
pkexec true
echo "user step 200" >>"$TEST_CALLS"
SH

# The real sudo and pkexec: every call that reaches them is recorded.
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
for command in sudo pkexec; do
  printf '#!/bin/bash\necho "%s $*" >>"$TEST_ESCALATIONS"\n[[ $1 != "tee" ]] || cat >"$2"\n' "$command" >"$mock_bin/$command"
done
cat >"$mock_bin/omarchy-sudo-allowed" <<'SH'
#!/bin/bash
[[ $TEST_ADMIN == "yes" ]]
SH
# omarchy-migrate takes the update lock; here it runs as if it already held it,
# and never touches the machine's real one.
cat >"$mock_bin/omarchy-update-lock" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

run_migrate() { # ADMIN
  local home="$test_tmp/home-$1"
  rm -rf "$home" "$test_tmp/machine-setting"
  mkdir -p "$home"
  : >"$test_tmp/calls"
  : >"$test_tmp/escalations"
  HOME="$home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$test_root" TEST_ADMIN="$1" TEST_TMP="$test_tmp" \
    TEST_CALLS="$test_tmp/calls" TEST_ESCALATIONS="$test_tmp/escalations" \
    "$ROOT/bin/omarchy-migrate" >"$test_tmp/out" 2>"$test_tmp/err"
}

run_migrate no || fail "a limited account's migrations finish" "$(cat "$test_tmp/err")"
[[ ! -s $test_tmp/escalations && ! -e $test_tmp/machine-setting ]] ||
  fail "a limited account's migrations never reach sudo or pkexec" "$(cat "$test_tmp/escalations")"
[[ $(cat "$test_tmp/calls") == $'user step 100\nuser step 200' ]] ||
  fail "a limited account's migrations apply its own part" "$(cat "$test_tmp/calls")"
[[ -f $test_tmp/home-no/.local/state/omarchy/migrations/100-machine-and-user.sh && -f $test_tmp/home-no/.local/state/omarchy/migrations/200-pkexec.sh ]] ||
  fail "a limited account's migrations are recorded as done"
grep -qx "Left to an administrator: sudo systemctl reload systemd-logind" "$test_tmp/err" &&
  grep -qx "Left to an administrator: pkexec true" "$test_tmp/err" ||
  fail "a limited account's run says what it left to an administrator" "$(cat "$test_tmp/err")"
pass "a limited account's migrations apply its own part and leave sudo and pkexec to an administrator"

run_migrate yes || fail "an administrator's migrations finish" "$(cat "$test_tmp/err")"
[[ $(cat "$test_tmp/machine-setting" 2>/dev/null) == "setting" ]] &&
  grep -qx "sudo systemctl reload systemd-logind" "$test_tmp/escalations" &&
  grep -qx "pkexec true" "$test_tmp/escalations" ||
  fail "an administrator's migrations use sudo and pkexec" "$(cat "$test_tmp/escalations")"
pass "an administrator's migrations use sudo and pkexec"

# Anything else that fails still fails, and stays pending.
cat >"$test_root/migrations/300-broken.sh" <<'SH'
false
SH
if run_migrate no; then fail "a migration that fails for a limited account fails the run"; fi
[[ ! -f $test_tmp/home-no/.local/state/omarchy/migrations/300-broken.sh ]] ||
  fail "a migration that fails for a limited account stays pending"
pass "a migration that fails for another reason stays pending for a limited account"

# A step about the account itself is no administrator's run's to do: it fails,
# says so, and stays pending, while the machine-wide ones before it are left.
rm -f "$test_root/migrations/300-broken.sh"
cat >"$test_root/migrations/400-this-account.sh" <<'SH'
sudo gpasswd -d "$USER" input
echo "user step 400" >>"$TEST_CALLS"
SH
cat >"$test_root/migrations/500-this-home.sh" <<'SH'
sudo chown root "$HOME/.config/thing"
SH
if run_migrate no; then fail "a step about a limited account itself fails its migration"; fi
grep -qx "Needs an administrator, for this account: sudo gpasswd -d $(id -un) input" "$test_tmp/err" &&
  [[ ! -s $test_tmp/escalations && $(cat "$test_tmp/calls") == $'user step 100\nuser step 200' ]] &&
  [[ ! -f $test_tmp/home-no/.local/state/omarchy/migrations/400-this-account.sh ]] ||
  fail "a step about a limited account itself says so and stays pending" "$(cat "$test_tmp/err"; cat "$test_tmp/calls")"
rm -f "$test_root/migrations/400-this-account.sh"
cat >"$test_root/migrations/450-this-owner.sh" <<'SH'
sudo chown "$USER:$USER" /var/lib/example
SH
if run_migrate no; then fail "a step naming a limited account as user:group fails its migration"; fi
grep -qx "Needs an administrator, for this account: sudo chown $(id -un):$(id -un) /var/lib/example" "$test_tmp/err" ||
  fail "a step naming a limited account as user:group says so" "$(cat "$test_tmp/err")"
rm -f "$test_root/migrations/450-this-owner.sh"
# A program that shares the account's name is still a machine-wide step.
cat >"$test_root/migrations/460-program-named-like-the-account.sh" <<'SH'
sudo -n "$USER" --check /etc/example
SH
if ! run_migrate no 2>/dev/null; then :; fi
grep -qx "Left to an administrator: sudo -n $(id -un) --check /etc/example" "$test_tmp/err" ||
  fail "a program that shares the account's name is left to an administrator" "$(cat "$test_tmp/err")"
rm -f "$test_root/migrations/460-program-named-like-the-account.sh"
if run_migrate no; then fail "a step about a limited account's home fails its migration"; fi
grep -q "Needs an administrator, for this account: sudo chown root .*/.config/thing" "$test_tmp/err" ||
  fail "a step about a limited account's home says so" "$(cat "$test_tmp/err")"
pass "a step about the limited account itself fails and stays pending, saying it needs an administrator"
