# Keep the ThinkPad T480's TrackPoint on the i8042 controller.
#
# The T480's Synaptics touchpad defaults to RMI4/InterTouch, and the TrackPoint
# then reaches psmouse through the touchpad's PS/2 passthrough
# (rmi4-00.fn03/serio0). When that passthrough loses sync it cannot recover:
# psmouse's recovery deactivates the psmouse parent and re-probes it, and an
# RMI4 passthrough has no psmouse parent. The TrackPoint is left sending
# misaligned packets or dead until the next reboot, and on this generation the
# keyboard can stall with it.
#
# Turning InterTouch off puts the TrackPoint back on the i8042 controller as a
# child of the touchpad's psmouse, so the same recovery can deactivate and
# re-probe it. The T480's touchpad works in either mode; PS/2 reports events
# less often, which is the price of a TrackPoint that recovers.
#
# This works around firmware that cannot be fixed here. Drop it if a kernel
# release learns to reset the RMI4 passthrough on its own; a psmouse option the
# administrator already set is left alone.
# See https://github.com/omacom/omarchy/issues/16252.
modprobe_dir="${OMARCHY_TRACKPOINT_MODPROBE_DIR:-/etc/modprobe.d}"
psmouse_options='^[[:space:]]*options[[:space:]]+psmouse[[:space:]].*synaptics_intertouch'

if omarchy-hw-match '^20L[56]' && ! grep -qsE "$psmouse_options" "$modprobe_dir"/*.conf; then
  mkdir -p "$modprobe_dir"
  cat >"$modprobe_dir/omarchy-thinkpad-t480-trackpoint.conf" <<'CONF'
# Keep the TrackPoint on i8042 so psmouse can recover it after a PS/2 desync.
# See install/hardware/lenovo/fix-thinkpad-t480-trackpoint.sh.
options psmouse synaptics_intertouch=0
CONF
fi
