echo "Install the Vivaldi theme hook for existing installs"

# Vivaldi installed before this feature has no post-update hook, so its live
# theme loader is never re-injected after a Vivaldi package upgrade. Repair it
# the same way the installer does: install the hook, then run it once to
# inject the loader and recreate the theme channel.
omarchy-pkg-present vivaldi || exit 0

omarchy-hook-install post-update "$OMARCHY_PATH/default/vivaldi/vivaldi-post-update"
"$OMARCHY_PATH/default/vivaldi/vivaldi-post-update"
