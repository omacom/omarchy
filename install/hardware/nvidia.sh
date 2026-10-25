# The NVIDIA N1x laptop's on-package GPU (10de:2e06) is handled by
# install/hardware/n1x.sh: whether the GPU may drive the panel depends on the
# system firmware and on the DKMS build, and there are no 32-bit libraries.
if omarchy-hw-aarch64-n1x; then
  echo "NVIDIA N1x platform detected; GPU driver policy is owned by hardware/n1x.sh"
elif lspci | grep -qi 'nvidia'; then
  # The 32-bit libraries come from multilib, which only x86_64 has.
  if omarchy-hw-nvidia-gsp; then
    PACKAGES=(nvidia-open-dkms nvidia-utils)
    if omarchy-hw-x86; then
      PACKAGES+=(lib32-nvidia-utils)
    fi
    PACKAGES+=(libva-nvidia-driver)
  elif omarchy-hw-nvidia-without-gsp; then
    PACKAGES=(nvidia-580xx-dkms nvidia-580xx-utils)
    if omarchy-hw-x86; then
      PACKAGES+=(lib32-nvidia-580xx-utils)
    fi
  fi

  # Bail if no supported GPU
  if [[ -z ${PACKAGES+x} ]]; then
    echo "No compatible driver for your NVIDIA GPU. See: https://wiki.archlinux.org/title/NVIDIA"
    exit 0
  fi

  omarchy-pkg-add "${PACKAGES[@]}"

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
