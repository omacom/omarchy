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
  # Ownership query, not a transaction: answer it without logging a call.
  # Only the library the setup cares about has an owner here, so any other path
  # comes back unowned the way pacman answers for a file no package ships.
  -Qqo)
    [[ $2 == /usr/lib/libfprint-2.so.2 ]] || exit 1
    [[ -n ${LIBFPRINT_OWNER:-} ]] || exit 1
    echo "$LIBFPRINT_OWNER"
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

assert_keeps_driver() {
  grep -qx 'pacman -S --needed --noconfirm --ask 4 -- fprintd usbutils' "$CALL_LOG" ||
    fail "$1"
  grep -q 'libfprint-git' "$CALL_LOG" && fail "$1: libfprint-git is not installed"
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

# Readers libfprint cannot drive at all run on a TOD stack -- a libfprint fork
# plus a vendor blob -- and that fork provides libfprint-2.so.2 itself. --ask 4
# would accept its removal silently, leaving the machine with no driver, so the
# owner of the library decides whether libfprint-git may replace it.
LIBFPRINT_OWNER=libfprint-tod INSTALLED=$'libfprint-tod' run_setup
assert_keeps_driver "a TOD-provided libfprint is kept instead of being replaced"
pass "a TOD-provided libfprint is kept and libfprint-git is skipped"

# The TOD packages are named differently per vendor, so the check has to follow
# the library's owner rather than any one package name.
LIBFPRINT_OWNER=libfprint-tod-git INSTALLED=$'libfprint-tod-git' run_setup
assert_keeps_driver "a differently named TOD package is kept too"
pass "the driver is kept by library ownership, not by package name"

LIBFPRINT_OWNER=libfprint-tod INSTALLED=$'libfprint-tod\nfprintd\nusbutils' run_setup
if grep -q '^pacman ' "$CALL_LOG"; then
  fail "a TOD machine with everything installed does not touch pacman"
fi
pass "a TOD machine with everything installed goes straight to enrollment"

LIBFPRINT_OWNER=libfprint run_setup
assert_installs "stock libfprint is still replaced by libfprint-git"
pass "stock libfprint is still replaced by libfprint-git"

LIBFPRINT_OWNER=libfprint-git INSTALLED=$'libfprint-git' run_setup
assert_installs "an existing libfprint-git still completes the package set"
pass "an existing libfprint-git still completes the package set"
