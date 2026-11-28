echo "Fix display brightness controls on the Razer Blade 16 RZ09-0581"

backlight_conf=/etc/limine-entry-tool.d/razer-blade16-ptl-display-backlight.conf
rebuild_marker=/var/lib/omarchy/migrations/1795484795

# The marker, written only after the rebuild succeeds, retries an interrupted rebuild and stops another user's run repeating it.
# A machine already booted with the option (a fresh install, which only marks the first user's migrations) needs nothing.
if omarchy-hw-match "RZ09-0581" && omarchy-hw-intel-ptl && omarchy-cmd-present limine-mkinitcpio && [[ ! -e $rebuild_marker ]] &&
  ! { [[ -f $backlight_conf ]] && grep -Eqs '(^| )xe\.enable_dpcd_backlight=1( |$)' /proc/cmdline; }; then
  source "$OMARCHY_PATH/install/hardware/razer/fix-razer-blade16-ptl-display-backlight.sh"

  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  omarchy-state set reboot-required
  sudo install -Dm644 /dev/null "$rebuild_marker"
fi
