# Display and boot setup for the Radxa Orion O6 and O6N (CIX Sky1 ACPI).

mkinitcpio_dir=${OMARCHY_RADXA_ORION_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64 && { omarchy-hw-match '^Radxa Orion O6$' || omarchy-hw-match '^Radxa Orion O6N$'; }; then
  echo "Detected Radxa Orion board, applying CIX Sky1 boot configuration..."

  # Include the PWM backlight, Linlon display engine and Trilin DisplayPort
  # drivers in the UKI so Plymouth's LUKS prompt lights up over DisplayPort
  # and HDMI. Their GPIO, regulator, USB-DP combo PHY and Type-C PD suppliers
  # are built into linux-omarchy. The ? skips a module a kernel lacks.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/radxa-orion.conf" <<'CONF'
MODULES+=(pwm_bl? linlon_dp? trilin_dpsub?)
CONF

  # Keep firmware-enabled clocks alive until all ACPI consumers bind, and
  # reserve contiguous scanout memory for linlondp.
  omarchy-boot-cmdline set radxa-orion clk_ignore_unused cma=512M
fi
