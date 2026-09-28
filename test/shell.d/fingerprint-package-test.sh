#!/bin/bash
#
# The fingerprint setup branches on the reader: Validity/Synaptics readers take
# a python-validity stack from the AUR, everything else gets libfprint-git in
# place of stock libfprint. The two conflict, so the swap has to happen inside
# one --ask 4 transaction, and a rerun with everything installed must not touch
# the package manager at all. Hardware detection and the package helpers are
# stubbed so the branch choice is deterministic on any host.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export INSTALLED_LOG="$scratch/installed"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat > "$scratch/bin/omarchy-hw-fingerprint" <<'STUB'
#!/bin/bash
exit "${HARDWARE_STATUS:-0}"
STUB
# Default to a non-Validity reader so the original cases keep exercising the
# libfprint path; the validity cases set VALIDITY_STATUS=0.
cat > "$scratch/bin/omarchy-hw-fingerprint-validity" <<'STUB'
#!/bin/bash
exit "${VALIDITY_STATUS:-1}"
STUB
cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  pacman | fprintd-enroll | systemctl) exec "$@" ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
# INSTALLED lists the installed package names, one per line, and mirrors
# omarchy-pkg-missing: packages absent from it are reported missing.
cat > "$scratch/bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
for pkg in "$@"; do
  grep -qx -- "$pkg" <<< "${INSTALLED:-}" || exit 0
done
exit 1
STUB
cat > "$scratch/bin/omarchy-pkg-aur-add" <<'STUB'
#!/bin/bash
printf 'aur-add %s\n' "$*" >> "$CALL_LOG"
for arg in "$@"; do
  printf '%s\n' "$arg" >> "$INSTALLED_LOG"
done
exit "${AUR_STATUS:-0}"
STUB
cat > "$scratch/bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >> "$CALL_LOG"
exit 0
STUB
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
exit 1
STUB
cat > "$scratch/bin/fprintd-verify" <<'STUB'
#!/bin/bash
echo verify >> "$CALL_LOG"
exit 1
STUB
chmod +x "$scratch/bin/"*

run_setup() {
  : > "$CALL_LOG"
  : > "$INSTALLED_LOG"
  if "$ROOT/bin/omarchy-setup-security-fingerprint" > "$scratch/output" 2>&1; then
    fail "setup stops on the simulated enrollment or installation failure"
  fi
  if grep -q 'Unexpected privileged call' "$CALL_LOG"; then
    fail "setup does not change PAM after failed enrollment"
  fi
}

assert_installs() {
  grep -qx 'pacman -S --needed --noconfirm --ask 4 -- libfprint-git fprintd usbutils' "$CALL_LOG" || fail "$1"
  (( $(grep -c '^pacman ' "$CALL_LOG") == 1 )) || fail "$1: one pacman transaction"
}

assert_validity_stack() {
  grep -qx 'aur-add python-validity' "$CALL_LOG" || fail "$1"
  grep -qx 'systemctl enable --now open-fprintd.service python3-validity.service python3-validity-suspend-hotfix.service' "$CALL_LOG" || fail "$1: services are enabled"
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

VALIDITY_STATUS=0 run_setup
assert_validity_stack "a Validity reader installs python-validity from the AUR"
grep -qx enroll "$CALL_LOG" || fail "the validity stack is followed by enrollment"
pass "a Validity reader installs python-validity and reaches enrollment"

VALIDITY_STATUS=0 INSTALLED=$'python-validity\nopen-fprintd\nfprintd-clients' run_setup
if grep -q '^aur-add' "$CALL_LOG"; then
  fail "a Validity reader with python-validity installed does not touch the AUR"
fi
grep -qx 'systemctl enable --now open-fprintd.service python3-validity.service python3-validity-suspend-hotfix.service' "$CALL_LOG" || fail "a Validity reader still enables the daemons"
grep -qx enroll "$CALL_LOG" || fail "a Validity reader with python-validity installed reaches enrollment"
pass "a Validity reader with python-validity installed skips the AUR and starts the daemons"

VALIDITY_STATUS=0 AUR_STATUS=1 run_setup
if grep -qx enroll "$CALL_LOG"; then
  fail "a failed AUR install prevents enrollment"
fi
pass "a failed python-validity install stops before enrollment"
