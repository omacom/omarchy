#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"

# Each argument is a PCI device as "vendor:class", in sysfs's own format.
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
    printf '%s\n' "${spec##*:}" >"$tmp_dir/devices/$slot/class"
    index=$((index + 1))
  done
}

# Build a DRM tree under $tmp_dir/drm. Args are "pci-index:connector:status"
# where pci-index matches write_pci_devices order. Connectors without a status
# file model writeback-only outputs. Multiple connectors for the same PCI
# index share one card directory.
write_drm_cards() {
  rm -rf "$tmp_dir/drm"
  mkdir -p "$tmp_dir/drm"

  local -A card_for_pci=()
  local next_card=0
  local spec pci_index connector status slot card card_index

  for spec in "$@"; do
    IFS=: read -r pci_index connector status <<<"$spec"
    slot=$(printf '0000:%02x:00.0' "$pci_index")

    if [[ -z ${card_for_pci[$pci_index]+x} ]]; then
      card_for_pci[$pci_index]=$next_card
      next_card=$((next_card + 1))
    fi
    card_index=${card_for_pci[$pci_index]}
    card="$tmp_dir/drm/card$card_index"

    if [[ ! -e $card/device ]]; then
      mkdir -p "$card"
      ln -s "$tmp_dir/devices/$slot" "$card/device"
    fi

    mkdir -p "$card/card$card_index-$connector"
    if [[ -n $status ]]; then
      printf '%s\n' "$status" >"$card/card$card_index-$connector/status"
    fi
  done
}

# Sources the hook config the way mkinitcpio does — with earlier drop-ins
# already applied — and prints the resulting HOOKS. mkinitcpio does not run
# under set -u, but the config must survive it, so source under it anyway.
# "unset" leaves MODULES undeclared entirely.
resolved_hooks() {
  local modules_decl=""
  [[ $1 == "unset" ]] || modules_decl="MODULES=($1)"

  # The vconsole block sources the host's /etc/vconsole.conf, which may set
  # only KEYMAP; predefine XKBLAYOUT so its expansion survives set -u and the
  # test stays independent of the machine it runs on.
  OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" \
  OMARCHY_DRM_PATH="$tmp_dir/drm" \
  bash -uc "
    FILES=()
    XKBLAYOUT=us
    $modules_decl
    source '$hooks_conf'
    echo \"\${HOOKS[*]}\"
  "
}

nvidia_modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

write_pci_devices
rm -rf "$tmp_dir/drm"
mkdir -p "$tmp_dir/drm"
with_kms=$(resolved_hooks "")
without_kms=${with_kms/ kms / }

[[ $with_kms == *" kms "* ]] ||
  fail "baseline HOOKS contains the kms hook" "actual: $with_kms"
pass "baseline HOOKS contains the kms hook"

assert_hooks() {
  local description="$1" modules="$2" expected="$3"
  local actual
  actual=$(resolved_hooks "$modules")

  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

# NVIDIA RTX class display controller.
write_pci_devices 0x10de:0x030000
write_drm_cards "0:DP-1:connected"
assert_hooks "nvidia-only system with early nvidia_drm drops only kms" \
  "$nvidia_modules" "$without_kms"
assert_hooks "nvidia-only system without early nvidia_drm keeps kms" \
  "" "$with_kms"
assert_hooks "unset MODULES under set -u keeps kms without erroring" \
  "unset" "$with_kms"

# AMD integrated graphics with a connected panel next to an NVIDIA 3D controller.
write_pci_devices 0x1002:0x030000 0x10de:0x030200
write_drm_cards "0:eDP-1:connected" "1:DP-1:connected"
assert_hooks "hybrid system keeps kms for the connected iGPU" \
  "$nvidia_modules" "$with_kms"

# Desktop: AMD iGPU present but idle (writeback only), displays on NVIDIA.
write_pci_devices 0x1002:0x030000 0x10de:0x030000
write_drm_cards "0:Writeback-1:" "1:DP-1:connected" "1:DP-2:connected"
assert_hooks "desktop with idle iGPU drops kms" \
  "$nvidia_modules" "$without_kms"

# Same PCI layout, but the iGPU has a connected output — keep kms.
write_pci_devices 0x1002:0x030000 0x10de:0x030000
write_drm_cards "0:HDMI-A-1:connected" "1:DP-1:connected"
assert_hooks "non-NVIDIA GPU with a connected output keeps kms" \
  "$nvidia_modules" "$with_kms"

# Idle iGPU whose DRM card is missing entirely: inconclusive, keep kms.
write_pci_devices 0x1002:0x030000 0x10de:0x030000
write_drm_cards "1:DP-1:connected"
assert_hooks "iGPU without a DRM card keeps kms" \
  "$nvidia_modules" "$with_kms"

# NVIDIA audio function only: no display controller found.
write_pci_devices 0x10de:0x040300
write_drm_cards
assert_hooks "no display controller found keeps kms" \
  "$nvidia_modules" "$with_kms"

write_pci_devices
write_drm_cards
assert_hooks "empty PCI tree keeps kms" \
  "$nvidia_modules" "$with_kms"

# A device directory missing its class/vendor attributes must not error, and
# counts as inconclusive: it could be another GPU, so kms stays.
write_pci_devices
write_drm_cards
mkdir -p "$tmp_dir/devices/0000:00:00.0"
assert_hooks "unreadable PCI device keeps kms" \
  "$nvidia_modules" "$with_kms"

# Even next to a readable NVIDIA GPU — the unreadable device may be the iGPU.
write_pci_devices 0x10de:0x030000
write_drm_cards "0:DP-1:connected"
mkdir -p "$tmp_dir/devices/0000:01:00.0"
assert_hooks "unreadable device beside an NVIDIA GPU keeps kms" \
  "$nvidia_modules" "$with_kms"
