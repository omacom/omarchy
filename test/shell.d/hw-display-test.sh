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

# omarchy-hw-external-monitors: a connected connector that is not a built-in
# panel counts as an external display.
drm_path="$tmp_dir/drm"

write_connectors() {
  rm -rf "$drm_path"
  mkdir -p "$drm_path"

  local connector state
  while (( $# )); do
    connector="$1"
    state="$2"
    mkdir -p "$drm_path/card0-$connector"
    printf '%s\n' "$state" >"$drm_path/card0-$connector/status"
    shift 2
  done
}

has_external_monitor() {
  OMARCHY_DRM_PATH="$drm_path" "$ROOT/bin/omarchy-hw-external-monitors"
}

write_connectors
set +e
empty_error=$(has_external_monitor 2>&1 >/dev/null)
empty_status=$?
set -e

(( empty_status != 0 )) || fail "an empty DRM tree has no external display"
[[ -z $empty_error ]] || fail "an empty DRM tree is handled quietly" "$empty_error"
pass "physical monitor detection handles an empty DRM tree"

for connector in eDP-1 LVDS-1 DSI-1; do
  write_connectors "$connector" connected

  if has_external_monitor; then
    fail "$connector is treated as an internal display"
  fi
done
pass "physical monitor detection ignores common internal panel connectors"

write_connectors LVDS-1 connected DP-1 connected
has_external_monitor || fail "external display is found alongside an LVDS panel"
pass "physical monitor detection finds an external display alongside an LVDS panel"

write_connectors eDP-1 connected HDMI-A-1 disconnected
if has_external_monitor; then
  fail "a disconnected external display is not reported as connected"
fi
pass "physical monitor detection ignores disconnected external displays"

write_connectors DP-1 connected
has_external_monitor || fail "external-only systems still report a connected display"
pass "physical monitor detection still supports external-only systems"

# Hyprland can list the Apple Touch Bar's DSI connector before the laptop
# panel. Use the real laptop/helper/lid/clamshell chain with fixture DRM and
# compositor boundaries; no installed config or running compositor is touched.
monitors_json="$tmp_dir/monitors.json"
monitor_calls="$tmp_dir/monitor-calls"
cat >"$tmp_dir/bin/hyprctl" <<'STUB'
#!/bin/bash
if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  cat "$TEST_MONITORS_JSON"
else
  printf '%s\n' "$*" >>"$TEST_MONITOR_CALLS"
fi
STUB
chmod +x "$tmp_dir/bin/hyprctl"

write_drm_card() {
  local card=$1 driver=$2 connector=$3 state=$4
  mkdir -p "$drm_path/$card/device" "$drm_path/$card-$connector"
  printf '%s\n' "$state" >"$drm_path/$card-$connector/status"
  if [[ $driver != "unknown" ]]; then
    printf 'DRIVER=%s\nOF_NAME=display-pipe\n' "$driver" >"$drm_path/$card/device/uevent"
  fi
}

laptop_output() {
  OMARCHY_DRM_PATH="$drm_path" TEST_MONITORS_JSON="$monitors_json" \
    PATH="$tmp_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-hyprland-monitor-laptop"
}

expect_laptop() {
  local expected=$1 description=$2 actual
  actual=$(laptop_output)
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected, actual: $actual"
  pass "$description"
}

write_connectors
write_drm_card card17 adp DSI-1 connected
write_drm_card card3 apple-drm eDP-1 connected
printf '%s\n' '[{"name":"DSI-1","disabled":false,"scale":1},{"name":"eDP-1","disabled":true,"scale":2}]' >"$monitors_json"
expect_laptop eDP-1 "the Touch Bar listed first does not hide a disabled laptop panel"
printf 'DRIVER=appletbdrm\n' >"$drm_path/card17/device/uevent"
expect_laptop eDP-1 "the appletbdrm Touch Bar is also excluded"
printf 'DRIVER=panel-driver\n' >"$drm_path/card17/device/uevent"
expect_laptop DSI-1 "a genuine DSI laptop panel is retained"
rm "$drm_path/card17/device/uevent"
expect_laptop DSI-1 "missing driver evidence preserves the original connector fallback"
rm -rf "$drm_path"
mkdir "$drm_path"
expect_laptop DSI-1 "missing sysfs preserves the original connector fallback"
write_drm_card card17 adp DSI-1 connected
write_drm_card card9 panel-driver DSI-1 connected
expect_laptop DSI-1 "an ambiguous same-name real panel is retained"
printf 'DRIVER=appletbdrm\n' >"$drm_path/card9/device/uevent"
write_drm_card card3 apple-drm eDP-1 connected
expect_laptop eDP-1 "only confirmed Touch Bar cards are excluded for a shared connector name"
printf '%s\n' '[{"name":"DSI-1","disabled":false}]' >"$monitors_json"
expect_laptop "" "a Touch Bar alone is not a laptop display"
printf '%s\n' '[{"name":"LVDS-1","disabled":false}]' >"$monitors_json"
expect_laptop LVDS-1 "ordinary LVDS panel discovery is unchanged"
printf '%s\n' '[{"name":"eDP-1","disabled":false}]' >"$monitors_json"
expect_laptop eDP-1 "ordinary eDP panel discovery is unchanged"

# Recover helpers are unrelated manual/mirror state machines. Keep those and
# compositor reloads at the boundary; all panel, lid and docking decisions below
# use the actual commands from this checkout.
for command in omarchy-hyprland-monitor-internal omarchy-hyprland-monitor-internal-mirror; do
  printf '#!/bin/bash\nexit 0\n' >"$tmp_dir/bin/$command"
done
for command in omarchy-restart-hyprctl omarchy-system-lock; do
  printf '#!/bin/bash\nprintf "%%s\\n" "%s" >>"$TEST_MONITOR_CALLS"\n' "$command" >"$tmp_dir/bin/$command"
done
chmod +x "$tmp_dir/bin/"*
lid_home="$tmp_dir/lid-home"
mkdir -p "$lid_home/.config/hypr" "$tmp_dir/lid/LID0" "$tmp_dir/input"
printf 'hl.monitor({ output = "eDP-1", mode = "preferred", scale = 2 })\n' >"$lid_home/.config/hypr/monitors.lua"
export HOME="$lid_home" OMARCHY_DRM_PATH="$drm_path" OMARCHY_ACPI_LID_PATH="$tmp_dir/lid" OMARCHY_INPUT_CLASS_PATH="$tmp_dir/input"
export TEST_MONITORS_JSON="$monitors_json" TEST_MONITOR_CALLS="$monitor_calls"
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
flag="$lid_home/.local/state/omarchy/toggles/hypr/internal-monitor-clamshell.lua"
write_drm_card card3 apple-drm DP-2 connected
printf '%s\n' '[{"name":"DSI-1","disabled":false,"scale":1},{"name":"eDP-1","disabled":false,"scale":2},{"name":"DP-2","disabled":false,"scale":1}]' >"$monitors_json"
printf 'state: closed\n' >"$tmp_dir/lid/LID0/state"
: >"$monitor_calls"
"$ROOT/bin/omarchy-system-lid-close"
[[ -f $flag && $(<"$flag") == 'hl.monitor({ output = "eDP-1", disabled = true })' ]] || fail "docked lid close disables the laptop panel, not the Touch Bar"
! grep -q omarchy-system-lock "$monitor_calls" || fail "a real external display keeps the docked session unlocked"
pass "docked lid close targets the real panel with the Touch Bar listed first"
printf 'state: open\n' >"$tmp_dir/lid/LID0/state"
"$ROOT/bin/omarchy-hyprland-monitor-clamshell"
[[ ! -e $flag ]] || fail "reopening the lid removes the real panel's clamshell override"
grep -F 'monitor = "eDP-1"' "$monitor_calls" >/dev/null || fail "reopening wakes the real panel"
pass "reopening restores the real panel after a Touch Bar-first lid close"
printf 'disconnected\n' >"$drm_path/card3-DP-2/status"
printf '%s\n' '[{"name":"DSI-1","disabled":false,"scale":1},{"name":"eDP-1","disabled":false,"scale":2}]' >"$monitors_json"
printf 'state: closed\n' >"$tmp_dir/lid/LID0/state"
: >"$monitor_calls"
"$ROOT/bin/omarchy-system-lid-close"
[[ ! -e $flag ]] || fail "the Touch Bar must not count as an external display for clamshell"
grep -q omarchy-system-lock "$monitor_calls" || fail "undocked lid close still locks before logind handles sleep"
pass "Touch Bar without an external display does not trigger clamshell"
