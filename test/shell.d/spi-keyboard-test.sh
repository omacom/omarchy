#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
cat >"$work/bin/cat" <<'STUB'
#!/bin/bash
if [[ $1 == /sys/class/dmi/id/product_name ]]; then
  [[ ${DMI_STATUS:-0} == 0 ]] || exit "$DMI_STATUS"
  printf '%s\n' "${DMI_MODEL:-Unknown}"
else
  /usr/bin/cat "$@"
fi
STUB
cat >"$work/bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
echo "$*" >>"$SPI_CALLS"
STUB
cat >"$work/bin/sudo" <<'STUB'
#!/bin/bash
# No host filesystem or kernel mutations in this fixture.
exit 0
STUB
chmod +x "$work/bin/"*
export SPI_CALLS="$work/calls"
for failure in 1 13; do
  DMI_STATUS=$failure PATH="$work/bin:$PATH" bash -eE "$ROOT/install/hardware/apple/fix-spi-keyboard.sh"
  [[ ! -f $SPI_CALLS ]] || fail 'missing/unreadable DMI must not install SPI drivers'
done
DMI_MODEL=MacBookPro13,2 PATH="$work/bin:$PATH" bash -eE "$ROOT/install/hardware/apple/fix-spi-keyboard.sh"
grep -Fxq macbook12-spi-driver-dkms "$SPI_CALLS" || fail 'matching Intel Mac retains SPI driver'
pass 'missing/unreadable DMI survives errexit and matching Intel Macs retain drivers'
