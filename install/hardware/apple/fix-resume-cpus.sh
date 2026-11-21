# The MacBook Pro (Mid 2015) takes seconds per CPU to bring its non-boot CPUs
# back when resuming from deep sleep, so the screen stays black long after the
# lid opens. A sleep hook takes those CPUs offline before sleep and brings them
# back once the system is running again.
if omarchy-hw-match "MacBookPro11,4"; then
  sleep_hook_dir="${OMARCHY_SYSTEM_SLEEP_DIR:-/usr/lib/systemd/system-sleep}"

  sudo mkdir -p "$sleep_hook_dir"
  sudo install -m 0755 "$OMARCHY_PATH/default/systemd/system-sleep/apple-fast-resume" "$sleep_hook_dir/apple-fast-resume"
fi
