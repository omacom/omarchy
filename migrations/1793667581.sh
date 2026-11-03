echo "Switch NVIDIA machines on linux-omarchy to NVIDIA modules prebuilt with the kernel instead of building them with DKMS"

# nvidia-open-dkms compiled NVIDIA's modules on the machine for every kernel
# update. linux-omarchy now ships them built and signed as
# linux-omarchy-nvidia-open. omarchy-pkg-nvidia-modules swaps them in, in one
# transaction, only when every installed kernel has its package, and leaves
# DKMS alone otherwise.
if omarchy-pkg-present nvidia-open-dkms; then
  omarchy-pkg-nvidia-modules --install
fi
