# Power management on the ASUS Zenbook 14 UX3480QA/UX3480QAB (Snapdragon X
# X1-26-100, Qualcomm WCN6855).
#
# 1. Wi-Fi 6E power save: Omarchy disables Wi-Fi power save globally in
#    omarchy-wifi-powersave.conf because Intel BE200/BE211 firmware drops links
#    and many cards add 20-300 ms latency spikes. On the UX3480QA's WCN6855
#    (ath11k_pci, 6 GHz 160 MHz), power save drops settled idle power from
#    2.37 W to 1.92 W (-0.45 to -0.48 W) with 4.9-14.1 ms idle-link latency.
# 2. USB/PHY runtime PM & webcam wakeup: Allow idle Qualcomm USB controllers
#    and QMP PHYs to runtime-suspend so unused USB/PHY GDSCs power down, and
#    disable wakeup on the internal USB2 webcam controller (a200000.usb, PDC 50
#    dp_hs_phy_irq) so it does not spuriously wake deep sleep after ~5 minutes.

nm_conf_dir=${OMARCHY_ZENBOOK_UX3480QA_NM_CONF_DIR:-/etc/NetworkManager/conf.d}
udev_rules_dir=${OMARCHY_ZENBOOK_UX3480QA_UDEV_RULES_DIR:-/etc/udev/rules.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3480QA"; then
  mkdir -p "$nm_conf_dir"
  cat >"$nm_conf_dir/zz-zenbook-14-ux3480qa-wifi-powersave.conf" <<'CONF'
# Override omarchy-wifi-powersave.conf on the ASUS Zenbook 14 UX3480QA (WCN6855):
# saves ~0.45-0.48 W on 6 GHz 160 MHz with 4.9-14.1 ms idle-link ping latency.
[connection]
wifi.powersave = 3
CONF

  mkdir -p "$udev_rules_dir"
  cat >"$udev_rules_dir/90-asus-zenbook-14-ux3480qa-power.rules" <<'RULES'
# Active/idle and deep sleep power management for the ASUS Zenbook 14 (UX3480QA/UX3480QAB, Purwa).

# Positive DMI guard so machines without DMI or with another board skip all rules.
ATTR{[dmi/id]sys_vendor}=="ASUS*", ATTR{[dmi/id]board_name}=="UX3480QA*", GOTO="zenbook_ux3480qa_power_start"
GOTO="zenbook_ux3480qa_power_end"
LABEL="zenbook_ux3480qa_power_start"

# Enable runtime PM auto-suspend on idle Qualcomm USB controllers and PHYs so
# unused USB/PHY GDSCs power down at idle.
ACTION=="add|bind|change", SUBSYSTEM=="platform", DRIVER=="dwc3-qcom", \
  ATTR{power/control}="auto", ATTR{power/autosuspend_delay_ms}="200"
ACTION=="add|bind|change", SUBSYSTEM=="platform", DRIVER=="xhci-hcd", \
  ATTR{power/control}="auto"
ACTION=="add|bind|change", SUBSYSTEM=="platform", DRIVER=="qcom-qmp-combo-phy|qcom-qmp-usb-phy", \
  ATTR{power/control}="auto"

# Disable wakeup on the internal USB2 webcam controller (a200000.usb, PDC 50
# dp_hs_phy_irq) so it does not spuriously wake deep sleep after ~5 minutes.
# Leave external USB3 controllers (a4/a6/a800000.usb) at their default wakeup
# setting because disabling their wakeup resets Purwa in suspend_noirq.
ACTION=="add|bind|change", SUBSYSTEM=="platform", KERNEL=="a200000.usb", DRIVER=="dwc3-qcom", \
  ATTR{power/wakeup}="disabled"

LABEL="zenbook_ux3480qa_power_end"
RULES

  # Apply the rules immediately on a live booted system (first-boot setup,
  # omarchy-apply-hardware, and upgrades) so webcam wakeup is disabled and USB
  # runtime PM is active during the first session too.
  if [[ $udev_rules_dir == "/etc/udev/rules.d" && -d /run/udev ]] && command -v udevadm >/dev/null 2>&1; then
    udevadm control --reload >/dev/null 2>&1 || true
    for dev in /sys/bus/platform/devices/*; do
      [[ -L $dev/driver ]] || continue
      drv=$(basename "$(readlink -f "$dev/driver" 2>/dev/null || true)" 2>/dev/null || true)
      case "$drv" in
        dwc3-qcom|xhci-hcd|qcom-qmp-combo-phy|qcom-qmp-usb-phy)
          udevadm trigger --action=change --sysname-match="$(basename "$dev")" --subsystem-match=platform >/dev/null 2>&1 || true
          ;;
      esac
    done
  fi
fi
