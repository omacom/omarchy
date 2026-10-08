#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

drm_path="$test_tmp/drm"

# Each "card" argument is vendor[:connector=status,connector=status,...], e.g.
# "0x10de" for a card with no connectors, or "0x1002:DP-1=connected" for one
# connector. Multiple connectors are comma-separated.
write_cards() {
  rm -rf "$drm_path"
  mkdir -p "$drm_path"

  local index=0 card vendor connectors connector_spec connector status
  for card in "$@"; do
    vendor="${card%%:*}"
    mkdir -p "$drm_path/card$index/device"
    printf '%s\n' "$vendor" >"$drm_path/card$index/device/vendor"

    if [[ $card == *:* ]]; then
      connectors="${card#*:}"
      IFS=',' read -ra connector_specs <<<"$connectors"
      for connector_spec in "${connector_specs[@]}"; do
        connector="${connector_spec%%=*}"
        status="${connector_spec#*=}"
        mkdir -p "$drm_path/card$index-$connector"
        printf '%s\n' "$status" >"$drm_path/card$index-$connector/status"
      done
    fi

    index=$((index + 1))
  done
}

sole_active_gpu() {
  OMARCHY_DRM_PATH="$drm_path" "$ROOT/bin/omarchy-hw-nvidia-sole-active-gpu"
}

write_cards
if sole_active_gpu; then
  fail "an empty DRM tree has no sole active GPU to report"
fi
pass "empty DRM tree reports nothing"

write_cards "0x1002:DP-1=disconnected"
if sole_active_gpu; then
  fail "a system with no NVIDIA GPU has nothing to pin"
fi
pass "no NVIDIA GPU reports nothing"

write_cards "0x10de:DP-1=connected"
if sole_active_gpu; then
  fail "a single NVIDIA GPU is already the only GPU; nothing to fix"
fi
pass "NVIDIA-only system reports nothing (already the sole GPU)"

write_cards "0x10de" "0x10de"
if sole_active_gpu; then
  fail "two NVIDIA GPUs are ambiguous; must not guess"
fi
pass "two NVIDIA GPUs reports nothing (ambiguous)"

# The exact bug report: a desktop with an idle AMD iGPU (no monitor plugged
# into its ports) and NVIDIA driving every display.
write_cards "0x1002:DP-1=disconnected,HDMI-A-1=disconnected" "0x10de:DP-1=connected,DP-2=connected"
output=$(sole_active_gpu) || fail "idle iGPU + active NVIDIA should report the NVIDIA card"
[[ $output == "/dev/dri/card1" ]] || fail "idle iGPU + active NVIDIA" "expected /dev/dri/card1, got $output"
pass "idle AMD iGPU alongside an active NVIDIA dGPU reports the NVIDIA card"

# A laptop with the panel wired to the iGPU must be left alone, even though
# NVIDIA is also present as an offload GPU.
write_cards "0x8086:eDP-1=connected" "0x10de"
if sole_active_gpu; then
  fail "a laptop panel on the iGPU must not be overridden"
fi
pass "laptop panel wired to the iGPU is left alone"

# A monitor plugged into the iGPU's own ports on a desktop must also be left
# alone, even if NVIDIA drives other monitors.
write_cards "0x1002:DP-1=connected" "0x10de:DP-1=connected"
if sole_active_gpu; then
  fail "a monitor on the iGPU's own port must not be overridden"
fi
pass "a monitor plugged into the iGPU's own port is left alone"

# Card indices are not guaranteed to be contiguous or start at 0.
write_cards_at_indices() {
  rm -rf "$drm_path"
  mkdir -p "$drm_path"
}

write_cards_at_indices
mkdir -p "$drm_path/card0/device" "$drm_path/card0-DP-1" "$drm_path/card2/device" "$drm_path/card2-DP-1"
printf '0x1002\n' >"$drm_path/card0/device/vendor"
printf 'disconnected\n' >"$drm_path/card0-DP-1/status"
printf '0x10de\n' >"$drm_path/card2/device/vendor"
printf 'connected\n' >"$drm_path/card2-DP-1/status"
output=$(sole_active_gpu) || fail "a gap in card numbering should still resolve"
[[ $output == "/dev/dri/card2" ]] || fail "gapped card numbering" "expected /dev/dri/card2, got $output"
pass "a gap in card numbering (card0, card2) still resolves correctly"

# card1 and card10 share the "card1" prefix; card10's own connectors must not
# be read as card1's, and vice versa.
write_cards_at_indices
mkdir -p "$drm_path/card1/device" "$drm_path/card1-DP-1" "$drm_path/card10/device" "$drm_path/card10-DP-1"
printf '0x10de\n' >"$drm_path/card1/device/vendor"
printf 'connected\n' >"$drm_path/card1-DP-1/status"
printf '0x1002\n' >"$drm_path/card10/device/vendor"
printf 'disconnected\n' >"$drm_path/card10-DP-1/status"
output=$(sole_active_gpu) || fail "card1 vs card10 prefix collision should not confuse connector matching"
[[ $output == "/dev/dri/card1" ]] || fail "card1/card10 prefix collision" "expected /dev/dri/card1, got $output"
pass "card1 and card10 connectors are not cross-matched by prefix"

write_cards_at_indices
mkdir -p "$drm_path/card1/device" "$drm_path/card1-DP-1" "$drm_path/card10/device" "$drm_path/card10-DP-1"
printf '0x10de\n' >"$drm_path/card1/device/vendor"
printf 'disconnected\n' >"$drm_path/card1-DP-1/status"
printf '0x1002\n' >"$drm_path/card10/device/vendor"
printf 'connected\n' >"$drm_path/card10-DP-1/status"
if sole_active_gpu; then
  fail "card10's own connected connector must still block the override"
fi
pass "card10 (the other GPU) having a connected connector still blocks the override"

# End-to-end: the real default/hypr/nvidia.lua, with both the PCI fixture its
# existing GSP/display detectors read and the DRM fixture this detector reads,
# must land AQ_DRM_DEVICES in Hyprland's environment.
require_command lua

pci_path="$test_tmp/pci"
mkdir -p "$pci_path/0"
printf '0x10de\n' >"$pci_path/0/vendor"
printf '0x1f91\n' >"$pci_path/0/device" # Turing: has GSP firmware
printf '0x030000\n' >"$pci_path/0/class"

write_cards "0x1002:DP-1=disconnected" "0x10de:DP-1=connected"

actual_env=$(
  OMARCHY_PCI_DEVICES_PATH="$pci_path" OMARCHY_DRM_PATH="$drm_path" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
require("default.hypr.helpers")
local env = {}
hl = { env = function(key, value) env[key] = value end }
require("default.hypr.nvidia")
print(env.AQ_DRM_DEVICES or "-")
LUA
)
[[ $actual_env == "/dev/dri/card1" ]] || fail "nvidia.lua end-to-end" "expected /dev/dri/card1, got $actual_env"
pass "default/hypr/nvidia.lua sets AQ_DRM_DEVICES end-to-end on an idle-iGPU + active-NVIDIA desktop"
