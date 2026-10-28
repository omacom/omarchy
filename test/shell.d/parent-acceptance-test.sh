#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/acceptance.d" "$test_tmp/etc/sudoers.d" \
  "$test_tmp/etc/polkit-1/rules.d" "$test_tmp/etc/pam.d" "$test_tmp/etc/omarchy"

# Exercise the real acceptance flow against fixture policy files and a sudo
# timestamp model. This checks the test's coverage and cleanup, not live PAM.
acceptance="$test_tmp/acceptance.d/parent-test.sh"
# Only the helper's invocations are redirected; the PAM lines it is grepped
# for keep the path pam_exec runs.
sed "s|/etc/|$test_tmp/etc/|g; s|PAM_TYPE=auth /usr/bin/omarchy-parent-unlock|PAM_TYPE=auth $test_tmp/bin/omarchy-parent-unlock|g" "$ROOT/test/acceptance.d/parent-test.sh" >"$acceptance"
cp "$ROOT/test/acceptance.d/base-test.sh" "$test_tmp/acceptance.d/base-test.sh"
printf 'Defaults rootpw\n' >"$test_tmp/etc/sudoers.d/omarchy-parent"
touch "$test_tmp/etc/sudoers.d/omarchy-parent-kid"
printf 'return ["unix-user:root"];\n' >"$test_tmp/etc/polkit-1/rules.d/40-omarchy-parent.rules"
printf 'child\n' >"$test_tmp/etc/omarchy/profile"
cat >"$test_tmp/etc/pam.d/sddm" <<'PAM'
auth [success=2 default=ignore] pam_unix.so
auth [success=1 default=ignore] pam_exec.so quiet seteuid expose_authtok /usr/bin/omarchy-parent-unlock
auth requisite pam_nologin.so
PAM
cp "$test_tmp/etc/pam.d/sddm" "$test_tmp/etc/pam.d/omarchy-lock-password"
touch "$test_tmp/etc/pam.d/sddm.omarchy-orig"

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$*" >>"$TEST_SUDO_LOG"
case "$1" in
  -K)
    rm -f "$TEST_SUDO_TIMESTAMP"
    ;;
  -S)
    cache=1
    for argument in "$@"; do
      if [[ $argument == "-k" ]]; then cache=0; fi
    done
    IFS= read -r password
    [[ $password == "$OMARCHY_ACCEPTANCE_SUDO_PASSWORD" ]] || exit 1
    # sudo -k -v authenticates without updating its timestamp.
    if (( cache )); then touch "$TEST_SUDO_TIMESTAMP"; fi
    ;;
  -n)
    [[ -f $TEST_SUDO_TIMESTAMP ]] || exit 1
    shift
    if [[ $1 == "-l" ]]; then
      [[ $3 == "/usr/bin/omarchy-theme-set-browser-policy" ]] || exit 1
      printf '!authenticate\n'
    elif [[ ${TEST_POLICY_FAILURE:-0} == "1" && $* == *"sddm.omarchy-orig"* ]]; then
      exit 1
    else
      exec "$@"
    fi
    ;;
  *) exit 1 ;;
