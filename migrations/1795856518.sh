echo "Keep external USB3 controllers active on the ASUS Zenbook 14 (UX3480QA)"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3480QA"; then
  exit 0
fi

rules_file=/etc/udev/rules.d/90-asus-zenbook-14-ux3480qa-power.rules
if [[ -f $rules_file ]] && ! grep -qF 'qcom-qmp-combo-phy' "$rules_file"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-14-ux3480qa-power.sh"

  # Restore kernel-default power/control=on on external USB3 controllers, their
  # xhci-hcd children, and QMP PHYs for the running session.
  shopt -s nullglob
  for dev in /sys/bus/platform/devices/*; do
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
