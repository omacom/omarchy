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
  -n) exit "${SUDO_CACHED:-1}" ;;
  -v) echo "sudo authenticated" >> "$CALL_LOG"; exit "${SUDO_V_STATUS:-0}" ;;
  pacman | fprintd-enroll) exec "$@" ;;
  omarchy-lifecycle-dispatch) echo "dispatch ${*:2}" >> "$CALL_LOG"; exit "${ENABLE_STATUS:-0}" ;;
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
# Both fail unless ENROLL_STATUS or VERIFY_STATUS says otherwise, stopping
# before PAM. ENROLL_OUTPUT is what fprintd-enroll prints first.
cat > "$scratch/bin/fprintd-enroll" <<'STUB'
#!/bin/bash
echo enroll >> "$CALL_LOG"
[[ -z ${ENROLL_OUTPUT:-} ]] || printf '%s\n' "$ENROLL_OUTPUT"
exit "${ENROLL_STATUS:-1}"
STUB
cat > "$scratch/bin/fprintd-verify" <<'STUB'
#!/bin/bash
echo verify >> "$CALL_LOG"
exit "${VERIFY_STATUS:-1}"
STUB
# fprintd on D-Bus: SCAN_TYPE is the default reader's scan type and READER_NAME
# its name; with SCAN_TYPE unset, fprintd doesn't answer. Never the host's own fprintd.
cat > "$scratch/bin/busctl" <<'STUB'
#!/bin/bash
[[ -n ${SCAN_TYPE:-} ]] || exit 1
case "$*" in
  *GetDefaultDevice*) echo 'o "/net/reactivated/Fprint/Device/0"' ;;
  *"/net/reactivated/Fprint/Device/0 net.reactivated.Fprint.Device scan-type"*) echo "s \"$SCAN_TYPE\"" ;;
  *"/net/reactivated/Fprint/Device/0 net.reactivated.Fprint.Device name"*) echo "s \"${READER_NAME:-Some USB reader}\"" ;;
  *) exit 1 ;;
esac
STUB
# The dispatcher as the user: ENABLE_HOOK is what enable-fingerprint resolves
# to (empty on a platform without one) and RESOLVE_STATUS its exit status.
cat > "$scratch/bin/omarchy-lifecycle-dispatch" <<'STUB'
#!/bin/bash
echo "resolve ${*:2}" >> "$CALL_LOG"
[[ ${RESOLVE_STATUS:-0} == 0 ]] || exit "$RESOLVE_STATUS"
printf '%s\n' "${ENABLE_HOOK-/usr/lib/omarchy/mac/enable-fingerprint}"
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
    fail "setup does not change PAM or lock recovery after a failed enrollment, installation or verify"
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

# A reader its platform keeps off until the owner agrees is turned on before
# enrolling; one the owner doesn't turn on stops setup with nothing enrolled.
[[ $(grep -E '^(resolve .*|dispatch .*|enroll)$' "$CALL_LOG") == $'resolve enable-fingerprint\ndispatch enable-fingerprint\nenroll' ]] ||
  fail "the platform turns its reader on before enrollment, resolved as the user first" "$(cat "$CALL_LOG")"
: > "$CALL_LOG"
if INSTALLED=$'libfprint-git\nfprintd\nusbutils' ENABLE_STATUS=1 ENROLL_STATUS=0 VERIFY_STATUS=0 \
  OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1; then
  fail "a reader the owner doesn't turn on stops setup"
fi
! grep -Eq '^(enroll|verify|apply-lock|pam .*)$' "$CALL_LOG" && grep -q 'was not turned on, so nothing was enrolled' "$scratch/output" ||
  fail "a reader that wasn't turned on is never enrolled, and setup says why" "$(cat "$CALL_LOG"; cat "$scratch/output")"
# The owner may read past sudo's timeout, so sudo is checked again after the hook.
: > "$CALL_LOG"
INSTALLED=$'libfprint-git\nfprintd\nusbutils' ENROLL_STATUS=0 VERIFY_STATUS=0 \
  OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1 || fail "setup with a platform hook succeeds"
[[ $(grep -E '^(dispatch .*|sudo authenticated|enroll)$' "$CALL_LOG") == $'sudo authenticated\ndispatch enable-fingerprint\nsudo authenticated\nenroll' ]] &&
  grep -qF "Confirm it's you again." "$scratch/output" ||
  fail "sudo is checked again after the platform hook, before enrolling" "$(cat "$CALL_LOG")"
pass "the platform turns its reader on before enrollment, and setup stops if it doesn't"

# A platform with no hook runs nothing as root for it, and one whose hook can't
# be resolved sets up the same way, saying so: a reader its platform keeps off
# stays off, and any other reader enrolls as on every platform.
: > "$CALL_LOG"
INSTALLED=$'libfprint-git\nfprintd\nusbutils' ENABLE_HOOK= ENROLL_STATUS=0 VERIFY_STATUS=0 \
  OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1 || fail "a platform without the hook sets up as before"
