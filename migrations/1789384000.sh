echo "Reclaim pre-4.0 user-owned Plymouth and SDDM theme directories"

# Pre-4.0 ISO installs created /usr/share/plymouth/themes/omarchy (and the
# sibling SDDM theme dir) as the installing user with mode 0700. Pacman does
# not re-chown an existing directory on upgrade, so 4.0+ omarchy-plymouth-set
# refuses to publish into it forever ("must be root-owned..."). A user-owned
# boot theme directory is also a privileged-path ownership hole: anything that
# user writes there is consumed by the boot splash as root. Same pattern as
# migrations/1788662350.sh for other pre-4.0 privileged paths.

plymouth_theme=/usr/share/plymouth/themes/omarchy
sddm_theme=/usr/share/sddm/themes/omarchy

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Symlinks are not ours to chown (would retarget whatever they point at).
# Missing paths are fine — a fresh package install owns them correctly.
reclaim_theme_directory() {
  local path=$1
  local uid mode

  if [[ -L $path ]]; then
    echo "  Leaving $path alone (symlink)."
    return 0
  fi

  if [[ ! -d $path ]]; then
    return 0
  fi

  uid=$(stat -c %u -- "$path") || return 1
  mode=$(stat -c %a -- "$path") || return 1

  if (( uid == 0 )) && (( (8#$mode & 0022) == 0 )); then
    return 0
  fi

  echo "  Repairing $path (was uid=$uid mode=$mode)"
  as_root chown root:root -- "$path"
  as_root chmod 755 -- "$path"
}

reclaim_theme_directory "$plymouth_theme"
reclaim_theme_directory "$sddm_theme"
