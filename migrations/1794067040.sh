echo "Keep the ThinkPad T480's TrackPoint on the i8042 controller"

# See install/hardware/lenovo/fix-thinkpad-t480-trackpoint.sh and issue #16252.
# An existing psmouse transport choice is the user's to keep.
modprobe_dir=/etc/modprobe.d
psmouse_options='^[[:space:]]*options[[:space:]]+psmouse[[:space:]].*synaptics_intertouch'

if ! omarchy-hw-match '^20L[56]' || grep -qsE "$psmouse_options" "$modprobe_dir"/*.conf; then
  exit 0
fi

sudo install -Dm644 /dev/stdin "$modprobe_dir/omarchy-thinkpad-t480-trackpoint.conf" <<'CONF'
# Keep the TrackPoint on i8042 so psmouse can recover it after a PS/2 desync.
# See install/hardware/lenovo/fix-thinkpad-t480-trackpoint.sh.
options psmouse synaptics_intertouch=0
CONF

omarchy-state set reboot-required
