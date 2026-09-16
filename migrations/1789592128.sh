echo "Point direct boot at the Omarchy kernel"

# Migration 1789325478 moved the default kernel to linux-omarchy through Limine's
# BOOT_ORDER. A direct boot EFI entry skips Limine and kept starting the old
# kernel's UKI. The refresh is a no-op without direct boot or once it points right.
omarchy-setup-direct-boot --refresh
