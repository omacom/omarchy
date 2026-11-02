# Disk unlock and sleep on the ASUS Zenbook A16 UX3607OA (Snapdragon X2 Elite).

mkinitcpio_dir=${OMARCHY_ZENBOOK_A16_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_ZENBOOK_A16_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
sleep_config_dir=${OMARCHY_ZENBOOK_A16_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3607OA"; then
  # The kernel defaults to deep sleep, PSCI system suspend, and resuming from
  # it resets the SoC. Suspend to idle resumes cleanly, so sleep that way.
  mkdir -p "$sleep_config_dir"
  cat >"$sleep_config_dir/zenbook-a16.conf" <<'CONF'
[Sleep]
MemorySleepMode=s2idle
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF

  # Bring up the keyboard, the embedded controller and the USB-C and USB-A
  # chains before disk unlock. The ? skips a module a kernel does not have.
  # The DSP driver stays out: listing it here would bypass the USB-root guard.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/zenbook-a16-initramfs.conf" <<'CONF'
MODULES+=(hid-asus? i2c-hid-of? asus_glymur_ec? qrtr? qcom_pd_mapper? pmic_glink?
  ps883x? pmic_glink_altmode? phy-nxp-ptn3222?)

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

  # Plymouth leaves the panel black at the unlock prompt, so ask for the
  # passphrase on the text console instead.
  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/zenbook-a16.conf" <<'CONF'
KERNEL_CMDLINE[default]+=" console=tty0 plymouth.enable=0"
CONF
fi
