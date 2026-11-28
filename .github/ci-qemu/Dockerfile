FROM ghcr.io/archlinux/archlinux:latest

# Minimal Arch QEMU image for running test/ci-vm with Arch's current QEMU
# instead of pulling and installing packages on every CI run.
RUN set -euo pipefail; \
    if ! grep -qw landlock /sys/kernel/security/lsm 2>/dev/null; then \
      printf '#!/bin/sh\nexec /usr/bin/pacman --disable-sandbox "$@"\n' >/usr/local/bin/pacman; \
      chmod 0755 /usr/local/bin/pacman; \
    fi; \
    sed -i '1i Server = https://mirror.omarchy.org/$repo/os/$arch' /etc/pacman.d/mirrorlist; \
    pacman -Syu --noconfirm --needed \
      qemu-system-x86 \
      qemu-hw-display-virtio-gpu \
      qemu-hw-display-virtio-vga \
      qemu-img \
      openssh; \
    rm -rf /var/cache/pacman/pkg/* /usr/local/bin/pacman
