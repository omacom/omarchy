echo "Switch N1x laptops to NVIDIA modules prebuilt for linux-omarchy instead of building them with DKMS"

# nvidia-open-dkms compiled NVIDIA's modules on the laptop for every kernel
# update. linux-omarchy-nvidia-open ships them built and signed with each
# kernel.
if omarchy-hw-aarch64-n1x && omarchy-pkg-present nvidia-open-dkms linux-omarchy; then
  # One transaction with --ask 4 so pacman accepts replacing the conflicting
  # nvidia-open-dkms in place, and no initramfs is built without the modules.
  sudo pacman -S --noconfirm --ask 4 linux-omarchy-nvidia-open
fi
