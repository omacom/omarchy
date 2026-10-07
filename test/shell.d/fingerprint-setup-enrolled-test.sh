#!/bin/bash
#
# Fingerprint setup must still reach PAM when a print is already enrolled, since
# fprintd-enroll refuses a finger saved under another finger name as enroll-duplicate.
# fprintd, sudo and omarchy-apply-lock are stubbed; they only record what setup asked for.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/pam.d"
# /etc/pam.d is redirected so the sudo and polkit steps run the same way on
# every host, whatever its own PAM files hold.
setup="$scratch/omarchy-setup-security-fingerprint"
sed "s|/etc/pam.d/|$scratch/pam.d/|g" "$ROOT/bin/omarchy-setup-security-fingerprint" > "$setup"
printf 'auth      include   system-auth\n' > "$scratch/pam.d/sudo"
export CALL_LOG="$scratch/calls"
export PATH="$scratch/bin:$ROOT/bin:$PATH"
export SCRATCH="$scratch"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" > "$scratch/bin/$1"
  chmod +x "$scratch/bin/$1"
}

stub sudo '[[ $1 == fprintd-enroll ]] && exec "$@"; printf "sudo %s\n" "$*" >> "$CALL_LOG"'
stub omarchy-hw-fingerprint 'exit 0'
# The lock screen PAM file comes from omarchy-apply-lock; the stub writes it where the redirected setup looks.
stub omarchy-apply-lock 'echo apply-lock >> "$CALL_LOG"; touch "$SCRATCH/pam.d/omarchy-lock-fingerprint"'
stub omarchy-pkg-missing 'exit 1'
stub gdbus '[[ -z $NO_READER ]] || exit 1; printf "(objectpath %s,)\n" "${DEFAULT_READER:-/net/reactivated/Fprint/Device/0}"'
stub fprintd-list 'printf "%s" "$FPRINTD_LIST"; exit "${LIST_STATUS:-0}"'
stub fprintd-enroll 'echo "fprintd-enroll $*" >> "$CALL_LOG"; [[ ${ENROLL_OK:-1} == 1 ]]'
stub fprintd-verify 'echo "fprintd-verify" >> "$CALL_LOG"; [[ ${VERIFY_OK:-1} == 1 ]]'

# fprintd-list output: a header per reader, then its prints for the user.
enrolled=$'found 1 devices\nDevice at /net/reactivated/Fprint/Device/0\nUsing device /net/reactivated/Fprint/Device/0\nFingerprints for user tester on Validity VFS5011 (swipe):\n - #0: right-index-finger\n'
none=$'found 1 devices\nDevice at /net/reactivated/Fprint/Device/0\nUsing device /net/reactivated/Fprint/Device/0\nUser tester has no fingers enrolled for Validity VFS5011.\n'
# Two readers, the print saved on Device/1 only.
other_reader=$'found 2 devices\nDevice at /net/reactivated/Fprint/Device/0\nDevice at /net/reactivated/Fprint/Device/1\nUsing device /net/reactivated/Fprint/Device/0\nUser tester has no fingers enrolled for Validity VFS5011.\nUsing device /net/reactivated/Fprint/Device/1\nFingerprints for user tester on Goodix MOC (press):\n - #0: right-index-finger\n'

assert_pam_configured() {
  grep -qx "sudo sed -i 1i auth      sufficient pam_fprintd.so $scratch/pam.d/sudo" "$CALL_LOG" ||
    fail "$1: sudo gets fingerprint authentication" "$(<"$CALL_LOG")"
  grep -q "^sudo tee $scratch/pam.d/polkit-1" "$CALL_LOG" || fail "$1: polkit gets fingerprint authentication" "$(<"$CALL_LOG")"
  grep -qx 'apply-lock' "$CALL_LOG" || fail "$1: the lock screen is set up through omarchy-apply-lock" "$(<"$CALL_LOG")"
}

assert_pam_untouched() {
  ! grep -q "^sudo tee $scratch/pam.d" "$CALL_LOG" || fail "$1" "$(<"$CALL_LOG")"
  ! grep -qx 'apply-lock' "$CALL_LOG" || fail "$1: omarchy-apply-lock was not called" "$(<"$CALL_LOG")"
}

run_setup() {
  : > "$CALL_LOG"
  rm -f "$scratch/pam.d/omarchy-lock-fingerprint"
  OMARCHY_PATH="$scratch" USER=tester bash "$setup" > "$scratch/out" 2>&1
}

