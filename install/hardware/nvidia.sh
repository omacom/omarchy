# The NVIDIA N1x laptop's on-package GPU (10de:2e06) is handled by
# install/hardware/n1x.sh: whether the GPU may drive the panel depends on the
# system firmware and on the DKMS build, and there are no 32-bit libraries.
if omarchy-hw-aarch64-n1x; then
  echo "NVIDIA N1x platform detected; GPU driver policy is owned by hardware/n1x.sh"
elif omarchy-hw-nvidia; then
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

  # Configure mkinitcpio for early loading. The modules are listed only when the
  # kernel has them: a DKMS build for a newly installed kernel can fail, and an
  # unconditional MODULES entry then fails the whole mkinitcpio run. No UKI is
  # written then, limine keeps the previous kernel's entry, and the kernel
  # update silently does nothing. Asking modinfo first degrades that case to a
  # nouveau-only image, which still boots, and the build log says so.
  #
  # As with thunderbolt_module.conf, the modules are named without ? and only
  # when the kernel has them, since a systemd initramfs copies MODULES as
  # written into modules-load.d. The module lives in updates/dkms, not
  # kernel/drivers/video, so ask modinfo rather than test a fixed path.
  #
  # Nothing rebuilds the image when the module appears later: a manual dkms
  # install is no pacman transaction, so run limine-mkinitcpio once it succeeds.
  mkdir -p /etc/mkinitcpio.conf.d
  cat > /etc/mkinitcpio.conf.d/nvidia.conf <<'EOF'
# Early-load the proprietary NVIDIA driver where the kernel has it; written by
# install/hardware/nvidia.sh. A kernel whose module is missing still gets a
# bootable image, and the warning below says why it went without it.
if [[ $(modinfo -k "${KERNELVERSION:-$(uname -r)}" -F filename nvidia 2>/dev/null) == /* ]]; then
  MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
else
  printf 'nvidia: module not built for %s — image without nvidia (nouveau fallback)\n' "${KERNELVERSION:-$(uname -r)}" >&2
fi
EOF
fi