esac
SH
printf '#!/bin/bash\nprintf "kid\\n"\n' >"$test_tmp/bin/id"
printf '#!/bin/bash\nexit "${STUB_PROFILE_STATUS:-0}"\n' >"$test_tmp/bin/omarchy-profile-child"
# The PAM helper, as the acceptance test runs it: the password on stdin, the
# account in PAM_USER, and only the parent password passes.
cat >"$test_tmp/bin/omarchy-parent-unlock" <<'SH'
#!/bin/bash
[[ ${PAM_USER:-} == kid && ${PAM_TYPE:-} == auth ]] || exit 1
[[ $(cat) == "$OMARCHY_ACCEPTANCE_SUDO_PASSWORD" ]]
SH
# A deliberate failure must not capture the development session's screen.
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/timeout"
chmod +x "$test_tmp/bin"/*

export TEST_SUDO_LOG="$test_tmp/sudo.log" TEST_SUDO_TIMESTAMP="$test_tmp/timestamp"

# Both passwords are supplied unless a caller sets ACCEPT_USER_PASSWORD or
# ACCEPT_SUDO_PASSWORD empty.
run_acceptance() {
  : >"$TEST_SUDO_LOG"
  PATH="$test_tmp/bin:$PATH" USER=kid OMARCHY_ACCEPTANCE_DIR="$test_tmp/artifacts" \
    OMARCHY_ACCEPTANCE_USER_PASSWORD="${ACCEPT_USER_PASSWORD-kid-password}" OMARCHY_ACCEPTANCE_SUDO_PASSWORD="${ACCEPT_SUDO_PASSWORD-parent-password}" \
    bash "$1"
}

run_acceptance "$acceptance" >"$test_tmp/output" 2>&1 ||
  fail "the parent acceptance test reaches every policy check" "$(<"$test_tmp/output")"
grep -q 'ok - the parent password is wired into the lock screen and the login screen' "$test_tmp/output" ||
  fail "the parent acceptance test reaches its final PAM assertion"
grep -q 'ok - omarchy-parent-unlock accepts the parent password' "$test_tmp/output" ||
  fail "the parent acceptance test runs the unlock helper against both passwords" "$(<"$test_tmp/output")"
! grep -q '# SKIP' "$test_tmp/output" || fail "a run with both passwords on a child install skips nothing" "$(<"$test_tmp/output")"
[[ ! -e $TEST_SUDO_TIMESTAMP && $(grep -cx -- '-K' "$TEST_SUDO_LOG") == 2 ]] ||
  fail "a successful parent acceptance test clears the sudo timestamp"
pass "the parent acceptance test caches validation through its policy checks and clears it on success"

if TEST_POLICY_FAILURE=1 run_acceptance "$acceptance" >"$test_tmp/output" 2>&1; then
  fail "a broken login policy fails the parent acceptance test"
fi
grep -q 'not ok - the packaged login stack is kept beside the child one' "$test_tmp/output" ||
  fail "the injected policy failure happens after sudo validation" "$(<"$test_tmp/output")"
[[ ! -e $TEST_SUDO_TIMESTAMP && $(grep -cx -- '-K' "$TEST_SUDO_LOG") == 2 ]] ||
  fail "a failed parent acceptance test clears the sudo timestamp"
pass "the parent acceptance test also clears cached credentials after a policy failure"

# The checks never pass by not running. Without the harness's designation a
# machine that is not a child install, or one without the passwords, skips and
# says so; a run named child fails on either, and a run named default fails
# on a child install.
STUB_PROFILE_STATUS=1 run_acceptance "$acceptance" >"$test_tmp/output" 2>&1 ||
  fail "an undesignated run on a non-child install exits cleanly" "$(<"$test_tmp/output")"
grep -qx 'ok - child install checks: not a child install # SKIP' "$test_tmp/output" ||
  fail "an undesignated run on a non-child install reports a skip" "$(<"$test_tmp/output")"
ACCEPT_USER_PASSWORD= run_acceptance "$acceptance" >"$test_tmp/output" 2>&1 ||
  fail "an undesignated run without the kid password exits cleanly" "$(<"$test_tmp/output")"
grep -q '^ok - child install checks: set OMARCHY_ACCEPTANCE_SUDO_PASSWORD .* # SKIP$' "$test_tmp/output" ||
  fail "an undesignated run without the passwords reports a skip" "$(<"$test_tmp/output")"
pass "without a designated profile the child checks skip visibly instead of passing"

if STUB_PROFILE_STATUS=1 OMARCHY_ACCEPTANCE_PROFILE=child run_acceptance "$acceptance" >"$test_tmp/output" 2>&1; then
  fail "a run designated child fails on a non-child install"
fi
grep -q 'not ok - a child run lands on a child install' "$test_tmp/output" ||
  fail "a child run on a non-child install names the mismatch" "$(<"$test_tmp/output")"
if ACCEPT_SUDO_PASSWORD= OMARCHY_ACCEPTANCE_PROFILE=child run_acceptance "$acceptance" >"$test_tmp/output" 2>&1; then
  fail "a run designated child fails without the parent password"
fi
grep -q 'not ok - a child run carries both passwords' "$test_tmp/output" ||
  fail "a child run without its passwords names what is missing" "$(<"$test_tmp/output")"
if OMARCHY_ACCEPTANCE_PROFILE=default run_acceptance "$acceptance" >"$test_tmp/output" 2>&1; then
  fail "a run designated default fails on a child install"
fi
grep -q 'not ok - a default run lands on a default install' "$test_tmp/output" ||
  fail "a default run on a child install names the mismatch" "$(<"$test_tmp/output")"
pass "a designated run fails instead of skipping when the install or the passwords do not match it"

# Restoring the reported -k idiom must stop at the first sudo -n assertion.
sed 's/sudo -S -v/sudo -S -k -v/' "$acceptance" >"$test_tmp/acceptance.d/uncached-test.sh"
if run_acceptance "$test_tmp/acceptance.d/uncached-test.sh" >"$test_tmp/output" 2>&1; then
  fail "the timestamp model detects validation that does not cache"
fi
grep -q "not ok - sudo is configured to ask for root's password" "$test_tmp/output" ||
  fail "uncached validation fails at the first noninteractive policy check" "$(<"$test_tmp/output")"
pass "the parent acceptance fixture detects the uncached sudo validation regression"
