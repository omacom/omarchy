# Install Vulkan drivers matching detected GPU hardware
# (NVIDIA Vulkan is handled by nvidia.sh via nvidia-utils)

declare -A VULKAN_DRIVERS=(
  [Intel]=vulkan-intel
  [AMD]=vulkan-radeon
  [Apple]=vulkan-asahi
)

PACKAGES=()

# RADV only drives GPUs bound to amdgpu. Pre-GCN cards (TeraScale and older,
# e.g. the Radeon HD 2400 in a 2007 iMac) stay on the radeon driver, where
# vulkan-radeon still installs radeon_icd.json but every device enumeration
# fails with VK_ERROR_INCOMPATIBLE_DRIVER. That stray ICD makes
# omarchy-hw-vulkan answer yes on a machine with no working Vulkan.
amd_gpu_on_amdgpu() {
  local device
  local pci_devices_path="${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"

  for device in "$pci_devices_path"/*; do
    [[ -e $device/vendor ]] || continue
    [[ $(< "$device/vendor") == "0x1002" ]] || continue
    [[ $(< "$device/class") == 0x03* ]] || continue
    [[ $(readlink -f "$device/driver") == */amdgpu ]] && return 0
  done

  return 1
}

for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" > /dev/null; then
    if [[ $vendor == "AMD" ]] && ! amd_gpu_on_amdgpu; then
      echo "Skipping vulkan-radeon: AMD GPU is not on amdgpu (pre-GCN), RADV cannot drive it"
      continue
    fi

    PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done

if (( ${#PACKAGES[@]} > 0 )); then
  omarchy-pkg-add "${PACKAGES[@]}"
fi
