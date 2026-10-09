echo "Enable automatic keyboard lighting from the ambient light sensor"

systemctl --user daemon-reload >/dev/null 2>&1 || true
if ! systemctl --user enable omarchy-brightness-keyboard-auto.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-brightness-keyboard-auto.service "$wants_dir/omarchy-brightness-keyboard-auto.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-brightness-keyboard-auto.service >/dev/null 2>&1 || true
fi
