# Install Vulkan drivers matching detected GPU hardware
# (NVIDIA Vulkan is handled by nvidia.sh via nvidia-utils)

declare -A VULKAN_DRIVERS=(
  [Intel]=vulkan-intel
  [AMD]=vulkan-radeon
  [Apple]=vulkan-asahi
  # virtio-gpu (QEMU/KVM "Red Hat Virtio") is not NVIDIA. Without a match,
  # later vulkan-driver consumers (Zed, etc.) let pacman pick nvidia-utils.
  [Virtio]=vulkan-virtio
)

PACKAGES=()

for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA compatible controller|Display controller|3D controller): .*$vendor" >/dev/null; then
    PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done

if (( ${#PACKAGES[@]} > 0 )); then
  omarchy-pkg-add "${PACKAGES[@]}"
fi