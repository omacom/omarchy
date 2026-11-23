#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" OMARCHY_DRM_PATH="$tmp_dir/drm" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH"

# Exit statuses, expected NVD_BACKEND/LIBVA/GLX/GSK_RENDERER values, then vendor:device:class[:boot_vga].
# Optional fields: card:connector:status:vendor DRM fixtures, then the cards AQ_DRM_DEVICES names, colon-separated.
while IFS='|' read -r description nvidia gsp without_gsp display expected_env devices connectors aq_cards; do
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"
  slot=0
  for spec in $devices; do
    IFS=: read -r vendor device class boot_vga <<<"$spec"
    device_dir="$tmp_dir/devices/$slot"
    mkdir -p "$device_dir"
    printf '%s\n' "$vendor" >"$device_dir/vendor"
    printf '%s\n' "$device" >"$device_dir/device"
    printf '%s\n' "$class" >"$device_dir/class"
    if [[ -n $boot_vga ]]; then
      printf '%s\n' "$boot_vga" >"$device_dir/boot_vga"
    fi
    slot=$((slot + 1))
  done

  rm -rf "$tmp_dir/drm"
  mkdir -p "$tmp_dir/drm"
  for spec in $connectors; do
    IFS=: read -r card connector status vendor <<<"$spec"
    mkdir -p "$tmp_dir/drm/$card-$connector" "$tmp_dir/drm/$card/device"
    printf '%s\n' "$status" >"$tmp_dir/drm/$card-$connector/status"
    printf '%s\n' "$vendor" >"$tmp_dir/drm/$card/device/vendor"
  done

  # Device nodes exist only for cards with DRM fixtures, so other names are missing entries.
  rm -rf "$tmp_dir/dev"
  mkdir -p "$tmp_dir/dev"
  unset AQ_DRM_DEVICES
  if [[ -n $aq_cards ]]; then
    aq_devices=()
    IFS=: read -ra cards <<<"$aq_cards"
    for card in "${cards[@]}"; do
      if [[ -d $tmp_dir/drm/$card ]]; then
        touch "$tmp_dir/dev/$card"
      fi
      aq_devices+=("$tmp_dir/dev/$card")
    done
    export AQ_DRM_DEVICES=$(IFS=:; printf '%s' "${aq_devices[*]}")
  fi

  for check in "nvidia:$nvidia" "nvidia-gsp:$gsp" "nvidia-without-gsp:$without_gsp" "nvidia-display:$display"; do
    status=0
    "omarchy-hw-${check%:*}" || status=$?
    [[ $status == "${check#*:}" ]] || fail "$description: ${check%:*}" "expected ${check#*:}, got $status"
  done

  # Run the real Lua config and detectors; capture only Hyprland's env calls.
  actual_env=$(lua - <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
require("default.hypr.helpers")
local env = {}
hl = { env = function(key, value) env[key] = value end }
require("default.hypr.nvidia")
print(table.concat({ env.NVD_BACKEND or "-", env.LIBVA_DRIVER_NAME or "-", env.__GLX_VENDOR_LIBRARY_NAME or "-", env.GSK_RENDERER or "-" }, " "))
LUA
  )
  [[ $actual_env == "$expected_env" ]] || fail "$description: driver environment" "expected $expected_env, got $actual_env"
  pass "$description"
