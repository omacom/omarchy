echo "Fix display brightness controls on the ASUS ROG Zephyrus G16 GU605MY"

backlight_conf="${OMARCHY_GU605MY_BACKLIGHT_CONF:-/etc/limine-entry-tool.d/asus-gu605my-display-backlight.conf}"
running_cmdline="${OMARCHY_GU605MY_RUNNING_CMDLINE:-/proc/cmdline}"
rebuild_marker="${OMARCHY_GU605MY_REBUILD_MARKER:-/var/lib/omarchy/migrations/1791499643}"

# The marker, written only after the rebuild succeeds, retries an interrupted rebuild and stops another user's run repeating it.
# A machine already booted with the option (a fresh install, which only marks the first user's migrations) needs nothing.
if omarchy-hw-match "GU605MY" && omarchy-cmd-present limine-mkinitcpio && [[ ! -e $rebuild_marker ]] &&
  ! { [[ -f $backlight_conf ]] && grep -Eqs '(^| )i915\.enable_dpcd_backlight=3( |$)' "$running_cmdline"; }; then
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-gu605my-display-backlight.sh"
  sudo limine-mkinitcpio
  omarchy-state set reboot-required
  sudo install -Dm644 /dev/null "$rebuild_marker"
fi
