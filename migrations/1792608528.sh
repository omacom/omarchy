echo "Reclaim pre-4.0 user-owned Plymouth and SDDM theme directories"

# Omarchy 3.7 and 3.8 published unlock themes with `sudo cp -a "$staging_dir/." "$theme_dir/"`, stamping the user's 0700 mktemp directory and files onto /usr/share/plymouth/themes/omarchy.
# Pacman never re-chowns an existing directory, so 4.0+ omarchy-plymouth-set refuses to publish into it, and the user can rewrite what the boot splash loads. The SDDM theme directory is checked the same way.

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
  local uid mode file replacement
  local -a files

  if [[ -L $path ]]; then
    echo "  Leaving $path alone (symlink)."
    return 0
  fi

  if [[ ! -d $path ]]; then
    return 0
  fi

  uid=$(stat -c %u -- "$path") || return 1
  mode=$(stat -c %a -- "$path") || return 1

  # Checked apart from the files, so a run interrupted after the chown still finishes on the next one.
  if (( uid != 0 )) || [[ $mode != "755" ]]; then
    echo "  Repairing $path (was uid=$uid mode=$mode)"
    as_root chown root:root -- "$path"
    as_root chmod 755 -- "$path"
  fi

  mapfile -d '' -t files < <(find "$path" -mindepth 1 -maxdepth 1 -type f \( ! -uid 0 -o -perm /022 \) -print0)
  wait $! || return 1

  # The files cp -a copied in are still the user's. Replace rather than chown them, so a descriptor the user holds open for writing reaches nothing.
  for file in "${files[@]}"; do
    echo "  Replacing $file with a root-owned copy"
    replacement=$(as_root mktemp -- "$path/.${file##*/}.omarchy-new.XXXXXX")
    as_root install -o root -g root -m 0644 -T -- "$file" "$replacement"
    as_root mv -fT -- "$replacement" "$file"
  done
}

reclaim_theme_directory "$plymouth_theme"
reclaim_theme_directory "$sddm_theme"
