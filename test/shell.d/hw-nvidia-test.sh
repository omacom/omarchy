#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Each argument is a PCI device as "vendor:device:class", in sysfs's own format.
write_pci_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$tmp_dir/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$tmp_dir/devices/$slot/vendor"
    printf '%s\n' "$(cut -d: -f2 <<<"$spec")" >"$tmp_dir/devices/$slot/device"
    printf '%s\n' "${spec##*:}" >"$tmp_dir/devices/$slot/class"
    index=$((index + 1))
  done
}

hw_nvidia() {
  OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" "$ROOT/bin/omarchy-hw-$1"
}

assert_detects() {
  local description="$1" nvidia="$2" gsp="$3" without_gsp="$4"

  local command
  for command in nvidia gsp without-gsp; do
    local expected
    case $command in
      nvidia) expected=$nvidia ;;
      gsp) expected=$gsp ;;
      without-gsp) expected=$without_gsp ;;
    esac

    local detector=nvidia
    [[ $command == "nvidia" ]] || detector="nvidia-$command"

    local actual=no
    hw_nvidia "$detector" && actual=yes

    [[ $actual == "$expected" ]] ||
      fail "$description" "omarchy-hw-$detector: expected $expected, got $actual"
  done

  pass "$description"
}

# AMD Cezanne integrated graphics.
write_pci_devices 0x1002:0x15e7:0x030000
assert_detects "a machine without an NVIDIA GPU detects nothing" no no no

# NVIDIA GA106M [RTX 3060 Mobile] alongside AMD Cezanne, the pair from issue #6660.
write_pci_devices 0x1002:0x15e7:0x030000 0x10de:0x2560:0x030200
assert_detects "a hybrid Ampere laptop detects a GSP GPU" yes yes no

# NVIDIA TU117M [GTX 1650 Mobile], the first generation with GSP firmware.
write_pci_devices 0x10de:0x1f91:0x030000
assert_detects "Turing is the oldest generation with GSP firmware" yes yes no

# NVIDIA GV100 [TITAN V], the newest generation without GSP firmware.
write_pci_devices 0x10de:0x1d81:0x030000
assert_detects "Volta is the newest generation without GSP firmware" yes no yes

# NVIDIA GP104 [GTX 1080].
write_pci_devices 0x10de:0x1b80:0x030000
assert_detects "Pascal detects a GPU without GSP firmware" yes no yes

# NVIDIA GM108M [GeForce 830M], the oldest part the 580xx driver supports.
write_pci_devices 0x10de:0x1340:0x030000
assert_detects "Maxwell detects a GPU without GSP firmware" yes no yes

# NVIDIA GK110 [GTX 780]. Kepler predates GSP but also predates 580xx, so
# claiming it here would install a driver that cannot drive it.
write_pci_devices 0x10de:0x1004:0x030000
assert_detects "Kepler is too old for either driver" yes no no

# NVIDIA GF100 [GTX 470], older still.
write_pci_devices 0x10de:0x06cd:0x030000
assert_detects "Fermi is too old for either driver" yes no no

# NVIDIA GB203 [RTX 5080], newer than every other device ID here.
write_pci_devices 0x10de:0x2c02:0x030000
assert_detects "Blackwell detects a GSP GPU" yes yes no

# The GA106 audio function carries the NVIDIA vendor ID but is not a GPU.
write_pci_devices 0x10de:0x228e:0x040300
assert_detects "a non-display NVIDIA function is not a GPU" no no no

write_pci_devices
assert_detects "a machine with no PCI devices detects nothing" no no no

# --- omarchy-hw-nvidia-drives-display (issue #10410) ---
# Fake DRM tree: cardN/device/vendor + cardN-NAME/status, with device → cardN.

drm_root="$tmp_dir/drm"

write_drm_tree() {
  # Args: pairs of "cardN:vendor" then connector specs "cardN-NAME:status"
  rm -rf "$drm_root"
  mkdir -p "$drm_root"

  local arg
  for arg in "$@"; do
    if [[ $arg == card[0-9]:* ]]; then
      local card=${arg%%:*}
      local vendor=${arg#*:}
      mkdir -p "$drm_root/$card/device"
      printf '%s\n' "$vendor" >"$drm_root/$card/device/vendor"
    elif [[ $arg == card[0-9]-* ]]; then
      local conn=${arg%%:*}
      local status=${arg#*:}
      local card=${conn%%-*}
      mkdir -p "$drm_root/$conn"
      printf '%s\n' "$status" >"$drm_root/$conn/status"
      ln -sfn "../$card" "$drm_root/$conn/device"
    fi
  done
}

drives_display() {
  OMARCHY_DRM_PATH="$drm_root" "$ROOT/bin/omarchy-hw-nvidia-drives-display"
}

assert_drives() {
  local description=$1 expected=$2
  local actual=no
  drives_display && actual=yes
  [[ $actual == "$expected" ]] ||
    fail "$description" "omarchy-hw-nvidia-drives-display: expected $expected, got $actual"
  pass "$description"
}

# Hybrid: NVIDIA present but all its connectors disconnected; iGPU panel connected.
write_drm_tree \
  card0:0x10de card1:0x1002 \
  card0-DP-1:disconnected card0-HDMI-A-1:disconnected \
  card1-eDP-1:connected
assert_drives "hybrid with idle NVIDIA dGPU does not drive the display" no

# Same hybrid with an external plugged into the NVIDIA card.
write_drm_tree \
  card0:0x10de card1:0x1002 \
  card0-DP-1:connected card0-HDMI-A-1:disconnected \
  card1-eDP-1:connected
assert_drives "hybrid with NVIDIA-connected external drives the display" yes

# NVIDIA-only desktop with a connected panel.
write_drm_tree \
  card0:0x10de \
  card0-DP-1:connected
assert_drives "NVIDIA-only machine with a connected output drives the display" yes

# NVIDIA card with no connectors at all.
write_drm_tree card0:0x10de
assert_drives "NVIDIA card with no connectors does not drive the display" no

# No NVIDIA card.
write_drm_tree \
  card0:0x8086 \
  card0-eDP-1:connected
assert_drives "Intel-only machine does not report NVIDIA driving the display" no

# Empty DRM tree.
write_drm_tree
assert_drives "empty DRM tree does not report NVIDIA driving the display" no
