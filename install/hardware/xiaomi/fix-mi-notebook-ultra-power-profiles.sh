# Let power profiles switch on the Xiaomi Mi NoteBook Ultra (TIMI TM2017).
# The drop-in says why power-profiles-daemon has to ignore the firmware's
# platform profile there.

if omarchy-hw-match "Mi NoteBook Ultra"; then
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/power-profiles-daemon.service.d/block-platform-profile.conf" \
    /etc/systemd/system/power-profiles-daemon.service.d/block-platform-profile.conf
fi
