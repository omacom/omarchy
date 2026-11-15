#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/lenovo/ideapad-slim-5x.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

require_platform_fixtures "the IdeaPad Slim 5x setup"

run_setup() (
  set -eE
  local dir=$1
  PATH="$ROOT/bin:$PATH"
  omarchy-hw-aarch64-qualcomm() { return 0; }

  OMARCHY_PROC_ROOT="$dir/proc" \
    OMARCHY_IDEAPAD_SLIM5X_DRM_ROOT="$dir/drm" \
    OMARCHY_IDEAPAD_SLIM5X_UKI_CONFIG="$dir/kernel/uki.conf" \
    OMARCHY_QUALCOMM_DTB_ROOT="$dir/dtbs" \
    source "$setup"
)

# A Slim 5x booted on the OLED tree, with the panel whose EDID header and
# manufacturer and product code are given in hex.
slim5x() {
  local dir=$1 panel=$2
  mkdir -p "$dir/proc/device-tree" "$dir/drm/card1-eDP-1" "$dir/dtbs/linux-omarchy/qcom" "$dir/kernel"
  printf 'lenovo,ideapad-slim5x-oled\0qcom,x1p42100\0' >"$dir/proc/device-tree/compatible"
  printf "\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\x00$panel\\x00\\x00\\x00\\x00" >"$dir/drm/card1-eDP-1/edid"
  : >"$dir/dtbs/linux-omarchy/qcom/x1p42100-lenovo-ideapad-slim5x-lcd.dtb"
  : >"$dir/dtbs/linux-omarchy/qcom/x1p42100-lenovo-ideapad-slim5x-oled.dtb"
  cat >"$dir/kernel/uki.conf" <<'CONF'
[UKI]
Cmdline=@/etc/kernel/cmdline
# BEGIN OMARCHY QUALCOMM DEVICE TREES
[UKI]
DeviceTreeAuto=/boot/dtbs/linux-omarchy/qcom/x1p42100-lenovo-ideapad-slim5x-oled.dtb
# END OMARCHY QUALCOMM DEVICE TREES
CONF
}

# CMN N140JCE-EL1, the 83HL's 1920x1200 LCD.
lcd="$scratch/lcd"
slim5x "$lcd" '\x0d\xae\x76\x14'
run_setup "$lcd" >/dev/null
printf 'lenovo,ideapad-slim5x-lcd\0qcom,x1p42100\0' >"$lcd/proc/device-tree/compatible"
run_setup "$lcd" >/dev/null
(( $(grep -c "^DeviceTree=$lcd/dtbs/linux-omarchy/qcom/x1p42100-lenovo-ideapad-slim5x-lcd.dtb\$" "$lcd/kernel/uki.conf") == 1 )) ||
  fail "the LCD model gets the LCD tree, once across reruns on either tree"
! grep -q 'DeviceTreeAuto' "$lcd/kernel/uki.conf" ||
  fail "the shared device-tree list is replaced, since the models share an SMBIOS identity"
grep -Fxq 'Cmdline=@/etc/kernel/cmdline' "$lcd/kernel/uki.conf" ||
  fail "unrelated UKI settings are preserved"

# Any other panel, here a Samsung one.
oled="$scratch/oled"
slim5x "$oled" '\x4c\x83\x65\x41'
cp -p "$oled/kernel/uki.conf" "$scratch/oled-uki.conf"
run_setup "$oled" >/dev/null
cmp -s "$scratch/oled-uki.conf" "$oled/kernel/uki.conf" ||
  fail "another panel keeps the device-tree list"

other="$scratch/other"
slim5x "$other" '\x0d\xae\x76\x14'
printf 'lenovo,yoga-slim7x\0qcom,x1e80100\0' >"$other/proc/device-tree/compatible"
cp -p "$other/kernel/uki.conf" "$scratch/other-uki.conf"
run_setup "$other" >/dev/null
cmp -s "$scratch/other-uki.conf" "$other/kernel/uki.conf" ||
  fail "other boards are left unchanged, even with the same panel"

pass "IdeaPad Slim 5x setup boots the LCD model on the LCD tree"
