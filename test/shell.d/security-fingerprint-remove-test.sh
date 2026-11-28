#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

remove="$ROOT/bin/omarchy-remove-security-fingerprint"
test_tmp=$(mktemp -d /tmp/omarchy-fingerprint-remove.XXXXXX)
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
case $1 in
  -n) exit "${TEST_SUDO_CACHED:-0}" ;;
  -v) printf 'sudo -v\n' >>"$TEST_LOG"; exit "${TEST_SUDO_V_FAIL:-0}" ;;
esac
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
if [[ $* == "fprintd-delete $TEST_EXPECTED_USER" ]]; then
  (( ${TEST_PRINTS_FAIL:-0} == 0 )) || echo "${TEST_PRINTS_OUTPUT:-delete failed}"
  exit "${TEST_PRINTS_FAIL:-0}"
fi
if [[ $* == "omarchy-lifecycle-dispatch disable-fingerprint" ]]; then
  exit "${TEST_HOOK_FAIL:-0}"
fi
[[ $# == 4 && $1 == rm && $2 == -rf && $3 == -- && $4 == "$TEST_FPRINT/$TEST_EXPECTED_USER" ]] || exit 91
[[ ${TEST_DELETE_FAIL:-0} == 0 ]] || exit 92
exec /usr/bin/rm -rf -- "$4"
SH
# TEST_DISABLE_HOOK is what disable-fingerprint resolves to as the user.
cat >"$test_tmp/bin/omarchy-lifecycle-dispatch" <<'SH'
#!/bin/bash
printf 'resolve %s\n' "${*:2}" >>"$TEST_LOG"
(( ${TEST_RESOLVE_FAIL:-0} == 0 )) || { echo "Error: cannot resolve" >&2; exit 1; }
printf '%s\n' "${TEST_DISABLE_HOOK-/usr/lib/omarchy/mac/disable-fingerprint}"
SH
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == fprintd-delete && ${TEST_FPRINTD:-1} == 1 ]]
SH
cat >"$test_tmp/bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf 'package %s\n' "$*" >>"$TEST_LOG"
[[ ${TEST_PACKAGE_FAIL:-0} == 0 ]]
SH
chmod +x "$test_tmp/bin/"* "$test_tmp/trusted-id"

# Root test runs still exercise the ordinary caller branch as a real user.
# The copied script and stubs live in this scratch tree, so a private checkout
# does not need to be traversable after dropping privileges.
if (( EUID == 0 )); then
  require_command setpriv
  passwd_entry=$(getent passwd nobody) || fail "an unprivileged test account is available"
  IFS=: read -r test_username _ test_uid test_gid _ _ _ <<<"$passwd_entry"
  [[ $test_uid =~ ^[0-9]+$ && $test_gid =~ ^[0-9]+$ ]] || fail "unprivileged test account has numeric IDs"
  touch "$log" "$output"
  chown -R "$test_uid:$test_gid" "$test_tmp"
else
  test_username=$(/usr/bin/id -un)
fi

