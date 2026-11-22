# The NVIDIA N1x laptop's on-package GPU (10de:2e06) is handled by
# install/hardware/n1x.sh: whether the GPU may drive the panel depends on the
# system firmware and on the DKMS build, and there are no 32-bit libraries.
if omarchy-hw-aarch64-n1x; then
  echo "NVIDIA N1x platform detected; GPU driver policy is owned by hardware/n1x.sh"
elif lspci | grep -qi 'nvidia'; then
  # No 32-bit libraries here. Only Steam and the other game launchers run
  # 32-bit code, and their installers add the driver's
  # (omarchy-install-gaming-gpu-lib32). Installed with the driver, they and
  # the multilib packages they pull in were 305 MB of the ISO's offline
  # mirror, for every machine.
  if omarchy-hw-nvidia-gsp; then
    PACKAGES=(linux-omarchy-nvidia-open nvidia-utils libva-nvidia-driver)
  elif omarchy-hw-nvidia-without-gsp; then
    PACKAGES=(nvidia-580xx-dkms nvidia-580xx-utils)
  fi

  # Bail if no supported GPU
  if [[ -z ${PACKAGES+x} ]]; then
    echo "No compatible driver for your NVIDIA GPU. See: https://wiki.archlinux.org/title/NVIDIA"
    exit 0
  fi

  # Local models run in Podman, which reaches the GPU through the CDI spec the
  # container toolkit writes.
  PACKAGES+=(nvidia-container-toolkit)

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
