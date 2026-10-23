#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

remove="$ROOT/bin/omarchy-remove-security-face"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
pamd="$test_tmp/etc/pam.d"
omarchy_etc="$test_tmp/etc/omarchy"
units="$test_tmp/etc/systemd/system"
sudoersd="$test_tmp/etc/sudoers.d"
log="$test_tmp/calls.log"
output="$test_tmp/output"
copy="$test_tmp/remove.sh"
mkdir -p "$stub_bin"

gate='auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed'
face_gate='auth      [success=2 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed'
hint_line='auth      optional pam_exec.so seteuid quiet stdout /usr/bin/omarchy-face-match --hint'
stable_line='auth      sufficient pam_exec.so seteuid quiet stdout expose_authtok /usr/bin/omarchy-face-match'
legacy_line='auth      sufficient pam_python.so /usr/lib/security/howdy/pam.py'
beta_line='auth      sufficient pam_howdy.so'
fingerprint_line='auth      sufficient pam_fprintd.so'
includes=$(printf '%s\n' $'auth\t\tinclude\t\tsystem-auth' $'account\t\tinclude\t\tsystem-auth')

for literal in 'lock_pam=/etc/pam.d/omarchy-lock-face' 'verify_pam=/etc/pam.d/omarchy-face-verify' 'face_conf=/etc/omarchy/face.conf' \
  'key_socket=/etc/systemd/system/omarchy-face-key.socket' 'key_service=/etc/systemd/system/omarchy-face-key.service' \
  'lock_grant=/etc/sudoers.d/omarchy-face-match'; do
  (( $(grep -Fxc "$literal" "$remove") == 1 )) || fail "removal names $literal exactly once"
done
sed -e "s|/etc/pam.d/|$pamd/|g" -e "s|/etc/omarchy/|$omarchy_etc/|g" -e "s|/etc/systemd/system/|$units/|g" -e "s|/etc/sudoers.d/|$sudoersd/|g" \
  -e "s|/usr/bin/id|$test_tmp/trusted-id|g" "$remove" >"$copy"
pass "removal names its fixed paths, and the test drives a retargeted copy"

cat >"$test_tmp/trusted-id" <<'SH'
#!/bin/bash
printf 'id %s\n' "$*" >>"$TEST_LOG"
printf '%s\n' "$TEST_ID_NAME"
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
set -euo pipefail

reject() {
  printf 'refusing unexpected sudo invocation:' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  exit 97
}

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