! grep -q '^dispatch ' "$CALL_LOG" && grep -qx enroll "$CALL_LOG" ||
  fail "a platform without the hook enrolls without a privileged dispatch" "$(cat "$CALL_LOG")"
: > "$CALL_LOG"
INSTALLED=$'libfprint-git\nfprintd\nusbutils' RESOLVE_STATUS=2 ENROLL_STATUS=0 VERIFY_STATUS=0 \
  OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1 || fail "a hook that can't be resolved doesn't stop setup" "$(cat "$scratch/output")"
! grep -q '^dispatch ' "$CALL_LOG" && grep -qx enroll "$CALL_LOG" && grep -q "couldn't be checked, so a reader the platform keeps off stays off" "$scratch/output" ||
  fail "a hook that can't be resolved runs nothing as root, enrolls as before and says so" "$(cat "$CALL_LOG"; cat "$scratch/output")"
pass "a platform without the hook runs nothing as root for it, and one that can't be told sets up as before"

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

# A press sensor, such as a Mac's Touch ID, takes a touch per sample, so setup
# says to lift and touch again; a swipe sensor keeps the moving-finger
# instruction, and one fprintd can't name is told neither.
press_text=$'Touch the sensor, lift your finger and touch it again.\nKeep going until it says Enrolled. A step can take a few touches.'
swipe_text="Keep moving the finger around on sensor until it says Enrolled."
unnamed_text=$'Touch or swipe the sensor, and keep going until it says Enrolled.\nA step can take a few tries.'
check_instruction() {
  INSTALLED=$'libfprint-git\nfprintd\nusbutils' SCAN_TYPE=$1 run_setup
  local text output
  output=$(<"$scratch/output")
  for text in "$press_text" "$swipe_text" "$unnamed_text"; do
    if [[ $text == "$2" ]]; then
      [[ $output == *"$text"* ]] || fail "$3" "$output"
    else
      [[ $output != *"$text"* ]] || fail "$3" "$output"
    fi
  done
}
check_instruction press "$press_text" "a press sensor is told to lift and touch again"
check_instruction swipe "$swipe_text" "a swipe sensor keeps the moving-finger instruction"
check_instruction "" "$unnamed_text" "a sensor fprintd can't name is told to touch or swipe"
pass "each scan type gets its own instruction, and an unnamed one is told to touch or swipe"

# The verify prompt names the reader's scan type, and neither when fprintd
# can't say which, so a press reader is never told to swipe.
check_verify_prompt() {
  : > "$CALL_LOG"
  INSTALLED=$'libfprint-git\nfprintd\nusbutils' SCAN_TYPE=$1 ENROLL_STATUS=0 VERIFY_STATUS=1 \
    OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1 || true
  grep -qF "Now let's verify that it's working correctly. $2" "$scratch/output" ||
    fail "a ${1:-unnamed} sensor is asked to verify with: $2" "$(cat "$scratch/output")"
}
check_verify_prompt press "Touch the sensor."
check_verify_prompt swipe "Swipe your finger across the sensor."
check_verify_prompt "" "Touch or swipe the sensor."
pass "the verify prompt names the scan type only when fprintd gives one"

# fprintd-enroll's raw results become instructions. Touch ID's duplicate check
# stage prints nothing; later stages count as steps, never touches, since one
# stage can take several.
enroll_lines=$'Using device /net/reactivated/Fprint/Device/0\nEnrolling right-index-finger finger.'
for result in stage-passed stage-passed retry-scan stage-passed unknown-error; do
  enroll_lines+=$'\nEnroll result: enroll-'$result
done
INSTALLED=$'libfprint-git\nfprintd\nusbutils' SCAN_TYPE=press READER_NAME='Apple secure enclave fingerprint sensor' \
  ENROLL_OUTPUT=$enroll_lines run_setup
expected=$'  ✓ Step 1 done. Keep lifting your finger and touching the sensor.
  That one didn\'t read. Keep lifting your finger and touching the sensor.
  ✓ Step 2 done. Keep lifting your finger and touching the sensor.
  ✗ Enrollment stopped. If you stopped before it said Enrolled, run this again and keep going.'
[[ $(grep -E '^  ' "$scratch/output") == "$expected" ]] ||
  fail "enrollment results read as instructions, counting steps after the duplicate check" "$(cat "$scratch/output")"
! grep -q 'Enroll result:' "$scratch/output" || fail "no raw fprintd result reaches the owner" "$(cat "$scratch/output")"
grep -q 'Enrollment failed' "$scratch/output" || fail "a failed enrollment still fails setup" "$(cat "$scratch/output")"
pass "enrollment results read as instructions, and a failed enrollment still fails setup"

