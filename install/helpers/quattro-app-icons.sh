# Restore PNGs the Quattro upgrade parked under
# ~/.local/share/applications/icons.omarchy-upgrade-to-quattro.*.bak when a
# surviving launcher still names that exact path. Sets quattro_icons_restored=1
# when a file was copied. Safe to re-run: an icon already in place is left
# alone, including a dangling symlink GNU cp would refuse to write through.

restore_quattro_app_menu_icons() {
  local apps_dir="$HOME/.local/share/applications"
  local icons_dir="$apps_dir/icons"
  local desktop icon icon_name backup candidate

  quattro_icons_restored=0

  for desktop in "$apps_dir"/*.desktop; do
    # An unreadable launcher makes sed exit non-zero, and a repair that dies on
    # one stray file aborts the whole Quattro upgrade under bash -euo pipefail.
    [[ -f $desktop && -r $desktop ]] || continue
    icon=$(sed -n '/^Icon=/ { s/^Icon=//; p; q; }' "$desktop")
    icon_name="${icon##*/}"
    [[ $icon == "$icons_dir/$icon_name" ]] || continue
    # A dangling symlink is not -e, and GNU cp then refuses to write through it
    # and exits 1. Under bash -euo pipefail that aborts the rest of the loop.
    [[ -e $icon || -L $icon ]] && continue
    # Last match wins: a home that survived two upgrades has one backup per run,
    # and the newest holds the icon the launcher was last drawn with.
    backup=""
    for candidate in "$apps_dir"/icons.omarchy-upgrade-to-quattro.*.bak/"$icon_name"; do
      [[ -f $candidate ]] || continue
      backup="$candidate"
    done
    [[ -n $backup ]] || continue
    # icons/ is itself a dangling symlink on some homes, and mkdir -p exits 1 on
    # one rather than following it.
    mkdir -p "$icons_dir" 2>/dev/null || continue
    cp -f "$backup" "$icon"
    quattro_icons_restored=1
  done

  return 0
}
