echo "Install headers so the Broadcom wl driver builds for the stock kernel"

# Arch dropped the prebuilt broadcom-wl on 2026-09-02, and its replaces entry
# swapped in broadcom-wl-dkms during the next upgrade. That pulls in dkms but not
# the headers the module builds against, so 2012-2015 MacBooks with a BCM4360 or
# BCM4331 came back from the upgrade with no Wi-Fi driver at all. The kernel
# migration gives linux-omarchy its headers, but the stock kernel stays installed
# as the boot fallback, and without headers that fallback still has no Wi-Fi.
# Installing the headers is enough: the dkms pacman hook builds the module.
omarchy-pkg-present broadcom-wl-dkms || exit 0

for kernel in linux linux-lts linux-zen linux-hardened; do
  if omarchy-pkg-present "$kernel"; then
    omarchy-pkg-add "$kernel-headers"
  fi
done
