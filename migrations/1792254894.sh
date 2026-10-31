echo "Install Mesa's CPU Vulkan driver in virtual machines"

# QEMU/virtio guests match no vendor in install/hardware/vulkan.sh, so they have
# no Vulkan driver at all. Ask about the VM first: lspci wakes suspended GPUs.
if omarchy-hw-vm && omarchy-pkg-missing vulkan-swrast; then
  if ! lspci | grep -iE '(VGA|Display).*(Intel|AMD|Apple)' >/dev/null && ! omarchy-hw-aarch64-qualcomm && ! omarchy-hw-nvidia; then
    omarchy-pkg-add vulkan-swrast
  fi
fi
