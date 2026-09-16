echo "Install kernel headers needed to build broadcom-wl-dkms"

# 4.0.3 replaced broadcom-wl with broadcom-wl-dkms without matching headers, so
# the module never built and Wi-Fi died after reboot. 1789444024.sh only covers
# linux-omarchy/linux-t2; older MacBooks still run linux.
if omarchy-pkg-present broadcom-wl-dkms; then
  for kernel in linux linux-lts linux-omarchy linux-t2; do
    if omarchy-pkg-present "$kernel"; then
      omarchy-pkg-add "$kernel-headers"
    fi
  done
fi
