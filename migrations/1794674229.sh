echo "Leave Turing's NVIDIA firmware out of the N1x initramfs"

# See install/hardware/n1x.sh, which writes the same drop-in for new installs.
# Only where the GPU drives the panel, which early-loads the NVIDIA modules.
# The next initramfs rebuild picks it up.
conf_dir="${OMARCHY_MKINITCPIO_CONF_DIR:-/etc/mkinitcpio.conf.d}"

omarchy-hw-aarch64-n1x || exit 0
[[ -f $conf_dir/nvidia.conf && ! -f $conf_dir/omarchy-n1x-nvidia-firmware.conf ]] || exit 0

sudo install -Dm644 /dev/stdin "$conf_dir/omarchy-n1x-nvidia-firmware.conf" <<'CONF'
# N1x: the Blackwell GPU boots its GSP from the ga10x firmware. The nvidia
# module also lists Turing's (tu10x), which only Turing GPUs load: leave it out
# of the initramfs, about 32 MB. mkinitcpio sources this file again after the
# hooks run, so add_firmware is wrapped only once. It returns the status of the
# firmware it did add, which add_module reads to warn about missing firmware.
if declare -F add_firmware >/dev/null && ! declare -F _omarchy_n1x_add_firmware >/dev/null; then
  eval "_omarchy_n1x_$(declare -f add_firmware)"
  add_firmware() {
    local fw
    local -a kept=()
    local -i status=0
    for fw; do
      case $fw in
        nvidia/*/gsp_tu10x.bin | nvidia/*/ucodes_tu10x.bin) ;;
        *) kept+=("$fw") ;;
      esac
    done
    if ((${#kept[@]})); then
      _omarchy_n1x_add_firmware "${kept[@]}" || status=$?
    fi
    return "$status"
  }
fi
CONF
