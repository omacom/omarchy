echo "Fix display brightness on the Google Pixelbook (Eve)"

# The backlight leaf only runs at install, so an existing Eve needs the drop-in
# and a boot image rebuilt with it. The running kernel keeps its old command
# line until reboot, so a marker records the machine-wide rebuild: another
# user's migration must not repeat it before then, while a missing marker
# still retries an interrupted rebuild.

running_cmdline="${OMARCHY_RUNNING_CMDLINE:-/proc/cmdline}"
rebuild_marker="${OMARCHY_PIXELBOOK_EVE_BACKLIGHT_MARKER:-/var/lib/omarchy/migrations/1791573437}"

omarchy-hw-google-pixelbook-eve || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0
[[ ! -e $rebuild_marker ]] || exit 0

# Already booted with the parameter, from this migration or the user's own
# drop-in, whatever value they chose.
[[ " $(<"$running_cmdline") " != *" i915.enable_dpcd_backlight="* ]] || exit 0

source "$OMARCHY_PATH/install/hardware/google/fix-pixelbook-eve-backlight.sh"
sudo limine-mkinitcpio
# Ask for the reboot before marking the rebuild done, so a failure in between
# leaves the migration pending instead of silently finished.
omarchy-state set reboot-required
sudo install -Dm644 /dev/null "$rebuild_marker"
