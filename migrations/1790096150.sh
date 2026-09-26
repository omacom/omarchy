echo "Seed fcitx5 DefaultIM from the console keyboard layout"

# fcitx5 defaults to keyboard-us. On a non-US install that IM wins for Qt
# fields (lock screen password) even when Hyprland's kb_layout from
# /etc/vconsole.conf is correct. Rewrite only the stock single-IM us profile;
# multi-IM setups are left alone. Fresh installs get the same seed from
# install/user/fcitx5-layout.sh.

# Seed helper stops a running fcitx5 before rewriting the profile so the
# daemon cannot flush the old layout back over the seed on exit.
changed=$(omarchy-fcitx5-seed-layout)
[[ $changed == changed ]] || exit 0

# Bring fcitx5 back up against the rewritten profile when a session is live;
# otherwise the next graphical login starts it cleanly.
if systemctl --user is-active --quiet graphical-session.target; then
  omarchy-restart-xcompose >/dev/null 2>&1 || true
fi