done <<'CASES'
AMD only|1|1|1|1|- - - -|0x1002:0x15e7:0x030000:1
NVIDIA audio only|1|1|1|0|- - - -|0x10de:0x228e:0x040300
No PCI devices|1|1|1|0|- - - -|
Turing (first GSP)|0|0|1|0|direct nvidia nvidia gl|0x10de:0x1f91:0x030000
Volta (last without GSP)|0|1|0|0|egl - nvidia gl|0x10de:0x1d81:0x030000
Maxwell (first 580xx)|0|1|0|0|egl - nvidia gl|0x10de:0x1340:0x030000
Kepler (unsupported)|0|1|1|0|- - - gl|0x10de:0x1004:0x030000
AMD display with Ampere offload|0|0|1|1|direct - - gl|0x1002:0x15bf:0x030000:1 0x10de:0x25ac:0x030200:0
Intel display with Maxwell offload|0|1|0|1|egl - - gl|0x8086:0x46a6:0x030000:1 0x10de:0x1340:0x030000:0
NVIDIA display with inactive iGPU|0|0|1|0|direct nvidia nvidia gl|0x1002:0x15bf:0x030000:0 0x10de:0x2c02:0x030000:1
Hybrid without boot_vga|0|0|1|0|direct nvidia nvidia gl|0x1002:0x15e7:0x030000 0x10de:0x2560:0x030200
Intel panel despite NVIDIA boot GPU|0|0|1|1|direct - - gl|0x8086:0x46a6:0x030000:0 0x10de:0x25ac:0x030000:1|card0:eDP-1:connected:0x8086 card1:HDMI-A-1:disconnected:0x10de
Intel boot GPU with its only monitor on NVIDIA|0|0|1|1|direct - - gl|0x8086:0x46a6:0x030000:1 0x10de:0x25ac:0x030000:0|card0:eDP-1:disconnected:0x8086 card12:HDMI-A-1:connected:0x10de
NVIDIA boot GPU with its only monitor on Intel|0|0|1|0|direct nvidia nvidia gl|0x8086:0x46a6:0x030000:0 0x10de:0x25ac:0x030000:1|card0:DP-1:connected:0x8086 card1:DP-2:disconnected:0x10de
Docked hybrid laptop with Intel boot GPU|0|0|1|1|direct - - gl|0x8086:0x46a6:0x030000:1 0x10de:0x25ac:0x030000:0|card0:eDP-1:connected:0x8086 card1:DP-1:connected:0x10de
Both GPUs connected with NVIDIA boot GPU|0|0|1|0|direct nvidia nvidia gl|0x8086:0x46a6:0x030000:0 0x10de:0x25ac:0x030000:1|card0:DP-2:connected:0x8086 card1:DP-1:connected:0x10de
Strix Point panel without boot_vga|0|0|1|1|direct - - gl|0x1002:0x150e:0x038000 0x10de:0x25ac:0x030000:0|card2:eDP-1:connected:0x1002 card1:HDMI-A-1:disconnected:0x10de
Strix Point panel beside a monitor on an NVIDIA port|0|0|1|1|direct - - gl|0x1002:0x150e:0x038000 0x10de:0x25ac:0x030000:0|card1:HDMI-A-1:connected:0x10de card2:DP-3:connected:0x1002 card2:eDP-1:connected:0x1002
NVIDIA panel beside a monitor on an Intel boot GPU|0|0|1|0|direct nvidia nvidia gl|0x8086:0x46a6:0x030000:1 0x10de:0x25ac:0x030000:0|card1:eDP-1:connected:0x10de card0:DP-1:connected:0x8086
Intel panel beside a monitor on an NVIDIA boot GPU|0|0|1|1|direct - - gl|0x8086:0x46a6:0x030000:0 0x10de:0x25ac:0x030000:1|card0:eDP-1:connected:0x8086 card1:DP-1:connected:0x10de
More Intel panels than NVIDIA panels with NVIDIA boot GPU|0|0|1|1|direct - - gl|0x8086:0x46a6:0x030000:0 0x10de:0x25ac:0x030000:1|card0:eDP-1:connected:0x8086 card0:eDP-2:connected:0x8086 card1:eDP-1:connected:0x10de
More NVIDIA panels than Intel panels with Intel boot GPU|0|0|1|0|direct nvidia nvidia gl|0x8086:0x46a6:0x030000:1 0x10de:0x25ac:0x030000:0|card0:eDP-1:connected:0x8086 card11:eDP-1:connected:0x10de card11:DSI-1:connected:0x10de
Intel panel with Maxwell offload|0|1|0|1|egl - - gl|0x8086:0x46a6:0x030000:0 0x10de:0x1340:0x030000:1|card0:eDP-1:connected:0x8086
Disconnected connectors retain Intel boot fallback|0|0|1|1|direct - - gl|0x8086:0x46a6:0x030000:1 0x10de:0x25ac:0x030000:0|card0:eDP-1:disconnected:0x8086 card1:DP-1:disconnected:0x10de
Disconnected connectors retain NVIDIA boot fallback|0|0|1|0|direct nvidia nvidia gl|0x8086:0x46a6:0x030000:0 0x10de:0x25ac:0x030000:1|card0:eDP-1:disconnected:0x8086 card1:DP-1:disconnected:0x10de
AQ_DRM_DEVICES picks Intel over an NVIDIA panel|0|0|1|1|direct - - gl|0x8086:0x46a6:0x030000:1 0x10de:0x25ac:0x030000:0|card1:eDP-1:connected:0x10de card0:DP-1:disconnected:0x8086|card7:card0
AQ_DRM_DEVICES picks NVIDIA over an Intel panel|0|0|1|0|direct nvidia nvidia gl|0x8086:0x46a6:0x030000:1 0x10de:0x25ac:0x030000:0|card0:eDP-1:connected:0x8086 card1:DP-1:connected:0x10de|card1
Disconnected connectors without boot_vga retain permissive fallback|0|0|1|0|direct nvidia nvidia gl|0x8086:0x46a6:0x030000 0x10de:0x25ac:0x030000|card0:eDP-1:disconnected:0x8086 card1:DP-1:disconnected:0x10de
CASES
