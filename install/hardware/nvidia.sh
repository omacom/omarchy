if lspci | grep -qi 'nvidia'; then
  # Check which kernel is installed and set appropriate headers package
  KERNEL_PACKAGE=$(pacman -Qqs '^linux(-zen|-lts|-hardened|-t2|-ptl)?$' | head -1 || true)
  [[ -n $KERNEL_PACKAGE ]] && omarchy-pkg-add "$KERNEL_PACKAGE-headers"

  if omarchy-hw-nvidia-gsp; then
    PACKAGES=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver)
  elif omarchy-hw-nvidia-without-gsp; then
    PACKAGES=(nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils)
  fi

  # Bail if no supported GPU
  if [[ -z ${PACKAGES+x} ]]; then
    echo "No compatible driver for your NVIDIA GPU. See: https://wiki.archlinux.org/title/NVIDIA"
    exit 0
  fi

  omarchy-pkg-add "${PACKAGES[@]}"

  # Enable Dynamic Boost on systems exposing NVIDIA's platform controller.
  # Match the ACPI hardware ID without assuming a particular device instance.
  if grep -qx 'NVDA0820' /sys/bus/acpi/devices/*/hid 2>/dev/null; then
    systemctl enable nvidia-powerd
  fi

  # Per-session Hyprland NVIDIA env vars are handled by default/hypr/nvidia.lua.

  # Configure modprobe for early KMS
  mkdir -p /etc/modprobe.d
  cat > /etc/modprobe.d/nvidia.conf <<'EOF'
options nvidia_drm modeset=1
EOF

  # Configure mkinitcpio for early loading
  mkdir -p /etc/mkinitcpio.conf.d
  cat > /etc/mkinitcpio.conf.d/nvidia.conf <<'EOF'
MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
EOF
fi
