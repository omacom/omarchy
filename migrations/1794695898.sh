echo "Replace GNOME Keyring with oo7"

gnome_keyring_units=(gnome-keyring-daemon.socket gnome-keyring-daemon.service)
keyrings_dir="${XDG_DATA_HOME:-$HOME/.local/share}/keyrings"
keyrings_backup="$keyrings_dir.pre-oo7"
portal_config="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-desktop-portal/hyprland-portals.conf"

# The package swap below removes these units for every user, so a user migrating
# after the first one finds them gone already.
systemctl --user disable --now "${gnome_keyring_units[@]}" 2>/dev/null || true

restore_gnome_keyring() {
  systemctl --user enable --now gnome-keyring-daemon.socket 2>/dev/null || true
  exit 1
}

# A multi-line secret written by gnome-keyring (#5105) stops oo7-daemon from
# starting at all, so repair first. If that fails, nothing has changed yet, and
# the migration stays pending with the keyring intact.
omarchy-keyring-repair || restore_gnome_keyring

# oo7 before 0.7 can't read gnome-keyring's plain-text keyrings, so an older one,
# installed or the only one a mirror has, fails the swap and leaves this pending.
# Since 0.7, oo7 no longer conflicts with gnome-keyring, so oo7 goes in first,
# keeping omarchy's org.freedesktop.secrets satisfied, and gnome-keyring is removed
# after. Left installed, its D-Bus activation file, PAM module and autostart
# entries would race oo7-daemon for the Secret Service at every login. Until
# oo7-daemon is enabled below, a failure leaves oo7 installed but idle.
oo7_min="oo7>=0.7.1"
if ! pacman -T "$oo7_min" gcr >/dev/null; then
  sudo pacman -S --noconfirm --needed "$oo7_min" gcr || restore_gnome_keyring
fi
if omarchy-pkg-present gnome-keyring; then
  sudo pacman -R --noconfirm gnome-keyring || restore_gnome_keyring
fi

# This copy, and the login.keyring oo7 leaves behind, still hold the secrets in
# plain text. They're the way back if a repair or the move goes wrong, so a later
# migration removes them once this has proven itself.
if [[ -d $keyrings_dir && ! -e $keyrings_backup ]]; then
  cp -a "$keyrings_dir" "$keyrings_backup"
  chmod 700 "$keyrings_backup"
fi

# oo7 only treats the keyring named "login" as the default collection, and doesn't
# read gnome-keyring's "default" pointer file. Left under Omarchy's name, the keyring
# would load beside a new empty default, and the Secret portal, which only looks in
# the default collection, would hand sandboxed apps a new key they can't decrypt with.
if [[ -f $keyrings_dir/default && ! -e $keyrings_dir/login.keyring ]]; then
  default_keyring=$(<"$keyrings_dir/default")
  if [[ -n $default_keyring && $default_keyring != */* && -f $keyrings_dir/$default_keyring.keyring ]]; then
    mv "$keyrings_dir/$default_keyring.keyring" "$keyrings_dir/login.keyring"
  fi
fi

omarchy-keyring-seal

# `systemctl disable` and `enable` need a live user manager, which an update from
# a TTY doesn't have, so write what they would have written.
rm -f "$HOME"/.config/systemd/user/*.wants/gnome-keyring-daemon.{socket,service}
systemctl --user daemon-reload >/dev/null 2>&1 || true
if ! systemctl --user enable oo7-daemon.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/default.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn /usr/lib/systemd/user/oo7-daemon.service "$wants_dir/oo7-daemon.service"
fi

# With no session to serve, the next login starts it. A failed live start leaves
# the migration pending, because nothing else provides the Secret Service now.
if [[ ${OMARCHY_UPGRADE_TO_QUATTRO_LIVE:-0} != 1 ]] && systemctl --user is-active --quiet default.target 2>/dev/null; then
  systemctl --user start oo7-daemon.service
fi

if [[ -f $portal_config ]]; then
  sed -i 's/^org\.freedesktop\.impl\.portal\.Secret=gnome-keyring$/org.freedesktop.impl.portal.Secret=oo7-portal/' "$portal_config"
fi

if systemctl --user is-active --quiet xdg-desktop-portal.service 2>/dev/null; then
  systemctl --user restart xdg-desktop-portal.service || echo "Failed to restart xdg-desktop-portal" >&2
fi
