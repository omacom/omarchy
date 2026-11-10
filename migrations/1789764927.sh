echo "Enable OWE desktop video backgrounds and lock feed"

omarchy-pkg-add owe owe-lockfeed
omarchy-hook-install theme-set /usr/share/owe/10-owe-sync

systemctl --user daemon-reload >/dev/null 2>&1 || true
if ! systemctl --user enable owed.service; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/owed.service "$wants_dir/owed.service"
fi

# A TTY update enables the next graphical login without starting a renderer
# against a missing Wayland session. A failed live start leaves this pending.
if [[ ${OMARCHY_UPGRADE_TO_QUATTRO_LIVE:-0} != 1 ]] && systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start owed.service
fi
