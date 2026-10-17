#!/bin/bash
#
# The fingerprint setup installs libfprint-git in place of stock libfprint. The
# two conflict, so the swap has to happen inside one --ask 4 transaction, and a
# rerun with everything installed must not touch pacman at all. The real
# omarchy-pkg-missing runs; pacman and the privileged calls are stubbed.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat > "$scratch/bin/omarchy-hw-fingerprint" <<'STUB'
#!/bin/bash
exit "${HARDWARE_STATUS:-0}"
STUB
cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  pacman | fprintd-enroll) exec "$@" ;;
  sed) printf 'pam %s\n' "$*" >> "$CALL_LOG" ;;
  tee) printf 'pam %s\n' "$*" >> "$CALL_LOG"; cat >/dev/null ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
# INSTALLED lists the installed package names, one per line.
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q)
    if [[ $2 == "--" ]]; then
      shift 2
    else
      shift
    fi
    grep -qx -- "$1" <<< "${INSTALLED:-}"
    ;;
  -S)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    exit "${INSTALL_STATUS:-0}"
    ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
cat > "$scratch/bin/fprintd-enroll" <<'STUB'
#!/bin/bash
# Stop before verification/PAM; no host authentication files may be changed.
echo enroll >> "$CALL_LOG"
exit "${ENROLL_STATUS:-1}"
STUB
# The first CLAIM_FAILURES verifications cannot claim the reader, as a VFS5011
# was reported to fail straight after enrollment.
cat > "$scratch/bin/fprintd-verify" <<'STUB'
#!/bin/bash
echo verify >> "$CALL_LOG"
if (( $(grep -cx verify "$CALL_LOG") <= ${CLAIM_FAILURES:-0} )); then
  echo "failed to claim device: GDBus.Error:net.reactivated.Fprint.Error.Internal: Open failed with error: transfer failed"
  exit 1
fi
exit "${VERIFY_STATUS:-1}"
STUB
cat > "$scratch/bin/sleep" <<'STUB'
#!/bin/bash
echo "sleep $*" >> "$CALL_LOG"
STUB
chmod +x "$scratch/bin/"*

cat > "$scratch/bin/omarchy-apply-lock" <<'STUB'
#!/bin/bash
echo apply-lock >> "$CALL_LOG"
if [[ ${LOCK_SETUP_UNKNOWN:-0} != "1" ]]; then
  touch "$TEST_LOCK_PAM"
fi
STUB
chmod +x "$scratch/bin/omarchy-apply-lock"

export TEST_LOCK_PAM="$scratch/omarchy-lock-fingerprint"
setup_script="$scratch/omarchy-setup-security-fingerprint"
sed "s|/etc/pam.d/omarchy-lock-fingerprint|$TEST_LOCK_PAM|g" "$ROOT/bin/omarchy-setup-security-fingerprint" > "$setup_script"
chmod +x "$setup_script"

run_setup() {
  : > "$CALL_LOG"
  if OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1; then
    fail "setup stops on the simulated enrollment or installation failure"
  fi
  if grep -Eq '^(pam |apply-lock$|Unexpected privileged call)' "$CALL_LOG"; then
    fail "setup does not change PAM or lock recovery after failed enrollment"
  fi
}

assert_installs() {
  grep -qx 'pacman -S --needed --noconfirm --ask 4 -- libfprint-git fprintd usbutils' "$CALL_LOG" || fail "$1"
  (( $(grep -c '^pacman ' "$CALL_LOG") == 1 )) || fail "$1: one pacman transaction"
}

run_setup
assert_installs "a fresh machine installs libfprint-git, fprintd and usbutils"
grep -qx enroll "$CALL_LOG" || fail "installation is followed by enrollment"
pass "a fresh machine installs libfprint-git and reaches enrollment"

INSTALLED=$'libfprint\nfprintd\nusbutils' run_setup
assert_installs "installed stock libfprint is replaced in the same transaction"
pass "installed stock libfprint is replaced without a removal step"

INSTALLED=$'libfprint-git\nfprintd\nusbutils' run_setup
if grep -q '^pacman' "$CALL_LOG"; then
  fail "a rerun with everything installed does not touch pacman"
fi
grep -qx enroll "$CALL_LOG" || fail "a rerun with everything installed reaches enrollment"
pass "a rerun with everything installed goes straight to enrollment"

