#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export OMARCHY_PATH="$ROOT"

# Exercise the real scripts against stubbed hardware.
lspci() { echo "00:02.0 VGA compatible controller: $gpu"; }
omarchy-hw-vm() { [[ $vm == "yes" ]]; }
omarchy-hw-nvidia() { [[ $gpu == NVIDIA* ]]; }
omarchy-hw-aarch64-qualcomm() { false; }
omarchy-pkg-missing() { true; }
omarchy-pkg-add() { printf '%s\n' "$*" >>"$scratch/packages"; }

for entry in "$ROOT/install/hardware/vulkan.sh" "$ROOT/migrations/1792254894.sh"; do
  for vm in yes no; do
    for gpu in "Red Hat, Inc. Virtio 1.0 GPU" "NVIDIA Corporation AD104" "Intel Corporation Arc"; do
      rm -f "$scratch/packages"
      source "$entry" >/dev/null
      if [[ $vm == "yes" && $gpu == Red* ]]; then
        [[ $(cat "$scratch/packages" 2>/dev/null) == "vulkan-swrast" ]] || fail "a VM with no Vulkan GPU gets the CPU driver" "$entry"
      else
        ! grep -qx 'vulkan-swrast' "$scratch/packages" 2>/dev/null || fail "only a VM with no Vulkan GPU gets the CPU driver" "$entry $vm $gpu"
      fi
    done
  done
done
pass "the CPU Vulkan driver is installed only in VMs with no Vulkan GPU"

# lspci wakes runtime-suspended GPUs, so the migration leaves bare metal alone.
lspci() { touch "$scratch/lspci"; }
vm=no
source "$ROOT/migrations/1792254894.sh" >/dev/null
[[ ! -e $scratch/lspci ]] || fail "the migration probes PCI only in a VM"
pass "the migration does not wake the GPUs of a machine that is not a VM"

grep -Fxq 'vulkan-swrast' "$ROOT/install/omarchy-other.packages" || fail "ISO can supply the CPU Vulkan driver offline"
pass "the CPU Vulkan driver is included in the offline package inventory"
