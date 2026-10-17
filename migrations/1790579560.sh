echo "Enable the Turbo key, fan sensor and extra power profiles on the Acer Nitro ANV14-61"

# The install-time quirk only reaches machines set up after it shipped. See
# install/hardware/acer/enable-predator-v4.sh for what predator_v4 changes on
# this model and why other Acer laptops are left alone.
conf="${OMARCHY_ACER_WMI_CONF:-/etc/modprobe.d/acer-wmi.conf}"

omarchy-hw-acer-predator-v4 || exit 0
modinfo -p acer_wmi 2>/dev/null | grep '^predator_v4:' >/dev/null || exit 0

# New installs carry this from the installer, and the first user to run the
# migration covers everyone after them. Any predator_v4 line, active or
# commented out, is a choice someone already made about this option.
if [[ -f $conf ]] && grep -q 'predator_v4' "$conf"; then
  exit 0
fi

sudo mkdir -p "$(dirname "$conf")"

# Append rather than overwrite, so anything else a user keeps here survives.
# The leading newline also covers a file that ends without one.
sudo tee -a "$conf" >/dev/null <<'CONF'

# This model is missing from acer-wmi's DMI quirk table. Without the Predator v4
# interface its Turbo key, fan sensor and quiet/balanced-performance profiles
# are unavailable.
options acer_wmi predator_v4=1
CONF

# modprobe only reads this when acer_wmi loads, and the module cannot be
# reloaded safely while the session is using its hotkeys and sensors.
omarchy-state set reboot-required