run_remove() {
  : >"$log"
  local status=0
  local sudo_env=()
  [[ -v SUDO_UID ]] && sudo_env=("SUDO_UID=$SUDO_UID")
  local fixture_env=(
    "TEST_LOG=$log" "TEST_FPRINT=$test_tmp/fprint" "TEST_EXPECTED_USER=$expected"
    "TEST_DIRECT_USER=$direct_user" "TEST_SUDO_USER=$sudo_user" "TEST_SUDO_UID=${SUDO_UID:-}"
    "TEST_ID_FAIL=${id_fail:-0}" "TEST_DELETE_FAIL=${delete_fail:-0}"
    "TEST_PACKAGE_FAIL=${package_fail:-0}" "TEST_PRINTS_FAIL=${prints_fail:-0}" "TEST_FPRINTD=${fprintd:-1}"
    "TEST_PRINTS_OUTPUT=${prints_output:-}" "TEST_SUDO_CACHED=${sudo_cached:-0}" "TEST_SUDO_V_FAIL=${sudo_v_fail:-0}"
    "TEST_HOOK_FAIL=${hook_fail:-0}" "TEST_RESOLVE_FAIL=${resolve_fail:-0}"
    "TEST_DISABLE_HOOK=${disable_hook-/usr/lib/omarchy/mac/disable-fingerprint}"
    "USER=spoofed" "SUDO_USER=spoofed"
    "PATH=$test_tmp/bin:/usr/bin:/bin"
  )
  if (( EUID == 0 )); then
    chown -R "$test_uid:$test_gid" "$test_tmp"
    setpriv --reuid="$test_uid" --regid="$test_gid" --clear-groups \
      env -u SUDO_UID "${sudo_env[@]}" "${fixture_env[@]}" bash "$copy" >"$output" 2>&1 || status=$?
  else
    env -u SUDO_UID "${sudo_env[@]}" "${fixture_env[@]}" bash "$copy" >"$output" 2>&1 || status=$?
  fi
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

# A match-on-chip reader keeps prints in the device too: fprintd deletes them
# there before anything else goes.
[[ $(grep -m1 '^sudo ' "$log") == 'sudo fprintd-delete alice' ]] || fail "fprintd deletes the prints first" "$(cat "$log")"
! grep -q 'may' "$output" || fail "a delete that worked warns about nothing" "$(cat "$output")"
prints_fail=1
mkdir -p "$test_tmp/fprint/alice"
run_remove || fail "a failed fprintd delete does not stop removal" "$(cat "$output")"
grep -q "may not have been deleted: delete failed" "$output" && [[ ! -e $test_tmp/fprint/alice ]] ||
  fail "a failed delete is reported, and the local files still go" "$(cat "$output")"
prints_output="No devices available"
run_remove || fail "removal with no reader available succeeds" "$(cat "$output")"
grep -q 'No fingerprint reader is available now' "$output" && ! grep -q 'may not have been deleted' "$output" ||
  fail "no reader to delete from is said plainly, not as a failed delete" "$(cat "$output")"
unset prints_fail prints_output
fprintd=0
run_remove || fail "removal without fprintd succeeds" "$(cat "$output")"
! grep -q '^sudo fprintd-delete' "$log" || fail "without fprintd nothing asks it to delete"
unset fprintd
pass "prints are deleted in the reader first, and a delete that can't run doesn't stop removal"

# A platform that turned its reader on for setup turns it off again, after the
# local files go and before the packages; a failure is reported, not fatal.
run_remove || fail "removal on a platform with the hook succeeds" "$(cat "$output")"
calls=$(grep -E '^(sudo rm|sudo omarchy-lifecycle-dispatch|package )' "$log")
[[ $calls == "sudo rm -rf -- $test_tmp/fprint/alice"$'\nsudo omarchy-lifecycle-dispatch disable-fingerprint\npackage fprintd libfprint libfprint-git' ]] ||
  fail "the platform turns its reader off after the local files go and before the packages" "$calls"
! grep -q 'may still be turned on' "$output" || fail "a hook that worked warns about nothing" "$(cat "$output")"
hook_fail=1
run_remove || fail "a failed platform hook does not stop removal" "$(cat "$output")"
grep -q 'may still be turned on' "$output" || fail "a failed platform hook is reported" "$(cat "$output")"
unset hook_fail
resolve_fail=1
run_remove || fail "a platform hook that can't be resolved does not stop removal" "$(cat "$output")"
! grep -q '^sudo omarchy-lifecycle-dispatch' "$log" && grep -q 'cannot resolve' "$output" && grep -q 'may still be turned on' "$output" ||
  fail "a platform hook that can't be resolved is reported, and nothing runs it" "$(cat "$log"; cat "$output")"
unset resolve_fail
disable_hook=
run_remove || fail "removal on a platform without the hook succeeds" "$(cat "$output")"
! grep -q 'may' "$output" || fail "a platform without the hook warns about nothing" "$(cat "$output")"
grep -qx 'resolve disable-fingerprint' "$log" && ! grep -q '^sudo omarchy-lifecycle-dispatch' "$log" ||
  fail "a platform without the hook runs nothing as root for it" "$(cat "$log")"
unset disable_hook
pass "the platform turns its reader off before the packages go, and a platform without the hook runs nothing for it"

# sudo asks in view before the silenced delete, and a refusal changes nothing.
sudo_cached=1
run_remove || fail "removal with sudo to authenticate succeeds" "$(cat "$output")"
[[ $(grep -m2 '^sudo ' "$log") == $'sudo -v\nsudo fprintd-delete alice' ]] || fail "sudo authenticates before the delete" "$(cat "$log")"
mkdir -p "$test_tmp/fprint/alice"
printf 'auth sufficient pam_fprintd.so\n' >"$test_tmp/etc/pam.d/sudo"
sudo_v_fail=1
if run_remove; then
  fail "removal stops when sudo won't authenticate"
fi
! grep -Eq '^sudo [^-]|^package ' "$log" && grep -Fq pam_fprintd.so "$test_tmp/etc/pam.d/sudo" && [[ -d $test_tmp/fprint/alice ]] &&
  grep -q 'needs administrator rights' "$output" || fail "a refused sudo changes nothing, and removal says why" "$(cat "$log"; cat "$output")"
: >"$test_tmp/etc/pam.d/sudo"
unset sudo_cached sudo_v_fail
pass "sudo authenticates in view before the delete, and a refusal changes nothing"

SUDO_UID=12345
run_remove || fail "unprivileged caller ignores forged SUDO_UID" "$(cat "$output")"
grep -Fxq 'id -un' "$log" || fail "unprivileged caller must resolve itself"
! grep -Fq 'id -nu' "$log" || fail "unprivileged caller must ignore SUDO_UID"
unset SUDO_UID
pass "unprivileged caller ignores forged SUDO_UID"

sed "s|$test_tmp/trusted-id|/usr/bin/id|g" "$copy" >"$test_tmp/absolute-id.sh"
copy="$test_tmp/absolute-id.sh" expected=$test_username
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
  if (( EUID == 0 )); then
    chown -R 0:0 "$test_tmp"
  fi
  run_root() {
    : >"$log"
    local status=0
    local sudo_env=()
    [[ -v SUDO_UID ]] && sudo_env=("SUDO_UID=$SUDO_UID")
    TEST_LOG="$log" TEST_FPRINT="$test_tmp/fprint" TEST_EXPECTED_USER="$expected" \
      TEST_DIRECT_USER=root TEST_SUDO_USER="$sudo_user" TEST_SUDO_UID="${SUDO_UID:-}" \
      USER=spoofed SUDO_USER=spoofed PATH="$test_tmp/bin:/usr/bin:/bin" \
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
