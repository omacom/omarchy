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

# This copy, and the login.keyring oo7 leaves behind, still hold the secrets in
# plain text. Taken before the repair, it's the way back if the repair or the
# move goes wrong, so a later migration removes them once this has proven itself.
if [[ -d $keyrings_dir && ! -e $keyrings_backup ]]; then
  cp -a "$keyrings_dir" "$keyrings_backup"
  chmod 700 "$keyrings_backup"
fi

# A multi-line secret written by gnome-keyring (#5105) stops oo7-daemon from
# starting at all, so repair first. Without the repair command nothing has
# changed yet, and the migration stays pending.
command -v omarchy-keyring-repair >/dev/null || restore_gnome_keyring

# Some keyrings can't be repaired safely, on this run or any later one, so
# leaving the migration pending would hold back every migration after it. Each
# keyring is tried on its own copy to find those, and they move into the backup,
# out of oo7's way. A repair that still fails, from a read or write error, leaves
# the migration pending.
if ! omarchy-keyring-repair; then
  for keyring in "$keyrings_dir"/*.keyring; do
    [[ -f $keyring ]] || continue
    probe=$(mktemp -d)
    if cp "$keyring" "$probe/" && ! OMARCHY_KEYRING_DIR=$probe omarchy-keyring-repair 2>/dev/null; then
      mv "$keyring" "$keyrings_backup/${keyring##*/}.unrepairable"
      echo "The keyring ${keyring##*/} can't be repaired safely, so its secrets are no longer available to apps." >&2
      echo "It was moved to $keyrings_backup/${keyring##*/}.unrepairable." >&2
    fi
    rm -rf "$probe"
  done
  omarchy-keyring-repair || restore_gnome_keyring
fi

# oo7 before 0.7 can't read gnome-keyring's plain-text keyrings, and before 0.7.3
# unlocking or re-keying a keyring it hasn't converted yet could reach the empty
# placeholder standing in for it and throw its secrets away. So an older oo7,
# installed or the only one a mirror has, fails the swap and leaves this pending.
# Since 0.7, oo7 no longer conflicts with gnome-keyring, so oo7 goes in first,
# keeping omarchy's org.freedesktop.secrets satisfied, and gnome-keyring is removed
# after. Left installed, its D-Bus activation file, PAM module and autostart
# entries would race oo7-daemon for the Secret Service at every login. Until
# oo7-daemon is enabled below, a failure leaves oo7 installed but idle.
oo7_min="oo7>=0.7.3"
if ! pacman -T "$oo7_min" gcr >/dev/null; then
  sudo pacman -S --noconfirm --needed "$oo7_min" gcr || restore_gnome_keyring
fi
if omarchy-pkg-present gnome-keyring; then
  sudo pacman -R --noconfirm gnome-keyring || restore_gnome_keyring
fi

# oo7 only treats the keyring named "login" as the default collection, and doesn't
# read gnome-keyring's "default" pointer file. Left under Omarchy's name, the keyring
# would load beside a new empty default, and the Secret portal, which only looks in
# the default collection, would hand sandboxed apps a new key they can't decrypt with.
# A login keyring next to another chosen default, left by a password login through
# pam_gnome_keyring, would take the default's place, so it moves to a free name and
# stays available as a collection of its own.
if [[ -f $keyrings_dir/default ]]; then
  default_keyring=$(<"$keyrings_dir/default")
  if [[ -n $default_keyring && $default_keyring != */* && $default_keyring != "login" &&
    -f $keyrings_dir/$default_keyring.keyring ]]; then
    if [[ -e $keyrings_dir/login.keyring ]]; then
      previous_login="previous_login"
      n=1
      while [[ -e $keyrings_dir/$previous_login.keyring ]]; do
        previous_login="previous_login_$((++n))"
      done
      mv "$keyrings_dir/login.keyring" "$keyrings_dir/$previous_login.keyring"
      echo "The keyring login.keyring was renamed to $previous_login.keyring, so $default_keyring stays the default." >&2
    fi
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

# A keyring with a password of its own doesn't open with the sealed credential, so
# it would stay locked at every login, and apps would ask for its password or miss
# its items. Its secrets are safe either way, so a skip or a failure here doesn't hold
# the migration back; the command says how to finish later.
omarchy-keyring-rekey || true

if [[ -f $portal_config ]]; then
  sed -i 's/^org\.freedesktop\.impl\.portal\.Secret=gnome-keyring$/org.freedesktop.impl.portal.Secret=oo7-portal/' "$portal_config"
fi

if systemctl --user is-active --quiet xdg-desktop-portal.service 2>/dev/null; then
  systemctl --user restart xdg-desktop-portal.service || echo "Failed to restart xdg-desktop-portal" >&2
fi
