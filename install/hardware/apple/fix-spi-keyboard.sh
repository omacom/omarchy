# Detect MacBook models that need SPI keyboard modules
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
if [[ $product_name =~ ^(MacBook[89],1|MacBook1[02],1|MacBookPro13,[123]|MacBookPro14,[123])$ ]]; then
  echo "Detected MacBook with SPI keyboard"

  omarchy-pkg-add macbook12-spi-driver-dkms
  if [[ $product_name == "MacBook8,1" ]]; then
    expected_modules="MODULES+=(applespi spi_pxa2xx_platform spi_pxa2xx_pci)"

    # The Wildcat Point GSPI controller (00:15.4) does transfers through the
    # companion DesignWare DMA engine (00:15.0). On this board those DMA
    # transfers never complete: applespi times out with -110 and IRQ 21 stays
    # at zero. dw_dmac_pci is builtin, so it cannot be blacklisted as a module.
    # Blacklisting its initcall forces spi-pxa2xx into PIO, which works.
    # Deep/S3 sleep then wedges the same SPI device until reboot; s2idle does not.
    pio=/etc/limine-entry-tool.d/macbook81-spi-pio.conf
    expected_pio=$(cat <<'EOF'
# MacBook8,1: DesignWare DMA never completes GSPI transfers.
KERNEL_CMDLINE[default]+=" initcall_blacklist=dw_pci_driver_init mem_sleep_default=s2idle"
EOF
    )
    if [[ -L $pio ]] || { [[ -e $pio ]] && [[ ! -f $pio || $(cat "$pio") != "$expected_pio" ]]; }; then
      echo "Preserving customized SPI boot parameters: $pio; reconcile them manually before retrying." >&2
      return 1
    fi
    sudo mkdir -p /etc/limine-entry-tool.d
    printf '%s\n' "$expected_pio" | sudo tee "$pio" >/dev/null
  else
    expected_modules="MODULES+=(applespi intel_lpss_pci spi_pxa2xx_platform)"
  fi
  modules=/etc/mkinitcpio.conf.d/macbook_spi_modules.conf
  if [[ -L $modules ]] || { [[ -e $modules ]] &&
    [[ ! -f $modules || ( $(cat "$modules") != "$expected_modules" &&
       $(cat "$modules") != "${expected_modules/+=/=}" ) ]]; }; then
    echo "Preserving customized SPI module configuration: $modules; reconcile it manually before retrying." >&2
    return 1
  fi
  sudo mkdir -p /etc/mkinitcpio.conf.d
  # Keep modules contributed by the main config and other drop-ins.
  printf '%s\n' "$expected_modules" | sudo tee "$modules" >/dev/null
fi
