# Disk unlock on the Dell XPS 13 9345 (Snapdragon X Elite).

mkinitcpio_dir=${OMARCHY_XPS13_9345_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree dell,xps13-9345; then
  # The kms hook puts msm in the initramfs, where it takes the panel over from
  # simpledrm but draws again only once every DisplayPort controller binds. The
  # two USB-C ones wait on the ps883x retimers and pmic_glink_altmode, which
  # otherwise load only after unlock, so the prompt stays black. Load that
  # chain, the display clocks and PHYs, and the IPC router and PD mapper
  # pmic_glink needs. The ? skips a module a kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/dell-xps13-9345-initramfs.conf" <<'CONF'
MODULES+=(msm? dispcc_x1e80100? gpucc_x1e80100? phy_qcom_edp? panel_edp?
  phy_qcom_qmp_combo? ps883x? qrtr? qcom_pd_mapper? pmic_glink? pmic_glink_altmode?)

# The Adreno X1's microcode, requested once when the display driver loads
# early. The board-signed zap shader is included by qcom-firmware-extract.
for firmware in qcom/gen70500_sqe.fw qcom/gen70500_gmu.bin; do
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
