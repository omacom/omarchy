# Install Vulkan drivers matching detected GPU hardware
# (NVIDIA Vulkan is handled by nvidia.sh via nvidia-utils)

declare -A VULKAN_DRIVERS=(
  [Intel]=vulkan-intel
  [AMD]=vulkan-radeon
  [Apple]=vulkan-asahi
)

PACKAGES=()

for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" > /dev/null; then
    PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done

# Adreno GPUs are platform devices, so lspci never sees them.
if omarchy-hw-aarch64-qualcomm; then
  PACKAGES+=(vulkan-freedreno)
fi

# QEMU/virtio guests match no vendor above, so without a CPU driver Vulkan
# applications (Zed, games) find no device and cannot start.
if (( ${#PACKAGES[@]} == 0 )) && omarchy-hw-vm && ! omarchy-hw-nvidia; then
  PACKAGES+=(vulkan-swrast)
fi

if (( ${#PACKAGES[@]} > 0 )); then
  omarchy-pkg-add "${PACKAGES[@]}"
fi
