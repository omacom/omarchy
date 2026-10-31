#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-face"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Scratch names avoid the fixed paths so the retargeting check below can grep
# for them.
stub_bin="$test_tmp/bin"
pamd="$test_tmp/pamd"
seclib="$test_tmp/security"
etc_howdy="$test_tmp/howdy-etc"
omarchy_etc="$test_tmp/omarchy-etc"
sudoersd="$test_tmp/sudoers-d"
units="$test_tmp/units"
face_key="$test_tmp/omarchy-face-key"
ir_device="$test_tmp/hm1092-ir"
log="$test_tmp/calls.log"
output="$test_tmp/output"
copy="$test_tmp/setup.sh"
mkdir -p "$stub_bin"

# The face block skips two lines (hint and module); fingerprint's gate skips one.
gate='auth      [success=2 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed'
gate1='auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed'
hint='auth      optional pam_exec.so seteuid quiet stdout /usr/bin/omarchy-face-match --hint'
# sudo and polkit ask first; the lock service waits for the key on its own.
stable_module="pam_exec.so seteuid quiet stdout expose_authtok /usr/bin/omarchy-face-match"
lock_module="pam_exec.so seteuid quiet stdout /usr/bin/omarchy-face-match"
legacy_module="pam_python.so $seclib/howdy/pam.py"

# The setup writes fixed root-owned paths. Retarget a scratch copy, and fail if
# a path is not named exactly as expected, so the seam keeps standing for the
# shipped command.
for literal in 'security_lib=/usr/lib/security' 'lock_pam=/etc/pam.d/omarchy-lock-face' \
  'verify_pam=/etc/pam.d/omarchy-face-verify' 'face_conf=/etc/omarchy/face.conf' 'face_key=/usr/bin/omarchy-face-key' \
  'key_socket=/etc/systemd/system/omarchy-face-key.socket' 'key_service=/etc/systemd/system/omarchy-face-key.service' \
  'face_device=/dev/video-hm1092-ir' 'lock_grant=/etc/sudoers.d/omarchy-face-match'; do
  (( $(grep -Fxc "$literal" "$setup") == 1 )) || fail "setup names $literal exactly once"
done
sed -e "s|^security_lib=/usr/lib/security$|security_lib=$seclib|" \
  -e "s|^face_key=/usr/bin/omarchy-face-key$|face_key=$face_key|" \
  -e "s|^face_device=/dev/video-hm1092-ir$|face_device=$ir_device|" \
  -e "s|/etc/pam.d/|$pamd/|g" \
  -e "s|/etc/howdy/|$etc_howdy/|g" \
  -e "s|/etc/systemd/system/|$units/|g" \
  -e "s|/etc/omarchy/|$omarchy_etc/|g" \
  -e "s|/etc/sudoers.d/|$sudoersd/|g" "$setup" >"$copy"
! grep -q '/etc/pam.d/\|/etc/howdy/\|/etc/omarchy/\|/etc/systemd/\|/etc/sudoers.d/' "$copy" || fail "the scratch copy keeps no fixed /etc path"
pass "setup names its fixed paths once each, and the test drives a retargeted copy"

