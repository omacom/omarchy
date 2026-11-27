# Make power-saver lower the CPU package power limits on AMD Raven, Picasso and
# Dali laptops, where power-profiles-daemon has no CPU control of its own.
# See omarchy-powerprofiles-cpu-limits.

if omarchy-hw-amd-raven && omarchy-battery-present; then
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-cpu-limits.service" /etc/systemd/system/omarchy-cpu-limits.service
  sudo systemctl enable omarchy-cpu-limits.service
fi
