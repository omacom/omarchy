echo "Pin Cursor's password store to gnome-libsecret so it finds the keyring on Hyprland"

# Cursor picks its secret store from the desktop name and finds none for Hyprland, so it warns
# that no OS keyring was found. Its launcher reads cursor-flags.conf, which new installs seed.
conf="${XDG_CONFIG_HOME:-$HOME/.config}/cursor-flags.conf"
if [[ ! -e $conf ]]; then
  mkdir -p "$(dirname "$conf")"
  cp "$OMARCHY_PATH/config/cursor-flags.conf" "$conf"
elif ! grep -q -- '^[[:space:]]*--password-store=' "$conf"; then
  [[ -n $(tail -c1 "$conf") ]] && echo >>"$conf"
  echo '--password-store=gnome-libsecret' >>"$conf"
fi
