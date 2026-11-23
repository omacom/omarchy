echo "Keep the ThinkPad T480's TrackPoint on the i8042 controller"

# See install/hardware/lenovo/fix-thinkpad-t480-trackpoint.sh and issue #16252.
# The leaf knows which machines need it and leaves an administrator's own
# psmouse transport choice alone, so the same rules decide here.
source "$OMARCHY_PATH/install/hardware/lenovo/fix-thinkpad-t480-trackpoint.sh"

# The leaf does nothing on another model and nothing where the administrator
# chose a transport of their own, so only a machine that got the file needs
# the reboot that puts it in effect.
if [[ -e /etc/modprobe.d/omarchy-thinkpad-t480-trackpoint.conf ]]; then
  omarchy-state set reboot-required
fi
