echo "Seed fcitx5 DefaultIM from the console keyboard layout"

# fcitx5 defaults to keyboard-us. On a non-US install that IM wins for Qt
# fields (lock screen password) even when Hyprland's kb_layout from
# /etc/vconsole.conf is correct. Rewrite only the stock single-IM us profile;
# multi-IM setups are left alone. Fresh installs get the same seed from
# install/user/fcitx5-layout.sh.

# The helper stops this user's daemon before writing and restores it on exit
# if it was running in a graphical session, including on failure.
omarchy-fcitx5-seed-layout >/dev/null
