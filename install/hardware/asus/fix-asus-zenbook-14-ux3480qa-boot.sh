# Disk unlock and sleep on the ASUS Zenbook 14 UX3480QA (Snapdragon X
# X1-26-100).

mkinitcpio_dir=${OMARCHY_ZENBOOK_UX3480QA_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
sleep_config_dir=${OMARCHY_ZENBOOK_UX3480QA_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3480QA"; then
  # msm lights the panel only once both USB-C DisplayPort controllers have
  # their bridges, which come from pmic_glink's altmode through the ports' SBU
  # muxes. Without these in the initramfs the panel stays dark at the unlock
  # prompt. The ? skips a module a kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/zenbook-14-ux3480qa-initramfs.conf" <<'CONF'
MODULES+=(qrtr? pmic_glink_altmode? gpio_sbu_mux?)
CONF

  # Use PSCI deep suspend (MemorySleepMode=deep). On the X1-26-100 Purwa
  # firmware here, s2idle leaves apss/cxsd/aosd/ddr at 0 (~0.94 W drain),
  # whereas deep suspend reaches ~99.99% APSS/CXSD/AOSD/DDR residency (~0.2-0.3 W)
  # with working Wi-Fi, Bluetooth, audio, webcam and display on resume (paired
  # with the switch-lid DTB fix in linux-omarchy-dtbs 7.3-77 and a200000.usb
  # wakeup disabled in 90-asus-zenbook-14-ux3480qa-power.rules). Keep
  # hibernation off as on the Zenbook A16.
  mkdir -p "$sleep_config_dir"
  cat >"$sleep_config_dir/zenbook-14-ux3480qa.conf" <<'CONF'
[Sleep]
MemorySleepMode=deep
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF
fi
