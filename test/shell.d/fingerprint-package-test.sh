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
cat > "$scratch/bin/fprintd-verify" <<'STUB'
#!/bin/bash
echo verify >> "$CALL_LOG"
exit "${VERIFY_STATUS:-1}"
STUB
chmod +x "$scratch/bin/"*

# No running shell unless a case sets SHELL_RUNNING: the text flow is what
# these cases exercise. With one, setup hands over to the enrollment overlay.
cat > "$scratch/bin/omarchy-shell" <<'STUB'
#!/bin/bash
[[ ${SHELL_RUNNING:-0} == "1" && $* == "shell ping" ]] && echo ok
STUB
cat > "$scratch/bin/omarchy-fingerprint-enroll" <<'STUB'
#!/bin/bash
echo overlay >> "$CALL_LOG"
STUB
chmod +x "$scratch/bin/omarchy-shell" "$scratch/bin/omarchy-fingerprint-enroll"

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

# With the shell running, setup is the overlay's job: hand over before any
# package, enrollment or PAM step.
: > "$CALL_LOG"
SHELL_RUNNING=1 OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1 ||
  fail "setup hands over to the overlay when the shell is running"
[[ $(cat "$CALL_LOG") == "overlay" ]] || fail "the overlay hand-over runs nothing else" "$(cat "$CALL_LOG")"
pass "setup hands over to the enrollment overlay when the shell is running"

: > "$CALL_LOG"
SHELL_RUNNING=1 HARDWARE_STATUS=1 OMARCHY_PATH="$scratch" "$setup_script" > "$scratch/output" 2>&1 &&
  fail "setup without a reader does not open the overlay"
[[ ! -s $CALL_LOG ]] || fail "setup without a reader does not open the overlay"
pass "setup without a reader does not open the overlay"

# --enable-login is how the overlay turns login on after its own enrollment
# and confirmation: the same PAM and lock steps, and nothing before them.
rm -f "$TEST_LOCK_PAM"
: > "$CALL_LOG"
OMARCHY_PATH="$scratch" "$setup_script" --enable-login > "$scratch/output" 2>&1 ||
  fail "--enable-login configures authentication"
grep -qx apply-lock "$CALL_LOG" || fail "--enable-login configures the lock screen"
if grep -qE '^(pacman|enroll|verify|overlay)' "$CALL_LOG"; then
  fail "--enable-login does not install, enroll, verify or open the overlay"
fi
pass "--enable-login configures login and nothing before it"

rm -f "$TEST_LOCK_PAM"
if LOCK_SETUP_UNKNOWN=1 OMARCHY_PATH="$scratch" "$setup_script" --enable-login > "$scratch/output" 2>&1; then
  fail "--enable-login fails when the lock screen cannot be confirmed"
fi
pass "--enable-login fails when the lock screen cannot be confirmed"

# The overlay's first run installs through omarchy-fingerprint-setup-helper.
# Run its install step against the same pacman stub: one transaction on a
# fresh machine, no pacman when everything is present, failure reported.
helper_install=$(sed -n '/^install_packages()/,/^}/p' "$ROOT/bin/omarchy-fingerprint-setup-helper")
[[ -n $helper_install ]] || fail "the setup helper defines install_packages"

run_helper_install() {
  : > "$CALL_LOG"
  bash -c "set -euo pipefail; $helper_install; install_packages" > "$scratch/output" 2>&1
}

run_helper_install || fail "the helper installs on a fresh machine"
assert_installs "the helper installs libfprint-git, fprintd and usbutils"
pass "the helper's install step makes the same single transaction"

INSTALLED=$'libfprint-git\nfprintd\nusbutils' run_helper_install ||
  fail "the helper succeeds when everything is installed"
if grep -q '^pacman' "$CALL_LOG"; then
  fail "the helper does not touch pacman when everything is installed"
fi
pass "the helper skips pacman when everything is installed"

if INSTALL_STATUS=1 run_helper_install; then
  fail "the helper fails when the package transaction fails"
fi
pass "the helper reports a failed package transaction"
