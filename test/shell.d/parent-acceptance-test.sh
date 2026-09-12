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
sed "s|/etc/|$test_tmp/etc/|g" "$ROOT/test/acceptance.d/parent-test.sh" >"$acceptance"
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
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/omarchy-profile-child"
# A deliberate failure must not capture the development session's screen.
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/timeout"
chmod +x "$test_tmp/bin"/*

export TEST_SUDO_LOG="$test_tmp/sudo.log" TEST_SUDO_TIMESTAMP="$test_tmp/timestamp"

run_acceptance() {
  : >"$TEST_SUDO_LOG"
  PATH="$test_tmp/bin:$PATH" USER=kid OMARCHY_ACCEPTANCE_DIR="$test_tmp/artifacts" \
    OMARCHY_ACCEPTANCE_USER_PASSWORD=kid-password OMARCHY_ACCEPTANCE_SUDO_PASSWORD=parent-password \
    bash "$1"
}

run_acceptance "$acceptance" >"$test_tmp/output" 2>&1 ||
  fail "the parent acceptance test reaches every policy check" "$(<"$test_tmp/output")"
grep -q 'ok - the parent password is wired into the lock screen and the login screen' "$test_tmp/output" ||
  fail "the parent acceptance test reaches its final PAM assertion"
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

# Restoring the reported -k idiom must stop at the first sudo -n assertion.
sed 's/sudo -S -v/sudo -S -k -v/' "$acceptance" >"$test_tmp/acceptance.d/uncached-test.sh"
if run_acceptance "$test_tmp/acceptance.d/uncached-test.sh" >"$test_tmp/output" 2>&1; then
  fail "the timestamp model detects validation that does not cache"
fi
grep -q "not ok - sudo is configured to ask for root's password" "$test_tmp/output" ||
  fail "uncached validation fails at the first noninteractive policy check" "$(<"$test_tmp/output")"
pass "the parent acceptance fixture detects the uncached sudo validation regression"
