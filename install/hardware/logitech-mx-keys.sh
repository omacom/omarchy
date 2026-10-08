# Logitech MX Keys / MX Keys S / MX Keys Mini: the S and Mini action keys
# (emoji, screenshot, dictation, mic mute, lock) send fixed chords meant for
# Logi Options+, which does not exist on Linux; on the MX Keys only the lock
# key's Super+L is remapped. When one of these keyboards is present -- over
# Bluetooth, a Unifying receiver or the Bolt receiver -- remap it with keyd so
# the keys reach their Omarchy equivalents. See default/keyd/logitech-mx-keys.conf
# (including which shortcuts this costs on that keyboard) and
# default/hypr/bindings/logitech-mx-keys.lua.
#
# Also invoked by migrations/1787838885.sh for existing installs. Re-run by hand
# with `bash "$OMARCHY_PATH/install/hardware/logitech-mx-keys.sh"` if the
# keyboard was asleep the first time.

# The Bolt probe opens /dev/hidraw* read/write and needs root (the sysfs scan
# for Bluetooth / Unifying does not). During install this script already runs as
# root; from the migration it runs as the user, so elevate the probe there.
mx_keys_hw() {
  if [[ $EUID -eq 0 ]]; then
    omarchy-hw-logitech-mx-keys "$@"
  else
    sudo "$OMARCHY_PATH/bin/omarchy-hw-logitech-mx-keys" "$@"
  fi
}

if mx_keys_ids=$(mx_keys_hw --keyd-ids) && [[ -n $mx_keys_ids ]]; then
  omarchy-pkg-add keyd

  # Build [ids] from what the detector actually found -- never ship the Bolt
  # receiver id on a machine where the MX Keys S is only on Bluetooth, or a
  # Unifying keyboard's own id on a machine that has no such keyboard.
  {
    printf '[ids]\n%s\n\n' "$mx_keys_ids"
    cat "$OMARCHY_PATH/default/keyd/logitech-mx-keys.conf"
  } | sudo tee /etc/keyd/logitech-mx-keys.conf >/dev/null
  sudo chmod 644 /etc/keyd/logitech-mx-keys.conf

  # restart, not just enable --now: keyd may already be running for another
  # keyboard, in which case only a restart picks up this new config file.
  # Enable last, so a failed restart leaves the migration's completion check
  # unsatisfied and the next update retries.
  sudo systemctl restart keyd.service
  sudo systemctl enable keyd.service
fi
