# Disk unlock and sleep on the ASUS Zenbook 14 UX3480QA (Snapdragon X
# X1-26-100).

mkinitcpio_dir=${OMARCHY_ZENBOOK_UX3480QA_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_ZENBOOK_UX3480QA_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
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

  # The kernel defaults to deep sleep, PSCI system suspend, here. Deep is the
  # only mode in which the SoC collapses its CX rail, but it wakes by itself
  # about every five minutes, ignores the keyboard, and has reset the laptop
  # instead of resuming. Suspend to idle draws more (qcom_stats cxsd stays at
  # 0) and resumes every time, so sleep that way.
  mkdir -p "$sleep_config_dir"
  cat >"$sleep_config_dir/zenbook-14-ux3480qa.conf" <<'CONF'
[Sleep]
MemorySleepMode=s2idle
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF

  # systemd picks the mode above only for its own suspend. Change the kernel's
  # default too, so rtcwake or a write to /sys/power/state does not land in
  # deep sleep.
  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/zenbook-14-ux3480qa.conf" <<'CONF'
KERNEL_CMDLINE[default]+=" mem_sleep_default=s2idle"
CONF
fi
