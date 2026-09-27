echo "Remove the obsolete MacBook SPI keyboard DKMS package"

# applespi is mainlined (it ships with the linux package), so the out-of-tree
# driver cannot build on current kernels: its include was removed in kernel
# 6.12 and the DKMS build fails on every kernel update once linux-headers is
# present. The initramfs drop-in written by
# install/hardware/apple/fix-spi-keyboard.sh loads the in-tree module instead,
# so the package is pure failure surface. Idempotent: nothing happens when the
# package is not installed.
omarchy-pkg-present macbook12-spi-driver-dkms || exit 0

product_file="${OMARCHY_SPI_DMI_PRODUCT:-/sys/class/dmi/id/product_name}"
modules_dir="${OMARCHY_SPI_MODULES_DIR:-/usr/lib/modules}"
if ! product=$(cat "$product_file" 2>/dev/null) || [[ -z $product ]]; then
  echo "Cannot identify the machine; preserving the legacy SPI package." >&2
  exit 1
fi

# The old package also owns iBridge/Touch Bar/ALS modules. An in-tree SPI
# module alone is not their replacement. Package presence is a prerequisite,
# not proof that T1Bridge firmware/session provisioning or hardware works.
if [[ $product =~ ^MacBookPro1[34],[23]$ ]] &&
  { ! omarchy-pkg-present t1bridge-dkms || ! omarchy-pkg-present t1bridge; }; then
  echo "Complete the documented manual T1Bridge transition before retiring the legacy package." >&2
  exit 1
fi

# Verify an actual in-tree module for every retained kernel. Do not accept an
# out-of-tree module that will disappear with the package being removed.
verified=0
for pkgbase in "$modules_dir"/*/pkgbase; do
  [[ -f $pkgbase ]] || continue
  kernel_dir=${pkgbase%/pkgbase}
  found=0
  for module in "$kernel_dir"/kernel/drivers/input/keyboard/applespi.ko*; do
    [[ -f $module ]] || continue
    if [[ $(modinfo -F name "$module" 2>/dev/null) == applespi ]]; then
      found=1
      break
    fi
  done
  if ((found == 0)); then
    echo "No in-tree applespi replacement for ${kernel_dir##*/}; preserving the legacy package." >&2
    exit 1
  fi
  verified=$((verified + 1))
done
if ((verified == 0)); then
  echo "No retained kernel could be verified; preserving the legacy package." >&2
  exit 1
fi
omarchy-pkg-drop macbook12-spi-driver-dkms
