#!/bin/bash
#
# Re-running fingerprint setup must still reach PAM when a print is already
# enrolled. enroll-duplicate exits non-zero, and remove-then-setup leaves prints
# in /var/lib/fprint — either way the wizard used to exit before writing PAM.
# Privileged PAM writers are stubbed so the host stacks are never touched.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export PATH="$scratch/bin:$ROOT/bin:$PATH"
export INSTALLED=$'libfprint-git\nfprintd\nusbutils'

cat > "$scratch/bin/omarchy-hw-fingerprint" <<'STUB'
#!/bin/bash
exit 0
STUB
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q) grep -qx "$2" <<< "${INSTALLED:-}" ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
# Log privileged PAM writers without touching /etc. Consume tee stdin so the
# heredocs in setup_pam_config / setup_lock_fingerprint_pam do not block.
cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  fprintd-enroll) exec "$@" ;;
  tee | sed)
    printf 'sudo %s\n' "$*" >> "$CALL_LOG"
    [[ $1 == tee ]] && cat >/dev/null
    exit 0
    ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
cat > "$scratch/bin/gum" <<'STUB'
#!/bin/bash
echo "gum $*" >> "$CALL_LOG"
exit "${GUM_ANSWER:-0}"
STUB
cat > "$scratch/bin/fprintd-list" <<'STUB'
#!/bin/bash
if [[ ${ENROLLED:-1} == 1 ]]; then
  cat <<'OUT'
found 1 devices
Device at /net/reactivated/Fprint/Device/0
Using device /net/reactivated/Fprint/Device/0
Fingerprints for user tester on Test Sensor (press):
 - #0: right-index-finger
OUT
else
  cat <<OUT
found 1 devices
Device at /net/reactivated/Fprint/Device/0
Using device /net/reactivated/Fprint/Device/0
User ${1:-tester} has no fingers enrolled for Test Sensor.
OUT
fi
STUB
cat > "$scratch/bin/fprintd-enroll" <<'STUB'
#!/bin/bash
echo enroll >> "$CALL_LOG"
echo "Enroll result: ${ENROLL_RESULT:-enroll-duplicate}"
exit "${ENROLL_STATUS:-1}"
STUB
cat > "$scratch/bin/fprintd-verify" <<'STUB'
#!/bin/bash
echo verify >> "$CALL_LOG"
exit "${VERIFY_STATUS:-0}"
STUB
chmod +x "$scratch/bin/"*

assert_pam_configured() {
  local description=$1
  grep -q 'sudo tee /etc/pam.d/omarchy-lock-fingerprint' "$CALL_LOG" ||
    fail "$description: lock fingerprint PAM was written"
  grep -qE 'sudo tee /etc/pam.d/polkit-1|sudo sed .*/etc/pam.d/sudo' "$CALL_LOG" ||
    fail "$description: sudo or polkit PAM was written"
}

run_setup() {
  : > "$CALL_LOG"
  env USER=tester "$@" "$ROOT/bin/omarchy-setup-security-fingerprint" > "$scratch/output" 2>&1
}

# Existing prints + confirm skip → no enroll, verify + PAM.
run_setup GUM_ANSWER=0
if grep -qx enroll "$CALL_LOG"; then
  fail "skipping enrollment does not call fprintd-enroll"
fi
grep -qx verify "$CALL_LOG" || fail "skipping enrollment still verifies"
grep -q 'gum confirm' "$CALL_LOG" || fail "existing prints prompt with gum confirm"
assert_pam_configured "skip enrollment configures PAM"
pass "existing prints can skip enrollment and configure PAM"

# Existing prints + decline skip + enroll-duplicate → still verify + PAM.
run_setup GUM_ANSWER=1 ENROLL_STATUS=1 ENROLL_RESULT=enroll-duplicate
grep -qx enroll "$CALL_LOG" || fail "declining skip still attempts enrollment"
grep -qx verify "$CALL_LOG" || fail "enroll-duplicate still verifies"
assert_pam_configured "enroll-duplicate configures PAM"
pass "enroll-duplicate with existing prints still configures PAM"

# No prints + enroll failure → exit 1, no PAM writers.
if run_setup ENROLLED=0 ENROLL_STATUS=1; then
  fail "enrollment failure without prints exits non-zero"
fi
grep -qx enroll "$CALL_LOG" || fail "a machine with no prints still enrolls"
if grep -qE 'sudo tee|sudo sed' "$CALL_LOG"; then
  fail "failed enrollment without prints does not write PAM"
fi
pass "enrollment failure without prints does not write PAM"

# Fresh enroll success → verify + PAM (no gum prompt when nothing enrolled).
run_setup ENROLLED=0 ENROLL_STATUS=0
grep -qx enroll "$CALL_LOG" || fail "a fresh machine enrolls"
grep -qx verify "$CALL_LOG" || fail "a fresh enroll verifies"
if grep -q 'gum confirm' "$CALL_LOG"; then
  fail "a fresh machine does not prompt to skip enrollment"
fi
assert_pam_configured "fresh enrollment configures PAM"
pass "fresh enrollment configures PAM after verify"
