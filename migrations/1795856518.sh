echo "Keep external USB3 controllers active on the ASUS Zenbook 14 (UX3480QA)"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3480QA"; then
  exit 0
fi

udev_rules_dir=${OMARCHY_ZENBOOK_UX3480QA_UDEV_RULES_DIR:-/etc/udev/rules.d}
nm_conf_dir=${OMARCHY_ZENBOOK_UX3480QA_NM_CONF_DIR:-/etc/NetworkManager/conf.d}
platform_devices_dir=${OMARCHY_ZENBOOK_UX3480QA_PLATFORM_DEVICES_DIR:-/sys/bus/platform/devices}
rules_file="$udev_rules_dir/90-asus-zenbook-14-ux3480qa-power.rules"

needs_rules_update=false
if [[ ! -f $rules_file ]] || grep -qF 'qcom-qmp-combo-phy' "$rules_file"; then
  needs_rules_update=true
fi

needs_live_restore=false
shopt -s nullglob
for dev in "$platform_devices_dir"/*; do
  [[ -L $dev/driver && -r $dev/power/control ]] || continue
  name=$(basename "$dev")
  [[ $name == "a200000.usb" ]] && continue
  drv=$(basename "$(readlink -f "$dev/driver" 2>/dev/null || true)" 2>/dev/null || true)
  case "$drv" in
    dwc3-qcom|qcom-qmp-combo-phy|qcom-qmp-usb-phy)
      [[ $(<"$dev/power/control") != "on" ]] && needs_live_restore=true
      ;;
    xhci-hcd)
      parent=$(basename "$(dirname "$(readlink -f "$dev")")")
      [[ $parent == "a200000.usb" ]] && continue
      [[ $(<"$dev/power/control") != "on" ]] && needs_live_restore=true
      ;;
  esac
done

if ! $needs_rules_update && ! $needs_live_restore; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" \
  OMARCHY_ZENBOOK_UX3480QA_NM_CONF_DIR="$nm_conf_dir" \
  OMARCHY_ZENBOOK_UX3480QA_UDEV_RULES_DIR="$udev_rules_dir" \
  OMARCHY_ZENBOOK_UX3480QA_PLATFORM_DEVICES_DIR="$platform_devices_dir" \
  bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-14-ux3480qa-power.sh"

  # Restore kernel-default power/control=on on external USB3 controllers, their
  # xhci-hcd children, and QMP PHYs for the running session.
  shopt -s nullglob
  for dev in "$OMARCHY_ZENBOOK_UX3480QA_PLATFORM_DEVICES_DIR"/*; do
    [[ -L $dev/driver && -w $dev/power/control ]] || continue
    name=$(basename "$dev")
    [[ $name == "a200000.usb" ]] && continue
    drv=$(basename "$(readlink -f "$dev/driver" 2>/dev/null || true)" 2>/dev/null || true)
    case "$drv" in
      dwc3-qcom|qcom-qmp-combo-phy|qcom-qmp-usb-phy)
        printf "on" >"$dev/power/control" 2>/dev/null || true
        ;;
      xhci-hcd)
        parent=$(basename "$(dirname "$(readlink -f "$dev")")")
        [[ $parent == "a200000.usb" ]] && continue
        printf "on" >"$dev/power/control" 2>/dev/null || true
        ;;
    esac
  done
'
