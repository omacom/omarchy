# Microsoft Surface Pro 11 (Snapdragon X Elite, OLED) board-specific setup.

mkinitcpio_dir=${OMARCHY_SURFACE_PRO11_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
uki_config=${OMARCHY_SURFACE_PRO11_UKI_CONFIG:-/etc/kernel/uki.conf}
dtb_root=${OMARCHY_QUALCOMM_DTB_ROOT:-/boot/dtbs}

# Only the X Elite OLED model has been tested. The LCD and X Plus models share
# the DMI product name but use other device trees and panels.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree microsoft,denali-oled; then
  echo "Detected Microsoft Surface Pro 11, applying board-specific support..."

  # Installs made before the Intel Surface fixes were limited to x86 carry
  # their keyboard module file. It sorts after this script's drop-in and
  # resets MODULES to Intel modules, leaving no panel or keyboard to unlock with.
  rm -f "$mkinitcpio_dir/surface_device_modules.conf"

  # Embed the OLED model's device tree instead of the list dtb-uki.sh writes.
  # systemd-stub picks from that list by SMBIOS identity, which the OLED, LCD
  # and X Plus models share. Omarchy's kernel carries the tree, found the way
  # dtb-uki.sh finds it; without it the list stays and an earlier pin goes.
  surface_pro11_dtb=""
  for dtb in "$dtb_root"/linux-omarchy*/qcom/x1e80100-microsoft-denali-oled.dtb; do
    if [[ -f $dtb ]]; then
      surface_pro11_dtb=$dtb
      break
    fi
  done

  if [[ -n $surface_pro11_dtb || -f $uki_config ]]; then
    mkdir -p "$(dirname "$uki_config")"
    uki_tmp=$(mktemp "${uki_config}.XXXXXX")

    if [[ -f $uki_config ]]; then
      cp -p "$uki_config" "$uki_tmp"
      awk -v pinned="${surface_pro11_dtb:+1}" '
        $0 == "# BEGIN OMARCHY SURFACE PRO 11 DEVICE TREE" || (pinned && $0 == "# BEGIN OMARCHY QUALCOMM DEVICE TREES") { managed = 1; next }
        managed && ($0 == "# END OMARCHY SURFACE PRO 11 DEVICE TREE" || $0 == "# END OMARCHY QUALCOMM DEVICE TREES") { managed = 0; next }
        !managed { print }
      ' "$uki_config" >"$uki_tmp"
    else
      chmod 0644 "$uki_tmp"
    fi

    if [[ -n $surface_pro11_dtb ]]; then
      {
        echo "# BEGIN OMARCHY SURFACE PRO 11 DEVICE TREE"
        echo "[UKI]"
        echo "DeviceTree=$surface_pro11_dtb"
        echo "# END OMARCHY SURFACE PRO 11 DEVICE TREE"
      } >>"$uki_tmp"
    fi

    if [[ -f $uki_config ]] && cmp -s "$uki_tmp" "$uki_config"; then
      rm -f "$uki_tmp"
    else
      mv -f "$uki_tmp" "$uki_config"
      # As in dtb-uki.sh: an image's first boot rebuilds after its last step,
      # but does not watch this file.
      if [[ -n ${OMARCHY_IMAGE_BOOT_REBUILD:-} ]]; then
        : >"$OMARCHY_IMAGE_BOOT_REBUILD"
      fi
    fi
  fi

  # Bring up the panel and the Flex Keyboard before disk unlock. The display
  # driver waits for the USB-C DisplayPort chain, so that loads early too,
  # with the IPC router and PD mapper pmic_glink needs to initialize. As in
  # qualcomm/initramfs.sh, the ? skips a module a kernel does not have, so its
  # image still builds.
  # The DSP driver stays out: listing it here would bypass the USB-root guard.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/surface-pro-11-initramfs.conf" <<'CONF'
MODULES+=(msm? dispcc_x1e80100? gpucc_x1e80100? videocc_sm8550? phy_qcom_edp?
  panel_samsung_atna33xc20? phy_qcom_qmp_combo? ps883x? qrtr? qcom_pd_mapper? pmic_glink?
  pmic_glink_altmode? i2c_qcom_geni? surface_aggregator? surface_aggregator_registry?
  surface_aggregator_hub? surface_hid_core? surface_hid?)

# The board-signed zap shader is included by qcom-firmware-extract. Wi-Fi board
# data and the audio topology are requested once if their drivers load early.
for firmware in \
  qcom/gen70500_sqe.fw \
  qcom/gen70500_gmu.bin \
  ath12k/WCN7850/hw2.0/board.bin \
  qcom/x1e80100/X1E80100-Microsoft-Surface-Pro-11-tplg.bin; do
  for suffix in '' .zst .xz; do
    for directory in "${OMARCHY_SURFACE_PRO11_FIRMWARE_ROOT:-/usr/lib/firmware}/updates" \
      "${OMARCHY_SURFACE_PRO11_FIRMWARE_ROOT:-/usr/lib/firmware}"; do
      if [[ -f $directory/$firmware$suffix ]]; then
        FILES+=("$directory/$firmware$suffix")
        break 2
      fi
    done
  done
done
unset firmware directory suffix
CONF

  # surface-pro-11-support carries Wi-Fi board data, audio and camera routing,
  # iptsd turns the digitizer's reports into pen and touch input, and the
  # sensor package serves the ADSP the light sensor's configuration.
  omarchy-pkg-add surface-pro-11-support iptsd surface-pro-11-sensors

  # The light sensor configuration is copied from the Windows installation,
  # which a full-disk install has already erased; it can be rerun later.
  surface-pro-11-sensors-extract || true
  systemctl enable surface-pro-11-sensors.service
fi
