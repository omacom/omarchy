echo "Enable ThinkPad keyboard backlight restore"

systemctl --user daemon-reload >/dev/null 2>&1 || true

# Updates can run outside a graphical session, so fall back to writing the
# symlink systemd would create when the user manager is unavailable.
if ! systemctl --user enable omarchy-thinkpad-keyboard-backlight.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-thinkpad-keyboard-backlight.service \
    "$wants_dir/omarchy-thinkpad-keyboard-backlight.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-thinkpad-keyboard-backlight.service >/dev/null 2>&1 || true
fi
