#!/bin/bash
#
# The stock-libfprint migration swaps libfprint-git out for stock libfprint,
# except on machines whose reader only libfprint-git can drive: there it must
# leave the driver the fingerprint setup installed alone. The real
# omarchy-hw-fingerprint-git runs against a sysfs fixture; pacman and the
# package helper are stubbed.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1785090473.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export OMARCHY_USB_DEVICES_PATH="$scratch/devices"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q) grep -qx "$2" <<< "${INSTALLED:-}" ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG" ;;
esac
STUB
cat > "$scratch/bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'omarchy-pkg-add %s\n' "$*" >> "$CALL_LOG"
STUB
chmod +x "$scratch/bin/"*

write_usb_device() {
  rm -rf "$OMARCHY_USB_DEVICES_PATH"
  mkdir -p "$OMARCHY_USB_DEVICES_PATH/1-0"
  printf '%s\n' "${1%%:*}" > "$OMARCHY_USB_DEVICES_PATH/1-0/idVendor"
  printf '%s\n' "${1#*:}" > "$OMARCHY_USB_DEVICES_PATH/1-0/idProduct"
}

run_migration() {
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" > /dev/null
}

write_usb_device '27c6:5395'
INSTALLED=$'libfprint-git\nfprintd' run_migration
grep -qx 'pacman -Rdd --noconfirm libfprint-git' "$CALL_LOG" || fail "a stock-driven reader drops libfprint-git"
grep -qx 'omarchy-pkg-add libfprint' "$CALL_LOG" || fail "a stock-driven reader installs stock libfprint"
pass "a stock-driven reader moves back to stock libfprint"

write_usb_device '06cb:010b'
INSTALLED=$'libfprint-git\nfprintd' run_migration
[[ ! -s $CALL_LOG ]] || fail "a reader only libfprint-git drives keeps it" "$(<"$CALL_LOG")"
pass "a reader only libfprint-git drives keeps it"

# An earlier run that removed libfprint-git and then failed to install stock
# leaves fprintd without a driver; the reader's needs do not change that.
INSTALLED='fprintd' run_migration
grep -qx 'omarchy-pkg-add libfprint' "$CALL_LOG" || fail "a half-finished swap still installs stock libfprint"
if grep -q '^pacman -R' "$CALL_LOG"; then
  fail "a half-finished swap has nothing left to remove"
fi
pass "a half-finished swap still installs stock libfprint"

write_usb_device '27c6:5395'
INSTALLED=$'libfprint\nfprintd' run_migration
[[ ! -s $CALL_LOG ]] || fail "stock libfprint already in place is left alone"
pass "stock libfprint already in place is left alone"
