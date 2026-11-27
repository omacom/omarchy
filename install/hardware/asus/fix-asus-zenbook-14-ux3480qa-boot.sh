# Disk unlock and sleep on the ASUS Zenbook 14 UX3480QA (Snapdragon X
# X1-26-100).

mkinitcpio_dir=${OMARCHY_ZENBOOK_UX3480QA_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
sleep_config_dir=${OMARCHY_ZENBOOK_UX3480QA_SLEEP_CONFIG_DIR:-/etc/systemd/sleep.conf.d}
dt_root=${OMARCHY_ZENBOOK_UX3480QA_DT_ROOT:-/sys/firmware/devicetree/base}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3480QA"; then
  # msm lights the panel only once both USB-C DisplayPort controllers have
  # their bridges, which come from pmic_glink's altmode through the ports' SBU
  # muxes. Without these in the initramfs the panel stays dark at the unlock
  # prompt. The ? skips a module a kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/zenbook-14-ux3480qa-initramfs.conf" <<'CONF'
MODULES+=(qrtr? pmic_glink_altmode? gpio_sbu_mux?)
CONF

  # Use PSCI deep suspend (MemorySleepMode=deep) once linux-omarchy-dtbs >=
  # 7.3-77 is installed AND booted (drops wakeup-event-action from switch-lid
  # so open-lid deep suspend does not wake on CX collapse exit). On the
  # X1-26-100 Purwa firmware here, s2idle leaves apss/cxsd/aosd/ddr at 0
  # (~0.94 W drain), whereas deep suspend reaches ~99.99% APSS/CXSD/AOSD/DDR
  # residency with working Wi-Fi, Bluetooth, audio, webcam and display on
  # resume. Until the updated device tree is installed and running, keep
  # s2idle so open-lid suspend stays reliable.
  dtbs_ver=$(pacman -Q linux-omarchy-dtbs 2>/dev/null | awk '{print $2}') || dtbs_ver=""
  mkdir -p "$sleep_config_dir"
  if [[ -n $dtbs_ver ]] && (( $(vercmp "$dtbs_ver" 7.3-77) >= 0 )) &&
    [[ -d $dt_root/gpio-keys/switch-lid && ! -e $dt_root/gpio-keys/switch-lid/wakeup-event-action ]]; then
    cat >"$sleep_config_dir/zenbook-14-ux3480qa.conf" <<'CONF'
[Sleep]
MemorySleepMode=deep
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF
  else
    cat >"$sleep_config_dir/zenbook-14-ux3480qa.conf" <<'CONF'
[Sleep]
MemorySleepMode=s2idle
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
CONF
  fi
fi
