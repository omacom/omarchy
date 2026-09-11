#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

nvidia_sh="$ROOT/install/hardware/nvidia.sh"

grep -Fq 'omarchy-hw-nvidia' "$nvidia_sh" ||
  fail "NVIDIA install uses the sysfs helper already used at session start"
! grep -Eq "lspci.*nvidia" "$nvidia_sh" ||
  fail "NVIDIA install does not grep lspci for the GPU"

# The GSP / 580xx split already goes through the helpers; keep that pairing.
grep -Fq 'omarchy-hw-nvidia-gsp' "$nvidia_sh" ||
  fail "NVIDIA install still chooses the GSP driver via sysfs"
grep -Fq 'omarchy-hw-nvidia-without-gsp' "$nvidia_sh" ||
  fail "NVIDIA install still chooses the 580xx driver via sysfs"
pass "NVIDIA driver install detects the GPU the same way Hyprland does"
