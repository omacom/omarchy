echo "Install Mesa's CPU Vulkan driver in virtual machines"

# QEMU/virtio guests match no vendor in install/hardware/vulkan.sh, and
# nvidia-utils' ICD has no device behind it without an NVIDIA GPU.
vulkan_device=0
if lspci | grep -iE '(VGA|Display).*(Intel|AMD|Apple)' >/dev/null || omarchy-hw-aarch64-qualcomm || omarchy-hw-nvidia; then
  vulkan_device=1
fi

if omarchy-hw-vm && (( vulkan_device == 0 )) && omarchy-pkg-missing vulkan-swrast; then
  omarchy-pkg-add vulkan-swrast
fi