# The predicate takes no arguments; the driver is the package, and the device
# Howdy reads is the relay's stable /dev/video-hm1092-ir.
cat >"$stub_bin/omarchy-hw-dell-xps-ir-camera" <<'SH'
#!/bin/bash
printf 'hw %s\n' "$*" >>"$TEST_LOG"
(( $# == 0 )) || exit 2
[[ $TEST_HW != absent ]]
SH

cat >"$stub_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $* == hm1092-ir-camera && $TEST_HW != nodriver ]]
SH

# The driver comes from Omarchy's repository, installed by the setup itself.
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$TEST_LOG"
[[ ${TEST_DRIVER_FAIL:-0} == 0 ]]
SH

# visudo parses unprivileged; the stub records what it was asked to parse.
cat >"$stub_bin/visudo" <<'SH'
#!/bin/bash
printf 'visudo %s\n' "$*" >>"$TEST_LOG"
[[ $1 == -cf ]] && cp "$2" "$TEST_TMP/grant-parsed"
[[ ${TEST_VISUDO:-ok} == ok ]]
SH

cat >"$stub_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash
printf 'aur %s\n' "$*" >>"$TEST_LOG"
[[ ${TEST_PKG_FAIL:-0} == 0 ]]
SH

# The scope question: answer with the TEST_CHOICE-th option, or cancel at 0
# the way gum does on Escape, with no output.
cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
printf 'gum %s\n' "$*" >>"$TEST_LOG"
[[ ${1:-} == choose ]] || exit 1
shift
options=()
while (( $# > 0 )) && [[ $1 != --* ]]; do
  options+=("$1")
  shift
done
(( TEST_CHOICE > 0 && TEST_CHOICE <= ${#options[@]} )) || exit 130
printf '%s\n' "${options[TEST_CHOICE - 1]}"
SH

# Howdy's layout is read from the package database, so the stub answers the
# exact query the setup makes with the files each AUR package installs.
cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
[[ $* == "-Qlq howdy" ]] || exit 1
case "$TEST_HOWDY_LAYOUT" in
  stable) printf '%s\n' "$TEST_SECLIB/howdy/" "$TEST_SECLIB/howdy/cli.py" "$TEST_SECLIB/howdy/pam.py" "$TEST_SECLIB/howdy/compare.py" "$TEST_SECLIB/howdy/config.ini" "/usr/bin/howdy" ;;
  beta) printf '%s\n' "$TEST_SECLIB/pam_howdy.so" "$TEST_ETC_HOWDY/" "$TEST_ETC_HOWDY/config.ini" "/usr/bin/howdy" ;;
  both) printf '%s\n' "$TEST_SECLIB/pam_howdy.so" "$TEST_SECLIB/howdy/compare.py" "$TEST_ETC_HOWDY/config.ini" "/usr/bin/howdy" ;;
  nomodule) printf '%s\n' "$TEST_SECLIB/howdy/config.ini" "/usr/bin/howdy" ;;
  noconfig) printf '%s\n' "$TEST_SECLIB/howdy/compare.py" "/usr/bin/howdy" ;;
  *) exit 1 ;;
esac
SH

# Execute only the setup's expected privileged protocol, and only inside the
# scratch tree; anything else is outside this harness.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
set -euo pipefail

reject() {
  printf 'refusing unexpected sudo invocation:' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  exit 97
}

in_scratch() {
  [[ $1 == "$TEST_TMP"/* ]]
}

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

case "${1:-}" in
  sed)
    [[ ${2:-} == "-i" ]] && in_scratch "${@: -1}" || reject "$@"
    exec /usr/bin/sed "${@:2}"
    ;;
  grep)
    in_scratch "${@: -1}" || reject "$@"
    exec /usr/bin/grep "${@:2}"
    ;;
  tee)
    (( $# == 2 )) && in_scratch "$2" || reject "$@"
    exec /usr/bin/tee "$2"
    ;;
  install)
    # Root-owned copies of the checkout's default files, and the validated
    # copy of the lock's grant; the scratch tree cannot be chowned, so the
    # owner flags are checked, not applied.
    (( $# == 8 )) && [[ "$3 $4 $5 $6" == "-o root -g root" ]] && in_scratch "$8" || reject "$@"
    if [[ $2 == -Dm644 && $7 == "$TEST_DEFAULTS"/* ]]; then
      exec /usr/bin/install -Dm644 "$7" "$8"
    fi
    [[ $2 == -Dm440 && $8 == "$TEST_TMP/sudoers-d/omarchy-face-match" ]] || reject "$@"
    exec /usr/bin/install -Dm440 "$7" "$8"
    ;;
  rm)
    (( $# == 3 )) && [[ $2 == "-f" ]] && in_scratch "$3" || reject "$@"
    exec /usr/bin/rm -f "$3"
    ;;
  howdy)
    [[ $* == "howdy add" ]] || reject "$@"
    [[ $TEST_ENROLL == "ok" ]]
    ;;
  pamtester)
    [[ $* == "pamtester omarchy-face-verify alice authenticate" ]] || reject "$@"
    cp "$TEST_TMP/pamd/omarchy-face-verify" "$TEST_TMP/verify-seen"
    [[ $TEST_VERIFY == "ok" ]]
    ;;
  systemctl)
    [[ $* == "systemctl daemon-reload" || $* == "systemctl enable --now omarchy-face-key.socket" ]] || reject "$@"
    ;;
  *)
    reject "$@"
    ;;
esac
SH

cat >"$stub_bin/omarchy-hyprland-toggle" <<'SH'
#!/bin/bash
printf 'toggle %s\n' "$*" >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

reset_fixture() {
  : >"$log"
  rm -rf "$pamd" "$seclib" "$etc_howdy" "$omarchy_etc" "$units" "$sudoersd" "$test_tmp/grant-parsed"
  mkdir -p "$pamd" "$seclib/howdy" "$etc_howdy" "$units" "$sudoersd"
  printf '#!/bin/bash\n' >"$face_key"
  chmod +x "$face_key"
  printf '#%%PAM-1.0\nauth\t\tinclude\t\tsystem-auth\naccount\t\tinclude\t\tsystem-auth\nsession\t\tinclude\t\tsystem-auth\n' >"$pamd/sudo"
  printf '[video]\ndevice_path = none\n' >"$seclib/howdy/config.ini"
  printf '[video]\ndevice_path = none\n' >"$etc_howdy/config.ini"
  rm -f "$ir_device"
}

# [TEST_CHOICE=<n>] invoke_setup <hw> <layout> [enroll] [verify] [pkg-fail]
# <hw>: absent, nodriver (no package), norelay (no relay device) or ready.
# TEST_CHOICE picks the scope: 1 everything, 2 sudo and polkit, 3 the lock screen.
invoke_setup() {
  local status=0

  if [[ $1 == ready ]]; then
    : >"$ir_device"
  fi
  TEST_LOG="$log" TEST_TMP="$test_tmp" TEST_SECLIB="$seclib" TEST_ETC_HOWDY="$etc_howdy" TEST_CHOICE="${TEST_CHOICE:-1}" \
    TEST_HW="$1" TEST_HOWDY_LAYOUT="$2" TEST_ENROLL="${3:-ok}" TEST_VERIFY="${4:-ok}" \
    TEST_PKG_FAIL="${5:-0}" TEST_DEFAULTS="$ROOT/default" OMARCHY_PATH="$ROOT" TEST_VISUDO="${TEST_VISUDO:-ok}" \
    TEST_DRIVER_FAIL="${TEST_DRIVER_FAIL:-0}" USER=alice \
    PATH="$stub_bin:/usr/bin:/bin" bash "$copy" </dev/null >"$output" 2>&1 || status=$?
  return "$status"
}

log_line_of() {
  grep -nF -- "$1" "$log" | head -n 1 | cut -d: -f1
}

assert_no_mutation() {
  local description="$1"

  ! grep -q '^sudo' "$log" || fail "$description" "$(cat "$log")"
  [[ ! -e $pamd/omarchy-lock-face && ! -e $pamd/omarchy-face-verify && ! -e $pamd/polkit-1 ]] || fail "$description left PAM files behind"
  [[ ! -e $omarchy_etc/face.conf ]] || fail "$description left the face policy behind"
  [[ ! -e $sudoersd/omarchy-face-match ]] || fail "$description left the lock's grant behind"
  [[ -z $(ls -A "$units") ]] || fail "$description left the key service behind"
  ! grep -q '^toggle' "$log" || fail "$description took the Copilot key" "$(cat "$log")"
}

expected_block() {
  printf '%s\n' "$gate" "$hint" "auth      sufficient $stable_module"
}

reset_fixture
invoke_setup absent stable && fail "setup fails without the camera"
assert_no_mutation "no camera installs or configures nothing"
! grep -q '^aur\|^pkg-add' "$log" || fail "no camera installs nothing" "$(cat "$log")"
pass "setup stops before installing anything when no camera is detected"

# The driver is installed only here, on the machine whose owner asked for the
# face, never by the installer on every matching machine.
reset_fixture
invoke_setup nodriver stable && fail "setup stops after installing the driver, which needs a reboot"
grep -qx 'pkg-add hm1092-ir-camera' "$log" || fail "setup installs the driver package" "$(cat "$log")"
grep -qi 'reboot' "$output" || fail "the reboot the driver needs is asked for" "$(cat "$output")"
grep -q 'omarchy setup security face' "$output" || fail "running the setup again is named" "$(cat "$output")"
assert_no_mutation "a freshly installed driver configures nothing yet"
! grep -q '^aur' "$log" || fail "a freshly installed driver builds no Howdy yet" "$(cat "$log")"
pass "setup installs the driver package itself and asks for the reboot it needs"

reset_fixture
TEST_DRIVER_FAIL=1 invoke_setup nodriver stable && fail "setup fails when the driver does not install"
assert_no_mutation "a failed driver install configures nothing"
! grep -q '^aur' "$log" || fail "a failed driver install builds no Howdy" "$(cat "$log")"
pass "setup stops when the driver package does not install"

reset_fixture
invoke_setup norelay stable && fail "setup fails while the relay publishes no device"
grep -q 'relay publishes no device' "$output" || fail "the missing relay device is explained" "$(cat "$output")"
grep -q 'hm1092-relay' "$output" || fail "the relay unit to check is named" "$(cat "$output")"
grep -qF 'linux-omarchy 7.2.8-2' "$output" || fail "the kernel whose ipu-bridge lists the sensor is named" "$(cat "$output")"
assert_no_mutation "a missing relay device configures nothing"
! grep -q '^aur\|^pkg-add' "$log" || fail "an installed driver is not installed again" "$(cat "$log")"
pass "setup explains the missing relay device and stops before installing anything"

reset_fixture
rm "$face_key"
invoke_setup nodriver stable && fail "setup fails without the key service"
grep -q 'omarchy-face-key is missing' "$output" || fail "the missing key service is explained" "$(cat "$output")"
assert_no_mutation "a missing key service configures nothing"
! grep -q '^aur\|^pkg-add' "$log" || fail "a missing key service installs nothing, not even the driver" "$(cat "$log")"
pass "setup stops before installing anything when Omarchy lacks the key service"

reset_fixture
TEST_CHOICE=0 invoke_setup ready stable && fail "setup stops when the scope question is cancelled"
assert_no_mutation "a cancelled scope question configures nothing"
! grep -q '^aur' "$log" || fail "a cancelled scope question installs nothing" "$(cat "$log")"
pass "setup asks where the face should work before installing anything, and a cancel stops it"

reset_fixture
invoke_setup ready stable ok ok 1 && fail "setup fails when the packages do not install"
assert_no_mutation "a failed package install configures nothing"
pass "setup stops when Howdy cannot be installed"

reset_fixture
invoke_setup ready nomodule && fail "setup fails when Howdy ships no PAM module"
assert_no_mutation "a Howdy without a PAM module configures nothing"
pass "setup stops when the installed Howdy has no PAM module"

reset_fixture
invoke_setup ready beta && fail "setup refuses a Howdy whose only PAM module is native"
grep -q 'compare.py' "$output" || fail "the refusal says what the key needs" "$(cat "$output")"
assert_no_mutation "a native module that cannot wait for the key configures nothing"
grep -qxF "device_path = none" "$etc_howdy/config.ini" || fail "a refused Howdy keeps its config" "$(cat "$etc_howdy/config.ini")"
pass "setup refuses Howdy's native PAM module, which scans without waiting for the key"

reset_fixture
invoke_setup ready noconfig && fail "setup fails when Howdy ships no config"
assert_no_mutation "a Howdy without a config configures nothing"
pass "setup stops when the installed Howdy has no configuration file"

reset_fixture
invoke_setup ready stable fail && fail "setup fails when enrollment fails"
grep -q 'Enrollment failed' "$output" || fail "a failed enrollment is reported" "$(cat "$output")"
! grep -q $'^sudo\t\(tee\|install\)' "$log" || fail "a failed enrollment writes no PAM file" "$(cat "$log")"
! grep -q '^toggle' "$log" || fail "a failed enrollment keeps the Copilot key with the menu" "$(cat "$log")"
[[ ! -e $pamd/omarchy-lock-face ]] || fail "a failed enrollment leaves no lock PAM file"
grep -qxF "device_path = $ir_device" "$seclib/howdy/config.ini" ||
  fail "Howdy is pointed at the IR device before enrollment" "$(cat "$seclib/howdy/config.ini")"
pass "a failed enrollment stops before any PAM stack is touched"

reset_fixture
invoke_setup ready stable ok fail && fail "setup fails when verification fails"
grep -q 'Verification failed' "$output" || fail "a failed verification is reported" "$(cat "$output")"
[[ ! -e $pamd/omarchy-face-verify ]] || fail "a failed verification removes its PAM service"
[[ ! -e $pamd/omarchy-lock-face ]] || fail "a failed verification writes no lock PAM file"
[[ ! -e $pamd/polkit-1 ]] || fail "a failed verification creates no polkit stack"
! grep -q 'omarchy-face-match' "$pamd/sudo" || fail "a failed verification leaves sudo alone" "$(cat "$pamd/sudo")"
[[ ! -e $omarchy_etc/face.conf ]] || fail "a failed verification writes no face policy"
[[ ! -e $sudoersd/omarchy-face-match ]] || fail "a failed verification installs no grant"
[[ -f $units/omarchy-face-key.socket ]] || fail "the key service verification needed stays for the next run"
pass "a failed verification removes its PAM service and touches no stack"

reset_fixture
invoke_setup ready stable || fail "setup succeeds with a ready camera and a verified face" "$(cat "$output"; cat "$log")"
expected_sudo=$(printf '%s\n' "$gate" "$hint" "auth      sufficient $stable_module" '#%PAM-1.0' \
  $'auth\t\tinclude\t\tsystem-auth' $'account\t\tinclude\t\tsystem-auth' $'session\t\tinclude\t\tsystem-auth')
[[ $(<"$pamd/sudo") == "$expected_sudo" ]] ||
  fail "sudo gets the gate and the face module on top of its stack" "$(cat "$pamd/sudo")"
expected_polkit=$(printf '%s\n' "$gate" "$hint" "auth      sufficient $stable_module" 'auth      include system-auth' '' \
  'account   include system-auth' 'password  include system-auth' 'session   include system-auth')
[[ $(<"$pamd/polkit-1") == "$expected_polkit" ]] ||
  fail "a missing polkit stack is created with the gate and the face module" "$(cat "$pamd/polkit-1")"
expected_lock=$(printf '%s\n' '#%PAM-1.0' "auth       required                    $lock_module" \
  'account    include                     system-local-login')
[[ $(<"$pamd/omarchy-lock-face") == "$expected_lock" ]] ||
  fail "the lock PAM service requires the face module" "$(cat "$pamd/omarchy-lock-face")"
verify_tee=$(grep -n $'^sudo\tinstall\t.*\t'"$pamd/omarchy-face-verify"'$' "$log" | head -n1 | cut -d: -f1)
[[ -n $verify_tee ]] || fail "verification installs its PAM service" "$(cat "$log")"
{ grep -qx 'ListenStream=/run/omarchy-face-key.sock' "$units/omarchy-face-key.socket" &&
  grep -qx 'SocketMode=0600' "$units/omarchy-face-key.socket"; } || fail "the key service listens on root's private socket" "$(cat "$units/omarchy-face-key.socket")"
{ grep -qx 'ExecStart=/usr/bin/omarchy-face-key serve' "$units/omarchy-face-key.service" &&
  grep -qx 'DeviceAllow=char-input r' "$units/omarchy-face-key.service" &&
  grep -qx 'DevicePolicy=closed' "$units/omarchy-face-key.service"; } || fail "the key service may read input devices and nothing else" "$(cat "$units/omarchy-face-key.service")"
(( $(log_line_of $'sudo\tsystemctl\tdaemon-reload') < $(log_line_of $'sudo\tsystemctl\tenable\t--now\tomarchy-face-key.socket') )) ||
  fail "systemd reads the units before the socket is enabled" "$(cat "$log")"
grep -qx 'toggle face-key on' "$log" || fail "Hyprland takes the Copilot key from the Omarchy menu" "$(cat "$log")"
(( $(log_line_of 'toggle face-key on') < verify_tee )) || fail "the key works before verification asks for it" "$(cat "$log")"
! grep -q 'expose_authtok' "$pamd/omarchy-lock-face" || fail "the lock service never asks: the lock screen cannot answer" "$(cat "$pamd/omarchy-lock-face")"
grep -qxF "device_path = $ir_device" "$seclib/howdy/config.ini" ||
  fail "Howdy's stable config points at the relay's stable device path, not a /dev/video number" "$(cat "$seclib/howdy/config.ini")"
! grep -q '^hw .' "$log" || fail "the hardware predicate is asked without arguments" "$(cat "$log")"
grep -qx 'aur howdy pamtester' "$log" || fail "Howdy and pamtester come from the AUR" "$(cat "$log")"
! grep -q '^pkg-add' "$log" || fail "an installed driver is not installed again" "$(cat "$log")"
! grep -q 'aur pam-python' "$log" || fail "the stable layout no longer pulls in pam-python" "$(cat "$log")"
(( $(log_line_of 'gum choose') < $(log_line_of 'aur ') )) || fail "the scope is asked before the long AUR builds" "$(cat "$log")"
verify_write=$verify_tee
verify_drop=$(log_line_of $'sudo\trm\t-f\t'"$pamd/omarchy-face-verify")
(( $(log_line_of $'sudo\thowdy\tadd') < verify_write )) || fail "enrollment precedes the verification service" "$(cat "$log")"
(( verify_write < $(log_line_of $'sudo\tpamtester') )) || fail "the verification service precedes verification" "$(cat "$log")"
grep -q 'press the Copilot key' "$output" || fail "verification asks for the key" "$(cat "$output")"
[[ $(<"$test_tmp/verify-seen") == "$(printf '%s\n' '#%PAM-1.0' "auth       required                    $lock_module --wait")" ]] ||
  fail "verification asks for the face alone: the helper waits for the key, and no password prompt appears" "$(cat "$test_tmp/verify-seen")"
(( $(log_line_of $'sudo\tpamtester') < verify_drop )) || fail "the verification service goes once it has served" "$(cat "$log")"
(( verify_drop < $(log_line_of $'sudo\tsed\t-i\t-e\t1i') )) || fail "verification precedes the sudo and polkit stacks" "$(cat "$log")"
(( verify_drop < $(log_line_of $'\t'"$pamd/omarchy-lock-face") )) || fail "verification precedes the lock service" "$(cat "$log")"
[[ ! -e $pamd/omarchy-face-verify ]] || fail "no verification service is left behind"
# Files the setup owns whole are the checkout's default/ files, copied, never
# written from heredocs, so an Omarchy update ships changes to them.
for pair in "systemd/system/omarchy-face-key.socket:$units/omarchy-face-key.socket" \
  "systemd/system/omarchy-face-key.service:$units/omarchy-face-key.service" \
  "pam.d/omarchy-lock-face:$pamd/omarchy-lock-face" "omarchy/face.conf:$omarchy_etc/face.conf"; do
  cmp -s "$ROOT/default/${pair%%:*}" "${pair#*:}" || fail "${pair#*:} is a copy of default/${pair%%:*}"
done
cmp -s "$ROOT/default/pam.d/omarchy-face-verify" "$test_tmp/verify-seen" || fail "verification uses a copy of default/pam.d/omarchy-face-verify"
grep -qx "auth       required                    $lock_module" "$ROOT/default/pam.d/omarchy-lock-face" ||
  fail "the shipped lock service carries the module line the setup checks Howdy for" "$(cat "$ROOT/default/pam.d/omarchy-lock-face")"
[[ $(grep -o 'sudo tee [^ ]*' "$setup") == "sudo tee /etc/pam.d/polkit-1" ]] ||
  fail "the only file the setup writes itself is a polkit stack it creates" "$(grep -n 'sudo tee ' "$setup")"
[[ $(grep -v -e '^#' -e '^$' "$omarchy_etc/face.conf") == $'LOCK_ATTEMPTS=1\nLOCK_WINDOW_MINUTES=60' ]] ||
  fail "the face policy allows one scan within an hour of locking" "$(cat "$omarchy_etc/face.conf")"
grep -q 'Perfect! Face authentication is now configured' "$output" || fail "success is reported" "$(cat "$output")"
cmp -s "$ROOT/default/sudoers.d/omarchy-face-match" "$sudoersd/omarchy-face-match" || fail "the lock screen gets the grant its helper elevates through"
[[ $(stat -c %a "$sudoersd/omarchy-face-match") == 440 ]] || fail "the grant is installed 0440, or sudo ignores it" "$(stat -c %a "$sudoersd/omarchy-face-match")"
cmp -s "$ROOT/default/sudoers.d/omarchy-face-match" "$test_tmp/grant-parsed" || fail "visudo parses the grant before it is installed"
(( $(log_line_of 'visudo -cf') < $(log_line_of $'\t'"$sudoersd/omarchy-face-match") )) || fail "the grant is parsed before it is installed" "$(cat "$log")"
(( $(log_line_of $'\t'"$sudoersd/omarchy-face-match") < $(log_line_of $'\t'"$pamd/omarchy-lock-face") )) ||
  fail "the grant is in place before the lock offers the face" "$(cat "$log")"
pass "setup enrolls, verifies through PAM, then configures sudo, polkit, the lock service with its grant and its policy"

before_sudo=$(<"$pamd/sudo")
before_polkit=$(<"$pamd/polkit-1")
printf 'LOCK_ATTEMPTS=3\nLOCK_WINDOW_MINUTES=10\n' >"$omarchy_etc/face.conf"
invoke_setup ready stable || fail "setup succeeds a second time" "$(cat "$output")"
[[ $(<"$pamd/sudo") == "$before_sudo" && $(<"$pamd/polkit-1") == "$before_polkit" ]] ||
  fail "a second run adds no duplicate lines" "$(cat "$pamd/sudo")"
[[ $(<"$omarchy_etc/face.conf") == $'LOCK_ATTEMPTS=3\nLOCK_WINDOW_MINUTES=10' ]] ||
  fail "a second run keeps an edited face policy" "$(cat "$omarchy_etc/face.conf")"
pass "setup is idempotent on an already configured stack and keeps an edited policy"

reset_fixture
printf '#%%PAM-1.0\nauth required %s\n' "$lock_module" >"$pamd/omarchy-lock-face"
cp "$ROOT/default/sudoers.d/omarchy-face-match" "$sudoersd/"
TEST_CHOICE=2 invoke_setup ready stable || fail "setup succeeds for sudo and polkit only" "$(cat "$output"; cat "$log")"
[[ $(sed -n 1,3p "$pamd/sudo") == "$(expected_block)" ]] || fail "sudo gets the asking block" "$(cat "$pamd/sudo")"
[[ $(sed -n 1,3p "$pamd/polkit-1") == "$(expected_block)" ]] || fail "polkit gets the asking block" "$(cat "$pamd/polkit-1")"
[[ ! -e $pamd/omarchy-lock-face ]] || fail "the lock service of an earlier run goes"
[[ ! -e $sudoersd/omarchy-face-match ]] || fail "the lock's grant of an earlier run goes with it"
(( $(log_line_of $'sudo\trm\t-f\t'"$pamd/omarchy-lock-face") < $(log_line_of $'sudo\trm\t-f\t'"$sudoersd/omarchy-face-match") )) ||
  fail "the lock stops offering the face before its grant goes" "$(cat "$log")"
[[ -f $omarchy_etc/face.conf ]] || fail "the face policy marks the setup done"
pass "sudo and polkit only: both stacks ask for the face and the lock screen keeps the password"

reset_fixture
cp "$pamd/sudo" "$test_tmp/sudo-plain"
printf '%s\n' "$(expected_block)" "$gate1" 'auth      sufficient pam_fprintd.so' "$(cat "$test_tmp/sudo-plain")" >"$pamd/sudo"
TEST_CHOICE=3 invoke_setup ready stable || fail "setup succeeds for the lock screen only" "$(cat "$output"; cat "$log")"
[[ $(<"$pamd/omarchy-lock-face") == "$(printf '%s\n' '#%PAM-1.0' "auth       required                    $lock_module" \
  'account    include                     system-local-login')" ]] || fail "the lock service requires the face module" "$(cat "$pamd/omarchy-lock-face")"
[[ $(<"$pamd/sudo") == "$(printf '%s\n' "$gate1" 'auth      sufficient pam_fprintd.so'; cat "$test_tmp/sudo-plain")" ]] ||
  fail "sudo loses the face block of an earlier run and keeps fingerprint with its gate" "$(cat "$pamd/sudo")"
[[ ! -e $pamd/polkit-1 ]] || fail "no polkit stack is created for the lock screen alone"
[[ -f $omarchy_etc/face.conf ]] || fail "the lock screen gets its face policy"
[[ -f $sudoersd/omarchy-face-match ]] || fail "the lock screen gets its grant"
pass "the lock screen only: the lock service is written and sudo and polkit keep the password"

reset_fixture
TEST_VISUDO=refuse invoke_setup ready stable && fail "setup fails when visudo refuses the grant"
[[ ! -e $sudoersd/omarchy-face-match ]] || fail "a grant visudo refuses is never installed"
[[ ! -e $pamd/omarchy-lock-face ]] || fail "a refused grant leaves the lock without the face"
pass "a grant visudo refuses stops the lock screen's setup before sudo reads it"

reset_fixture
printf '%s\n' "$gate1" 'auth      sufficient pam_fprintd.so' >"$test_tmp/fingerprint-top"
cat "$test_tmp/fingerprint-top" "$pamd/sudo" >"$test_tmp/sudo-with-fingerprint"
cp "$test_tmp/sudo-with-fingerprint" "$pamd/sudo"
invoke_setup ready stable || fail "setup succeeds beside a fingerprint stack" "$(cat "$output")"
expected_sudo=$(cat "$test_tmp/fingerprint-top"; expected_block; sed 1,2d "$test_tmp/sudo-with-fingerprint")
[[ $(<"$pamd/sudo") == "$expected_sudo" ]] ||
  fail "face goes below the fingerprint pair, which keeps its gate, so a typed password reaches pam_unix without waiting for a finger" "$(cat "$pamd/sudo")"
pass "setup keeps an existing fingerprint stack and its gate, and puts the face below it"

# The face rides on the password prompt, so it goes below every module that
# waits on its own, FIDO2 too, and an earlier block above one of them moves.
reset_fixture
u2f='auth      sufficient pam_u2f.so cue authfile=/etc/fido2/fido2'
{ printf '%s\n' "$u2f"; cat "$test_tmp/fingerprint-top" "$pamd/sudo"; } >"$test_tmp/sudo-with-both"
{ expected_block; cat "$test_tmp/sudo-with-both"; } >"$pamd/sudo"
invoke_setup ready stable || fail "setup succeeds over a face block above FIDO2 and fingerprint" "$(cat "$output")"
expected_sudo=$(printf '%s\n' "$u2f"; cat "$test_tmp/fingerprint-top"; expected_block; sed 1,3d "$test_tmp/sudo-with-both")
[[ $(<"$pamd/sudo") == "$expected_sudo" ]] ||
  fail "an earlier face block above FIDO2 and fingerprint moves below both, once" "$(cat "$pamd/sudo")"
before_sudo=$(<"$pamd/sudo")
invoke_setup ready stable || fail "setup succeeds a second time beside FIDO2 and fingerprint" "$(cat "$output")"
[[ $(<"$pamd/sudo") == "$before_sudo" ]] || fail "a block below FIDO2 and fingerprint stays as it is" "$(cat "$pamd/sudo")"
pass "the face goes below FIDO2 and fingerprint, and an earlier block above them moves down"

reset_fixture
printf 'auth      sufficient %s\n%s' "$stable_module" "$(cat "$pamd/sudo")" >"$pamd/sudo"
invoke_setup ready stable || fail "setup succeeds over a gateless face line" "$(cat "$output")"
(( $(grep -c -- 'omarchy-hw-laptop-closed' "$pamd/sudo") == 1 )) || fail "a missing gate is added once" "$(cat "$pamd/sudo")"
[[ $(sed -n 1,3p "$pamd/sudo") == "$(printf '%s\n' "$gate" "$hint" "auth      sufficient $stable_module")" ]] ||
  fail "the gate and the hint land directly above the face module" "$(cat "$pamd/sudo")"
(( $(grep -c -- 'omarchy-face-match' "$pamd/sudo") == 2 )) || fail "the stray face line is replaced, not duplicated" "$(cat "$pamd/sudo")"
pass "setup repairs a face line that lost its clamshell gate"

reset_fixture
printf '%s\n%s\n%s' "$gate1" "auth      sufficient $legacy_module" "$(cat "$pamd/sudo")" >"$pamd/sudo"
invoke_setup ready stable || fail "setup succeeds over a pam_python face line" "$(cat "$output")"
[[ $(sed -n 1,3p "$pamd/sudo") == "$(printf '%s\n' "$gate" "$hint" "auth      sufficient $stable_module")" ]] ||
  fail "the pam_python pair is replaced by the asking block" "$(cat "$pamd/sudo")"
! grep -q 'pam_python' "$pamd/sudo" || fail "no pam_python line remains" "$(cat "$pamd/sudo")"
(( $(grep -c -- 'omarchy-hw-laptop-closed' "$pamd/sudo") == 1 )) || fail "the old gate goes with its module" "$(cat "$pamd/sudo")"
pass "setup replaces the pam_python glue of an earlier setup with the asking block"

reset_fixture
printf '%s\n%s\n%s' "$gate1" "auth      sufficient $lock_module" "$(cat "$pamd/sudo")" >"$pamd/sudo"
invoke_setup ready stable || fail "setup succeeds over a face line that never asked" "$(cat "$output")"
[[ $(sed -n 1,3p "$pamd/sudo") == "$(printf '%s\n' "$gate" "$hint" "auth      sufficient $stable_module")" ]] ||
  fail "a face line without the hint and expose_authtok is upgraded to the asking block" "$(cat "$pamd/sudo")"
pass "setup upgrades a face line that scanned without asking"

reset_fixture
invoke_setup ready both || fail "setup succeeds with a Howdy that ships compare.py beside a native module" "$(cat "$output"; cat "$log")"
[[ $(sed -n 1,3p "$pamd/sudo") == "$(expected_block)" ]] || fail "compare.py serves through the helper, not the native module" "$(cat "$pamd/sudo")"
! grep -q 'pam_howdy' "$pamd/sudo" || fail "the native module is never configured" "$(cat "$pamd/sudo")"
grep -qxF "device_path = $ir_device" "$etc_howdy/config.ini" ||
  fail "the config the package ships under /etc points at the IR device" "$(cat "$etc_howdy/config.ini")"
pass "setup uses compare.py and the configuration the installed Howdy ships"
