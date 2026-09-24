#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

remove="$ROOT/bin/omarchy-remove-security-fingerprint"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/etc/pam.d" "$test_tmp/fprint"
copy="$test_tmp/remove.sh"
log="$test_tmp/calls"
output="$test_tmp/output"

(( $(grep -Fxc 'sudo rm -rf -- "/var/lib/fprint/$fingerprint_user"' "$remove") == 1 )) ||
  fail "fingerprint removal has one fixed deletion path"
sed -e "s|/etc/pam.d/|$test_tmp/etc/pam.d/|g" \
  -e "s|/var/lib/fprint/|$test_tmp/fprint/|g" \
  -e "s|/usr/bin/id|$test_tmp/trusted-id|g" "$remove" >"$copy"

cat >"$test_tmp/trusted-id" <<'SH'
#!/bin/bash
printf 'id %s\n' "$*" >>"$TEST_LOG"
[[ ${TEST_ID_FAIL:-0} == 0 ]] || exit 93
case "$1" in
  -un) printf '%s\n' "$TEST_DIRECT_USER" ;;
  -nu)
    [[ $# == 2 && $2 == "+$TEST_SUDO_UID" ]] || exit 90
    printf '%s\n' "$TEST_SUDO_USER"
    ;;
  *) exit 90 ;;
esac
SH
cat >"$test_tmp/bin/id" <<'SH'
#!/bin/bash
: >"$TEST_FPRINT/../untrusted-id-called"
printf 'bob\n'
SH
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
[[ $# == 4 && $1 == rm && $2 == -rf && $3 == -- && $4 == "$TEST_FPRINT/$TEST_EXPECTED_USER" ]] || exit 91
[[ ${TEST_DELETE_FAIL:-0} == 0 ]] || exit 92
exec /usr/bin/rm -rf -- "$4"
SH
cat >"$test_tmp/bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf 'package %s\n' "$*" >>"$TEST_LOG"
[[ ${TEST_PACKAGE_FAIL:-0} == 0 ]]
SH
chmod +x "$test_tmp/bin/"* "$test_tmp/trusted-id"

run_remove() {
  : >"$log"
  local status=0
  TEST_LOG="$log" TEST_FPRINT="$test_tmp/fprint" TEST_EXPECTED_USER="$expected" \
    TEST_DIRECT_USER="$direct_user" TEST_SUDO_USER="$sudo_user" TEST_SUDO_UID="${SUDO_UID:-}" \
    TEST_ID_FAIL="${id_fail:-0}" SUDO_UID="${SUDO_UID:-}" \
    TEST_DELETE_FAIL="${delete_fail:-0}" TEST_PACKAGE_FAIL="${package_fail:-0}" \
    USER=spoofed SUDO_USER=spoofed PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    bash "$copy" >"$output" 2>&1 || status=$?
  return "$status"
}

direct_user=alice sudo_user=alice expected=alice
unset SUDO_UID
mkdir -p "$test_tmp/fprint/alice" "$test_tmp/fprint/bob"
touch "$test_tmp/fprint/alice/print" "$test_tmp/fprint/bob/print"
run_remove || fail "direct user removal succeeds" "$(cat "$output")"
[[ ! -e $test_tmp/fprint/alice && -f $test_tmp/fprint/bob/print ]] ||
  fail "only the invoking user's local files are deleted"
grep -Fxq 'id -un' "$log" || fail "direct user is resolved through id"
grep -Fq "sudo rm -rf -- $test_tmp/fprint/alice" "$log" || fail "deletion precedes package drop"
[[ $(tail -n 1 "$log") == 'package fprintd libfprint libfprint-git' ]] || fail "packages drop after deletion"
grep -Fq "alice's local saved fingerprints have been removed" "$output" || fail "success describes local saved files"
pass "direct user ignores spoofed USER and leaves other accounts alone"

SUDO_UID=12345
run_remove || fail "unprivileged caller ignores forged SUDO_UID" "$(cat "$output")"
grep -Fxq 'id -un' "$log" || fail "unprivileged caller must resolve itself"
! grep -Fq 'id -nu' "$log" || fail "unprivileged caller must ignore SUDO_UID"
unset SUDO_UID
pass "unprivileged caller ignores forged SUDO_UID"

sed "s|$test_tmp/trusted-id|/usr/bin/id|g" "$copy" >"$test_tmp/absolute-id.sh"
copy="$test_tmp/absolute-id.sh" expected=$(/usr/bin/id -un)
mkdir -p "$test_tmp/fprint/$expected"
run_remove || fail "absolute system id ignores malicious PATH id" "$(cat "$output")"
[[ ! -e $test_tmp/fprint/$expected && -f $test_tmp/fprint/bob/print ]] || fail "system id selects only the invoking user"
copy="$test_tmp/remove.sh" expected=alice
pass "absolute system id ignores malicious PATH id"

run_remove || fail "missing fingerprint directory is idempotent" "$(cat "$output")"
pass "missing user directory succeeds"

delete_fail=1
run_remove && fail "deletion failure must fail removal"
! grep -Fq 'package ' "$log" || fail "deletion failure must stop package removal"
! grep -Fq 'have been removed' "$output" || fail "deletion failure must suppress success"
unset delete_fail
pass "deletion failure stops package removal and success"

package_fail=1
run_remove && fail "package failure must fail removal"
! grep -Fq 'have been removed' "$output" || fail "package failure must suppress success"
unset package_fail
pass "package failure suppresses success"

for direct_user in '' . .. 'other/name'; do
  printf 'auth required pam_fprintd.so\n' >"$test_tmp/etc/pam.d/sudo"
  run_remove && fail "unsafe identity must fail: $direct_user"
  ! grep -Eq '^sudo |^package ' "$log" || fail "unsafe identity changed host state: $direct_user"
done
: >"$test_tmp/etc/pam.d/sudo"
pass "unsafe direct identities fail before any mutation"

printf 'auth required pam_fprintd.so\n' >"$test_tmp/etc/pam.d/sudo"
id_fail=1
run_remove && fail "failed id lookup must abort"
! grep -Eq '^sudo |^package ' "$log" || fail "failed id lookup changed state"
grep -Fq 'pam_fprintd.so' "$test_tmp/etc/pam.d/sudo" || fail "failed id lookup changed PAM"
unset id_fail
: >"$test_tmp/etc/pam.d/sudo"
pass "failed id lookup aborts before mutations"

if unshare -Ur true >/dev/null 2>&1; then
  run_root() {
    : >"$log"
    local status=0
    local sudo_env=()
    [[ -v SUDO_UID ]] && sudo_env=("SUDO_UID=$SUDO_UID")
    TEST_LOG="$log" TEST_FPRINT="$test_tmp/fprint" TEST_EXPECTED_USER="$expected" \
      TEST_DIRECT_USER=root TEST_SUDO_USER="$sudo_user" TEST_SUDO_UID="${SUDO_UID:-}" \
      USER=spoofed SUDO_USER=spoofed PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
      env -u SUDO_UID "${sudo_env[@]}" unshare -Ur bash "$copy" >"$output" 2>&1 || status=$?
    return "$status"
  }

  SUDO_UID=1000 sudo_user=alice expected=alice
  mkdir -p "$test_tmp/fprint/alice"
  run_root || fail "root through sudo resolves numeric SUDO_UID" "$(cat "$output"; cat "$log")"
  [[ ! -e $test_tmp/fprint/alice ]] || fail "root through sudo deletes the caller's files"
  grep -Fxq 'id -nu +1000' "$log" || fail "root through sudo uses numeric UID lookup"
  pass "root through sudo ignores spoofed SUDO_USER"

  # Exercise real coreutils lookup with a numeric username shadowing UID 1000.
  if unshare -Ur -m true >/dev/null 2>&1; then
    printf 'alice:x:1000:1000::/:/bin/bash\n1000:x:2000:2000::/:/bin/bash\n' >"$test_tmp/passwd"
    awk '/^remove_pam_config\(\)/ { exit } { print }' "$remove" >"$test_tmp/identity.sh"
    resolved=$(unshare -Ur -m bash -c '
      mount --make-rprivate /
      mount --bind "$1" /etc/passwd
      SUDO_UID=1000 source "$2"
      printf "%s\n" "$fingerprint_user"
    ' bash "$test_tmp/passwd" "$test_tmp/identity.sh")
    [[ $resolved == alice ]] || fail "numeric UID lookup ignores a numeric username" "$resolved"
    pass "real id resolves the UID despite a colliding numeric username"
  else
    skip "mount namespaces unavailable; real numeric username collision"
  fi

  for SUDO_UID in bogus '../1000'; do
    run_root && fail "non-numeric SUDO_UID must fail"
    [[ ! -s $log ]] || fail "invalid SUDO_UID reached a command"
  done
  SUDO_UID=1000 sudo_user='../bob'
  run_root && fail "unsafe resolved sudo identity must fail"
  ! grep -Eq '^sudo |^package ' "$log" || fail "unsafe sudo identity changed state"
  pass "invalid sudo UID and unsafe resolved name fail before mutation"

  unset SUDO_UID
  expected=root
  mkdir -p "$test_tmp/fprint/root"
  run_root || fail "direct root resolves itself" "$(cat "$output")"
  [[ ! -e $test_tmp/fprint/root ]] || fail "direct root deletes its own files"
  grep -Fxq 'id -un' "$log" || fail "direct root uses id -un"
  pass "direct root retains its invocation behavior"
else
  skip "user namespaces unavailable; root identity cases"
fi

[[ ! -e $test_tmp/untrusted-id-called ]] || fail "malicious PATH id was executed"
pass "PATH id was never executed in any identity case"
