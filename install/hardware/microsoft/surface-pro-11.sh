# Microsoft Surface Pro 11 (Snapdragon X Elite, OLED) board-specific setup.

surface_pro11_compatible=""
compatible_path=${OMARCHY_SURFACE_PRO11_COMPATIBLE_PATH:-/sys/firmware/devicetree/base/compatible}
mkinitcpio_dir=${OMARCHY_SURFACE_PRO11_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
limine_config_dir=${OMARCHY_SURFACE_PRO11_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
uki_config=${OMARCHY_SURFACE_PRO11_UKI_CONFIG:-/etc/kernel/uki.conf}

if [[ -r $compatible_path ]]; then
  surface_pro11_compatible=$(tr '\0' '\n' <"$compatible_path")
fi

# Only the X Elite OLED model has been tested. The LCD and X Plus models share
# the DMI product name but use other device trees and panels.
if omarchy-hw-qualcomm-soc && grep -qx 'microsoft,denali-oled' <<<"$surface_pro11_compatible"; then
  echo "Detected Microsoft Surface Pro 11, applying board-specific support..."

  # Boot configuration comes first, so the Surface kernel's image is built with
  # it when the kernel is installed below.

  # Installs made before the Intel Surface fixes were limited to x86 carry
  # their keyboard module file, which resets MODULES to Intel modules.
  rm -f "$mkinitcpio_dir/surface_device_modules.conf"

  # Embed the Surface kernel's device tree instead of the generic list, whose
  # device trees belong to the stock kernel. The markers match dtb-uki.sh.
  mkdir -p "$(dirname "$uki_config")"
  uki_tmp=$(mktemp "$uki_config.XXXXXX")
  if [[ -f $uki_config ]]; then
    cp -p "$uki_config" "$uki_tmp"
    awk '
      $0 == "# BEGIN OMARCHY QUALCOMM DEVICE TREES" || $0 == "# BEGIN OMARCHY SURFACE PRO 11 DEVICE TREE" { managed = 1; next }
      managed && ($0 == "# END OMARCHY QUALCOMM DEVICE TREES" || $0 == "# END OMARCHY SURFACE PRO 11 DEVICE TREE") { managed = 0; next }
      !managed { print }
    ' "$uki_config" >"$uki_tmp"
  else
    chmod 0644 "$uki_tmp"
  fi
  cat >>"$uki_tmp" <<'CONF'
# BEGIN OMARCHY SURFACE PRO 11 DEVICE TREE
[UKI]
DeviceTree=/boot/dtbs/linux-sp11/qcom/x1e80100-microsoft-denali-oled.dtb
# END OMARCHY SURFACE PRO 11 DEVICE TREE
CONF
  mv -f "$uki_tmp" "$uki_config"
  unset uki_tmp

  # Bring up the panel and the Flex Keyboard before disk unlock. The display
  # driver waits for the USB-C DisplayPort chain, so that loads early too,
  # with the IPC router and PD mapper pmic_glink needs to initialize. The
  # Surface modules are optional so a stock kernel's image still builds.
  # The DSP driver stays out: listing it here would bypass the USB-root guard.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/surface-pro-11-initramfs.conf" <<'CONF'
MODULES+=(msm dispcc_x1e80100 gpucc_x1e80100 videocc_sm8550 phy_qcom_edp
  panel_samsung_atna33xc20 phy_qcom_qmp_combo ps883x qrtr qcom_pd_mapper pmic_glink pmic_glink_altmode
  i2c_qcom_geni surface_aggregator? surface_aggregator_registry?
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

  # Named to sort after omarchy-defaults.conf: the last BOOT_ORDER wins.
  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/zz-surface-pro-11.conf" <<'CONF'
BOOT_ORDER="linux-sp11*, *fallback, Snapshots"
CONF

  # The Surface kernel adds touch, pen and the Surface Aggregator keyboard,
  # and needs its own device tree. The UKI device tree setting applies to
  # every kernel, so it replaces the stock kernel instead of sitting beside it.
  # surface-pro-11-support carries Wi-Fi board data, audio and camera routing.
  # A failed install stops here, before the stock kernel is removed.
  surface_pro11_kernel=(linux-sp11)
  if pacman -Q linux-aarch64-headers &>/dev/null; then
    surface_pro11_kernel+=(linux-sp11-headers)
  fi
  omarchy-pkg-add "${surface_pro11_kernel[@]}" surface-pro-11-support
  unset surface_pro11_kernel
  for stock_kernel in linux-aarch64 linux-aarch64-headers; do
    if pacman -Q "$stock_kernel" &>/dev/null; then
      pacman -Rdd --noconfirm "$stock_kernel"
    fi
  done
  unset stock_kernel

  # libcamera with IMX681 support replaces a stock libcamera if something
  # already installed one; --noconfirm alone would answer that prompt with N.
  pacman -S --needed --noconfirm --ask 4 libcamera-surface-pro-11 pipewire-libcamera

  # iptsd turns the digitizer's reports into pen and touch input, the sensor
  # package serves the ADSP the light sensor's configuration, and the patched
  # power-profiles-daemon reaches the Surface's platform profile.
  omarchy-pkg-add iptsd surface-pro-11-sensors power-profiles-daemon-surface-pro-11

  # The light sensor configuration is copied from the Windows installation,
  # which a full-disk install has already erased; it can be rerun later.
  surface-pro-11-sensors-extract || true
  systemctl enable surface-pro-11-sensors.service surface-pro-11-power-profile-cpufreq.service
fi
