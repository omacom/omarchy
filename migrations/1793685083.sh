echo "Switch NVIDIA machines on linux-omarchy from DKMS to prebuilt NVIDIA modules"

# linux-omarchy-nvidia-open ships the modules built with each kernel, so
# kernel updates no longer compile them. It only covers linux-omarchy, so a
# machine with another kernel installed (1789325478 kept the previous one for
# recovery) stays on DKMS. One transaction with --ask 4 so pacman accepts
# replacing the conflicting nvidia-open-dkms in place.
if omarchy-pkg-present nvidia-open-dkms linux-omarchy &&
  [[ $(cat /usr/lib/modules/*/pkgbase 2>/dev/null | sort -u) == "linux-omarchy" ]]; then
  sudo pacman -S --noconfirm --ask 4 linux-omarchy-nvidia-open
fi