# A failed verify fails setup and leaves PAM and the lock screen alone; the
# success path's order is checked above.
: > "$CALL_LOG"
if INSTALLED=$'libfprint-git\nfprintd\nusbutils' SCAN_TYPE=press ENROLL_STATUS=0 VERIFY_STATUS=1 \
  OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1; then
  fail "a failed verify fails setup" "$(cat "$scratch/output")"
fi
grep -qx verify "$CALL_LOG" && ! grep -Eq '^(pam |apply-lock$|Unexpected privileged call)' "$CALL_LOG" ||
  fail "a failed verify leaves PAM and the lock screen alone" "$(cat "$CALL_LOG")"
pass "a failed verify fails setup, leaving PAM and the lock screen alone"

# The verify step's results, in fprintd-verify's own format (each with " (done)"
# or " (not done)"), through the functions setup uses.
source <(sed -n '/^fprintd_chatter()/,/^}/p;/^enroll_progress()/,/^}/p;/^verify_progress()/,/^}/p' \
  "$ROOT/bin/omarchy-setup-security-fingerprint")
[[ $(printf '%s\n' 'Using device /net/reactivated/Fprint/Device/0' 'Listing enrolled fingers:' ' - #0: right-index-finger' \
  'Verify started!' 'Verifying: right-index-finger' 'Verify result: verify-retry-scan (not done)' \
  'Verify result: verify-finger-not-centered (not done)' 'Verify result: verify-match (done)' |
  verify_progress "Touch again.") == $'  That one didn\'t read. Touch again.\n  Not centered: use the middle of the sensor. Touch again.\n  ✓ Matched.' ]] ||
  fail "verify results, retries included, read as instructions"
[[ $(printf '%s\n' 'Verify result: verify-no-match (done)' | verify_progress "Touch again.") == $'  ✗ No match.' ]] ||
  fail "a failed verify says so"
pass "verify results read as instructions"

# Only Touch ID's first stage is its duplicate check. On any other reader, one
# that doesn't identify or one whose duplicate check took a touch, the first
# stage to pass is step 1.
INSTALLED=$'libfprint-git\nfprintd\nusbutils' SCAN_TYPE=press ENROLL_OUTPUT=$enroll_lines run_setup
[[ $(grep -c 'Step [0-9] done' "$scratch/output") == 3 ]] ||
  fail "another reader's first stage is step 1" "$(cat "$scratch/output")"
INSTALLED=$'libfprint-git\nfprintd\nusbutils' ENROLL_OUTPUT=$enroll_lines run_setup
[[ $(grep -c 'Step [0-9] done' "$scratch/output") == 3 ]] ||
  fail "a reader fprintd can't name has its first stage counted" "$(cat "$scratch/output")"
[[ $(printf '%s\n' 'Enroll result: enroll-stage-passed' 'Enroll result: enroll-stage-passed' | enroll_progress "Again." 1) == \
  $'  ✓ Step 1 done. Again.' ]] || fail "with a duplicate check, the first stage is not a step"
pass "only a reader with a duplicate check leaves its first stage out of the steps"

# sudo's own prompt comes first and is named as such; with sudo already
# authenticated there is no prompt to explain.
INSTALLED=$'libfprint-git\nfprintd\nusbutils' SCAN_TYPE=press run_setup
grep -qF "First, confirm it's you." "$scratch/output" && grep -qx 'sudo authenticated' "$CALL_LOG" ||
  fail "setup names sudo's prompt and authenticates before enrolling" "$(cat "$scratch/output")"
(( $(grep -n "First, confirm it's you." "$scratch/output" | cut -d: -f1) < $(grep -n "Let's set up" "$scratch/output" | cut -d: -f1) )) ||
  fail "sudo's prompt comes before the enrollment instructions" "$(cat "$scratch/output")"
INSTALLED=$'libfprint-git\nfprintd\nusbutils' SCAN_TYPE=press SUDO_CACHED=0 run_setup
! grep -qF "First, confirm it's you." "$scratch/output" && ! grep -qx 'sudo authenticated' "$CALL_LOG" ||
  fail "an authenticated sudo is not asked again" "$(cat "$scratch/output")"
pass "sudo is authenticated, and named, before the enrollment instructions"

# What fprintd prints when it can't go on (a claimed device, no fingers) is
# shown; its routine lines are not.
[[ $(printf '%s\n' 'Using device /net/reactivated/Fprint/Device/0' \
  'failed to claim device: GDBus.Error:net.reactivated.Fprint.Error.AlreadyInUse: Device was already claimed' |
  enroll_progress "Touch again.") == '  failed to claim device: GDBus.Error:net.reactivated.Fprint.Error.AlreadyInUse: Device was already claimed' ]] ||
  fail "why enrollment could not start is shown"