case "${1:-}" in
  sed)
    [[ ${2:-} == "-i" && ${@: -1} == "$TEST_PAMD"/* ]] || reject "$@"
    exec /usr/bin/sed "${@:2}"
    ;;
  rm)
    case "$*" in
      "rm -f $TEST_PAMD/omarchy-lock-face" | "rm -f $TEST_PAMD/omarchy-face-verify" | "rm -f $TEST_OMARCHY_ETC/face.conf" | \
        "rm -f $TEST_UNITS/omarchy-face-key.socket" | "rm -f $TEST_UNITS/omarchy-face-key.service" | \
        "rm -f $TEST_SUDOERSD/omarchy-face-match") ;;
      *) reject "$@" ;;
    esac
    exec /usr/bin/rm -f "$3"
    ;;
  systemctl)
    case "$*" in
      "systemctl disable --now omarchy-face-key.socket" | "systemctl stop omarchy-face-key.service" | "systemctl daemon-reload") ;;
      *) reject "$@" ;;
    esac
    ;;
  howdy)
    [[ $* == "howdy -U $TEST_ID_NAME -y clear" ]] || reject "$@"
    [[ ${TEST_CLEAR_FAIL:-0} == 0 ]]
    ;;
  *)
    reject "$@"
    ;;
esac
SH

cat >"$stub_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $* == "howdy" && ${TEST_HOWDY_PRESENT:-1} == 1 ]]
SH

cat >"$stub_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf 'package %s\n' "$*" >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-hyprland-toggle-enabled" <<'SH'
#!/bin/bash
[[ $* == "face-key" && -f $TEST_TOGGLE ]]
SH

cat >"$stub_bin/omarchy-hyprland-toggle" <<'SH'
#!/bin/bash
printf 'toggle %s\n' "$*" >>"$TEST_LOG"
[[ $* == "face-key off" ]] && rm -f "$TEST_TOGGLE"
SH

chmod +x "$stub_bin"/* "$test_tmp/trusted-id"

write_stack() {
  local file=$1
  shift
  printf '%s\n' "$@" >"$pamd/$file"
}

reset_fixture() {
  : >"$log"
  rm -rf "$pamd" "$omarchy_etc" "$units" "$sudoersd" "$test_tmp/toggle"
  mkdir -p "$pamd" "$omarchy_etc" "$units" "$sudoersd"
}

# invoke_remove [user] [howdy-present] [clear-fail]
invoke_remove() {
  local status=0

  TEST_LOG="$log" TEST_PAMD="$pamd" TEST_OMARCHY_ETC="$omarchy_etc" TEST_UNITS="$units" TEST_SUDOERSD="$sudoersd" TEST_TOGGLE="$test_tmp/toggle" \
    TEST_ID_NAME="${1-alice}" TEST_HOWDY_PRESENT="${2:-1}" \
    TEST_CLEAR_FAIL="${3:-0}" USER=spoofed SUDO_USER=spoofed \
    PATH="$stub_bin:/usr/bin:/bin" env -u SUDO_UID bash "$copy" </dev/null >"$output" 2>&1 || status=$?
  return "$status"
}

log_line_of() {
  grep -nF -- "$1" "$log" | head -n 1 | cut -d: -f1
}

reset_fixture
write_stack sudo "$face_gate" "$hint_line" "$stable_line" "$gate" "$fingerprint_line" "$includes"
write_stack polkit-1 "$face_gate" "$hint_line" "$stable_line" "$includes"
printf 'auth required pam_exec.so seteuid quiet stdout /usr/bin/omarchy-face-match\n' >"$pamd/omarchy-lock-face"
cp "$pamd/omarchy-lock-face" "$pamd/omarchy-face-verify"
cp "$ROOT/default/sudoers.d/omarchy-face-match" "$sudoersd/"
printf 'LOCK_ATTEMPTS=1\nLOCK_WINDOW_MINUTES=60\n' >"$omarchy_etc/face.conf"
: >"$units/omarchy-face-key.socket"
: >"$units/omarchy-face-key.service"
: >"$test_tmp/toggle"
invoke_remove || fail "removal succeeds on a configured machine" "$(cat "$output"; cat "$log")"
[[ $(<"$pamd/sudo") == "$(printf '%s\n' "$gate" "$fingerprint_line" "$includes")" ]] ||
  fail "sudo keeps the fingerprint pair and loses only the face pair" "$(cat "$pamd/sudo")"
[[ $(<"$pamd/polkit-1") == "$includes" ]] || fail "polkit loses the face pair" "$(cat "$pamd/polkit-1")"
[[ ! -e $pamd/omarchy-lock-face ]] || fail "the lock PAM service is removed"
[[ ! -e $sudoersd/omarchy-face-match ]] || fail "the lock's grant is removed"
(( $(log_line_of $'sudo\trm\t-f\t'"$pamd/omarchy-lock-face") < $(log_line_of $'sudo\trm\t-f\t'"$sudoersd/omarchy-face-match") )) ||
  fail "the lock stops offering the face before its grant goes" "$(cat "$log")"
[[ ! -e $pamd/omarchy-face-verify ]] || fail "a verification service an interrupted setup left is removed"
[[ ! -e $omarchy_etc/face.conf ]] || fail "the lock screen's face policy is removed"
(( $(log_line_of $'sudo\trm') < $(log_line_of $'sudo\thowdy') )) || fail "PAM is cleaned before the models" "$(cat "$log")"
(( $(log_line_of $'sudo\thowdy') < $(log_line_of 'package ') )) || fail "models are cleared before the package drop" "$(cat "$log")"
[[ $(tail -n 1 "$log") == 'package howdy pam-python pamtester hm1092-ir-camera' ]] || fail "the face packages and the driver the setup installed drop last" "$(cat "$log")"
grep -Fq "alice's local face models have been removed" "$output" || fail "success names the user" "$(cat "$output")"
[[ ! -e $units/omarchy-face-key.socket && ! -e $units/omarchy-face-key.service ]] || fail "the key service's units are removed"
(( $(log_line_of $'sudo\tsed') < $(log_line_of $'sudo\tsystemctl\tdisable\t--now\tomarchy-face-key.socket') )) ||
  fail "no stack offers the face by the time its key service stops" "$(cat "$log")"
(( $(log_line_of $'sudo\tsystemctl\tstop\tomarchy-face-key.service') < $(log_line_of $'sudo\trm\t-f\t'"$units/omarchy-face-key.socket") )) ||
  fail "the key service stops before its units go" "$(cat "$log")"
(( $(log_line_of $'sudo\trm\t-f\t'"$units/omarchy-face-key.service") < $(log_line_of $'sudo\tsystemctl\tdaemon-reload') )) ||
  fail "systemd forgets the units once they are gone" "$(cat "$log")"
grep -qx 'toggle face-key off' "$log" || fail "the Copilot key returns to the Omarchy menu" "$(cat "$log")"
pass "removal strips the face pair from sudo and polkit, stops the key service, clears the models and drops the packages"

reset_fixture
write_stack sudo "$face_gate" "$hint_line" "$stable_line" "$includes"
write_stack polkit-1 "$face_gate" "$hint_line" "$stable_line" "$includes"
printf 'LOCK_ATTEMPTS=1\n' >"$omarchy_etc/face.conf"
invoke_remove || fail "removal succeeds after a sudo and polkit setup" "$(cat "$output"; cat "$log")"
[[ $(<"$pamd/sudo") == "$includes" && $(<"$pamd/polkit-1") == "$includes" ]] || fail "sudo and polkit lose the face block" "$(cat "$pamd/sudo" "$pamd/polkit-1")"
[[ ! -e $omarchy_etc/face.conf ]] || fail "the face policy goes with them"
grep -q 'package howdy' "$log" || fail "the packages drop without a lock service to remove" "$(cat "$log")"
pass "removal undoes a sudo and polkit setup without a lock service"

reset_fixture
write_stack sudo "$gate" "$fingerprint_line" "$includes"
printf 'auth required pam_exec.so seteuid quiet stdout /usr/bin/omarchy-face-match\n' >"$pamd/omarchy-lock-face"
printf 'LOCK_ATTEMPTS=1\n' >"$omarchy_etc/face.conf"
invoke_remove || fail "removal succeeds after a lock screen setup" "$(cat "$output"; cat "$log")"
[[ ! -e $pamd/omarchy-lock-face && ! -e $omarchy_etc/face.conf ]] || fail "the lock service and its policy go"
[[ $(<"$pamd/sudo") == "$(printf '%s\n' "$gate" "$fingerprint_line" "$includes")" ]] || fail "sudo without face lines keeps its fingerprint pair" "$(cat "$pamd/sudo")"
! grep -q $'^sudo\tsed' "$log" || fail "a stack without face lines is not rewritten" "$(cat "$log")"
pass "removal undoes a lock screen setup and leaves sudo alone"

reset_fixture
write_stack sudo "$gate" "$beta_line" "$includes"
invoke_remove || fail "removal succeeds with the beta module" "$(cat "$output")"
[[ $(<"$pamd/sudo") == "$includes" ]] || fail "the beta module pair is removed" "$(cat "$pamd/sudo")"
pass "removal recognises Howdy's native module"

reset_fixture
write_stack sudo "$gate" "$legacy_line" "$includes"
invoke_remove || fail "removal succeeds over the pam_python glue of an earlier setup" "$(cat "$output")"
[[ $(<"$pamd/sudo") == "$includes" ]] || fail "the pam_python pair is removed" "$(cat "$pamd/sudo")"
pass "removal recognises the pam_python glue of earlier setups"

reset_fixture
write_stack sudo "$stable_line" "$gate" "$fingerprint_line" "$includes"
invoke_remove || fail "removal succeeds over a gateless face line" "$(cat "$output")"
[[ $(<"$pamd/sudo") == "$(printf '%s\n' "$gate" "$fingerprint_line" "$includes")" ]] ||
  fail "a gateless face line goes and the fingerprint gate stays" "$(cat "$pamd/sudo")"
pass "removal takes only the gate directly above the face module"

reset_fixture
write_stack sudo "$includes" "$gate"
invoke_remove || fail "removal succeeds with a trailing gate" "$(cat "$output")"
[[ $(<"$pamd/sudo") == "$(printf '%s\n' "$includes" "$gate")" ]] || fail "a stack without face lines is untouched" "$(cat "$pamd/sudo")"
! grep -q $'^sudo\tsed' "$log" || fail "a stack without face lines is not rewritten" "$(cat "$log")"
pass "removal leaves a stack without face lines alone"

reset_fixture
write_stack sudo "$includes"
invoke_remove alice 0 || fail "removal succeeds when nothing is configured" "$(cat "$output")"
# /etc/sudoers.d is root's alone, so the grant is removed without a look first.
[[ $(grep '^sudo' "$log") == $'sudo\trm\t-f\t'"$sudoersd/omarchy-face-match" ]] ||
  fail "nothing configured runs no privileged command but clearing the grant" "$(cat "$log")"
! grep -q '^toggle' "$log" || fail "a Copilot key that was never taken stays with the menu" "$(cat "$log")"
grep -q '^package howdy' "$log" || fail "the package drop still runs" "$(cat "$log")"
pass "removal is idempotent when face authentication was never set up"

reset_fixture
write_stack sudo "$gate" "$stable_line" "$includes"
invoke_remove alice 1 1 && fail "a failed model clear fails the removal"
! grep -q '^package' "$log" || fail "a failed model clear stops the package drop" "$(cat "$log")"
! grep -q 'have been removed' "$output" || fail "a failed model clear suppresses success" "$(cat "$output")"
pass "a failed model clear stops the package removal"

for name in '' . .. 'other/name'; do
  reset_fixture
  write_stack sudo "$gate" "$stable_line" "$includes"
  invoke_remove "$name" && fail "unsafe identity must fail: $name"
  ! grep -Eq '^sudo|^package' "$log" || fail "unsafe identity changed host state: $name" "$(cat "$log")"
done
pass "unsafe user names fail before any mutation"
