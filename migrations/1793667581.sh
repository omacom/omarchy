echo "Switch NVIDIA machines on linux-omarchy from DKMS to prebuilt NVIDIA modules"

# linux-omarchy-nvidia-open ships the modules built with each kernel, so
# kernel updates no longer compile them. One transaction with --ask 4 so pacman
# accepts replacing the conflicting nvidia-open-dkms in place.
if omarchy-pkg-present nvidia-open-dkms linux-omarchy; then
  sudo pacman -S --noconfirm --ask 4 linux-omarchy-nvidia-open
fi
