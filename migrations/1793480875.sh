echo "Install the Vulkan driver a virtual machine is missing"

# install/hardware/vulkan.sh gave QEMU/virtio guests no Vulkan driver at all.
# Ask about the VM first: vulkan.sh runs lspci, which wakes suspended GPUs.
if omarchy-hw-vm && omarchy-pkg-missing vulkan-swrast; then
  source "$OMARCHY_PATH/install/hardware/vulkan.sh"
fi
