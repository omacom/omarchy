# Disk unlock on the HP OmniBook Ultra 14-kg0xxx (Snapdragon X2 Elite).

mkinitcpio_dir=${OMARCHY_HP_OMNIBOOK_ULTRA_14_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "OmniBook Ultra Laptop 14-kg0"; then
  # The display driver resets the panel's output when it loads from the
  # initramfs, and draws again only once its three USB-C outputs have bound,
  # which waits for pmic_glink_altmode. Without it here the unlock prompt
  # stays black. The ? skips a module a kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/hp-omnibook-ultra-14-initramfs.conf" <<'CONF'
MODULES+=(qrtr? qcom_pd_mapper? pmic_glink? pmic_glink_altmode?)

# The Adreno X2's microcode, requested once if the display driver loads early.
for firmware in qcom/gen80100_sqe.fw qcom/gen80100_gmu.bin; do
  for suffix in '' .zst .xz; do
    for directory in /usr/lib/firmware/updates /usr/lib/firmware; do
      if [[ -f $directory/$firmware$suffix ]]; then
        FILES+=("$directory/$firmware$suffix")
        break 2
      fi
    done
  done
done
unset firmware directory suffix
CONF
fi
