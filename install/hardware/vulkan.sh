# Install Vulkan drivers matching detected GPU hardware
# (NVIDIA Vulkan is handled by nvidia.sh via nvidia-utils)

PACKAGES=()

if omarchy-hw-pci --class 03 8086:*; then
  PACKAGES+=(vulkan-intel)
fi
if omarchy-hw-pci --class 03 1002:*; then
  PACKAGES+=(vulkan-radeon)
fi
if omarchy-hw-pci --class 03 106b:*; then
  PACKAGES+=(vulkan-asahi)
fi

# Adreno GPUs are platform devices, so lspci never sees them.
if omarchy-hw-aarch64-qualcomm; then
  PACKAGES+=(vulkan-freedreno)
fi

if (( ${#PACKAGES[@]} > 0 )); then
  omarchy-pkg-add "${PACKAGES[@]}"
fi
