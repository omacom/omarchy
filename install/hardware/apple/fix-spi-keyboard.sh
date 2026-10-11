# Detect MacBook models that need SPI keyboard modules.
# Not every machine has a DMI product name, and under set -e an unguarded read
# of a missing one aborts the hardware pass.
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"
if [[ $product_name =~ MacBook[89],1|MacBook1[02],1|MacBookPro13,[123]|MacBookPro14,[123] ]]; then
  echo "Detected MacBook with SPI keyboard"

  # macbook12-spi-driver-dkms is obsolete: applespi is mainlined (it ships in
  # the kernel package, and its header that the out-of-tree copy needs was
  # removed in 6.12), so the DKMS build fails on every kernel update once
  # linux-headers is present. Only the initramfs drop-in below is needed to
  # get the in-tree module into the initramfs (load-bearing for LUKS roots).
  sudo mkdir -p /etc/mkinitcpio.conf.d
  if [[ $product_name == "MacBook8,1" ]]; then
    echo "MODULES=(applespi spi_pxa2xx_platform spi_pxa2xx_pci)" | \
      sudo tee /etc/mkinitcpio.conf.d/macbook_spi_modules.conf >/dev/null
  else
    echo "MODULES=(applespi intel_lpss_pci spi_pxa2xx_platform)" | \
      sudo tee /etc/mkinitcpio.conf.d/macbook_spi_modules.conf >/dev/null
  fi
fi
