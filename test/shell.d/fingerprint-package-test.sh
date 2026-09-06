#!/bin/bash
#
# The fingerprint setup picks the driver from the reader on the bus: stock
# libfprint for most, the omarchy repo's libfprint-git for readers stock cannot
# drive yet, and only when the repo offers a pin new enough for them. The real
# omarchy-hw-* detectors and omarchy-pkg-present run against a sysfs fixture;
# only pacman and the privileged calls are stubbed.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command vercmp

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export OMARCHY_USB_DEVICES_PATH="$scratch/devices"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  pacman | fprintd-enroll) exec "$@" ;;
  *) echo "Unexpected privileged call: $*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
# INSTALLED holds one "name version" line per installed package; AVAILABLE_VERSION
# is what the sync db offers for libfprint-git, empty when it has none.
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q)
    grep -m1 "^$2 " <<< "${INSTALLED:-}"
    ;;
  -Si)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    [[ -n ${AVAILABLE_VERSION:-} ]] || { echo "error: package '$2' was not found" >&2; exit 1; }
    printf 'Version         : %s\n' "$AVAILABLE_VERSION"
    ;;
  -S)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    exit "${INSTALL_STATUS:-0}"
    ;;
  *) exit 99 ;;
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

write_usb_devices() {
  rm -rf "$OMARCHY_USB_DEVICES_PATH"
  mkdir -p "$OMARCHY_USB_DEVICES_PATH"

  local index=0 spec
  for spec in "$@"; do
    local dev="$OMARCHY_USB_DEVICES_PATH/1-$index"
    mkdir -p "$dev"
    printf '%s\n' "${spec%%:*}" > "$dev/idVendor"
    spec=${spec#*:}
    printf '%s\n' "${spec%%:*}" > "$dev/idProduct"
    [[ $spec == *:* ]] && printf '%s\n' "${spec#*:}" > "$dev/product"
    index=$((index + 1))
  done
}

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
  local description="$1"
  shift
  grep -qx "pacman -S --needed --noconfirm --ask 4 $*" "$CALL_LOG" || fail "$description"
  (( $(grep -c '^pacman -S ' "$CALL_LOG") == 1 )) || fail "$description: one install transaction"
  if grep -q '^pacman -R' "$CALL_LOG"; then
    fail "$description: never removes the installed driver first"
  fi
}

assert_no_install() {
  local description="$1"
  if grep -q '^pacman -S ' "$CALL_LOG"; then
    fail "$description"
  fi
}

assert_enrolls() {
  grep -qx enroll "$CALL_LOG" || fail "$1"
}

assert_no_enroll() {
  if grep -qx enroll "$CALL_LOG"; then
    fail "$1"
  fi
}

stock_reader='27c6:5395:Goodix Fingerprint USB Device'
git_reader='06cb:010b'
minimum=1:1.94.100.r10.g6f9479c-1
older=1:1.94.10.r12.gd79f157-1.1
newer=1:1.94.100.r11.gabcdef0-1
common=$'fprintd 1.94.5-1\nusbutils 018-1'

write_usb_devices "$stock_reader"
run_setup
assert_installs "a stock reader installs stock libfprint" libfprint fprintd usbutils
assert_enrolls "a stock reader reaches enrollment"
if grep -q '^pacman -Si' "$CALL_LOG"; then
  fail "a stock reader never consults the sync db"
fi
pass "a stock reader installs stock libfprint and reaches enrollment"

INSTALLED="libfprint-git $older"$'\n'"$common" run_setup
assert_installs "a stock reader replaces a leftover libfprint-git" libfprint fprintd usbutils
pass "a stock reader replaces a leftover libfprint-git in one transaction"

INSTALLED="libfprint 1.94.100-1"$'\n'"$common" run_setup
assert_no_install "a stock reader with everything installed skips pacman"
assert_enrolls "a stock reader with everything installed reaches enrollment"
pass "a stock reader with everything installed goes straight to enrollment"

write_usb_devices "$git_reader"
AVAILABLE_VERSION=$minimum run_setup
assert_installs "a git-only reader installs the omarchy repo's libfprint-git" omarchy/libfprint-git fprintd usbutils
assert_enrolls "a git-only reader reaches enrollment"
grep -qx 'pacman -Si omarchy/libfprint-git' "$CALL_LOG" || fail "the sync db query is qualified with the omarchy repo"
pass "a git-only reader installs omarchy/libfprint-git and reaches enrollment"

AVAILABLE_VERSION=$newer run_setup
assert_enrolls "a newer libfprint-git pin is accepted"
pass "a newer libfprint-git pin reaches enrollment"

for version in "$older" ''; do
  AVAILABLE_VERSION=$version run_setup
  assert_no_install "an old or missing libfprint-git pin stops before installation"
  assert_no_enroll "an old or missing libfprint-git pin stops before enrollment"
  grep -q 'Run omarchy update later' "$scratch/output" || fail "a stale repository gives an update instruction"
  if grep -q 'was not found' "$scratch/output"; then
    fail "a missing package does not leak pacman's error"
  fi
done
pass "an old or missing libfprint-git pin leaves the installed driver alone"

INSTALLED="libfprint-git $older"$'\n'"$common" AVAILABLE_VERSION=$minimum run_setup
assert_installs "an installed libfprint-git below the floor is upgraded" omarchy/libfprint-git fprintd usbutils
pass "an installed libfprint-git below the floor is upgraded"

INSTALLED="libfprint-git $minimum"$'\n'"$common" run_setup
assert_no_install "a current libfprint-git skips pacman"
if grep -q '^pacman -Si' "$CALL_LOG"; then
  fail "a current libfprint-git never consults the sync db"
fi
assert_enrolls "a current libfprint-git reaches enrollment"
pass "a current libfprint-git goes straight to enrollment"

INSTALLED="libfprint 1.94.100-1"$'\n'"$common" AVAILABLE_VERSION=$minimum run_setup
assert_installs "a git-only reader replaces installed stock libfprint" omarchy/libfprint-git fprintd usbutils
pass "a git-only reader replaces installed stock libfprint"

AVAILABLE_VERSION=$minimum INSTALL_STATUS=1 run_setup
assert_no_enroll "a failed package transaction prevents enrollment"
pass "a failed installation stops before enrollment"

write_usb_devices '0bda:5842:USB2.0 Camera'
run_setup
[[ ! -s $CALL_LOG ]] || fail "missing hardware stops before package operations"
pass "missing hardware performs no package operations"
