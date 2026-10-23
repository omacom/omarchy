echo "Restore app-menu icons the Quattro upgrade moved out from under surviving launchers"

# The upgrade used to park every stock PNG under
# ~/.local/share/applications/icons.omarchy-upgrade-to-quattro.*.bak before
# leftover custom .desktop files were rewritten. Those launchers still name
# the old absolute Icon= path, so the Apps menu shows a generic icon and the
# shell logs QQuickImage "Cannot open" on every open. The same pass also
# installed Alacritty.desktop even when alacritty was not on PATH.

# Shared with omarchy-refresh-applications. Refresh is the command the upgrade
# tells a user to rerun, and it has to put the same PNGs back without replaying
# every other migration.
source "$OMARCHY_PATH/install/helpers/quattro-app-icons.sh"
restore_quattro_app_menu_icons

apps_dir="$HOME/.local/share/applications"

removed_alacritty=0
# The upgrade-installed ghost is byte-identical to the shipped launcher. A
# stock copy with only Exec= rewritten (Flatpak, wrapper, SSH) is kept, even
# when it still carries TryExec=alacritty.
shipped_alacritty="$OMARCHY_PATH/default/alacritty/Alacritty.desktop"
if [[ -f $apps_dir/Alacritty.desktop ]] && omarchy-cmd-missing alacritty &&
  cmp -s "$apps_dir/Alacritty.desktop" "$shipped_alacritty"; then
  rm -f "$apps_dir/Alacritty.desktop"
  removed_alacritty=1
fi

if (( quattro_icons_restored || removed_alacritty )) && omarchy-cmd-present update-desktop-database; then
  update-desktop-database "$apps_dir" >/dev/null 2>&1 || true
fi
