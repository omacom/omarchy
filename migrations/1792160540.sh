echo "Ignore lid events on Razer Blade laptops with broken EC/ACPI firmware"

# Razer Blade laptops (verified on the Blade 15 Base Model (Late 2020),
# RZ09-03519) ship with EC/ACPI firmware whose wake handshake is broken, so
# the lid-close -> sleep -> lid-open -> wake flow fails: after a resume the
# lid state is stuck at "closed" and the machine re-suspends seconds after
# the lid opens, with omarchy-sleep-lock restarting in a loop. The
# install-time quirk (install/hardware/fix-razer-lid-sleep.sh) only reaches
# machines configured after it shipped, so existing installs still sleep on
# lid close on affected hardware. See
# https://github.com/omacom/omarchy/issues/15649 for the full evidence.

sys_vendor_file="${OMARCHY_RAZER_LID_SYS_VENDOR:-/sys/class/dmi/id/sys_vendor}"
product_name_file="${OMARCHY_RAZER_LID_PRODUCT_NAME:-/sys/class/dmi/id/product_name}"
conf="${OMARCHY_RAZER_LID_CONF:-/etc/systemd/logind.conf.d/30-razer-lid-ignore.conf}"

sys_vendor="$(cat "$sys_vendor_file" 2>/dev/null || true)"
product_name="$(cat "$product_name_file" 2>/dev/null || true)"

if [[ $sys_vendor != Razer* || $product_name != *Blade* ]]; then
  exit 0
fi

# A fresh install already carries this from the installer.
if [[ -f $conf ]]; then
  exit 0
fi

sudo mkdir -p "$(dirname "$conf")"
sudo tee "$conf" >/dev/null <<'EOF'
# Razer Blade laptops: the EC/ACPI firmware breaks the lid -> sleep path
# (stale lid state after resume, erratic EC wakes), and logind's default of
# sleeping on lid close turns that into a re-suspend loop with the lid open.
# Ignore lid events: the display switches off with the lid closed, the
# machine keeps running, and opening the lid reliably brings the display
# back. See https://github.com/omacom/omarchy/issues/15649
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF

# logind reads the drop-in at service start, so the running session keeps
# the old behavior until the next boot.
omarchy-state set reboot-required
