# Chuwi MiniBook X: stop the pointer shaking under a resting finger.
#
# The Hantick 0911:5288 touchpad reports a few units of noise while a finger
# holds still but declares no axis fuzz, so libinput applies no hysteresis and
# passes every wobble on to the pointer. Declare the fuzz in hwdb; libinput
# takes it as its hysteresis margin. 12 holds the pointer still without making
# slow, small movements sticky.

hwdb_dir=${OMARCHY_MINIBOOK_X_HWDB_DIR:-/etc/udev/hwdb.d}

if omarchy-hw-chuwi-minibook-x; then
  mkdir -p "$hwdb_dir"
  cat >"$hwdb_dir/61-omarchy-chuwi-minibook-x-touchpad.hwdb" <<'HWDB'
# Chuwi MiniBook X touchpad: declare axis fuzz so libinput filters jitter;
# see install/hardware/chuwi/fix-minibook-x-touchpad.sh.
evdev:name:* 0911:5288*:dmi:*svnCHUWI*:pnMiniBookX:*
 EVDEV_ABS_00=:::12
 EVDEV_ABS_01=:::12
 EVDEV_ABS_35=:::12
 EVDEV_ABS_36=:::12
HWDB
  systemd-hwdb update
fi