INSTALL_STATUS=1 run_setup
if grep -qx enroll "$CALL_LOG"; then
  fail "a failed package transaction prevents enrollment"
fi
pass "a failed installation stops before enrollment"

HARDWARE_STATUS=1 run_setup
[[ ! -s $CALL_LOG ]] || fail "missing hardware stops before package operations"
pass "missing hardware performs no package operations"

# Successful setup must reuse the same lock/recovery installer as updates.
: > "$CALL_LOG"
OMARCHY_PATH="$scratch" ENROLL_STATUS=0 VERIFY_STATUS=0 \
  "$setup_script" > "$scratch/output" 2>&1 || fail "successful enrollment configures authentication"
[[ $(grep -E '^(enroll|verify|apply-lock)$' "$CALL_LOG") == $'enroll\nverify\napply-lock' ]] ||
  fail "setup configures lock recovery once, after enrollment and verification"
pass "setup reuses apply-lock after enrollment and verification"

rm -f "$TEST_LOCK_PAM"
if OMARCHY_PATH="$scratch" ENROLL_STATUS=0 VERIFY_STATUS=0 LOCK_SETUP_UNKNOWN=1 \
  "$setup_script" > "$scratch/output" 2>&1; then
  fail "an inconclusive lock installer cannot report successful lock setup"
fi
grep -q 'lock-screen configuration could not be confirmed' "$scratch/output" || fail "inconclusive setup explains how to retry"
if grep -q 'Perfect!\|You can use your fingerprint' "$scratch/output"; then
  fail "inconclusive setup does not promise fingerprint unlock"
fi
pass "an inconclusive lock installer cannot report successful lock setup"

# A reader still busy after enrollment is waited for, not reported as a mismatch.
: > "$CALL_LOG"
OMARCHY_PATH="$scratch" ENROLL_STATUS=0 VERIFY_STATUS=0 CLAIM_FAILURES=2 \
  "$setup_script" > "$scratch/output" 2>&1 || fail "a reader that frees up is verified"
[[ $(grep -E '^(enroll|verify|sleep.*|apply-lock)$' "$CALL_LOG") == $'enroll\nverify\nsleep 5\nverify\nsleep 5\nverify\napply-lock' ]] ||
  fail "a claim failure is retried after a pause" "$(<"$CALL_LOG")"
grep -q '^pam ' "$CALL_LOG" || fail "a reader that frees up still gets PAM configured"
pass "a reader still busy after enrollment is retried, then configured"

: > "$CALL_LOG"
OMARCHY_PATH="$scratch" ENROLL_STATUS=0 VERIFY_STATUS=0 CLAIM_FAILURES=3 \
  "$setup_script" > "$scratch/output" 2>&1 || true
(( $(grep -cx verify "$CALL_LOG") == 3 )) || fail "a reader that stays busy is tried three times" "$(<"$CALL_LOG")"
if grep -Eq '^(pam |apply-lock$)' "$CALL_LOG"; then
  fail "an unverified print leaves PAM alone"
fi
grep -q 'reader could not be opened' "$scratch/output" || fail "a busy reader is reported as the reader" "$(<"$scratch/output")"
if grep -q 'try enrolling again' "$scratch/output"; then
  fail "a busy reader does not send the user back to enrollment"
fi
grep -q "Let's setup your right index finger" "$scratch/output" || fail "retries keep earlier setup output" "$(<"$scratch/output")"
(( $(grep -c '^failed to claim device' "$scratch/output") == 3 )) || fail "every attempt's output reaches the user" "$(<"$scratch/output")"
pass "a reader that stays busy is reported as the reader and leaves PAM alone"

: > "$CALL_LOG"
OMARCHY_PATH="$scratch" ENROLL_STATUS=0 VERIFY_STATUS=1 \
  "$setup_script" > "$scratch/output" 2>&1 || true
[[ $(grep -E '^(verify|sleep.*)$' "$CALL_LOG") == verify ]] || fail "a mismatch is not retried" "$(<"$CALL_LOG")"
grep -q 'try enrolling again' "$scratch/output" || fail "a mismatch suggests enrolling again"
if grep -Eq '^(pam |apply-lock$)' "$CALL_LOG"; then
  fail "a mismatch leaves PAM alone"
fi
pass "a finger that does not match is reported once, without a retry"
