# Install Vulkan drivers matching detected GPU hardware
# (NVIDIA Vulkan is handled by nvidia.sh via nvidia-utils)

declare -A VULKAN_DRIVERS=(
  [Intel]=vulkan-intel
  [AMD]=vulkan-radeon
  [Apple]=vulkan-asahi
)

PACKAGES=()

for vendor in "${!VULKAN_DRIVERS[@]}"; do
  # Anchor on the class name: T2 Macs list "Non-VGA unclassified device: Apple Inc.",
  # which an unanchored VGA match would take for an Apple GPU.
  if lspci | grep -iE "^\S+ (VGA compatible controller|Display controller): .*$vendor" > /dev/null; then
    PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done

if (( ${#PACKAGES[@]} > 0 )); then
  omarchy-pkg-add "${PACKAGES[@]}"
fi
