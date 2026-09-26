echo "Force SPI PIO on MacBook8,1 so the built-in keyboard works"

# The install-time leaf already loads applespi for this model, but that is not
# enough: DesignWare DMA on 00:15.0 never completes GSPI transfers, so the
# keyboard and trackpad time out until the controller is forced into PIO.
# See install/hardware/apple/fix-spi-keyboard.sh.
product="${OMARCHY_MACBOOK81_DMI_PRODUCT:-/sys/class/dmi/id/product_name}"
limine_conf="${OMARCHY_MACBOOK81_LIMINE_CONF:-/etc/limine-entry-tool.d/macbook81-spi-pio.conf}"
repair_marker="${OMARCHY_MACBOOK81_REPAIR_MARKER:-/var/lib/omarchy/migrations/1788318101}"

product_name="$(cat "$product" 2>/dev/null || true)"
if [[ $product_name != "MacBook8,1" ]]; then
  exit 0
fi

expected=$(cat <<'EOF'
# MacBook8,1: DesignWare DMA never completes GSPI transfers.
KERNEL_CMDLINE[default]+=" initcall_blacklist=dw_pci_driver_init mem_sleep_default=s2idle"
EOF
)

# Only the exact shipped drop-in establishes both active settings here.
# Do not infer active shell assignments from text inside comments or blocks.
if [[ -L $limine_conf ]] || { [[ -e $limine_conf ]] &&
  [[ ! -f $limine_conf || $(cat "$limine_conf") != "$expected" ]]; }; then
  echo "Preserving customized SPI boot parameters: $limine_conf; reconcile both required parameters manually before retrying." >&2
  exit 1
fi

needs_limine_rebuild=0
if [[ ! -f $limine_conf ]]; then
  # Invalidate an earlier success before changing the configuration. A failed
  # rebuild must remain retryable even if this file is complete next time.
  sudo rm -f "$repair_marker"
  sudo mkdir -p "$(dirname "$limine_conf")"
  printf '%s\n' "$expected" | sudo tee "$limine_conf" >/dev/null
  needs_limine_rebuild=1
fi

# A marker is written only after a successful machine-wide boot rebuild.
# The running kernel's old command line is not proof of the next boot image.
if [[ ! -e $repair_marker ]]; then
  needs_limine_rebuild=1
fi
if (( needs_limine_rebuild )); then
  sudo rm -f "$repair_marker"
  sudo limine-mkinitcpio
  sudo install -Dm644 /dev/null "$repair_marker"
fi
