echo "Repair legacy user-owned Plymouth and SDDM theme directories"

repair_legacy_theme_dir() {
  local dir=$1

  # Missing is fine: a later package install or plymouth-set creates it.
  # Symlinks are hostile; leave them for the publisher's validation to refuse.
  if [[ -L $dir || ! -d $dir ]]; then
    return 0
  fi

  local uid
  uid=$(stat -c %u -- "$dir")
  if (( uid == 0 )); then
    return 0
  fi

  sudo chown -R root:root -- "$dir"
  sudo find "$dir" -xdev -type d -exec chmod 0755 -- {} +
  sudo find "$dir" -xdev -type f -exec chmod 0644 -- {} +
}

repair_legacy_theme_dir /usr/share/plymouth/themes/omarchy
repair_legacy_theme_dir /usr/share/sddm/themes/omarchy