[[ $(printf '%s\n' 'Using device /net/reactivated/Fprint/Device/0' 'No fingers enrolled for this device.' |
  verify_progress "Touch again.") == '  No fingers enrolled for this device.' ]] || fail "why verify could not start is shown"
pass "fprintd's reasons for stopping reach the owner, its routine lines do not"

# A sudo that won't authenticate stops setup with a reason, before enrolling.
INSTALLED=$'libfprint-git\nfprintd\nusbutils' SCAN_TYPE=press SUDO_V_STATUS=1 run_setup
grep -qF "Setup needs administrator rights to enroll a fingerprint." "$scratch/output" && ! grep -qx enroll "$CALL_LOG" ||
  fail "a failed sudo stops setup with a reason" "$(cat "$scratch/output")"
pass "a failed sudo stops setup with a reason, before enrolling"

# Every retry fprintd 1.94.5 can send keeps enrollment going; only a failure
# says it stopped, and a result fprintd adds later is shown, not called a stop.
[[ $(printf '%s\n' 'Enrolling right-index-finger finger.' 'Enroll result: enroll-stage-passed' 'Enroll result: enroll-too-fast' \
  'Enroll result: enroll-swipe-too-short' 'Enroll result: enroll-stage-passed' 'Enroll result: enroll-some-new-result' \
  'Enroll result: enroll-completed' | enroll_progress "Swipe it again." 1) == $'  Too fast. Swipe it again.\n  Too short. Swipe it again.\n  ✓ Step 1 done. Swipe it again.\n  enroll-some-new-result\n  ✓ Enrolled.' ]] ||
  fail "enrollment retries keep going, and an unknown result is shown"
[[ $(printf '%s\n' 'Verify result: verify-too-fast (not done)' 'Verify result: verify-some-new-retry (not done)' \
  'Verify result: verify-unknown-error (done)' | verify_progress "Swipe it again.") == $'  Too fast. Swipe it again.\n  That one didn\'t read. Swipe it again.\n  ✗ The check stopped (verify-unknown-error).' ]] ||
  fail "any verify result that isn't done is a retry"
pass "every retry keeps the step going, and only a finished failure says it stopped"

# Each of fprintd 1.94.5's enroll and verify results, one by one.
check_enroll() {
  [[ $(printf 'Enroll result: %s\n' "$1" | enroll_progress "Again.") == "$2" ]] ||
    fail "enroll result $1 reads as: $2" "$(printf 'Enroll result: %s\n' "$1" | enroll_progress "Again.")"
}
check_enroll enroll-completed $'  ✓ Enrolled.'
check_enroll enroll-retry-scan "  That one didn't read. Again."
check_enroll enroll-swipe-too-short '  Too short. Again.'
check_enroll enroll-finger-not-centered '  Not centered: use the middle of the sensor. Again.'
check_enroll enroll-remove-and-retry '  Lift your finger off the sensor, then try again.'
check_enroll enroll-too-fast '  Too fast. Again.'
check_enroll enroll-duplicate $'  ✗ That finger is already enrolled.'
check_enroll enroll-data-full $'  ✗ The reader has no room for another fingerprint.'
check_enroll enroll-disconnected $'  ✗ The reader was disconnected.'
for result in enroll-failed enroll-unknown-error; do
  check_enroll "$result" $'  ✗ Enrollment stopped. If you stopped before it said Enrolled, run this again and keep going.'
done
check_verify() {
  [[ $(printf 'Verify result: %s\n' "$1" | verify_progress "Again.") == "$2" ]] ||
    fail "verify result $1 reads as: $2" "$(printf 'Verify result: %s\n' "$1" | verify_progress "Again.")"
}
check_verify 'verify-match (done)' $'  ✓ Matched.'
check_verify 'verify-no-match (done)' $'  ✗ No match.'
check_verify 'verify-retry-scan (not done)' "  That one didn't read. Again."
check_verify 'verify-swipe-too-short (not done)' '  Too short. Again.'
check_verify 'verify-finger-not-centered (not done)' '  Not centered: use the middle of the sensor. Again.'
check_verify 'verify-remove-and-retry (not done)' '  Lift your finger off the sensor, then try again.'
# The line names no gesture, so it reads right on press and swipe readers alike.
[[ $(printf 'Enroll result: enroll-remove-and-retry\n' | enroll_progress "Swipe it again.") == '  Lift your finger off the sensor, then try again.' ]] ||
  fail "a swipe reader asked to lift its finger isn't told to touch"
check_verify 'verify-too-fast (not done)' '  Too fast. Again.'
check_verify 'verify-disconnected (done)' $'  ✗ The reader was disconnected.'
check_verify 'verify-unknown-error (done)' $'  ✗ The check stopped (verify-unknown-error).'
pass "each enroll and verify result fprintd 1.94.5 sends reads as intended"
