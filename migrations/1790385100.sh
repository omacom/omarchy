echo "Repair a corrupt passwordless default keyring before session apps use it"

# Existing installs can already be stuck on a password-protected Default_Keyring
# that autologin cannot unlock, or on a cleartext file poisoned by a multi-line
# secret. Enable the early session repair and run it once now.
omarchy-keyring-repair || true

systemctl --user daemon-reload >/dev/null 2>&1 || true

# `systemctl enable` needs a live user manager, which an update from a TTY does
# not have, so fall back to writing the symlink it would have written.
if ! systemctl --user enable omarchy-keyring-repair.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session-pre.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/omarchy-keyring-repair.service \
    "$wants_dir/omarchy-keyring-repair.service"
fi
