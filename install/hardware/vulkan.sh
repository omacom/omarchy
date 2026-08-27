# Install Vulkan drivers matching detected GPU hardware
# (NVIDIA Vulkan is handled by nvidia.sh via nvidia-utils)

source "$OMARCHY_PATH/install/helpers/pci-sysfs.sh"

declare -A VULKAN_DRIVERS=(
  [0x8086]=vulkan-intel
  [0x1002]=vulkan-radeon
  [0x106b]=vulkan-asahi
)

PACKAGES=()

for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if omarchy-pci-class-vendor 0x03 "$vendor"; then
    PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done

if (( ${#PACKAGES[@]} > 0 )); then
  omarchy-pkg-add "${PACKAGES[@]}"
fi
