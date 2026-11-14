echo "Let power profiles switch on the Xiaomi Mi NoteBook Ultra"

# See install/hardware/xiaomi/fix-mi-notebook-ultra-power-profiles.sh, which
# sets up new installs the same way.
omarchy-hw-match "Mi NoteBook Ultra" || exit 0

# The drop-in is machine-wide, so another user's run may already have put it in place.
cmp -s "$OMARCHY_PATH/default/systemd/system/power-profiles-daemon.service.d/block-platform-profile.conf" \
  /etc/systemd/system/power-profiles-daemon.service.d/block-platform-profile.conf && exit 0

source "$OMARCHY_PATH/install/hardware/xiaomi/fix-mi-notebook-ultra-power-profiles.sh"
sudo systemctl daemon-reload

# A running daemon keeps the platform profile until restarted, and only then
# can it apply the AC/battery choice it refused before. Leave a daemon the user
# stopped or masked alone.
if systemctl is-active --quiet power-profiles-daemon.service; then
  sudo systemctl try-restart power-profiles-daemon.service
  # Switching needs polkit's active-session grant, which an update over SSH
  # lacks; omarchy-powerprofiles-init applies it at the next login instead.
  omarchy-powerprofiles-set autodetect || echo "The power profile will be applied at the next login"
fi
