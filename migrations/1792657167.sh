echo "Install omarchy-mac on Apple Silicon Macs set up before it became a default"

# Updates add no new defaults, so a Mac installed before omarchy-mac joined the
# Apple Silicon list misses its greeter display wait, audio watchdog and Wi-Fi
# resume fix. Both setups are idempotent, so each user gets the user setup.
if omarchy-hw-aarch64-apple; then
  omarchy-pkg-add omarchy-mac
  system_marker=/var/lib/omarchy/migrations/1792657167
  if [[ ! -f $system_marker ]]; then
    sudo omarchy-lifecycle-dispatch setup-system
    sudo install -Dm644 /dev/null "$system_marker"
  fi
  omarchy-lifecycle-dispatch setup-user
fi
