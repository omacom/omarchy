# Disk unlock on the ASUS Vivobook S 15 S5507QA (Snapdragon X Elite).

mkinitcpio_dir=${OMARCHY_VIVOBOOK_S15_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

# The X Plus model reports S5507QA_S5507QA, runs another device tree and has
# not been tested.
if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "S5507QAD"; then
  # The display driver waits for the USB-C DisplayPort chain, so the panel
  # stays black at the unlock prompt until that chain and the display clocks
  # and PHYs load, which is otherwise only after unlock. Load them early, with
  # the IPC router and PD mapper pmic_glink needs. The ? skips a module a
  # kernel does not have.
  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/vivobook-s15-initramfs.conf" <<'CONF'
MODULES+=(msm? dispcc_x1e80100? gpucc_x1e80100? phy_qcom_edp? panel_samsung_atna33xc20?
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
