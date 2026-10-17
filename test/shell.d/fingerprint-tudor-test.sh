#!/bin/bash
#
# Tudor guidance in the fingerprint setup: a rerun on a machine that already
# runs the community synaTudor TOD stack must never reinstall libfprint-git
# (it conflicts with libfprint-tod-git and would remove the working driver),
# and a failed enrollment explains Tudor only when the failure itself says no
# device is available — naming the exact sysfs reader, not the first 06cb
# entry lsusb lists. Fixtures model sysfs; no host USB or auth files change.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/devices"
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
echo enroll >> "$CALL_LOG"
printf '%s\n' "${ENROLL_OUTPUT:-}"
exit "${ENROLL_STATUS:-1}"
STUB
chmod +x "$scratch/bin/"*

export TEST_LOCK_PAM="$scratch/omarchy-lock-fingerprint"
setup_script="$scratch/omarchy-setup-security-fingerprint"
sed "s|/etc/pam.d/omarchy-lock-fingerprint|$TEST_LOCK_PAM|g" "$ROOT/bin/omarchy-setup-security-fingerprint" > "$setup_script"
chmod +x "$setup_script"

write_usb_devices() {
  rm -rf "$scratch/devices"
  mkdir -p "$scratch/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local dev="$scratch/devices/1-$index"
    mkdir -p "$dev"
    printf '%s\n' "${spec%%:*}" >"$dev/idVendor"
    printf '%s\n' "${spec#*:}" >"$dev/idProduct"
    index=$((index + 1))
  done
}

# INSTALLED keeps the package step quiet so each run reaches enrollment;
# ENROLL_STATUS stays 1 so each run takes the failure branch.
run_setup_expecting_enroll_failure() {
  : > "$CALL_LOG"
  rm -f "$TEST_LOCK_PAM"
  if OMARCHY_PATH="$scratch" OMARCHY_USB_DEVICES_PATH="$scratch/devices" \
    INSTALLED="${INSTALLED:-$'libfprint-git\nfprintd\nusbutils'}" ENROLL_STATUS=1 \
    ENROLL_OUTPUT="${ENROLL_OUTPUT:-}" "$setup_script" > "$scratch/output" 2>&1; then
    fail "enrollment failure exits nonzero"
  fi
  grep -qx enroll "$CALL_LOG" || fail "setup reaches enrollment"
  if grep -Eq '^(pam |apply-lock$|Unexpected privileged call)' "$CALL_LOG"; then
    fail "failed enrollment does not change PAM or lock recovery"
  fi
  [[ ! -e $TEST_LOCK_PAM ]] || fail "failed enrollment creates no lock file"
}

NO_DEVICE_OUTPUT='Impossible to enroll: GDBus.Error:net.reactivated.Fprint.Error.NoSuchDevice: No devices available'

for tudor_id in 00be 00da 00fd 00ff; do
  write_usb_devices "06cb:$tudor_id"
  ENROLL_OUTPUT="$NO_DEVICE_OUTPUT" run_setup_expecting_enroll_failure
  grep -q 'synaTudor' "$scratch/output" || fail "06cb:$tudor_id with no-device failure suggests synaTudor"
  grep -q "06cb:$tudor_id" "$scratch/output" || fail "06cb:$tudor_id names its own id"
  pass "06cb:$tudor_id with no-device failure suggests synaTudor"
done

# The message must name the Tudor reader even when another 06cb device sorts
# first: glob order puts 1-0 before 1-1, so the decoy wins any first-06cb
# lookup that does not check product ids.
write_usb_devices "06cb:abcd" "06cb:00be"
ENROLL_OUTPUT="$NO_DEVICE_OUTPUT" run_setup_expecting_enroll_failure
grep -q '06cb:00be' "$scratch/output" || fail "tudor guidance names the tudor reader, not the decoy"
if grep -q '06cb:abcd' "$scratch/output"; then
  fail "tudor guidance never names the non-tudor 06cb device"
fi
pass "tudor guidance names the tudor reader, not another 06cb device"

# A Tudor machine whose other reader fails enrollment for its own reason keeps
# the general message: Tudor presence alone never explains the failure.
write_usb_devices "06cb:00be"
ENROLL_OUTPUT='Impossible to enroll: failed to scan finger, try again' run_setup_expecting_enroll_failure
grep -q 'Please try again' "$scratch/output" || fail "scan failure keeps the general message"
if grep -q 'synaTudor' "$scratch/output"; then
  fail "scan failure does not suggest synaTudor"
fi
pass "scan failure on a tudor machine keeps the general message"

# No-device failure without Tudor hardware keeps the general message too.
write_usb_devices "27c6:609c"
ENROLL_OUTPUT="$NO_DEVICE_OUTPUT" run_setup_expecting_enroll_failure
grep -q 'Please try again' "$scratch/output" || fail "non-tudor failure keeps the general message"
if grep -q 'synaTudor' "$scratch/output"; then
  fail "non-tudor failure does not suggest synaTudor"
fi
pass "non-tudor failure keeps the general message"

# An empty sysfs tree (no readers at all) is the same general case.
write_usb_devices
ENROLL_OUTPUT="$NO_DEVICE_OUTPUT" run_setup_expecting_enroll_failure
grep -q 'Please try again' "$scratch/output" || fail "empty sysfs keeps the general message"
pass "empty sysfs keeps the general message"

# Enrollment's own output must reach the user, not be swallowed by the error
# check: scan progress is the only guidance while the finger is moving.
write_usb_devices "06cb:00be"
ENROLL_OUTPUT="scan-marker-741 $NO_DEVICE_OUTPUT" run_setup_expecting_enroll_failure
grep -q 'scan-marker-741' "$scratch/output" || fail "enrollment output reaches the user"
pass "enrollment output reaches the user"

# A rerun with the TOD stack installed must not touch pacman at all, or the
# libfprint-git install would remove the working TOD driver.
write_usb_devices "06cb:00be"
INSTALLED=$'libfprint-tod-git\nfprintd\nusbutils' ENROLL_OUTPUT="$NO_DEVICE_OUTPUT" run_setup_expecting_enroll_failure
if grep -q '^pacman' "$CALL_LOG"; then
  fail "a rerun with the TOD stack installed does not touch pacman"
fi
pass "a rerun with the TOD stack installed goes straight to enrollment"

# A TOD machine missing helpers tops them up without naming libfprint-git.
: > "$CALL_LOG"
write_usb_devices "06cb:00be"
if OMARCHY_PATH="$scratch" OMARCHY_USB_DEVICES_PATH="$scratch/devices" \
  INSTALLED='libfprint-tod-git' ENROLL_STATUS=1 \
  ENROLL_OUTPUT="$NO_DEVICE_OUTPUT" "$setup_script" > "$scratch/output" 2>&1; then
  fail "enrollment failure exits nonzero"
fi
grep -qx 'pacman -S --needed --noconfirm --ask 4 -- fprintd usbutils' "$CALL_LOG" ||
  fail "a TOD machine installs only the missing helpers"
if grep -q 'libfprint-git' "$CALL_LOG"; then
  fail "a TOD machine never reinstalls libfprint-git"
fi
pass "a TOD machine tops up helpers without touching libfprint-git"
