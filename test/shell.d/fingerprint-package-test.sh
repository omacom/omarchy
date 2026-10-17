#!/bin/bash
#
# The fingerprint setup installs libfprint-git when no libfprint provider is
# present, or when only Arch stock libfprint is. A community fork that already
# provides libfprint must not be replaced, and a package transaction must
# restart fprintd so enroll does not talk to a stale .so. The real
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
  sed) printf 'pam %s\n' "$*" >> "$CALL_LOG" ;;
  tee) printf 'pam %s\n' "$*" >> "$CALL_LOG"; cat >/dev/null ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
# INSTALLED lists installed package names, one per line.
# PROVIDES maps query=provider for pacman -Qq provides resolution (forks).
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
resolve() {
  local query=$1
  if grep -qx "$query" <<< "${INSTALLED:-}"; then
    printf '%s\n' "$query"
    return 0
  fi
  local line provider target
  while IFS= read -r line; do
    [[ -z $line ]] && continue
    target=${line%%=*}
    provider=${line#*=}
    if [[ $target == "$query" ]] && grep -qx "$provider" <<< "${INSTALLED:-}"; then
      printf '%s\n' "$provider"
      return 0
    fi
  done <<< "${PROVIDES:-}"
  return 1
}

case "$1" in
  -Qq)
    shift
    [[ ${1:-} == -- ]] && shift
    found=0
    for query in "$@"; do
      if out=$(resolve "$query"); then
        printf '%s\n' "$out"
        found=1
      fi
    done
    (( found ))
    ;;
  -Q)
    shift
    [[ ${1:-} == -- ]] && shift
    resolve "${1:-}" >/dev/null
    ;;
  -S)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    exit "${INSTALL_STATUS:-0}"
    ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
cat > "$scratch/bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >> "$CALL_LOG"
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

assert_full_install() {
  grep -qx 'pacman -S --needed --noconfirm --ask 4 libfprint-git fprintd usbutils' "$CALL_LOG" || fail "$1"
  (( $(grep -c '^pacman ' "$CALL_LOG") == 1 )) || fail "$1: one pacman transaction"
  grep -qx 'systemctl try-restart fprintd.service' "$CALL_LOG" || fail "$1: restarts fprintd after install"
}

run_setup
assert_full_install "a fresh machine installs libfprint-git, fprintd and usbutils"
grep -qx enroll "$CALL_LOG" || fail "installation is followed by enrollment"
pass "a fresh machine installs libfprint-git and reaches enrollment"

INSTALLED=$'libfprint\nfprintd\nusbutils' run_setup
grep -qx 'pacman -S --needed --noconfirm --ask 4 libfprint-git' "$CALL_LOG" ||
  fail "installed stock libfprint is replaced with libfprint-git only"
(( $(grep -c '^pacman ' "$CALL_LOG") == 1 )) || fail "stock replacement: one pacman transaction"
grep -qx 'systemctl try-restart fprintd.service' "$CALL_LOG" ||
  fail "stock replacement restarts fprintd"
pass "installed stock libfprint is replaced without a removal step"

INSTALLED=$'libfprint-git\nfprintd\nusbutils' run_setup
if grep -q '^pacman' "$CALL_LOG"; then
  fail "a rerun with everything installed does not touch pacman"
fi
if grep -q '^systemctl' "$CALL_LOG"; then
  fail "a no-op package path does not restart fprintd"
fi
grep -qx enroll "$CALL_LOG" || fail "a rerun with everything installed reaches enrollment"
pass "a rerun with everything installed goes straight to enrollment"

INSTALLED=$'libfprint-goodix53x5\nfprintd\nusbutils' \
  PROVIDES=$'libfprint=libfprint-goodix53x5\nlibfprint-2=libfprint-goodix53x5' \
  run_setup
if grep -q '^pacman' "$CALL_LOG"; then
  fail "a working libfprint fork is not replaced with libfprint-git"
fi
if grep -q '^systemctl' "$CALL_LOG"; then
  fail "keeping a fork does not restart fprintd"
fi
grep -qx enroll "$CALL_LOG" || fail "a forked libfprint still reaches enrollment"
pass "a working libfprint fork is left alone"

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
