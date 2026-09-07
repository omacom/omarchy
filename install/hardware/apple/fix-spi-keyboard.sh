# Detect MacBook models that need SPI keyboard modules
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
if [[ $product_name =~ MacBook[89],1|MacBook1[02],1|MacBookPro13,[123]|MacBookPro14,[123] ]]; then
  echo "Detected MacBook with SPI keyboard"

  # The stock T1 kernel includes applespi; the legacy DKMS driver no longer
  # builds against it. Keep the initramfs modules for early keyboard input.
  sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)"
  if [[ $sys_vendor != "Apple Inc." || ! $product_name =~ ^MacBookPro(13,[23]|14,[23])$ ]]; then
    omarchy-pkg-add macbook12-spi-driver-dkms
  fi
  sudo mkdir -p /etc/mkinitcpio.conf.d
  if [[ $product_name == "MacBook8,1" ]]; then
    echo "MODULES=(applespi spi_pxa2xx_platform spi_pxa2xx_pci)" | \
      sudo tee /etc/mkinitcpio.conf.d/macbook_spi_modules.conf >/dev/null
  else
    echo "MODULES=(applespi intel_lpss_pci spi_pxa2xx_platform)" | \
      sudo tee /etc/mkinitcpio.conf.d/macbook_spi_modules.conf >/dev/null
  fi
fi