FPRINTD_LIST=$enrolled run_setup || fail "setup succeeds with a print already enrolled" "$(<"$scratch/out")"
! grep -q '^fprintd-enroll' "$CALL_LOG" || fail "an enrolled print is not enrolled again"
grep -qx 'fprintd-verify' "$CALL_LOG" || fail "an enrolled print is verified"
assert_pam_configured "an enrolled print"
pass "an already-enrolled print skips enrollment and configures PAM"

FPRINTD_LIST=$none run_setup || fail "setup succeeds when enrollment works" "$(<"$scratch/out")"
grep -qx 'fprintd-enroll tester' "$CALL_LOG" || fail "no fingers enrolled still enrolls" "$(<"$CALL_LOG")"
assert_pam_configured "a new print"
pass "\"no fingers enrolled\" is not mistaken for an enrolled print"

if FPRINTD_LIST=$none ENROLL_OK=0 run_setup; then
  fail "a failed enrollment exits non-zero"
fi
assert_pam_untouched "a failed enrollment leaves PAM alone"
pass "a failed enrollment stops before PAM"

FPRINTD_LIST=$enrolled VERIFY_OK=0 run_setup || true
assert_pam_untouched "an enrolled print that fails to verify leaves PAM alone"
grep -q 'fprintd-delete tester' "$scratch/out" ||
  fail "an enrolled print that fails to verify says how to start over" "$(<"$scratch/out")"
grep -q 'fprintd-delete tester -f <finger>' "$scratch/out" ||
  fail "an enrolled print that fails to verify says how to remove one finger" "$(<"$scratch/out")"
pass "an enrolled print that fails to verify explains how to enroll again"

FPRINTD_LIST=$none VERIFY_OK=0 run_setup || true
grep -qx 'fprintd-enroll tester' "$CALL_LOG" || fail "nothing enrolled still enrolls before verifying" "$(<"$CALL_LOG")"
grep -q 'fprintd-delete tester' "$scratch/out" ||
  fail "a new print that fails to verify says how to start over" "$(<"$scratch/out")"
pass "a new print that fails to verify explains how to enroll again"

# fprintd-verify checks the default reader. A print saved only on another one
# would skip enrollment and then fail verification, so it does not count.
FPRINTD_LIST=$other_reader run_setup || fail "setup succeeds with a print on another reader" "$(<"$scratch/out")"
grep -qx 'fprintd-enroll tester' "$CALL_LOG" || fail "a print on another reader still enrolls on the default" "$(<"$CALL_LOG")"
assert_pam_configured "a print enrolled on the default reader"
pass "a print saved on a different reader than the default is not counted"

FPRINTD_LIST=$other_reader DEFAULT_READER=/net/reactivated/Fprint/Device/1 run_setup ||
  fail "setup succeeds with a print on the default of two readers" "$(<"$scratch/out")"
! grep -q '^fprintd-enroll' "$CALL_LOG" || fail "a print on the default reader is not enrolled again"
pass "a print on the default of two readers skips enrollment"

# A list that fails is not the same as no prints: enrolling then could hit
# enroll-duplicate and end at "Enrollment failed" with the wrong advice.
if FPRINTD_LIST=$'ListEnrolledFingers failed: timeout\n' LIST_STATUS=1 run_setup; then
  fail "a failed fprintd-list stops setup"
fi
! grep -q '^fprintd-enroll' "$CALL_LOG" || fail "a failed fprintd-list does not enroll" "$(<"$CALL_LOG")"
! grep -q '^sudo' "$CALL_LOG" || fail "a failed fprintd-list leaves PAM alone" "$(<"$CALL_LOG")"
assert_pam_untouched "a failed fprintd-list leaves the lock screen alone"
grep -q "fprintd-list tester" "$scratch/out" || fail "a failed fprintd-list says what to check" "$(<"$scratch/out")"
pass "a failed fprintd-list stops before enrollment and says what to check"

# A detected sensor libfprint cannot drive leaves fprintd with no default reader.
# Enrollment then fails with fprintd's own "No devices available".
if NO_READER=1 FPRINTD_LIST=$none ENROLL_OK=0 run_setup; then
  fail "setup with no default reader exits non-zero"
fi
grep -qx 'fprintd-enroll tester' "$CALL_LOG" || fail "no default reader still tries to enroll" "$(<"$CALL_LOG")"
! grep -q 'Could not check' "$scratch/out" || fail "no default reader is not blamed on fprintd-list" "$(<"$scratch/out")"
assert_pam_untouched "no default reader leaves PAM alone"
pass "no default reader goes to enrollment, which reports fprintd's error"
