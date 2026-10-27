echo "Restore Bluetooth on/off preference after login"

# BlueZ AutoEnable can race systemd-rfkill across reboot (#13342). Re-apply the
# last omarchy-bluetooth-power choice once the graphical session is up.

unit_src="$OMARCHY_PATH/default/systemd/user/omarchy-bluetooth-power-restore.service"
unit_dst="$HOME/.config/systemd/user/omarchy-bluetooth-power-restore.service"

mkdir -p -- "$(dirname -- "$unit_dst")"
install -Dm644 -- "$unit_src" "$unit_dst"

systemctl --user daemon-reload >/dev/null 2>&1 || true

if ! systemctl --user enable omarchy-bluetooth-power-restore.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn "$unit_dst" "$wants_dir/omarchy-bluetooth-power-restore.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-bluetooth-power-restore.service >/dev/null 2>&1 || true
fi
