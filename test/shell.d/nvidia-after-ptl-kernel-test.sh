#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

all="$ROOT/install/hardware/all.sh"

nvidia_line=$(grep -n 'hardware/nvidia.sh' "$all" | cut -d: -f1)
ptl_line=$(grep -n 'hardware/intel/ptl-kernel.sh' "$all" | cut -d: -f1)
ipu_line=$(grep -n 'hardware/intel/ipu7-camera.sh' "$all" | cut -d: -f1)

[[ -n $nvidia_line && -n $ptl_line ]] || fail "nvidia and ptl-kernel both run during hardware setup"
((ptl_line < nvidia_line)) ||
  fail "NVIDIA DKMS runs after the Panther Lake kernel swap"
pass "NVIDIA DKMS runs after the Panther Lake kernel swap"

[[ -n $ipu_line ]] || fail "ipu7 camera DKMS still runs during hardware setup"
((ptl_line < ipu_line)) ||
  fail "ipu7 camera DKMS still runs after the Panther Lake kernel swap"
pass "ipu7 camera DKMS still runs after the Panther Lake kernel swap"

# Count nvidia.sh invocations so we did not leave a second early copy.
nvidia_count=$(grep -c 'hardware/nvidia.sh' "$all")
((nvidia_count == 1)) || fail "nvidia.sh runs once"
pass "nvidia.sh runs once"
