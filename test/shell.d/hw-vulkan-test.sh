#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" OMARCHY_VULKAN_ICD_PATH="$tmp_dir/icd.d" PATH="$ROOT/bin:$PATH"

# Expected exit status, whether a Vulkan ICD is installed, then vendor:device:class[:driver].
while IFS='|' read -r description expected icd devices; do
  rm -rf "$tmp_dir/devices" "$tmp_dir/icd.d"
  mkdir -p "$tmp_dir/devices" "$tmp_dir/icd.d"
  [[ $icd == "icd" ]] && touch "$tmp_dir/icd.d/radeon_icd.json"

  slot=0
  for spec in $devices; do
    IFS=: read -r vendor device class driver <<<"$spec"
    device_dir="$tmp_dir/devices/$slot"
    mkdir -p "$device_dir"
    printf '%s\n' "$vendor" >"$device_dir/vendor"
    printf '%s\n' "$device" >"$device_dir/device"
    printf '%s\n' "$class" >"$device_dir/class"
    if [[ -n $driver ]]; then
      ln -s "../../../bus/pci/drivers/$driver" "$device_dir/driver"
    fi
    slot=$((slot + 1))
  done

  status=0
  omarchy-hw-vulkan || status=$?
  [[ $status == "$expected" ]] || fail "$description" "expected $expected, got $status"
  pass "$description"
done <<'CASES'
iMac12,2: TeraScale Radeon and Sandy Bridge|1|icd|0x1002:0x6740:0x030000:radeon 0x8086:0x0102:0x038000:i915
TeraScale Radeon only|1|icd|0x1002:0x6740:0x030000:radeon
GCN Radeon left on radeon|1|icd|0x1002:0x6798:0x030000:radeon
Radeon with no driver bound|1|icd|0x1002:0x6798:0x030000
Sandy Bridge only|1|icd|0x8086:0x0126:0x030000:i915
Ironlake only|1|icd|0x8086:0x0046:0x030000:i915
Ivy Bridge (first hasvk)|0|icd|0x8086:0x0152:0x030000:i915
Radeon on amdgpu|0|icd|0x1002:0x15bf:0x030000:amdgpu
Sandy Bridge with NVIDIA|0|icd|0x8086:0x0116:0x030000:i915 0x10de:0x1f91:0x030200:nvidia
TeraScale Radeon with amdgpu Radeon|0|icd|0x1002:0x6740:0x030000:radeon 0x1002:0x73bf:0x030000:amdgpu
Virtio GPU|0|icd|0x1af4:0x1050:0x030000:virtio-pci
Old Intel non-GPU IDs are ignored|0|icd|0x8086:0x0100:0x060000 0x8086:0x0152:0x030000:i915
Old Intel non-GPU IDs don't count as GPUs|1|icd|0x8086:0x0100:0x060000 0x1002:0x6740:0x030000:radeon
No PCI GPU (Apple Silicon)|0|icd|
No ICD installed|1|none|0x1002:0x15bf:0x030000:amdgpu
CASES
