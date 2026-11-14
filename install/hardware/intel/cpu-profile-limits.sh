# Make power profiles change the CPU on Intel machines without hardware P-states.
#
# power-profiles-daemon drives the CPU through energy_performance_preference,
# which only exists with HWP (Skylake and newer). On older Intel laptops the
# file is absent, so every profile leaves the CPU in an identical state and
# turbo stays unrestricted on battery. Map the profiles onto no_turbo and
# scaling_max_freq instead.

if omarchy-hw-intel-no-hwp && omarchy-battery-present; then
  echo "Detected Intel CPU without HWP, enabling CPU frequency limits for power profiles"

  sudo tee /etc/systemd/system/omarchy-powerprofiles-intel-no-hwp-watch.service >/dev/null <<'EOF'
[Unit]
Description=Omarchy CPU Frequency Limits for Power Profiles (Intel, no HWP)
# power-profiles-daemon is D-Bus activated (Type=dbus, BusName=...), so
# querying or watching its ActiveProfile starts it on demand -- this only
# needs D-Bus itself to be up. Do not add After=/Wants=power-profiles-daemon
# here: the packaged unit is itself After=multi-user.target, while this unit
# is (implicitly, via WantedBy=multi-user.target) Before=multi-user.target,
# so ordering directly after it creates a cycle that systemd breaks by
# dropping this unit's start job.
After=dbus.service

[Service]
Type=simple
ExecStart=/usr/bin/omarchy-powerprofiles-intel-no-hwp-watch
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl enable omarchy-powerprofiles-intel-no-hwp-watch.service

  # Resuming re-registers cpufreq and drops the limits, and the watcher only
  # fires on an actual profile change, not on resume. A service ordered
  # After=/WantedBy= the sleep targets is not a post-resume hook (that
  # ordering fires around entering sleep, not waking from it, and can itself
  # cycle against those targets) -- system-sleep is the real, kernel-driven
  # pre/post hook mechanism, and this repo already uses it elsewhere.
  sudo install -m 0755 -o root -g root \
    "$OMARCHY_PATH/default/systemd/system-sleep/powerprofiles-intel-no-hwp" \
    /usr/lib/systemd/system-sleep/powerprofiles-intel-no-hwp
fi
