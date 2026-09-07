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
  pacman | fprintd-enroll | systemctl) exec "$@" ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
# INSTALLED lists the installed package names, one per line.
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q | -Qq)
    if grep -qx "$2" <<< "${INSTALLED:-}" || grep -qx "$2" "$INSTALLED_LOG"; then
      [[ $1 != "-Qq" ]] || printf '%s\n' "$2"
      exit 0
    fi
    exit 1
    ;;
  -S)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    [[ ${INSTALL_STATUS:-0} == 0 ]] || exit "$INSTALL_STATUS"
    for arg in "$@"; do
      [[ $arg == -* ]] || printf '%s\n' "$arg" >> "$INSTALLED_LOG"
    done
    ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
cat > "$scratch/bin/fingerprint-tui" <<'STUB'
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
cat > "$scratch/bin/omarchy-restart-gum" <<'STUB'
#!/bin/bash
:
STUB
cat > "$scratch/bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >> "$CALL_LOG"
STUB
chmod +x "$scratch/bin/"*
export INSTALLED_LOG="$scratch/installed"

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
  grep -qx 'pacman -S --needed --noconfirm --ask 4 libfprint-git fprintd usbutils' "$CALL_LOG" || fail "$1"
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

INSTALLED=t1bridge run_setup
grep -qx 'pacman -S --noconfirm --needed libfprint-t1bridge fprintd-t1bridge usbutils' "$CALL_LOG" || fail "T1 setup installs the matched pair"
[[ $(grep -c '^pacman ' "$CALL_LOG") == 1 ]] || fail "T1 setup uses one package transaction"
grep -qx 'systemctl restart fprintd.service' "$CALL_LOG" || fail "T1 setup loads the installed driver"
grep -qx enroll "$CALL_LOG" || fail "T1 setup reaches standard enrollment"
pass "T1 setup installs the matched pair before standard enrollment"

INSTALLED=$'t1bridge\nlibfprint-t1bridge\nfprintd-t1bridge\nusbutils' run_setup
! grep -q '^pacman ' "$CALL_LOG" || fail "the installed T1 pair is preserved"
grep -qx enroll "$CALL_LOG" || fail "installed T1 packages reach enrollment"
pass "the installed T1 pair is preserved"

for conflict in libfprint libfprint-git fprintd; do
  INSTALLED=$(printf 't1bridge\n%s\n' "$conflict") run_setup
  [[ ! -s $CALL_LOG ]] || fail "T1 conflict stops before any mutation" "$(<"$CALL_LOG")"
done
for conflict in libfprint-t1bridge fprintd-t1bridge; do
  INSTALLED="$conflict" run_setup
  [[ ! -s $CALL_LOG ]] || fail "an orphan T1 package cannot be replaced by ordinary setup" "$(<"$CALL_LOG")"
done
pass "competing T1 and ordinary fingerprint stacks stop before changes"

INSTALLED=t1bridge INSTALL_STATUS=1 run_setup
! grep -Eq '^(enroll|systemctl)' "$CALL_LOG" || fail "failed T1 installation stops before service changes or enrollment"
pass "failed T1 installation stops before service changes or enrollment"
