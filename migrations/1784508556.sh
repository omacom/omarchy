echo "Pin browser password store to gnome-libsecret (prevents cookie/login loss on Hyprland)"

# Chromium-based browsers auto-detect their os_crypt backend; on Hyprland the xdg-desktop-portal
# Secret backend has no provider and fails, so they can fall back to the 'basic' (v10) store.
# A swap from the gnome-libsecret (v11) key to the basic key makes existing cookies and saved
# passwords undecryptable, so the browser silently drops them and the user is logged out of
# everything. Pin gnome-libsecret so the backend is deterministic across reboots and updates.
#
# The pin cuts the other way for a browser that had already fallen back to the basic store:
# moving it back to gnome-libsecret leaves the passwords it encrypted with the v10 basic key
# undecryptable under the v11 key, and the browser then silently bulk-deletes what it cannot
# read - Brave Sync propagates the deletion to every synced device. Back up each browser's
# logins and cookies right before appending its pin; if the backup cannot be made, defer the
# whole migration (exit 75) so it retries on the next update instead of pinning unprotected.

# Copies the password and cookie databases the coming password-store swap would destroy out of
# every profile of $1 (chromium, brave, chrome or microsoft-edge-stable) that holds any:
# 'Default', 'Profile N', or any directory with a 'Login Data' or 'Cookies' database, plus the
# -wal/-journal sidecars. Prints the backup path when it backed anything up; returns non-zero
# without touching the browser data when the backup cannot be completed.
backup_browser_passwords() {
  local browser="$1" data_dir backup_dir profile_dir profile_name file backed_up=0
  local -a profile_files=()

  case $browser in
    chromium) data_dir="$HOME/.config/chromium" ;;
    brave) data_dir="$HOME/.config/BraveSoftware/Brave-Browser" ;;
    chrome) data_dir="$HOME/.config/google-chrome" ;;
    microsoft-edge-stable) data_dir="$HOME/.config/microsoft-edge" ;;
    *) return 0 ;;
  esac

  backup_dir="$HOME/.local/state/omarchy/migration-backups/1784508556-$browser-$(date +%Y%m%d%H%M%S)"

  for profile_dir in "$data_dir"/*/; do
    [[ -f "$profile_dir/Login Data" || -f "$profile_dir/Cookies" ]] || continue
    profile_files=()
    for file in "$profile_dir/Login Data" "$profile_dir/Login Data"-* "$profile_dir/Cookies" "$profile_dir/Cookies"-*; do
      [[ -f $file ]] || continue
      profile_files+=("$file")
    done
    (( ${#profile_files[@]} > 0 )) || continue

    profile_name=$(basename "$profile_dir")
    mkdir -p "$backup_dir/$profile_name" || return 1
    for file in "${profile_files[@]}"; do
      cp -a "$file" "$backup_dir/$profile_name/" || return 1
    done
    backed_up=1
  done

  if (( backed_up )); then
    echo "Backed up $browser's saved logins and cookies to $backup_dir before pinning its password store:"
    echo "the pin can leave those databases undecryptable, and the browser then deletes the logins it"
    echo "cannot read (Brave Sync propagates the deletions to every synced device). If logins vanish,"
    echo "quit the browser and restore the databases from that backup."
  fi
}

for conf in ~/.config/{chromium,brave,chrome,microsoft-edge-stable}-flags.conf; do
  if [[ -f $conf ]] && ! grep -q -- '--password-store=' "$conf"; then
    browser=${conf##*/}
    browser=${browser%.conf}
    browser=${browser%-flags}
    if ! backup_browser_passwords "$browser"; then
      echo "Could not back up $browser's logins and cookies; leaving $conf unpinned so this migration retries on the next update" >&2
      exit 75
    fi
    [[ -n $(tail -c1 "$conf") ]] && echo >>"$conf"
    echo '--password-store=gnome-libsecret' >>"$conf"
  fi
done
