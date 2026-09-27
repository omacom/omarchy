#!/bin/bash
#
# Fingerprint setup must still reach PAM when a print from an earlier run is
# already enrolled, because fprintd-enroll refuses it as enroll-duplicate.
# fprintd and sudo are stubbed; sudo only records what setup asked it to do.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-fingerprint"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" > "$scratch/bin/$1"
  chmod +x "$scratch/bin/$1"
}

stub sudo '[[ $1 == fprintd-enroll ]] && exec "$@"; printf "sudo %s\n" "$*" >> "$CALL_LOG"'
stub omarchy-hw-fingerprint 'exit 0'
stub omarchy-pkg-missing 'exit 1'
stub fprintd-list 'printf "%s" "$FPRINTD_LIST"'
stub fprintd-enroll 'echo "fprintd-enroll $*" >> "$CALL_LOG"; [[ ${ENROLL_OK:-1} == 1 ]]'
stub fprintd-verify 'echo "fprintd-verify" >> "$CALL_LOG"; [[ ${VERIFY_OK:-1} == 1 ]]'

enrolled=$'Fingerprints for user tester on Validity VFS5011 (swipe):\n - #0: right-index-finger\n'
none=$'User tester has no fingers enrolled for Validity VFS5011.\n'

run_setup() {
  : > "$CALL_LOG"
  USER=tester bash "$setup" > "$scratch/out" 2>&1
}

FPRINTD_LIST=$enrolled run_setup || fail "setup succeeds with a print already enrolled" "$(<"$scratch/out")"
! grep -q '^fprintd-enroll' "$CALL_LOG" || fail "an enrolled print is not enrolled again"
grep -qx 'fprintd-verify' "$CALL_LOG" || fail "an enrolled print is verified"
grep -q '^sudo tee /etc/pam.d/omarchy-lock-fingerprint' "$CALL_LOG" ||
  fail "an enrolled print gets its PAM configuration" "$(<"$CALL_LOG")"
pass "an already-enrolled print skips enrollment and configures PAM"

FPRINTD_LIST=$none run_setup || fail "setup succeeds when enrollment works" "$(<"$scratch/out")"
grep -qx 'fprintd-enroll tester' "$CALL_LOG" || fail "no fingers enrolled still enrolls" "$(<"$CALL_LOG")"
grep -q '^sudo tee /etc/pam.d/omarchy-lock-fingerprint' "$CALL_LOG" || fail "a new print gets its PAM configuration"
pass "\"no fingers enrolled\" is not mistaken for an enrolled print"

if FPRINTD_LIST=$none ENROLL_OK=0 run_setup; then
  fail "a failed enrollment exits non-zero"
fi
! grep -q '^sudo tee /etc/pam.d' "$CALL_LOG" || fail "a failed enrollment leaves PAM alone" "$(<"$CALL_LOG")"
pass "a failed enrollment stops before PAM"

FPRINTD_LIST=$enrolled VERIFY_OK=0 run_setup || true
! grep -q '^sudo tee /etc/pam.d' "$CALL_LOG" || fail "an enrolled print that fails to verify leaves PAM alone"
grep -q 'fprintd-delete tester' "$scratch/out" ||
  fail "an enrolled print that fails to verify says how to start over" "$(<"$scratch/out")"
pass "an enrolled print that fails to verify explains how to enroll again"
