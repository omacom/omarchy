echo "Enable power tuning and PSCI deep sleep on the ASUS Zenbook 14 (UX3480QA)"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3480QA"; then
  exit 0
fi

dt_root="${OMARCHY_DT_ROOT:-/sys/firmware/devicetree/base}"

# Apply Wi-Fi 6E power save and USB/PHY runtime PM + webcam wakeup rules
# immediately; both are safe on any kernel/DTB version.
sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-14-ux3480qa-power.sh"
  nmcli general reload conf >/dev/null 2>&1 || true

  # NetworkManager only applies wifi.powersave when a connection activates, so
  # also enable it directly for the running session unless the active profile
  # explicitly overrides 802-11-wireless.powersave (1=ignore, 2=disable).
  shopt -s nullglob
  for wireless in /sys/class/net/*/wireless; do
    iface=$(basename "$(dirname "$wireless")")
    uuid=$(nmcli -g GENERAL.CON-UUID dev show "$iface" 2>/dev/null || true)
    powersave=""
    if [[ -n $uuid && $uuid != "--" ]]; then
      if ! powersave=$(nmcli -g 802-11-wireless.powersave con show uuid "$uuid" 2>/dev/null); then
        continue
      fi
    fi
    if [[ -z $powersave || $powersave == 0* || $powersave == 3* || $powersave == "default" || $powersave == "enable" ]]; then
      iw dev "$iface" set power_save on 2>/dev/null || true
    fi
  done
'

# Switching from s2idle to PSCI deep sleep requires linux-omarchy-dtbs >= 7.3-77
# (drops wakeup-event-action from switch-lid so open-lid deep suspend does not
# wake on CX collapse exit) booted on the running kernel.
dtbs_ver=$(pacman -Q linux-omarchy-dtbs 2>/dev/null | awk '{print $2}') || dtbs_ver=""
if [[ -z $dtbs_ver ]] || (( $(vercmp "$dtbs_ver" 7.3-77) < 0 )); then
  echo "Waiting for linux-omarchy-dtbs >= 7.3-77 before switching to deep sleep"
  exit 75
fi

if [[ ! -d $dt_root/gpio-keys/switch-lid || -e $dt_root/gpio-keys/switch-lid/wakeup-event-action ]]; then
  omarchy-state set reboot-required
  echo "Reboot required to load the updated ASUS Zenbook 14 device tree before switching to deep sleep"
  exit 75
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" OMARCHY_ZENBOOK_UX3480QA_DT_ROOT="$dt_root" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-14-ux3480qa-boot.sh"
'
