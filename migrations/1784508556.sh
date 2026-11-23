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
# The backup logic lives in omarchy-browser-password-backup, which defers while the browser
# runs or while a --user-data-dir override cannot be resolved, and prints each backup path.

for conf in ~/.config/{chromium,brave,chrome,microsoft-edge-stable}-flags.conf; do
  if [[ -f $conf ]] && ! grep -q -- '--password-store=' "$conf"; then
    browser=${conf##*/}
    browser=${browser%.conf}
    browser=${browser%-flags}
    if ! omarchy-browser-password-backup "$browser" "$conf"; then
      echo "Could not back up $browser's logins and cookies; leaving $conf unpinned so this migration retries on the next update" >&2
      exit 75
    fi
    [[ -n $(tail -c1 "$conf") ]] && echo >>"$conf"
    echo '--password-store=gnome-libsecret' >>"$conf"
  fi
done
