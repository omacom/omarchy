#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

write_backlights() {
  rm -rf "$tmp_dir/backlight"
  mkdir -p "$tmp_dir/backlight"

  local device
  for device in "$@"; do
    mkdir -p "$tmp_dir/backlight/$device"
  done
}

# A copy of the command reads its platform file from a fixture root: none
# unless a case writes one, whatever the machine running the suite has installed.
platform_root="$tmp_dir/platform"
mkdir -p "$platform_root" "$tmp_dir/bin"
platform_root_copy "$ROOT/bin/omarchy-hw-display" "$tmp_dir/bin/omarchy-hw-display" "$platform_root"

write_displays_conf() {
  printf '%s\n' "$@" >"$platform_root/displays.conf"
}

hw_display() {
  OMARCHY_BACKLIGHT_PATH="$tmp_dir/backlight" "$tmp_dir/bin/omarchy-hw-display"
}

write_backlights intel_backlight
device=$(hw_display)
[[ $device == "intel_backlight" ]] || fail "the only backlight is used" "actual: $device"
pass "the only backlight is used"

write_backlights acpi_video0 amdgpu_bl1
device=$(hw_display)
[[ $device == "amdgpu_bl1" ]] || fail "globbed candidates beat the alphabetical fallback" "actual: $device"
pass "globbed candidates beat the alphabetical fallback"

write_backlights acpi_video0 intel_backlight
device=$(hw_display)
[[ $device == "intel_backlight" ]] || fail "the candidate order is honored" "actual: $device"
pass "the candidate order is honored"

write_backlights nvidia_wmi_ec_backlight
device=$(hw_display)
[[ $device == "nvidia_wmi_ec_backlight" ]] || fail "an unknown backlight falls back to the first device" "actual: $device"
pass "an unknown backlight falls back to the first device"

write_backlights appletb_backlight gmux_backlight
device=$(hw_display)
[[ $device == "gmux_backlight" ]] || fail "a T2 Mac uses gmux instead of the Touch Bar" "actual: $device"
pass "a T2 Mac uses gmux instead of the Touch Bar"

write_backlights appletb_backlight
if hw_display >/dev/null 2>&1; then
  fail "the T2 Touch Bar is never used as the display backlight"
fi
pass "the T2 Touch Bar is never used as the display backlight"

write_backlights acpi_video0 amdgpu_bl0 appletb_backlight gmux_backlight intel_backlight
device=$(hw_display)
[[ $device == "gmux_backlight" ]] || fail "gmux outranks the GPU backlights on dual-GPU Macs" "actual: $device"
pass "gmux outranks the GPU backlights on dual-GPU Macs"

write_backlights
if hw_display >/dev/null 2>&1; then
  fail "no backlight device reports failure"
fi
pass "no backlight device reports failure"

# An empty platform file changes nothing.
: >"$platform_root/displays.conf"
write_backlights acpi_video0 amdgpu_bl1
device=$(hw_display)
[[ $device == "amdgpu_bl1" ]] || fail "an empty platform file keeps the candidate order" "actual: $device"
write_backlights nvidia_wmi_ec_backlight
device=$(hw_display)
[[ $device == "nvidia_wmi_ec_backlight" ]] || fail "an empty platform file keeps the fallback" "actual: $device"
pass "an empty platform file changes nothing"

write_displays_conf '# accessory panels' 'backlight-skip accessory-pipe' 'backlight-skip *.dsi.0' 'backlight-prefer panel-bl'
write_backlights 1000.dsi.0 accessory-pipe
if hw_display >/dev/null 2>&1; then
  fail "a skipped backlight is never the fallback"
fi
write_backlights 1000.dsi.0 accessory-pipe zz-other
device=$(hw_display)
[[ $device == "zz-other" ]] || fail "the fallback passes over skipped backlights" "actual: $device"
pass "a platform's skipped backlights are never the fallback"

write_backlights 1000.dsi.0 amdgpu_bl0 panel-bl
device=$(hw_display)
[[ $device == "panel-bl" ]] || fail "a preferred backlight beats the GPU backlights" "actual: $device"
printf 'backlight-prefer panel-bl\r\n' >"$platform_root/displays.conf"
device=$(hw_display)
[[ $device == "panel-bl" ]] || fail "a file saved with CRLF line ends reads the same" "actual: $device"
write_displays_conf '# accessory panels' 'backlight-skip accessory-pipe' 'backlight-skip *.dsi.0' 'backlight-prefer panel-bl'
write_backlights gmux_backlight panel-bl
device=$(hw_display)
[[ $device == "gmux_backlight" ]] || fail "gmux still beats a preferred backlight" "actual: $device"
pass "a platform's preferred backlight follows gmux and beats the GPU backlights"

write_displays_conf 'backlight-prefer second-bl' 'backlight-prefer first-bl'
write_backlights first-bl second-bl
device=$(hw_display)
[[ $device == "second-bl" ]] || fail "preferences are tried in file order" "actual: $device"
pass "preferences are tried in file order"

write_displays_conf 'backlight-skip intel_backlight' 'backlight-prefer panel-bl' 'backlight-skip panel-bl'
write_backlights acpi_video0 intel_backlight panel-bl
device=$(hw_display)
[[ $device == "acpi_video0" ]] || fail "a skip beats preferred and built-in candidates" "actual: $device"
write_displays_conf 'backlight-skip gmux_backlight'
write_backlights gmux_backlight intel_backlight
device=$(hw_display)
[[ $device == "intel_backlight" ]] || fail "a skip beats gmux" "actual: $device"
pass "a skip beats preferred and built-in candidates"

write_displays_conf 'backlight-prefer panel-*' 'backlight-prefer .' 'backlight-prefer ..'
write_backlights amdgpu_bl0 panel-bl
device=$(hw_display)
[[ $device == "amdgpu_bl0" ]] || fail "a preference is a literal name" "actual: $device"
pass "a preference is a literal name"

# Only whole directives count: an unknown one, a path, an extra word or a
# trailing comment leaves the line out; the last line needs no newline.
printf '%s\n' 'backlight-future panel-bl' 'backlight-prefer ../panel-bl' 'backlight-prefer panel-bl extra' \
  'backlight-skip acpi_video0 # comment' >"$platform_root/displays.conf"
printf 'backlight-prefer last-bl' >>"$platform_root/displays.conf"
write_backlights acpi_video0 last-bl panel-bl
device=$(hw_display)
[[ $device == "last-bl" ]] || fail "malformed directives are ignored and the last line is read" "actual: $device"
write_displays_conf 'backlight-skip acpi_video0 # comment'
write_backlights acpi_video0
device=$(hw_display)
[[ $device == "acpi_video0" ]] || fail "a directive with a trailing comment is ignored" "actual: $device"
pass "malformed directives are ignored and the last line is read"
