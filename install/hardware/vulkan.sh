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
#
# Skip only on radeon: an installer booted with nomodeset binds no driver at
# all, which says nothing about the installed system.
amd_gpu_only_on_radeon() {
  local device driver
  local on_radeon=false
  local pci_devices_path="${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"

  for device in "$pci_devices_path"/*; do
    [[ -e $device/vendor ]] || continue
    [[ $(< "$device/vendor") == "0x1002" ]] || continue
    [[ $(< "$device/class") == 0x03* ]] || continue

    driver=$(readlink -f "$device/driver")
    [[ $driver == */amdgpu ]] && return 1
    [[ $driver == */radeon ]] && on_radeon=true
  done

  [[ $on_radeon == true ]]
}

for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" > /dev/null; then
    if [[ $vendor == "AMD" ]] && amd_gpu_only_on_radeon; then
      echo "Skipping vulkan-radeon: AMD GPU is on the radeon driver, which RADV cannot drive"
      continue
    fi

    PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done

if (( ${#PACKAGES[@]} > 0 )); then
  omarchy-pkg-add "${PACKAGES[@]}"
fi
