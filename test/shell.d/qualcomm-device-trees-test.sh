#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

dtb_dir="$tmp/dtbs/linux-omarchy/qcom"
proc_dir="$tmp/proc"
uki_conf="$tmp/uki.conf"
stub="$tmp/linuxaa64.efi.stub"
mkdir -p "$dtb_dir" "$proc_dir/device-tree"
: >"$stub"

# Write a minimal synthetic DTB carrying a single FDT_PROP (token 3) with the
# given NUL-separated compatible strings.
write_dtb() {
  python3 - "$@" <<'PY'
import struct
import sys

path = sys.argv[1]
compat = b"".join(s.encode() + b"\x00" for s in sys.argv[2:])
prop = struct.pack(">III", 3, len(compat), 0) + compat
with open(path, "wb") as f:
    f.write(b"\xd0\x0d\xfe\xed" + b"\x00" * 36 + prop)
PY
}

write_dtb "$dtb_dir/x1p42100-asus-zenbook-14-ux3480qa.dtb" "asus,zenbook-14-ux3480qa" "qcom,x1p42100"
write_dtb "$dtb_dir/x1p42100-other-board.dtb" "other,prefix" "asus,zenbook-14-ux3480qa" "qcom,x1p42100"
write_dtb "$dtb_dir/x1e80100-lenovo-yoga-slim7x.dtb" "lenovo,yoga-slim7x" "qcom,x1e80100"
write_dtb "$dtb_dir/x1e80100-lenovo-yoga-slim7x-el2.dtb" "lenovo,yoga-slim7x" "qcom,x1e80100"

printf '%s\0' "asus,zenbook-14-ux3480qa" "qcom,x1p42100" >"$proc_dir/device-tree/compatible"

run_update() {
  OMARCHY_QUALCOMM_DTB_ROOT="$tmp/dtbs" \
    OMARCHY_QUALCOMM_UKI_CONFIG="$uki_conf" \
    OMARCHY_QUALCOMM_UKI_STUB="$stub" \
    OMARCHY_PROC_ROOT="$proc_dir" \
    "$ROOT/bin/omarchy-update-qualcomm-device-trees" "$@"
}

# Exact FDT_PROP length matching picks the Zenbook DTB and ignores the longer
# compatible list that ends with the same strings, as well as *-el2.dtb files.
out=$(run_update --install)
grep -Fqx "DeviceTree=$dtb_dir/x1p42100-asus-zenbook-14-ux3480qa.dtb" "$uki_conf" ||
  fail "exact compatible match sets DeviceTree=" "$(<"$uki_conf")"
grep -Fq "DeviceTreeAuto=" "$uki_conf" || fail "DeviceTreeAuto= was written" "$(<"$uki_conf")"
! grep -Fq -- "-el2.dtb" "$uki_conf" || fail "*-el2.dtb must stay out of DeviceTreeAuto=" "$(<"$uki_conf")"
grep -Fq "Listed 3 device trees" <<<"$out" || fail "reports 3 non-el2 device trees" "$out"
pass "matches exact FDT_PROP compatible bytes without matching longer suffixes"

# Ambiguous match (two DTBs with identical compatible) omits DeviceTree=.
write_dtb "$dtb_dir/x1p42100-duplicate.dtb" "asus,zenbook-14-ux3480qa" "qcom,x1p42100"
run_update >/dev/null
! grep -Fq "DeviceTree=" "$uki_conf" || fail "ambiguous match must omit DeviceTree=" "$(<"$uki_conf")"
rm -f "$dtb_dir/x1p42100-duplicate.dtb"
pass "omits DeviceTree= when more than one DTB matches"

# Non-build Limine hook callers (limine-install, limine-snapper-sync) skip the
# refresh, while limine-mkinitcpio-install runs it.
HOOK_CALLER=limine-install run_update >/dev/null
! grep -Fq "DeviceTree=" "$uki_conf" || fail "HOOK_CALLER=limine-install must not refresh uki.conf" "$(<"$uki_conf")"
HOOK_CALLER=limine-mkinitcpio-install run_update >/dev/null
grep -Fqx "DeviceTree=$dtb_dir/x1p42100-asus-zenbook-14-ux3480qa.dtb" "$uki_conf" ||
  fail "HOOK_CALLER=limine-mkinitcpio-install refreshes uki.conf" "$(<"$uki_conf")"
pass "skips non-build Limine hook callers and runs for limine-mkinitcpio-install"
