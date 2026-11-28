# Power management on the ASUS Zenbook 14 UX3480QA/UX3480QAB (Snapdragon X
# X1-26-100, Qualcomm WCN6855).
#
# 1. Wi-Fi 6E power save: Omarchy disables Wi-Fi power save globally in
#    omarchy-wifi-powersave.conf because Intel BE200/BE211 firmware drops links
#    and many cards add 20-300 ms latency spikes. On the UX3480QA's WCN6855
#    (ath11k_pci, 6 GHz 160 MHz), power save drops settled idle power from
#    2.37 W to 1.92 W (-0.45 to -0.48 W) with 4.9-14.1 ms idle-link latency.
# 2. Internal USB2 webcam controller (a200000.usb) runtime PM & wakeup: Allow
#    a200000.usb and its xhci-hcd child to runtime-suspend so gcc_usb20_prim_gdsc
#    powers down at idle, and disable wakeup (PDC 50 dp_hs_phy_irq) so it does
#    not spuriously wake deep sleep after ~5 minutes.
#    Leave external USB3 controllers (a4/a6/a800000.usb), their xhci-hcd
#    children, and QMP PHYs at default power/control=on: Purwa's DT sets
#    snps,dis_u2_susphy_quirk on all three external controllers, and runtime-
#    suspending them during pmic_glink USB-C negotiation causes "HS-PHY not in
#    L2" / "HC died" with zero wakeup IRQs, killing USB-C docks and Ethernet.

nm_conf_dir=${OMARCHY_ZENBOOK_UX3480QA_NM_CONF_DIR:-/etc/NetworkManager/conf.d}
udev_rules_dir=${OMARCHY_ZENBOOK_UX3480QA_UDEV_RULES_DIR:-/etc/udev/rules.d}
run_udev_dir=${OMARCHY_ZENBOOK_UX3480QA_RUN_UDEV_DIR:-/run/udev}
platform_devices_dir=${OMARCHY_ZENBOOK_UX3480QA_PLATFORM_DEVICES_DIR:-/sys/bus/platform/devices}

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

# Enable runtime PM auto-suspend and disable spurious deep-sleep wakeup (PDC 50
# dp_hs_phy_irq) on the internal USB2 webcam controller (a200000.usb) and its
# xhci-hcd child so gcc_usb20_prim_gdsc powers down at idle.
# Leave external USB3 controllers (a4/a6/a800000.usb), their xhci-hcd children,
# and QMP PHYs at kernel defaults: Purwa sets snps,dis_u2_susphy_quirk on all
# three external controllers (runtime-suspending them drops USB-C docks/Ethernet
# with "HS-PHY not in L2" / "HC died"), and disabling their wakeup hard-resets
# Purwa in suspend_noirq.
ACTION=="add|bind|change", SUBSYSTEM=="platform", KERNEL=="a200000.usb", DRIVER=="dwc3-qcom", \
  ATTR{power/control}="auto", ATTR{power/wakeup}="disabled"
ACTION=="add|bind|change", SUBSYSTEM=="platform", KERNELS=="a200000.usb", DRIVER=="xhci-hcd", \
  ATTR{power/control}="auto"

LABEL="zenbook_ux3480qa_power_end"
RULES

  # Apply the rules immediately on a live booted system (first-boot setup,
  # omarchy-apply-hardware, and upgrades), skipping install chroots where
  # /run/udev is bind-mounted from the live ISO.
  if [[ ($udev_rules_dir == "/etc/udev/rules.d" || -n ${OMARCHY_ZENBOOK_UX3480QA_RUN_UDEV_DIR:-}) && -d $run_udev_dir ]] &&
    ! systemd-detect-virt --chroot -q 2>/dev/null &&
    command -v udevadm >/dev/null 2>&1; then
    udevadm control --reload >/dev/null 2>&1 || true
    if [[ -d $platform_devices_dir/a200000.usb ]]; then
      udevadm trigger --action=change --sysname-match="a200000.usb" --subsystem-match=platform >/dev/null 2>&1 || true
      for child in "$platform_devices_dir"/a200000.usb/xhci-hcd.*; do
        [[ -d $child ]] || continue
        udevadm trigger --action=change --sysname-match="$(basename "$child")" --subsystem-match=platform >/dev/null 2>&1 || true
      done
    fi
  fi
fi
