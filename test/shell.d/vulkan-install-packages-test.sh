#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

assert_packages() {
  local description="$1" vm="$2" gpu="$3" expected="$4"
  local actual
  actual=$(TEST_VM="$vm" TEST_GPU="$gpu" bash -euo pipefail -c '
    lspci() { printf "%s\n" "00:02.0 VGA compatible controller: $TEST_GPU"; }
    omarchy-hw-vm() { [[ $TEST_VM == "yes" ]]; }
    omarchy-hw-nvidia() { [[ $TEST_GPU == NVIDIA* ]]; }
    omarchy-hw-aarch64-qualcomm() { return 1; }
    omarchy-pkg-add() { printf "%s\n" "$*"; }
    source "$ROOT/install/hardware/vulkan.sh"
  ')
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected; actual: $actual"
  pass "$description"
}

assert_packages "a virtio GPU in a VM gets the CPU Vulkan driver" yes "Red Hat, Inc. Virtio 1.0 GPU" vulkan-swrast
assert_packages "a passed-through GPU in a VM gets only its own driver" yes "Intel Corporation Arc" vulkan-intel
assert_packages "a VM with an NVIDIA GPU is left to nvidia.sh" yes "NVIDIA Corporation AD104" ""
assert_packages "bare metal never gets the CPU Vulkan driver" no "Red Hat, Inc. Virtio 1.0 GPU" ""
