echo "Show an OSD when the firmware changes the ACPI platform profile"

# install/user/first-run only runs on the first login of a fresh install, so
# existing installs get the unit enabled here instead.

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written.
if ! systemctl --user enable omarchy-powerprofiles-osd.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-powerprofiles-osd.service \
    "$wants_dir/omarchy-powerprofiles-osd.service"
fi

# Nothing to start into over SSH; the next graphical login handles it. A failed
# start only delays the OSD, so it stays quiet.
if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start omarchy-powerprofiles-osd.service >/dev/null 2>&1 || true
fi
